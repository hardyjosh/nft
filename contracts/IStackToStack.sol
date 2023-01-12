// SPDX-License-Identifier: CAL
pragma solidity ^0.8.0;

interface IStackToStack {
    function uint256ToUint256(
        uint256[] calldata inputStack
    ) external view returns (uint256[] memory outputStack);
}
