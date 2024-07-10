// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

contract BaseERC20 {
    string public tokenName;
    string public tokenSymbol;
    uint8 public tokenDecimals;
    uint256 public tokenTotalSupply;

    mapping(address => uint256) public accountBalances;
    mapping(address => mapping(address => uint256)) private accountAllowances;

    event TransferEvent(address indexed sender, address indexed recipient, uint256 amount);
    event ApprovalEvent(address indexed owner, address indexed spender, uint256 amount);

    constructor() {
        tokenName = "BaseERC20";
        tokenSymbol = "BERC20";
        tokenDecimals = 18;
        tokenTotalSupply = 100000000 * (10 ** uint256(tokenDecimals));
        accountBalances[msg.sender] = tokenTotalSupply;
    }

    function getBalance(address account) public view returns (uint256) {
        return accountBalances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(accountBalances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        accountBalances[msg.sender] -= amount;
        accountBalances[recipient] += amount;

        emit TransferEvent(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(accountBalances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(accountAllowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        accountBalances[sender] -= amount;
        accountBalances[recipient] += amount;
        accountAllowances[sender][msg.sender] -= amount;

        emit TransferEvent(sender, recipient, amount);
        return true;
    }

    function authorizeSpender(address spender, uint256 amount) public returns (bool) {
        accountAllowances[msg.sender][spender] = amount;
        emit ApprovalEvent(msg.sender, spender, amount);
        return true;
    }

    function getAllowance(address owner, address spender) public view returns (uint256) {
        return accountAllowances[owner][spender];
    }

    function transferAndCall(address to, uint256 amount) public returns (bool success) {
        require(transfer(to, amount));
        if (to.code.length > 0) { // to is a contract
            try IERC1363Receiver(to).onTransferReceived(msg.sender, msg.sender, amount, "") returns (bytes4 rtVal) {
                require(rtVal == IERC1363Receiver.onTransferReceived.selector);
            } catch {
                revert();
            }
        }
        return true; // Explicitly return true to indicate success
    }
}

abstract contract ERC20WithCallback is IERC1363Receiver {
    using Address for address;
    event CallbackEvent(bool success);

    function onTransferReceived(address /*operator*/,
        address from,
        uint256 amount,
        bytes memory /*data*/
    ) external virtual returns (bytes4) {
        tokenReceived(from, amount);
        return this.onTransferReceived.selector;
    }

    function tokenReceived(address from, uint256 amount) public virtual returns(bool);
}

contract TokenBank is ERC20WithCallback {
    BaseERC20 public baseToken;
    mapping(address => uint256) public accountBalances;

    constructor(address _baseToken) {
        baseToken = BaseERC20(_baseToken);
    }

    function onTransferReceived(address /* operator */, address from, uint256 value, bytes calldata /* data */) external override returns (bytes4) {
        accountBalances[from] += value;
        emit CallbackEvent(true);
        return IERC1363Receiver.onTransferReceived.selector;
    }

    function tokenReceived(address from, uint256 amount) public override returns (bool) {
        accountBalances[from] += amount;
        emit CallbackEvent(true);
        return true;
    }

    function deposit(uint256 amount) public {
        require(baseToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }
}

// contract Counter {
//     // 一个没有接收转账能力的合约，用于检测
//     uint256 public counter;
//     function get() public view returns (uint256) {
//         return counter;
//     }
//     function add(uint256 x) public payable {
//         counter += x;
//     }
// }