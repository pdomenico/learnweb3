
const { ethers } = require("hardhat");
require("dotenv").config()
require("@nomiclabs/hardhat-etherscan");

async function main() {
    const Verify = await ethers.getContractFactory("Verify")
    console.log("got the contract")
    const verify = await Verify.deploy()
    console.log("sent the deploy tx")
    await verify.deployed()
    console.log("Contract deployed at ", verify.address)
    console.log("waiting...")
    await new Promise(r => setTimeout(r, 20000));
    console.log("done waiting")

    await hre.run("verify:verify", {
        address: verify.address,
        constructorArguments: []
    })
}

main()
    .then(() => {
        process.exit(0)
    })
    .catch(e => {
        console.log(e)
        process.exit(1)
    })