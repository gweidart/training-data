pragma solidity ^0.4.11;
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }
contract MessageToken {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
address owner;
address EMSAddress;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function MessageToken() {
balanceOf[this] = 10000000000000000000000000000000000000;
totalSupply = 10000000000000000000000000000000000000;
name = "Messages";
symbol = "\2709";
decimals = 0;
owner = msg.sender;
}
function transfer(address _to, uint256 _value) {
if (_to != address(this)) throw;
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value)
returns (bool success) {
if(msg.sender == owner){
EMSAddress = _spender;
allowance[this][_spender] = _value;
return true;
}
}
function register(address _address)
returns (bool success){
if(msg.sender == EMSAddress){
allowance[_address][EMSAddress] = totalSupply;
return true;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (_to == 0x0) throw;
if (balanceOf[_from] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function getBalance(address _address) constant returns (uint256 balance){
return balanceOf[_address];
}
}