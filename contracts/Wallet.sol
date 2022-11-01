// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Core is Owner {
    address payable public owner;

    /**
    * @dev If to send any payments to aave directly.  For example, if someone pays someone $10 for lunch, it goes into Aave automatically
    **/
    uint256 public autoEarn;

    /**
    * @dev The default place to send to earn, such as Aave
    **/
    address public defaultEarner;

    /**
    * @dev List of earning protocols like Yearn and Aave
    **/
    struct RouterData {
        uint8 id;
        address router; // router contract address
        bool hasBalance;
        bool exists; // if initiated
        bool active; // can be used
    }

    uint256 internal routersCount;
    mapping(uint256 => address) internal routersList;
    mapping(address => RouterData) internal routers;


    struct Payments {
        address token;
        uint256 amount;
        string description;
        uint256 when;
        address from;
        bool earned;
        address earner;
    }

    /**
    * @dev List of payments to wallet
    **/
    uint256 internal lensPaysCount;
    // mapping(uint256 => address) internal lensPaysList;
    mapping(uint256 => Payments) internal lensPays;

    /**
    * @dev List of do-not-accept tokens
    **/
    mapping(address => bool) internal blacklistAssets;

    constructor(address[] memory routers, address defaultEarner, bool autoEarn_) payable {
        autoEarn = autoEarn_;
        owner = payable(msg.sender);
    }

    function deposit(address token, uint256 amount, string description) public {
        require(token != address(0), "You aren't the owner");
        require(amount != 0, "You aren't the owner");
        require(!blacklistAssets[token], "I don't want this shitcoin!");

        // _beforeDeposit();
        IERC20(token).safeTransferFrom(msg.sender,  address(this), amount);

        if (autoEarn && defaultEarner != address(0)) {
            _earn(defaultEarner, token, amount);
        } else {
            // something else or nothing else
        }

        // _afterDeposit();


        Payments storage payment = lensPays[lensPaysCount];
        payment.token = token;
        payment.amount = amount;
        payment.description = description;
        payment.when = block.timestamp;
        payment.from = msg.sender;
        payment.earned = autoEarn && defaultEarner != address(0);
        payment.earner = autoEarn && defaultEarner != address(0) ? defaultEarner : address(0);
        lensPaysCount++;

        // emit Deposit();
    }

    function redeem(address token, uint256 amount) public onlyOwner {
        require(token != address(0), "You aren't the owner");
        require(amount != 0, "You aren't the owner");

        // track liquidity to give users better revert messages in production
        // uint256 liquidity = 0;

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (amount > balance) {
            uint256 amount_ = amount;
            for (uint256 i = 0; i < routersCount && amount_ > 0; i++) {
                if (routersList[i] == address(0)) {
                    continue;
                }
                uint256 balance = IRouter(routersList[i]).getBalance(token, address(this));
                if (balance == 0) {
                    continue;
                }
                uint256 liquidity = IRouter(routersList[i]).getLiquidity(token);
                uint256 redeemAmount = amount_ > liquidity ? liquidity : amount_;
                _redeemEarnings(routersList[i], token, amount)
                amount_ = amount_ - redeemAmount;
            }
        }

        // trips revert if not enough was redeemed
        _underlying.safeTransfer(msg.sender, amount);

        // emit Redeem();
    }

    /**
    * @dev Manually add to earnings from assets within this contract
    **/
    function depositEarnings(address router, address token, uint256 amount) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance != 0, "Balance is zero");
        amount = amount > balance ? balance : amount;
        _earn(routersList[i], token, amount);
    }

    /**
    * @dev Manually redeem earnings
    **/
    function redeemEarnings(address router, address token, uint256 amount) public onlyOwner {
        uint256 balance = IRouter(router).getBalance(token, address(this));
        require(balance != 0, "Balance is zero");
        uint256 liquidity = IRouter(router).getLiquidity(token);
        uint256 amount = amount > liquidity ? liquidity : amount;
        _redeemEarnings(routersList[i], token, amount);
    }

    /**
    * @dev Set default earner.  Set to address zero for no earnings
    **/
    function setDefaultEarner(address router) public onlyOwner {
        defaultEarner = router;
    }

    function setAutoEarn(bool value) public onlyOwner {
        require(autoEarn != value, "Auto Earn set!");

        autoEarn = value;
    }

    function _earn(address router, address token, uint256 amount) internal {
        // _beforeEarn();
        // IRouter(router).deposit(token, amount, address(this));
        // _afterEarn();
    }

    function _redeemEarnings(address router, address token, uint256 amount) internal {
        // _beforeRedeem();
        // IRouter(router).redeem(token, amount, address(this));
        // _afterRedeem();
    }

}
