//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFakeNFTMarketplace {
    function getPrice() external pure returns (uint);

    function available(uint _tokenId) external view returns (bool);

    function purchase(uint _tokenId) external payable;
}

interface ICryptoDevsNFT {
    function balanceOf(address _owner) external view returns (uint);

    function tokenOfOwnerByIndex(address owner, uint index)
        external
        view
        returns (uint);
}

contract CryptoDevsDAO is Ownable {
    struct Proposal {
        uint nftTokenId;
        uint deadline;
        uint yayVotes;
        uint nayVotes;
        bool executed;
        mapping(uint => bool) voters;
    }
    mapping(uint => Proposal) public proposals;
    uint public numProposals;

    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevsNFT cryptoDevsNFT;
    enum Vote {
        YAY,
        NAY
    }

    constructor(address _marketplace, address _nft) payable {
        cryptoDevsNFT = ICryptoDevsNFT(_nft);
        nftMarketplace = IFakeNFTMarketplace(_marketplace);
    }

    modifier nftHolderOnly() {
        require(
            cryptoDevsNFT.balanceOf(msg.sender) > 0,
            "You're not an nft owner!"
        );
        _;
    }

    modifier activeProposalOnly(uint _proposalIndex) {
        require(
            proposals[_proposalIndex].deadline > block.timestamp,
            "Deadline exceeded!"
        );
        _;
    }

    modifier inactiveProposalOnly(uint _proposalId) {
        require(
            proposals[_proposalId].deadline <= block.timestamp,
            "The deadline hasn't passed yet!"
        );
        require(!proposals[_proposalId].executed, "Proposal already executed!");
        _;
    }

    function createProposal(uint _tokenId)
        external
        nftHolderOnly
        returns (uint)
    {
        require(nftMarketplace.available(_tokenId), "NFT not for sale!");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _tokenId;
        proposal.deadline = block.timestamp + 5 minutes;
        ++numProposals;
        return numProposals - 1;
    }

    function voteOnProposal(uint _proposalIndex, Vote vote)
        external
        nftHolderOnly
        activeProposalOnly(_proposalIndex)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        uint voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint numVotes = 0;

        for (uint i = 0; i < voterNFTBalance; i++) {
            uint tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (!proposal.voters[tokenId]) {
                ++numVotes;
                proposal.voters[tokenId] = true;
            }
        }
        require(numVotes > 0, "You already voted!");
        if (vote == Vote.YAY) {
            proposal.yayVotes += numVotes;
        } else {
            proposal.nayVotes += numVotes;
        }
    }

    function executeProposal(uint _proposalId)
        external
        nftHolderOnly
        inactiveProposalOnly(_proposalId)
    {
        Proposal storage proposal = proposals[_proposalId];
        if (proposal.yayVotes > proposal.nayVotes) {
            uint price = nftMarketplace.getPrice();
            require(address(this).balance >= price);
            nftMarketplace.purchase{value: price}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    function withdraw() external onlyOwner {
        msg.sender.call{value: address(this).balance}("");
    }

    receive() external payable {}

    fallback() external payable {}
}
