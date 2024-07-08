// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
}



// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract BaseERC20 {
//     string public name;
//     string public symbol;
//     uint8 public decimals;
//     uint256 public totalSupply;

//     mapping(address => uint256) balances;

//     mapping(address => mapping(address => uint256)) allowances;

//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(
//         address indexed owner,
//         address indexed spender,
//         uint256 value
//     );

//     constructor() public {
//         // write your code here
//         // set name,symbol,decimals,totalSupply

//         balances[msg.sender] = totalSupply;
//     }

//     function balanceOf(address _owner) public view returns (uint256 balance) {
//         // write your code here
//     }

//     function transfer(
//         address _to,
//         uint256 _value
//     ) public returns (bool success) {
//         // write your code here

//         emit Transfer(msg.sender, _to, _value);
//         return true;
//     }

//     function transferFrom(
//         address _from,
//         address _to,
//         uint256 _value
//     ) public returns (bool success) {
//         // write your code here

//         emit Transfer(_from, _to, _value);
//         return true;
//     }

//     function approve(
//         address _spender,
//         uint256 _value
//     ) public returns (bool success) {
//         // write your code here

//         emit Approval(msg.sender, _spender, _value);
//         return true;
//     }

//     function allowance(
//         address _owner,
//         address _spender
//     ) public view returns (uint256 remaining) {
//         // write your code here
//     }
// }