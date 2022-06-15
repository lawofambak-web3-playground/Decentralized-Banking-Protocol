//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./AaveInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // Need this???
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AaveUserDeposit {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public admin;

    address public constant AAVEV2_LPADDRESSPROVIDER_ADDRESS =
        0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;

    address public constant AAVEV2_WETHGATEWAY_ADDRESS =
        0xcc9a0B7c43DC2a5F023Bb9b738E45B0Ef6B06E04;

    address public constant AAVEV2_WETH_ADDRESS =
        0x030bA81f1c18d280636F32af80b9AAd02Cf0854e;

    address public constant AAVEV2_DATA_PROVIDER =
        0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d;

    AAVEV2WETH internal aaveWethGateway =
        AAVEV2WETH(AAVEV2_WETHGATEWAY_ADDRESS);

    LPADDRESSPROVIDER internal lpAddressProvider =
        LPADDRESSPROVIDER(AAVEV2_LPADDRESSPROVIDER_ADDRESS);

    IERC20 internal aWeth = IERC20(AAVEV2_WETH_ADDRESS);

    constructor() {
        // Sets admin of contract to deployer
        admin = msg.sender;
    }

    function depositIntoAaveInternal() external payable {
        // Only admin can call this function
        require(msg.sender == admin, "Not admin");

        console.log(
            "Aave User Deposit contract AWETH balance before deposit: ",
            aWeth.balanceOf(address(this))
        );

        // Retrieve current address of Aave V2 lending pool
        address lendingPoolAddress = lpAddressProvider.getLendingPool();

        // Send ETH to Aave from contract for AWETH and transfers to this contract
        aaveWethGateway.depositETH{value: msg.value}(
            lendingPoolAddress,
            address(this),
            0
        );

        console.log(
            "Aave User Deposit contract AWETH balance after deposit: ",
            aWeth.balanceOf(address(this))
        );
    }

    function withdrawFromAaveInternal(address _withdrawTo, uint256 _ethAmount)
        external
    {
        // Only admin can call this function
        require(msg.sender == admin, "Not admin");

        console.log(
            "Aave User Deposit contract AWETH balance before withdrawal: ",
            aWeth.balanceOf(address(this))
        );

        // Require user contract's AWETH balance to be greater than or equal to withdraw amount
        // Note: AWETH is pegged 1:1 with ETH
        require(
            aWeth.balanceOf(address(this)) >= _ethAmount,
            "Withdraw amount too large"
        );

        // Retrieve current address of Aave V2 lending pool
        address lendingPoolAddress = lpAddressProvider.getLendingPool();

        // Allow AWETH Gateway contract to burn associated AWETH
        aWeth.safeIncreaseAllowance(AAVEV2_WETHGATEWAY_ADDRESS, _ethAmount);

        // Withdraw ETH from Aave and send to user address accordingly
        aaveWethGateway.withdrawETH(
            lendingPoolAddress,
            _ethAmount,
            _withdrawTo
        );

        console.log(
            "Aave User Deposit contract AWETH balance after withdrawal: ",
            aWeth.balanceOf(address(this))
        );
    }
}
