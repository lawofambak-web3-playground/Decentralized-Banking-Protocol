//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LPADDRESSPROVIDER {
    function getLendingPool() external view returns (address);
}

interface AAVEV2WETH {
    function depositETH(
        address lendingPool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    function withdrawETH(
        address lendingPool,
        uint256 amount,
        address onBehalfOf
    ) external;
}
