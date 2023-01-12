// SPDX-License-Identifier: CAL
pragma solidity =0.8.17;

import "@beehiveinnovation/rain-protocol/contracts/bytes/LibBytes.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

library LibStringChunker {
    using Math for uint256;

    function stringToUint256(
        string memory stringToChunk
    ) internal pure returns (uint256[] memory) {
        uint256[] memory stack_ = new uint256[](
            bytes(stringToChunk).length.ceilDiv(0x20)
        );

        uint256 pointerToStringFirstByte_;
        uint256 pointerToStack_;
        assembly ("memory-safe") {
            pointerToStringFirstByte_ := add(stringToChunk, 0x20)
            pointerToStack_ := stack_
        }

        LibBytes.unsafeCopyBytesTo(
            pointerToStringFirstByte_,
            pointerToStack_,
            bytes(stringToChunk).length
        );

        return stack_;
    }
}
