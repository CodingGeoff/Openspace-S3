// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {

    mapping(address => uint) public userBalances; 
    address[3] public topUsers; 

    // 获取用户余额
    function getUserBalance() public view returns (uint) {
        return userBalances[msg.sender];
    }

    // 取款/提现
    function withdrawAmount(uint amount) public payable {
        require(amount <= userBalances[msg.sender], "Insufficient balance");
        userBalances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // 存款
    function depositAmount() public payable {
        userBalances[msg.sender] += msg.value;
        updateTopUsers();
    }

    // 接收Ether
    receive() external payable {
        depositAmount();
    }

    // 更新存款金额前三用户
    function updateTopUsers() internal {
        int index = -1;
        for (int i = 2; i >= 0; i--) {
            if (userBalances[msg.sender] > userBalances[topUsers[uint(i)]]) {
                index = i;  
            } else {
                break;
            }
        }
        if (index != -1) {
            // 右移数组元素，为新元素腾出空间
            for (int j = 2; j > index; j--) {
                topUsers[uint(j)] = topUsers[uint(j - 1)];
            }
            topUsers[uint(index)] = msg.sender;
        }
    }
}
