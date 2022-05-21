//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoanExample is FlashLoanSimpleReceiverBase {
    using SafeMath for uint;

    event Log(address asset, uint val);

    constructor(IPoolAddressesProvider provider)
        FlashLoanSimpleReceiverBase(provider)
    {}

    function createFlashLoan(address asset, uint amount) external {
        address receiver = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(receiver, asset, amount, params, referralCode);
    }

    function executeOperation(
        address asset,
        uint amount,
        uint premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        uint amountOwed = amount.add(premium);
        IERC20(asset).approve(address(POOL), amountOwed);
        emit Log(asset, amountOwed);
        return true;
    }
}
