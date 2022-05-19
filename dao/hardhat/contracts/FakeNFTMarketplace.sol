//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeNFTMarketplace {
    mapping(uint => address) public tokens;
    uint public immutable price = 0.1 ether;

    function purchase(uint _tokenId) external payable {
        require(msg.value >= price, "The price is 0.1 ether!");
        tokens[_tokenId] = msg.sender;
    }

    function getPrice() external pure returns (uint) {
        return price;
    }

    function available(uint _tokenId) external view returns (bool) {
        return tokens[_tokenId] == address(0);
    }
}
