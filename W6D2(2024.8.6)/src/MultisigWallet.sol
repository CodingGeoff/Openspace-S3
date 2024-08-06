// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

contract MultiSigWallet {
    address[] public owners;
    uint public required;
    mapping(address => bool) public isOwner;
    mapping(uint => mapping(address => bool)) public confirmations;
    struct Transaction {
        address destination;
        uint value;
        bool executed;
    }
    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!confirmations[_txIndex][msg.sender], "Transaction already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required number of owners");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    function submitTransaction(address _destination, uint _value) public onlyOwner {
        uint txIndex = transactions.length;
        transactions.push(Transaction({
            destination: _destination,
            value: _value,
            executed: false
        }));
        emit SubmitTransaction(msg.sender, txIndex, _destination, _value);
    }

    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        confirmations[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) public txExists(_txIndex) notExecuted(_txIndex) {
        require(_getConfirmationCount(_txIndex) >= required, "Cannot execute transaction");

        Transaction storage transaction = transactions[_txIndex];
        transaction.executed = true;

        (bool success, ) = transaction.destination.call{value: transaction.value}("");
        require(success, "Transaction failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function _getConfirmationCount(uint _txIndex) private view returns (uint count) {
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[_txIndex][owners[i]]) {
                count += 1;
            }
        }
    }

    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed destination, uint value);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
}
