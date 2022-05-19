const {ethers} = require("hardhat")
const {CRYPTODEVS_NFT_CONTRACT_ADDRESS} = require("../constants")

async function main() {
    const FakeNFTMarketplace = await ethers.getContractFactory("FakeNFTMarketplace")
    const fakeNFTMarketplace = await FakeNFTMarketplace.deploy()
    await fakeNFTMarketplace.deployed()
    console.log("Deployed marketplace contract at ", fakeNFTMarketplace.address)

    const CryptoDevsDAO = await ethers.getContractFactory("CryptoDevsDAO")
    const cryptoDevsDAO = await CryptoDevsDAO.deploy(
        fakeNFTMarketplace.address,
        CRYPTODEVS_NFT_CONTRACT_ADDRESS
    )
    await cryptoDevsDAO.deployed()
    console.log("Deployed DAO contract at ", cryptoDevsDAO.address)
    

}

main()
    .then(() => {
        process.exit(0)
    })
    .catch(e => {
        console.log(e)
        process.exit(1)
    })