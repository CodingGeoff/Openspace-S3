// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/console.sol";

contract SmartBank {

  mapping(address => uint256) public balances;
  mapping(address => address) _nextAccounts;
  uint256 public totalAccounts;
  address constant GUARD = address(999);

  constructor() {
    _nextAccounts[GUARD] = GUARD;
  }

  event Deposited(address indexed from, uint256 amount);
  event Withdrawn(address indexed to, uint256 amount);
  event TopDeposits(address[] accounts);
  function Deposit() public payable {
    if (_nextAccounts[msg.sender] == address(0)){
        uint256 deposit = balances[msg.sender] + msg.value;
        require(_nextAccounts[msg.sender] == address(0), "Add Account: Pre-existing account");
        address index = _findIndex(deposit);
        balances[msg.sender] = deposit;  
        _nextAccounts[msg.sender] = _nextAccounts[index];
        _nextAccounts[index] = msg.sender;
        totalAccounts++;
    }
    else{
        updateDeposit(balances[msg.sender] + msg.value);
    }
    emit Deposited(msg.sender, msg.value);
  }

 function Withdraw(uint256 amount) public {
    require(balances[msg.sender]>= amount, "Withdraw: Insufficient balance");
    updateDeposit(balances[msg.sender] - amount);
    payable(msg.sender).transfer(amount);
    emit Withdrawn(msg.sender, amount);
  }


  function updateDeposit(uint256 newDeposit) public {
    require(_nextAccounts[msg.sender] != address(0), "Update Deposit: Account not found");
    address prevAccount = _findPrevAccount(msg.sender);
    address nextAccount = _nextAccounts[msg.sender];
    if(_verifyIndex(prevAccount, newDeposit, nextAccount)){
      balances[msg.sender] = newDeposit;
    } else {
      removeAccount();
      uint256 deposit = newDeposit;
      require(_nextAccounts[msg.sender] == address(0), "Add Account: Pre-existing account");
      address index = _findIndex(deposit);
      balances[msg.sender] = deposit;  
      _nextAccounts[msg.sender] = _nextAccounts[index];
      _nextAccounts[index] = msg.sender;
      totalAccounts++;
      // addAccount(newDeposit);
    }
  }

  function removeAccount() public {
    require(_nextAccounts[msg.sender] != address(0), "Remove Account: Account not found");
    address prevAccount = _findPrevAccount(msg.sender);
    _nextAccounts[prevAccount] = _nextAccounts[msg.sender];
    _nextAccounts[msg.sender] = address(0);
    // payable(msg.sender).transfer(balances[msg.sender]); 
    // the bank will collapse with this line uncommented
    balances[msg.sender] = 0;
    totalAccounts--;
  }

  function getTopAccounts(uint256 k) public returns(address[] memory) {
    require(k <= totalAccounts, "Get Top Accounts: Invalid input parameter");
    address[] memory accountList = new address[](k);
    address currentAddress = _nextAccounts[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      accountList[i] = currentAddress;
      currentAddress = _nextAccounts[currentAddress];
    }
    emit TopDeposits(accountList);
    return accountList;
  }

  function _verifyIndex(address prevAccount, uint256 newValue, address nextAccount)
    internal
    view
    returns(bool)
  {
    return (prevAccount == GUARD || balances[prevAccount] >= newValue) &&
           (nextAccount == GUARD || newValue > balances[nextAccount]);
  }

  function _findIndex(uint256 newValue) internal view returns(address candidateAddress) {
    candidateAddress = GUARD;
    while(true) {
      if(_verifyIndex(candidateAddress, newValue, _nextAccounts[candidateAddress]))
        return candidateAddress;
      candidateAddress = _nextAccounts[candidateAddress];
    }
  }

  function _isPrevAccount(address account, address prevAccount) internal view returns(bool) {
    return _nextAccounts[prevAccount] == account;
  }

  function _findPrevAccount(address account) internal view returns(address) {
    address currentAddress = GUARD;
    while(_nextAccounts[currentAddress] != GUARD) {
      if(_isPrevAccount(account, currentAddress))
        return currentAddress;
      currentAddress = _nextAccounts[currentAddress];
    }
    return address(0);
  }
}
