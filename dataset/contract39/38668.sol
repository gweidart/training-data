pragma solidity ^0.4.10;
contract DickButtCoin {
string public standard = 'Token 0.69';
string public name = "Dick Butt Coin";
string public symbol = "DBC";
uint8 public decimals = 0;
uint256 public totalSupply = 0;
mapping (address => uint256) _balance;
mapping (address => bool) _used;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
bool active;
uint public deactivateTime;
function updateActivation() {
active = (now < deactivateTime);
}
function balanceOf(address addr) constant returns(uint) {
if(active && _used[addr] == false) {
return _balance[addr] +1;
}
return _balance[addr];
}
function MyToken()
{
deactivateTime = now + 90 days;
}
modifier checkInit(address addr) {
if(active && _used[addr] == false) {
_used[addr] = true;
_balance[addr] ++;
}
_;
}
function transfer(address _to, uint256 _value) checkInit(msg.sender) {
if (_to == 0x0) throw;
if (_balance[msg.sender] < _value) throw;
if (_balance[_to] + _value < _balance[_to]) throw;
_balance[msg.sender] -= _value;
_balance[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value) checkInit(msg.sender)
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (_to == 0x0) throw;
if (_balance[_from] < _value) throw;
if (_balance[_to] + _value < _balance[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
_balance[_from] -= _value;
_balance[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
}