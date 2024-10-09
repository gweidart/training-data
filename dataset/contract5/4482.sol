pragma solidity ^0.4.10;
contract CryptAI
{
string 		public standard = 'Token 0.1';
string 		public name = "CryptAI";
string 		public symbol = "TAI";
uint8 		public decimals = 2;
uint256 	public totalSupply = 7000000 * 1e2;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function balanceOf(address _owner) public constant returns(uint256 tokens)
{
require(_owner != 0x0);
return balances[_owner];
}
function balanceOfReadable(address _owner) public constant returns(uint256 tokens)
{
require(_owner != 0x0);
return balances[_owner] / 1e2;
}
function transfer(address _to, uint256 _value) public returns(bool success)
{
require(_to != 0x0 && _value > 0 && balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
function canTransferFrom(address _owner, address _spender) public constant returns(uint256 tokens)
{
require(_owner != 0x0 && _spender != 0x0);
if (_owner == _spender)
{
return balances[_owner];
}
else
{
return allowed[_owner][_spender];
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns(bool success)
{
require(_value > 0 && _from != 0x0 && _to != 0x0 &&
allowed[_from][msg.sender] >= _value &&
balances[_from] >= _value);
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns(bool success)
{
require(_spender != 0x0 && _spender != msg.sender);
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
constructor() public
{
balances[msg.sender] = totalSupply;
emit TokenDeployed(totalSupply);
}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event TokenDeployed(uint256 _totalSupply);
}