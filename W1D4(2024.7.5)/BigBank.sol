// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public admin;
    mapping(address => uint256) public deposits;
    address[] public topDepositors;

    constructor() {
        admin = msg.sender;
    }
    
    function deposit() public payable virtual {
        require(msg.value > 0.01 ether, "Deposit amount must be greater than 0.01 ether");
        deposits[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
    }


    receive() external payable virtual{
        deposits[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
    }

    function withdraw(uint256 amount) external virtual{
        require(msg.sender == admin, "Only admin can withdraw");
        require(address(this).balance >= amount, "Insufficient balance");
        payable(admin).transfer(amount);
    }

    function updateTopDepositors(address depositor) internal {
        if (topDepositors.length < 3) {
            topDepositors.push(depositor);
        } else {
            for (uint i = 0; i < topDepositors.length; i++) {
                if (deposits[depositor] > deposits[topDepositors[i]]) {
                    topDepositors[i] = depositor;
                    break;
                }
            }
        }
    }
}



contract BigBank is Bank {
    address public BankOwner;

    constructor()
    {
        BankOwner = msg.sender;
    }

    modifier minDeposit() {
        require(msg.value >= 0.001 ether, "Minimum deposit is 0.001 ether");
        _;
    }

    function transferAdmin(address _newAdmin) external {
        require(msg.sender == admin, "Only admin can transfer admin rights");
        BankOwner = _newAdmin;
    }

    function withdraw(uint256 amount) external override {
        require(msg.sender == BankOwner, "Only owner can withdraw");
        require(address(this).balance >= amount, "Insufficient balance");
        payable(BankOwner).transfer(amount);
    }

    receive() external payable minDeposit override{
        deposits[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
    }
}




contract Ownable {
    address public owner;
    BigBank public bigBank;

    constructor(address payable _bigBank) {
        owner = msg.sender;
        bigBank = BigBank(_bigBank);
    }

    function withdrawFromBigBank(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw from BigBank");
        bigBank.withdraw(amount);
    }
}
