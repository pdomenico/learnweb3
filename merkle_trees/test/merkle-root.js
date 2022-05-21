const { expect } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require("keccak256");
const { MerkleTree } = require("merkletreejs");

function encodeLeaf(address, spots) {
    return ethers.utils.defaultAbiCoder.encode(
        ["address", "uint64"],
        [address, spots]
    )
}

describe("Check if merkle root is working", () => {
    it("Should be able to verify if a given address is in whitelist or not", async () => {
        
        // Get test addresses
        const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners()

        const list = [
            encodeLeaf(owner.address, 2),
            encodeLeaf(addr1.address, 2),
            encodeLeaf(addr2.address, 2),
            encodeLeaf(addr3.address, 2),
            encodeLeaf(addr4.address, 2),
            encodeLeaf(addr5.address, 2),
        ]

        const merkleTree = new MerkleTree(list, keccak256, {
            hashLeaves: true,
            sortPairs: true
        })
        const root = merkleTree.getHexRoot();

        // Deploy the whitelist contract
        const Whitelist = await ethers.getContractFactory("Whitelist")
        const whitelist = await Whitelist.deploy(root)
        await whitelist.deployed()
        console.log("Deployed whitelist at ", whitelist.address)

        const leaf = keccak256(list[0])
        const proof = merkleTree.getHexProof(leaf)

        let verified = await whitelist.checkInWhitelist(proof, 2)
        expect(verified).to.equal(true)

        verified = await whitelist.checkInWhitelist(proof, 3)
        expect(verified).to.equal(false)
    })
})