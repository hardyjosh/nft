// SPDX-License-Identifier: CAL
pragma solidity =0.8.17;

import "@beehiveinnovation/rain-protocol/contracts/flow/erc721/FlowERC721.sol";

struct ProgrammableFlowERC721Config {
    address tokenURIModule;
    StateConfig stateConfig;
}

SourceIndex constant TOKENURI_ENTRYPOINT = SourceIndex.wrap(0);
uint256 constant TOKENURI_MIN_OUTPUTS = 1;
uint256 constant TOKENURI_MAX_OUTPUTS = 1;

/// @title ProgrammableFlowERC721
contract ProgrammableFlowERC721 is FlowERC721 {
    using LibStackPointer for uint256[];
    using LibStackPointer for StackPointer;
    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];
    using LibInterpreterState for InterpreterState;
    using FixedPointMath for uint256;

    EncodedDispatch internal _tokenURIdispatch;

    /// @param config_ source and token config. Also controls delegated claims.
    function initialize(
        FlowERC721Config calldata config_,
        ProgrammableFlowERC721Config calldata programmableConfig
    ) external initializer {
        FlowERC721 flowERC721 = new FlowERC721();
        flowERC721.initialize(config_);
        address expression_ = IExpressionDeployerV1(
            config_.flowConfig.expressionDeployer
        ).deployExpression(
                programmableConfig.stateConfig,
                LibUint256Array.arrayFrom(TOKENURI_MIN_OUTPUTS)
            );
        _tokenURIdispatch = LibEncodedDispatch.encode(
            expression_,
            TOKENURI_ENTRYPOINT,
            TOKENURI_MAX_OUTPUTS
        );
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        uint256[] memory callerContext_ = LibUint256Array.arrayFrom(
            uint256(uint160(ownerOf(tokenId))),
            tokenId
        );
        EncodedDispatch dispatch_ = _dispatch;
        (uint256[] memory stack_, uint256[] memory stateChanges_) = _interpreter
            .eval(
                dispatch_,
                LibContext.build(
                    new uint256[][](0),
                    callerContext_,
                    new SignedContext[](0)
                )
            );
        // require(stack_.asStackPointerAfter().peek() > 0, "INVALID_TRANSFER");
        // if (stateChanges_.length > 0) {
        //     _interpreter.stateChanges(stateChanges_);
        // }

        uint256 stackTop = stack_.asStackPointerAfter().peek();

        return string(abi.encodePacked(stackTop));
    }
}
