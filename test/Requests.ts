import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
// import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

import {impersonatedProfileIds, impersonatedProfileIds2} from "../helpers/constants.ts"

describe.only("Requests", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {

    // Contracts are deployed using the first signer/account by default
    const [owner] = await ethers.getSigners();

    const AddressesProvider = await ethers.getContractFactory("AddressesProvider");
    const addressesProvider = await AddressesProvider.deploy();
    console.log("addressesProvider deployed")

    const LensProvider = await ethers.getContractFactory("LensProvider");
    const lensProvider = await LensProvider.deploy();
    await lensProvider.setLensHub("0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d") // mainnet polygon
    console.log("lensProvider deployed")

    await addressesProvider.setLensProvider(lensProvider.address)

    const Hub = await ethers.getContractFactory("Hub");
    const hub = await Hub.deploy(addressesProvider.address);
    console.log("hub deployed")

    await addressesProvider.setHub(hub.address)

    const ModulesHub = await ethers.getContractFactory("ModulesHub");
    const modulesHub = await ModulesHub.deploy();
    console.log("modulesHub deployed")

    await addressesProvider.setModulesHub(modulesHub.address)

    const RoutersHub = await ethers.getContractFactory("RoutersHub");
    const routersHub = await RoutersHub.deploy();
    console.log("routersHub deployed")

    await addressesProvider.setRoutersHub(routersHub.address)

    const SettingsHub = await ethers.getContractFactory("SettingsHub");
    const settingsHub = await SettingsHub.deploy();
    console.log("settingsHub deployed")

    // await addressesProvider.setSettingsHub(settingsHub.address)

    const RequestsModule = await ethers.getContractFactory("RequestsModule");
    const requestsModule = await RequestsModule.deploy(addressesProvider.address);
    console.log("RequestsModule deployed")

    const ERC20Requests = await ethers.getContractFactory("ERC20Requests");
    const erc20Requests = await ERC20Requests.deploy(addressesProvider.address);
    console.log("erc20Requests deployed")

    await routersHub.initializeRouter(erc20Requests.address)

    const ERC721Payments = await ethers.getContractFactory("ERC721Payments");
    const erc721Payments = await ERC721Payments.deploy();
    console.log("erc721Payments deployed")

    await routersHub.initializeRouter(erc721Payments.address)

    const MintableERC20 = await ethers.getContractFactory("MintableERC20");
    const gho = await MintableERC20.deploy("GHO", "GHO", 18);

    const MockPaymentsSettingsModule = await ethers.getContractFactory("MockPaymentsSettingsModule");
    const mockPaymentsSettingsModule = await MockPaymentsSettingsModule.deploy(modulesHub.address);

    console.log("routersHub", routersHub.address)

    // set up protocol module
    await modulesHub.initializeModule(requestsModule.address, "payment", []);
    await requestsModule.setEncoder(erc20Requests.address)
    console.log("requestsModule.setEncoder")

    // https://polygonscan.com/token/0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d?a=0x74945418ad2f477bf32231ddb0620024a08659ee
    const impersonatedSignerAddress = "0x74945418ad2f477bf32231ddb0620024a08659ee"
    const impersonatedSigner = await ethers.getImpersonatedSigner(impersonatedSignerAddress);

    // https://polygonscan.com/token/0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d?a=0x2f2a6f077d8edd63c6d7d1b7145c64450f5b76b7
    const impersonatedSignerAddress2 = "0x2f2a6f077d8edd63c6d7d1b7145c64450f5b76b7"
    const impersonatedSigner2 = await ethers.getImpersonatedSigner(impersonatedSignerAddress2);


    // await modulesHub.initializeSettings(mockPaymentsSettingsModule.address, "payment", []);

    return { 
      addressesProvider, 
      hub, 
      modulesHub, 
      requestsModule, 
      erc20Requests, 
      erc721Payments, 
      gho, 
      impersonatedSigner, 
      impersonatedSigner2 
    };
  }

  async function decodeProposalEvent(iface, data, topics) {
    const log = iface.parseLog({ data, topics });
    return log
  }

  describe("Initialize Requests Module", async function () {
    it("Should create wallets", async function () {
      const [owner, user2, user3] = await ethers.getSigners();
      const { 
        addressesProvider, 
        hub, 
        modulesHub, 
        requestsModule, 
        erc20Requests, 
        erc721Payments, 
        gho, 
        impersonatedSigner, 
        impersonatedSigner2 
      } = await loadFixture(deploy);
      await hub.connect(impersonatedSigner).create(impersonatedProfileIds[0]);
      const walletAddress = await hub.getWallet(impersonatedProfileIds[0])
      const Wallet = await ethers.getContractFactory("Wallet");
      const wallet = await Wallet.attach(walletAddress)
      expect(await wallet.owner()).to.equal(impersonatedSigner.address);
    });

    it("Test Requests Module", async function () {
      const [owner, user2, user3] = await ethers.getSigners();
      const { 
        addressesProvider, 
        hub, 
        modulesHub, 
        requestsModule, 
        erc20Requests, 
        erc721Payments, 
        gho, 
        impersonatedSigner, 
        impersonatedSigner2 
      } = await loadFixture(deploy);
      // owner wallet
      await hub.connect(impersonatedSigner).create(impersonatedProfileIds[0]);
      const impWalletAddress = await hub.getWallet(impersonatedProfileIds[0])
      const Wallet = await ethers.getContractFactory("Wallet");
      const impWallet = await Wallet.attach(impWalletAddress)
      expect(await impWallet.owner()).to.equal(impersonatedSigner.address);
      // user2 wallet
      await hub.connect(impersonatedSigner2).create(impersonatedProfileIds2[0]);
      const imp2WalletAddress = await hub.getWallet(impersonatedProfileIds2[0])
      const imp2Wallet = await Wallet.attach(imp2WalletAddress)
      expect(await imp2Wallet.owner()).to.equal(impersonatedSigner2.address);

      // request GHO from imp2 through imp
      const amount = ethers.utils.parseUnits("1000", 18);

      const descriptionString = "Potatoes and corn"
      // set up calldata
      const calldata1 = erc20Requests.interface.encodeFunctionData('transferFrom', [
        impersonatedProfileIds[0], // onBehalfOfProfileId
        requestsModule.address,  // module
        gho.address, // token
        impersonatedProfileIds[0], // toProfileId
        imp2WalletAddress, // to
        amount, // amount
        descriptionString // description
      ]);

      // make requests
      let tx = await impWallet.connect(impersonatedSigner).execute(
        [erc20Requests.address],
        [0],
        [calldata1],
        descriptionString,
      );
      const receipt = await tx.wait();
      const log = await decodeProposalEvent(requestsModule.interface, receipt.logs[0].data, receipt.logs[0].topics)
      const functionId = log.args.functionId.toString()


      // mint imp2 GHO so he can send it over
      await gho.mintTo(imp2WalletAddress, amount);

      expect(await gho.balanceOf(imp2WalletAddress)).to.equal(amount);
      expect(await gho.balanceOf(impWalletAddress)).to.equal('0');

      const calldata1_1 = gho.interface.encodeFunctionData('approve', [
        requestsModule.address,  // module
        amount, // token
      ]);

      const calldata2_1 = requestsModule.interface.encodeFunctionData('execute', [
        functionId
      ]);

      tx = await imp2Wallet.connect(impersonatedSigner2).execute(
        [gho.address, requestsModule.address],
        [0,0],
        [calldata1_1, calldata2_1],
        descriptionString,
      );

      expect(await gho.balanceOf(imp2WalletAddress)).to.equal('0');
      expect(await gho.balanceOf(impWalletAddress)).to.equal(amount);
    });
  })
});
