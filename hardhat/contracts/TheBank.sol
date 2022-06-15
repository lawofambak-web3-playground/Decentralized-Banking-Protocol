//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "./CompoundInterface.sol";
import "./AaveUserDeposit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TheBank is ReentrancyGuard {
    using SafeMath for uint256;

    address public constant COMPOUND_CETH_ADDRESS =
        0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    address public constant AAVEV2_WETH_ADDRESS =
        0x030bA81f1c18d280636F32af80b9AAd02Cf0854e;

    CETH internal ceth = CETH(COMPOUND_CETH_ADDRESS);

    IERC20 internal aWeth = IERC20(AAVEV2_WETH_ADDRESS);

    /*
    Mapping of user's CETH balance
    (NOTE: value does not change as interest is 
    accrued through increasing exchange rate so this
    value represents the amount minted from deposit)
    */
    mapping(address => uint256) private userCethBalance;

    /*
    Mapping of user's AWETH balance contract address
    (NOTE: since interest in Aave is accrued through
    increasing AWETH balance of user, a separate contract
    represents a user's AWETH balance instead of this
    contract)
    */
    mapping(address => address) private aaveUserContract;

    // Allows contract to receive ETH
    receive() external payable {}

    // Returns AWETH balance of given address
    function getAaveBalance(address _user) public view returns (uint256) {
        return aWeth.balanceOf(_user);
    }

    // Deposit ETH into Compound (Bank contract holds cTokens for users)
    function depositIntoCompound() external payable nonReentrant {
        // CETH contract balance before depositing into Compound
        uint256 beforeDepositBalance = ceth.balanceOf(address(this));
        console.log(
            "CETH contract balance before deposit: ",
            beforeDepositBalance
        );
        console.log(
            "User's CETH balance before deposit: ",
            userCethBalance[msg.sender]
        );

        // Send ETH to Compound from contract for CETH
        console.log("Supplying ETH to Compound...");
        ceth.mint{value: msg.value}();

        // Calculate user's CETH balance by calculating the difference
        // of CETH contract balance before and after ceth.mint() and
        // then update user's CETH balance
        userCethBalance[msg.sender] += (ceth.balanceOf(address(this)) -
            beforeDepositBalance);

        console.log(
            "CETH contract balance after deposit: ",
            ceth.balanceOf(address(this))
        );
        console.log(
            "User's CETH balance after deposit: ",
            userCethBalance[msg.sender]
        );
    }

    // Withdraw ETH from Compound
    function withdrawFromCompound(uint256 ethAmount) external nonReentrant {
        // Require user's CETH balance to be greater 0 (need to deposit first)
        require(userCethBalance[msg.sender] > 0, "User has no deposit");

        // Check if user's max CETH balance in terms of ETH is greater than or equal to withdrawal amount
        uint256 userEthBalance = (userCethBalance[msg.sender] *
            ceth.exchangeRateCurrent()) / 1e18;
        console.log("User's CETH balance in terms of ETH: ", userEthBalance);

        require(userEthBalance >= ethAmount, "Withdrawal Amount Too Large");

        // CETH contract balance before withdrawing from Compound
        uint256 beforeWithdrawBalance = ceth.balanceOf(address(this));
        console.log(
            "CETH contract balance before withdrawal: ",
            beforeWithdrawBalance
        );
        console.log(
            "User's CETH balance before withdrawal: ",
            userCethBalance[msg.sender]
        );

        console.log("Withdrawing ETH from Compound...");
        // Require withdrawal to be successful (Compound's redeemUnderlying() function)
        require(ceth.redeemUnderlying(ethAmount) == 0, "Withdraw Failed");

        // Calculate user's CETH balance by calculating the difference
        // of CETH contract balance before and after ceth.redeemUnderlying()
        // and then update user's CETH balance
        userCethBalance[msg.sender] -= (beforeWithdrawBalance -
            ceth.balanceOf(address(this)));

        console.log(
            "CETH contract balance after withdrawal: ",
            ceth.balanceOf(address(this))
        );
        console.log(
            "User's CETH balance after withdrawal: ",
            userCethBalance[msg.sender]
        );

        // Make user address payable to send ETH to
        address payable withdrawTo = payable(msg.sender);

        // Sending ETH withdraw amount to user
        (bool sent, ) = withdrawTo.call{value: ethAmount}("");
        require(sent, "Failed to send ETH");
    }

    // Withdraw Max ETH from Compound
    function withdrawMaxFromCompound() external nonReentrant {
        // Require user's CETH balance to be greater 0 (need to deposit first)
        require(userCethBalance[msg.sender] > 0, "User has no deposit");

        // Calculates user's max ETH amount to send to user
        uint256 maxEthAmount = (userCethBalance[msg.sender] *
            ceth.exchangeRateCurrent()) / 1e18;
        console.log("User's CETH balance in terms of ETH: ", maxEthAmount);

        // CETH contract balance before withdrawing from Compound
        uint256 beforeWithdrawBalance = ceth.balanceOf(address(this));

        console.log(
            "CETH contract balance before withdrawal: ",
            beforeWithdrawBalance
        );
        console.log(
            "User's CETH balance before withdrawal: ",
            userCethBalance[msg.sender]
        );

        console.log("Withdrawing Max ETH from Compound...");
        // Require withdrawal to be successful (Compound's redeem() function)
        require(
            ceth.redeem(userCethBalance[msg.sender]) == 0,
            "Withdraw Failed"
        );

        // Calculate user's CETH balance by calculating the difference
        // of CETH contract balance before and after ceth.redeem()
        // and then update user's CETH balance
        userCethBalance[msg.sender] -= (beforeWithdrawBalance -
            ceth.balanceOf(address(this)));

        // Require user's CETH balance to be 0 since they withdrew max amount
        require(userCethBalance[msg.sender] == 0, "Withdraw Max Failed");

        console.log(
            "CETH contract balance after withdrawal: ",
            ceth.balanceOf(address(this))
        );
        console.log(
            "User's CETH balance after withdrawal: ",
            userCethBalance[msg.sender]
        );

        // Make user address payable to send ETH to
        address payable withdrawTo = payable(msg.sender);

        // Sending ETH withdraw amount to user
        (bool sent, ) = withdrawTo.call{value: maxEthAmount}("");
        require(sent, "Failed to send ETH");
    }

    // Deposit ETH into Aave (User Deposit Contract holds aTokens)
    function depositIntoAave() external payable nonReentrant {
        // Checks if user has already deposited
        if (aaveUserContract[msg.sender] == address(0)) {
            // Creates a new user deposit contract
            AaveUserDeposit depositContract = new AaveUserDeposit();
            // Stores user deposit contract address
            aaveUserContract[msg.sender] = address(depositContract);
            console.log(
                "New user deposit contract address: ",
                aaveUserContract[msg.sender]
            );
            // Deposit ETH into Aave for user
            depositContract.depositIntoAaveInternal{value: msg.value}();
        } else {
            // Loads returning user deposit contract associated with user
            AaveUserDeposit depositContract = AaveUserDeposit(
                aaveUserContract[msg.sender]
            );
            console.log(
                "Returning user deposit contract address: ",
                aaveUserContract[msg.sender]
            );
            // Deposit ETH into Aave for returning user
            depositContract.depositIntoAaveInternal{value: msg.value}();
        }
    }

    // Withdraw ETH from Aave
    function withdrawFromAave(uint256 ethAmount) external nonReentrant {
        // Assigns msg.sender the address to withdraw to
        address payable withdrawTo = payable(msg.sender);

        // Require user to have deposited already
        require(
            aaveUserContract[msg.sender] != address(0),
            "Need to deposit first"
        );

        // Loads returning user deposit contract associated with user
        AaveUserDeposit depositContract = AaveUserDeposit(
            aaveUserContract[msg.sender]
        );
        console.log(
            "Returning user deposit contract address: ",
            aaveUserContract[msg.sender]
        );
        // Withdraw ETH from Aave for returning user
        depositContract.withdrawFromAaveInternal(withdrawTo, ethAmount);
    }

    // Withdraw Max ETH from Aave
    function withdrawMaxFromAave() external nonReentrant {
        // Assigns msg.sender the address to withdraw to
        address payable withdrawTo = payable(msg.sender);

        // Require user to have deposited already
        require(
            aaveUserContract[msg.sender] != address(0),
            "Need to deposit first"
        );

        // Loads returning user deposit contract associated with user
        AaveUserDeposit depositContract = AaveUserDeposit(
            aaveUserContract[msg.sender]
        );
        console.log(
            "Returning user deposit contract address: ",
            aaveUserContract[msg.sender]
        );

        // Calculates max AWETH balance of user
        uint256 userAwethBalance = aWeth.balanceOf(
            aaveUserContract[msg.sender]
        );
        // Withdraw ETH from Aave for returning user
        depositContract.withdrawFromAaveInternal(withdrawTo, userAwethBalance);
    }
}
