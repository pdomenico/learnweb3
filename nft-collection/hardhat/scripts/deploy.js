const {ethers} = require("hardhat")
require("dotenv").config()
const {WHITELIST_CONTRACT_ADDRESS, METADATA_URL} = require("../constants")

async function main() {
    const CryptoDevs = await ethers.getContractFactory("CryptoDevs")
    const cryptodevs = await CryptoDevs.deploy(METADATA_URL, WHITELIST_CONTRACT_ADDRESS)
    await cryptodevs.deployed()

    console.log("Deployed CryptoDevs contract at: ", cryptodevs.address)
    
}

main()
    .then(() => process.exit(0))
    .catch(e => {
        console.log(e)
        process.exit(1)
    })