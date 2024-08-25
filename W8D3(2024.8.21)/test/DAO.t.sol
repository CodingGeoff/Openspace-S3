// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/ERC20_DAO.sol";
import "../src/Governance.sol";
import "../src/Bank.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract GovernanceTest is Test {
    Token public token;
    Governance public governance;
    Bank public bank;
    TimelockController public timelock;
    address public owner;
    address public proposer;
    address public voter;

    function setUp() public {
        owner = address(this);
        proposer = address(0x1);
        voter = address(0x2);

        token = new Token("Governance Token", "GT", 1000 * 10**18);
        token.transfer(proposer, 100 * 10**18);
        token.transfer(voter, 100 * 10**18);

        address[] memory proposers = new address;
        proposers[0] = proposer;
        address[] memory executors = new address;
        executors[0] = address(0);

        timelock = new TimelockController(1 days, proposers, executors);
        governance = new Governance(token, timelock, 4, 1, 1);
        bank = new Bank{value: 100 ether}(address(timelock));

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governance));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governance));
        timelock.grantRole(timelock.TIMELOCK_ADMIN_ROLE(), owner);
    }

    function testProposeAndExecute() public {
        // Propose to withdraw funds from the Bank contract
        address[] memory targets = new address;
        targets[0] = address(bank);
        uint256[] memory values = new uint256;
        values[0] = 0;
        bytes[] memory calldatas = new bytes;
        calldatas[0] = abi.encodeWithSignature("withdraw()");

        vm.prank(proposer);
        uint256 proposalId = governance.propose(targets, values, calldatas, "Withdraw funds from Bank");

        // Vote on the proposal
        vm.warp(block.timestamp + 1); // Move forward in time to start voting
        vm.prank(voter);
        governance.castVote(proposalId, 1); // Vote in favor

        // Move forward in time to end voting and queue the proposal
        vm.warp(block.timestamp + 2);
        governance.queue(targets, values, calldatas, keccak256(bytes("Withdraw funds from Bank")));

        // Execute the proposal
        vm.warp(block.timestamp + 1 days + 1);
        governance.execute(targets, values, calldatas, keccak256(bytes("Withdraw funds from Bank")));

        // Check if the funds were withdrawn
        assertTrue(bank.isReleased());
    }
}
