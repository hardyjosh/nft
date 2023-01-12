import { ethers } from "hardhat";
import { keccak256 } from "ethers/lib/utils";
import { PathGenerator } from "../typechain";

const RAIN_FLOW_SENTINEL = ethers.BigNumber.from(
    keccak256([...Buffer.from("RAIN_FLOW_SENTINEL")])
);

describe.only("PathGenerator", async function () {
    it("Generates a path from a stack", async () => {
        const pathGeneratorFactory = await ethers.getContractFactory("PathGenerator");
        const pathGenerator = (await pathGeneratorFactory.deploy()) as PathGenerator;
        const stack = [
            10,
            50,
            RAIN_FLOW_SENTINEL,
            35,
            64
        ]
        console.log(await pathGenerator.uint256ToUint256(stack))
    })
});