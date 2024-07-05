// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function deposit() external payable;
    function withdraw(uint amount) external;
    function userBalances(address user) external view returns (uint);
    function topUsers(uint index) external view returns (address);
}

contract Bank is IBank {
    mapping(address => uint) public override userBalances;
    address[3] public override topUsers;

    function deposit() public payable virtual override {
        userBalances[msg.sender] += msg.value;
        updateTopUsers();
    }

    // 接收以太币
    receive() external payable {
        deposit();
    }

    // 更新存款金额前三用户
    function updateTopUsers() internal {
        address[3] memory tempTopUsers = topUsers;
        for (uint i = 0; i < 3; i++) {
            if (userBalances[msg.sender] > userBalances[tempTopUsers[i]]) {
                for (uint j = 2; j > i; j--) {
                    tempTopUsers[j] = tempTopUsers[j - 1];
                }
                tempTopUsers[i] = msg.sender;
                break;
            }
        }
        topUsers = tempTopUsers;
    }

    function withdraw(uint amount) public virtual override {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        userBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}

// Ownable 合约用于管理所有权
contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}

// BigBank 合约
contract BigBank is Bank, Ownable {
    address private BigBankAdmin;
    uint public balance;

    constructor() {
        BigBankAdmin = msg.sender;
    }

    // 要求最小存款金额为 0.001 ether
    modifier minDeposit() {
        require(msg.value >= 0.001 ether, "Minimum deposit is 0.001 ether");
        _;
    }

    // 重写存款函数，包含最低存款金额
    function deposit() public payable override minDeposit {
        super.deposit();
        balance += msg.value; // 将存款金额加入大银行的资金池
    }

    modifier onlyAdmin() {
        require(msg.sender == BigBankAdmin, "Only the admin can call this function");
        _;
    }

    function withdraw(uint amount) public override onlyOwner {
        require(amount <= balance, "Insufficient contract balance");
        payable(owner).transfer(amount);
        balance -= amount;
        userBalances[msg.sender] -= amount;
    }

    function transferOwnership(address newOwner) public payable onlyAdmin {
        owner = newOwner;
    }
}
