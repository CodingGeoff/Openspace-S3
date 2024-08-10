// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// /*
//     编写一个 Bank 合约，实现功能：

//     可以通过 Metamask 等钱包直接给 Bank 合约地址存款
//     在 Bank 合约记录每个地址的存款金额
//     编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
//     用数组记录存款金额的前 3 名用户
// */

// contract Bank {
//     // owner：合约部署者即为合约的所有者，拥有撤回资金的权限。
//     address public owner;
//     // balances：mapping 类型，用于存储每个地址的存款金额。
//     mapping(address => uint256) public balances;
//     address[3] public topDepositUsers;

//     // Deposit 事件，用于记录存款操作
//     event Deposit(address indexed user, uint256 amount);
//     // Withdraw 事件，用于记录提款操作
//     event Withdraw(address indexed user, uint256 amount);

//     // 构造函数，设置合约所有者为部署者
//     constructor(address _owner) {
//         owner = _owner;
//     }

//     // Modifier: Only owner
//     modifier onlyOwner() {
//         require(msg.sender == owner, "Only owner can call this function");
//         _;
//     }

//     // Deposit function
//     // deposit()：存款函数，任何人可以调用，将发送的以太币存入合约，并更新用户的存款记录和前三名用户列表。
//     function deposit() public payable {
//         require(msg.value > 0, "Deposit amount must be greater than 0");
//         balances[msg.sender] += msg.value;
//         emit Deposit(msg.sender, msg.value);

//         // 更新前三名存款用户
//         updateTopUsers(msg.sender);
//     }

//     // Withdraw function (only owner can call)
//     // withdraw()：提款函数，只有合约所有者（管理员）可以调用，用于从合约中提取资金。
//     function withdraw(address user, uint256 amount) external onlyOwner {
//         require(amount > 0, "Withdraw amount must be greater than 0");
//         require(
//             amount <= address(this).balance,
//             "Insufficient contract balance"
//         );

//         payable(user).transfer(amount);
//         emit Withdraw(user, amount);
//     }

//     // Internal function to update top deposit users
//     // updateTopUsers()：内部函数，用于更新前三名存款用户的列表。
//     function updateTopUsers(address user) internal {
//         uint256 userBalance = balances[user];

//         // 检查用户是否已经在前三名中
//         for (uint256 i = 0; i < topDepositUsers.length; i++) {
//             if (user == topDepositUsers[i]) {
//                 sortTopUsers();
//                 return;
//             }
//         }

//         // 如果用户不在前三名且当前存款大于第三名
//         if (userBalance > balances[topDepositUsers[2]]) {
//             topDepositUsers[2] = user;
//             sortTopUsers();
//         }
//     }

//     // Sort the top deposit users
//     function sortTopUsers() internal {
//         for (uint256 i = 0; i < topDepositUsers.length - 1; i++) {
//             for (uint256 j = i + 1; j < topDepositUsers.length; j++) {
//                 if (
//                     balances[topDepositUsers[i]] < balances[topDepositUsers[j]]
//                 ) {
//                     address tempUser = topDepositUsers[i];
//                     topDepositUsers[i] = topDepositUsers[j];
//                     topDepositUsers[j] = tempUser;
//                 }
//             }
//         }
//     }

//     // View function to get top deposit users and amounts
//     // getTopDepositUsers()：查看函数，返回前三名存款用户和对应的存款金额数组。
//     function getTopDepositUsers()
//         external
//         view
//         returns (address[3] memory, uint256[3] memory)
//     {
//         uint256[3] memory topAmounts;
//         for (uint256 i = 0; i < topDepositUsers.length; i++) {
//             topAmounts[i] = balances[topDepositUsers[i]];
//         }
//         return (topDepositUsers, topAmounts);
//     }

//     // Fallback function to receive Ether
//     // receive()：fallback 函数，用于接收以太币存款，调用 deposit() 函数处理存款。
//     receive() external payable {
//         deposit();
//     }
// }