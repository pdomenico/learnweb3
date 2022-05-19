//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    ERC20 cryptoDevToken;

    constructor(address _cryptoDevToken) ERC20("CryptoDev LP Token", "CDLP") {
        require(_cryptoDevToken != address(0));
        cryptoDevToken = ERC20(_cryptoDevToken);
    }

    function getReserve() public view returns (uint) {
        return cryptoDevToken.balanceOf(address(this));
    }

    function addLiquidity(uint _amount)
        external
        payable
        returns (uint liquidity)
    {
        uint tokenReserve = getReserve();

        if (tokenReserve == 0) {
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = msg.value;
            _mint(msg.sender, liquidity);
            return liquidity;
        }

        uint ethReserve = address(this).balance - msg.value;
        uint tokenAmount = (msg.value * tokenReserve) / ethReserve;
        require(_amount >= tokenAmount, "Not enough tokens!");
        cryptoDevToken.transferFrom(msg.sender, address(this), tokenAmount);
        liquidity = (totalSupply() * msg.value) / ethReserve;
        _mint(msg.sender, liquidity);
    }

    function removeLiquidity(uint _amount)
        external
        returns (uint ethWithdrawn, uint tokensWithdrawn)
    {
        require(_amount > 0, "Can't withdraw 0 liquidity!");

        uint totalSupply = totalSupply();
        ethWithdrawn = (_amount * address(this).balance) / totalSupply;
        tokensWithdrawn = (_amount * getReserve()) / totalSupply;

        _burn(msg.sender, _amount);
        msg.sender.call{value: ethWithdrawn}("");
        cryptoDevToken.transfer(msg.sender, tokensWithdrawn);
    }

    function getAmountOfTokens(
        uint _inputAmount,
        uint _inputReserve,
        uint _outputReserve
    ) public pure returns (uint outputAmount) {
        uint numerator = _inputAmount * _outputReserve;
        uint denominator = _inputReserve + _inputAmount;
        outputAmount = (numerator * 99) / (denominator * 100);
    }

    function ethToCryptoDevToken(uint _minTokens) public payable {
        uint tokenAmount = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            getReserve()
        );

        require(_minTokens <= tokenAmount, "You didn't send enough ether!");
        cryptoDevToken.transfer(msg.sender, tokenAmount);
    }

    function cryptoDevTokenToEth(uint _tokensSold, uint _minEth) public {
        uint ethAmount = getAmountOfTokens(
            _tokensSold,
            getReserve(),
            address(this).balance
        );

        require(_minEth <= ethAmount, "You didn't send enough tokens!");
        cryptoDevToken.transferFrom(msg.sender, address(this), _tokensSold);
        msg.sender.call{value: ethAmount}("");
    }
}
