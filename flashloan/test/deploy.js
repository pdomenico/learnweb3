const { expect, assert } = require("chai");
const { BigNumber } = require("ethers");
const { ethers, waffle, artifacts } = require("hardhat");
const hre = require("hardhat");

const { DAI, DAI_WHALE, POOL_ADDRESS_PROVIDER } = require("../config");

describe("Take and repay a flash loan", () => {
    let flashLoanExample
    let token
    const BALANCE_AMOUNT_DAI = ethers.utils.parseEther("2000")
    it("Should deploy the contract", async () => {
        const FlashLoanExample = await ethers.getContractFactory("FlashLoanExample")
        flashLoanExample = await FlashLoanExample.deploy(POOL_ADDRESS_PROVIDER)
        await flashLoanExample.deployed()
        console.log("Contract deployed at ", flashLoanExample.address)
    })

    it("Should transfer DAI from the whale to the contract address", async () => {
    
        token = await ethers.getContractAt("IERC20", DAI);

        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [DAI_WHALE]
        })
        const signer = await ethers.getSigner(DAI_WHALE)
        await token
            .connect(signer)
            .transfer(flashLoanExample.address, BALANCE_AMOUNT_DAI)
        
        const contractBalance = await token.balanceOf(flashLoanExample.address)
        expect(contractBalance).to.equal(BALANCE_AMOUNT_DAI)
    })

    it("Should execute the flashloan transaction", async () => {
        const tx = await flashLoanExample.createFlashLoan(DAI, 1000)
        await tx.wait()
        const remainingBalance = await token.balanceOf(flashLoanExample.address)
        expect(remainingBalance).to.be.lt(BALANCE_AMOUNT_DAI)
    })
})