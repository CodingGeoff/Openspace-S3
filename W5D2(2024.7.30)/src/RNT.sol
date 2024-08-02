// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IERC20} from "./UniswapV2/interfaces/IERC20.sol";


contract RNT is IERC20 {

    uint256 public constant TOTAL_SUPPLY = 10**9 * 10**18;

    string public name = "RntToken";
    string public symbol = "RNT";
    uint8 public decimals = 18;

    constructor() {
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }

    function _mint(address _to, uint256 _amount) private {
        balances[_to] += _amount;
        totalSupply += _amount;
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool success) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success) {
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view virtual override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;










}