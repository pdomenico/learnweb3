const {ethers} = require("hardhat")
require("dotenv").config()
const {CRYPTO_DEVS_NFT_CONTRACT_ADDRESS} = require("../constants")

async function main() {
  const CryptoDevToken = await ethers.getContractFactory("CryptoDevToken")
  const cryptoDevToken = await CryptoDevToken.deploy(CRYPTO_DEVS_NFT_CONTRACT_ADDRESS)
  await cryptoDevToken.deployed()
  console.log("Token contract deployed at: ", cryptoDevToken.address)
}

main()
  .then(() => {
    process.exit(0)
  })
  .catch(e => {
    console.log(e)
    process.exit(1)
  })
