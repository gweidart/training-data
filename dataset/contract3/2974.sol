pragma solidity ^0.4.24;
interface ERC165 {
function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
contract CRAM {
string public name;
uint8 public decimals;
string public symbol;
uint256 public totalSupply;
mapping (address => uint256) private balances;
mapping (address => mapping (address => uint256)) private allowed;
mapping (bytes4 => bool) internal supportedInterfaces;
constructor() public {
totalSupply = 333333333;
balances[msg.sender] = totalSupply;
name = "CRAM COIN!";
decimals = 0;
symbol = "CRAM!";
supportedInterfaces[0x01ffc9a7] = true;
supportedInterfaces[0x36372b07] = true;
supportedInterfaces[0x942e8b22] = true;
}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Cram(address indexed _from, address indexed _to, uint256 _value, string _message);
function supportsInterface(bytes4 interfaceID) external view returns (bool) {
require(interfaceID != 0xffffffff);
return supportedInterfaces[interfaceID];
}
function () public {
revert("You cannot buy CRAM! Coins, you fool.");
}
function cram(address _to, uint256 _value, string _message) external returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Cram(msg.sender, _to, _value, _message);
return true;
} else { return false; }
}
function transfer(address _to, uint256 _value) external returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
} else { return false; }
}
function balanceOf(address _owner) external view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) external returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
return true;
}
}