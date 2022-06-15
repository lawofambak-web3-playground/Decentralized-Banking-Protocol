//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

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

    function getWETHAddress() external view returns (address);
}

// interface AAVEV2DATA {
//     function getReserveData(address asset)
//         external
//         view
//         returns (
//             uint256 availableLiquidity,
//             uint256 totalStableDebt,
//             uint256 totalVariableDebt,
//             uint256 liquidityRate,
//             uint256 variableBorrowRate,
//             uint256 stableBorrowRate,
//             uint256 averageStableBorrowRate,
//             uint256 liquidityIndex,
//             uint256 variableBorrowIndex,
//             uint40 lastUpdateTimestamp
//         );
// }
