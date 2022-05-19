const {ethers} = require("hardhat")

async function main() {
    const Whitelist = await ethers.getContractFactory("Whitelist");
    const whitelist = await Whitelist.deploy(10) 
    await whitelist.deployed()

    console.log("Whitelist contract deployed at ", whitelist.address)

}

main()
    .then(() => process.exit())
    .catch(e => {
        console.log(e)
        process.exit()
    })