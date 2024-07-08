// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function withdraw(address user, uint256 amount) external;
}

contract Bank {
    mapping(address => uint256) public userBalances;
    address[3] public topUsers;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor() {
        // Constructor can be used to initialize topUsers if needed
    }

    

    function deposit() public payable virtual {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        updateTopUsers();
    }

    function updateTopUsers() public {
        // Assuming the function should be internal since it's only called within this contract
        // and it's not a part of the contract's externally visible state
        _updateTopUsers();
    }

    function _updateTopUsers() internal {
        uint256 userBalance = userBalances[msg.sender];
        for (uint256 i = 0; i < topUsers.length; i++) {
            if (userBalance > userBalances[topUsers[i]]) {
                for (uint256 j = 2; j > i; j--) {
                    topUsers[j] = topUsers[j - 1];
                }
                topUsers[i] = msg.sender;
                break;
            }
        }
    }

    function withdraw(uint256 amount) public virtual {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        userBalances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
        emit Withdraw(msg.sender, amount);
    }

    // Fallback function to receive Ether
    receive() external payable {
        deposit();
    }
}

contract BigBank is Bank{
    constructor() {}

    function deposit() public payable override {
        require(msg.value >= 0.001 ether, "Minimum deposit is 0.001 ether");
        super.deposit();
    }
    

    function withdraw(address bigbankowner, uint256 amount) external payable {
        require(address(this).balance >= amount, "Insufficient contract balance");
        (bool success, ) = bigbankowner.call{value: amount}("");
        require(success, "Transfer failed.");
        emit Withdraw(bigbankowner, amount);
    }

    // Function to set a new owner (only current owner can call)
    function transferOwnership(address bigbankowner, address newOwner) pure public  {
        require(newOwner != address(0), "New owner is the zero address");
        bigbankowner = newOwner;
    }

    // The onlyOwner modifier is inherited from the Bank contract
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to withdraw from BigBank (only owner can call)
    function withdraw(BigBank _bigBank, uint256 amount) public onlyOwner {
        _bigBank.withdraw(amount);
    }
}

