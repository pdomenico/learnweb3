// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LW3Punks is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string _baseTokenURI;
    uint public _price = 0.01 ether;
    bool public _paused;
    uint8 public maxTokenIds = 10;
    uint8 public tokenIds;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused!");
        _;
    }

    constructor(string memory baseURI) ERC721("LW3Punks", "LW3P") {
        _baseTokenURI = baseURI;
    }

    function mint() external payable onlyWhenNotPaused {
        require(tokenIds < maxTokenIds, "Exceeded maximum supply!");
        require(msg.value >= _price, "Need to send more eth!");
        ++tokenIds;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, _tokenId.toString(), ".json")
                )
                : "";
    }

    function setPaused(bool _val) public onlyOwner {
        _paused = _val;
    }

    function withdraw() public onlyOwner {
        msg.sender.call{value: address(this).balance}("");
    }

    receive() external payable {}

    fallback() external payable {}
}
