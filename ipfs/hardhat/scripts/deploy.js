const { hexZeroPad } = require("ethers/lib/utils");
require("@nomiclabs/hardhat-etherscan")
const {ethers} = require("hardhat")
require("dotenv").config()

async function main() {
    const metadataURL = "ipfs://Qmbygo38DWF1V8GttM1zy89KzyZTPU2FLUzQtiDvB7q6i5"
    const Contract = await ethers.getContractFactory("LW3Punks");
    const contract = await Contract.deploy(metadataURL)
    await contract.deployed()

    console.log("Deployed contract at ", contract.address);
    await new Promise(r => setTimeout(r, 20000));
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [metadataURL]
    })

}

main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e)
        process.exit(1)
    })