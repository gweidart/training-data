pragma solidity ^0.4.23;
contract DelegateProvider {
function getDelegate() public view returns (address delegate);
}
contract DelegateProxy {
function delegatedFwd(address _dst, bytes _calldata) internal {
assembly {
let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
let size := returndatasize
let ptr := mload(0x40)
returndatacopy(ptr, 0, size)
switch result case 0 { revert(ptr, size) }
default { return(ptr, size) }
}
}
}
contract Token {
function transfer(address _to, uint _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
function approve(address _spender, uint256 _value) returns (bool success);
function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
function balanceOf(address tokenOwner) public constant returns (uint balance);
}
contract WalletStorage {
address public owner;
}
contract WalletProxy is WalletStorage, DelegateProxy {
event ReceivedETH(address from, uint256 amount);
constructor() public {
owner = msg.sender;
}
function() public payable {
if (msg.value > 0) {
emit ReceivedETH(msg.sender, msg.value);
}
if (gasleft() > 2400) {
delegatedFwd(DelegateProvider(owner).getDelegate(), msg.data);
}
}
}
contract Wallet is WalletStorage {
function transferERC20Token(Token token, address to, uint256 amount) public returns (bool) {
require(msg.sender == owner);
return token.transfer(to, amount);
}
function transferEther(address to, uint256 amount) public returns (bool) {
require(msg.sender == owner);
return to.call.value(amount)();
}
function() public payable {}
}