import { ethers } from "hardhat";
import { FlowERC721ConfigStruct, FlowInitializedEvent, ProgrammableFlowERC721, ProgrammableFlowERC721ConfigStruct } from "../typechain/contracts/ProgrammableFlowERC721";
import { rainterpreterDeploy } from "../utils/deploy/interpreter/shared/rainterpreter/deploy";
import { rainterpreterExpressionDeployerDeploy } from "../utils/deploy/interpreter/shared/rainterpreterExpressionDeployer/deploy";
import { Parser, rainterpreterOpMeta, State, StateConfig } from '@rainprotocol/rainlang';
import { getEvents } from "../utils/events";
import { keccak256 } from "ethers/lib/utils";

console.log('test')
export const SENTINEL_HIGH_BITS =
  "0xF000000000000000000000000000000000000000000000000000000000000000";

export const RAIN_FLOW_SENTINEL = ethers.BigNumber.from(
  keccak256([...Buffer.from("RAIN_FLOW_SENTINEL")])
).or(SENTINEL_HIGH_BITS);


export const RAIN_FLOW_ERC721_SENTINEL = ethers.BigNumber.from(
  keccak256([...Buffer.from("RAIN_FLOW_ERC721_SENTINEL")])
).or(SENTINEL_HIGH_BITS);

describe("ProgrammableERC721", async function () {
  // Contracts are deployed using the first signer/account by default
  const [you, otherAccount] = await ethers.getSigners();

  const programmableFlowERC721Factory = await ethers.getContractFactory("ProgrammableFlowERC721");
  console.log(programmableFlowERC721Factory)
  const erc721 = (await programmableFlowERC721Factory.deploy()) as ProgrammableFlowERC721;

  const interpreter = await rainterpreterDeploy();
  const expressionDeployer = await rainterpreterExpressionDeployerDeploy(
    interpreter
  );

  console.log(interpreter.address, expressionDeployer.address)

  it("Initialize", async () => {
    console.log('test3')
    const canTransferExp = `_: 1`
    const flowExp = `
    _: ${RAIN_FLOW_SENTINEL},
    _: ${RAIN_FLOW_SENTINEL},
    _: ${RAIN_FLOW_SENTINEL},
    _: ${RAIN_FLOW_SENTINEL},
    _: ${RAIN_FLOW_ERC721_SENTINEL},
    _: ${RAIN_FLOW_ERC721_SENTINEL},
    _: 1,
    _: context<0 0>()
    `
    const tokenUriExp = `_: 1`

    const stateConfig = Parser.getStateConfig(canTransferExp, rainterpreterOpMeta) as StateConfig;
    const flowStateConfig = Parser.getStateConfig(flowExp, rainterpreterOpMeta) as StateConfig;
    const tokenUriStateConfig = Parser.getStateConfig(tokenUriExp, rainterpreterOpMeta) as StateConfig;

    const configStruct: FlowERC721ConfigStruct = {
      name: "FlowERC721",
      symbol: "F721",
      stateConfig,
      flowConfig: {
        expressionDeployer: expressionDeployer.address,
        interpreter: interpreter.address,
        flows: [
          flowStateConfig,
        ],
      },
    };

    const programmableConfig: ProgrammableFlowERC721ConfigStruct = {
      tokenURIModule: "",
      stateConfig: tokenUriStateConfig
    }

    const deployTransaction = await erc721["initialize((string,string,(bytes[],uint256[]),(address,address,(bytes[],uint256[])[])),(address,(bytes[],uint256[])))"](configStruct, programmableConfig)

    const flowExpressions = (await getEvents(
      deployTransaction,
      "FlowInitialized",
      erc721
    )) as FlowInitializedEvent["args"][];

    const _txFlowCanTransfer = await erc721
      .connect(you)
      .flow(flowExpressions[0].dispatch, [1], []);

    console.log(erc721.ownerOf(1))
  });
});
