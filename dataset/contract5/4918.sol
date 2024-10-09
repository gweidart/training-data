pragma solidity ^0.4.24;
contract Token
{
function totalSupply() constant public returns (uint256 supply);
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token
{
function transfer(address _to, uint256 _value) public returns (bool success)
{
if (balances[msg.sender] >= _value && _value > 0)
{
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
else
{
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
{
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
} else { return false; }
}
function balanceOf(address _owner) public constant returns (uint256 balance)
{
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success)
{
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining)
{
return allowed[_owner][_spender];
}
function totalSupply() constant public returns (uint256 supply)
{
return _totalSupply;
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 _totalSupply;
}
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract MulaCoin is StandardToken
{
string public name;
uint8 public decimals;
string public symbol;
string public version = '1.0';
uint256 public unitsOneEthCanBuy;
uint256 public totalEthInWei;
address public fundsWallet;
modifier onlyFundOwner () {
require(msg.sender == fundsWallet);
_;
}
constructor() public
{
_totalSupply 		 = 3000000000000000000000000000;
balances[msg.sender]     = _totalSupply;
name 				 = "MULA COIN";
decimals 			 = 18;
symbol 				 = "MUT";
unitsOneEthCanBuy 	 = 4356;
fundsWallet 		 = msg.sender;
}
function() payable public
{
totalEthInWei = totalEthInWei + msg.value;
uint256 amount = msg.value * unitsOneEthCanBuy;
if (balances[fundsWallet] < amount)
{
revert();
}
balances[fundsWallet] = balances[fundsWallet] - amount;
balances[msg.sender] = balances[msg.sender] + amount;
emit Transfer(fundsWallet, msg.sender, amount);
fundsWallet.transfer(msg.value);
}
function changePrice(uint256 _newPrice) public onlyFundOwner
{
unitsOneEthCanBuy = _newPrice;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success)
{
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}