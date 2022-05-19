const {ethers} = require("hardhat")
require("dotenv").config()
const {CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS} = require("../constants")

async function main() {
    console.log("hey")
    const Exchange = await ethers.getContractFactory("Exchange")
    console.log("got the contract, now deploying it")
    const exchange = await Exchange.deploy(CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS)
    console.log("sent the tx")
    await exchange.deployed()
    console.log("Deployed exchange contract at ", exchange.address)
}

main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e)
        process.exit(1)
    })