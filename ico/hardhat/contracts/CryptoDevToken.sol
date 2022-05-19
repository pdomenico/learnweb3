// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    uint public constant tokenPrice = 0.001 ether;
    uint public constant tokensPerNFT = 10e18;
    uint public constant maxTotalSupply = 10000e18;
    ICryptoDevs CryptoDevsNFT;
    mapping(uint => bool) tokenIdsClaimed;

    constructor(address _cryptoDevsNFT) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsNFT);
    }

    function mint(uint _amount) public payable {
        require(
            msg.value >= (_amount * tokenPrice),
            "mint: you didn't send enough ether!"
        );
        uint amount = _amount * 1e18;
        require(
            (totalSupply() + amount) <= maxTotalSupply,
            "mint: exceeds max supply!"
        );
        _mint(msg.sender, amount);
    }

    function claim() public {
        uint senderBalance = CryptoDevsNFT.balanceOf(msg.sender);
        require(senderBalance > 0, "You don't have any NFTs!");
        uint unclaimedNFTs = 0;
        for (uint i = 0; i < senderBalance; i++) {
            uint tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                ++unclaimedNFTs;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(unclaimedNFTs > 0, "You already claimed all the tokens!");
        _mint(msg.sender, unclaimedNFTs * tokensPerNFT);
    }

    receive() external payable {}

    fallback() external payable {}
}
