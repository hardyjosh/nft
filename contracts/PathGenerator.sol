// SPDX-License-Identifier: CAL
pragma solidity =0.8.17;
import "./IStackToStack.sol";
import "./LibStringChunker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

uint256 constant PARAM_SENTINEL = uint256(keccak256(bytes("PARAM_SENTINEL")));

contract PathGenerator is IStackToStack {
    using LibStringChunker for string;
    using Strings for uint256;

    function uint256ToUint256(
        uint256[] memory inputStack
    ) external pure returns (uint256[] memory outputStack) {
        string memory finalString;
        uint256 param = 0;
        bool writeParams = false;
        string memory separator = "?";

        for (uint i = 0; i < outputStack.length; i++) {
            if (inputStack[i] == PARAM_SENTINEL) {
                writeParams = true;
            } else {
                if (writeParams) {
                    if (param == 1) {
                        separator = "&";
                    }
                    finalString = string.concat(
                        finalString,
                        separator,
                        param.toString(),
                        "=",
                        inputStack[i].toString()
                    );
                    param++;
                } else {
                    finalString = string.concat(
                        finalString,
                        "/",
                        inputStack[i].toString()
                    );
                }
            }
        }

        outputStack = finalString.stringToUint256();
        return outputStack;
    }
}
