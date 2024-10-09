pragma solidity ^0.4.18;
contract owned {
address public Owner;
function owned() public{
Owner = msg.sender;
}
modifier onlyOwner(){
require(msg.sender == Owner);
_;
}
function TransferOwnership(address newOwner) onlyOwner public {
Owner = newOwner;
}
function abort() onlyOwner public {
selfdestruct(Owner);
}
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract ZegartToken is owned {
string public name;
string public symbol;
string public version;
uint8 public decimals = 18;
uint256 public totalSupply;
bool tradable;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
mapping (address => bool) public frozenAccounts;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event RecieveEth(address indexed _from, uint256 _value);
event WithdrawEth(address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event SoldToken(address _buyer, uint256 _value, string note);
event BonusToken(address _customer, uint256 _value, string note);
function () payable public {
RecieveEth(msg.sender, msg.value);
}
function withdrawal(address _to, uint256 Ether, uint256 Token) onlyOwner public {
require(this.balance >= Ether && balances[this] >= Token );
if(Ether >0){
_to.transfer(Ether);
WithdrawEth(_to, Ether);
}
if(Token > 0)
{
require(balances[_to] + Token > balances[_to]);
balances[this] -= Token;
balances[_to] += Token;
Transfer(this, _to, Token);
}
}
function ZegartToken(
uint256 initialSupply,
string tokenName,
string tokenSymbol,
string contractversion
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balances[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
version = contractversion;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balances[_from] >= _value);
require(balances[_to] + _value > balances[_to]);
require(!frozenAccounts[_from]);
require(!frozenAccounts[_to]);
uint previousBalanceOf = balances[_from] + balances[_to];
balances[_from] -= _value;
balances[_to] += _value;
Transfer(_from, _to, _value);
assert(balances[_from] + balances[_to] == previousBalanceOf);
}
function GrantToken(address _customer, uint256 _value, string note) onlyOwner public {
require(balances[msg.sender] >= _value && balances[_customer] + _value > balances[_customer]);
BonusToken( _customer,  _value,  note);
balances[msg.sender] -= _value;
balances[_customer] += _value;
Transfer(msg.sender, _customer, _value);
}
function BuyToken(address _buyer, uint256 _value, string note) onlyOwner public {
require(balances[msg.sender] >= _value && balances[_buyer] + _value > balances[_buyer]);
SoldToken( _buyer,  _value,  note);
balances[msg.sender] -= _value;
balances[_buyer] += _value;
Transfer(msg.sender, _buyer, _value);
}
function FreezeAccount(address toFreeze) onlyOwner public {
frozenAccounts[toFreeze] = true;
}
function UnfreezeAccount(address toUnfreeze) onlyOwner public {
delete frozenAccounts[toUnfreeze];
}
function MakeTradable(bool t) onlyOwner public {
tradable = t;
}
function Tradable() public view returns(bool) {
return tradable;
}
modifier notFrozen(){
require (!frozenAccounts[msg.sender]);
_;
}
function transfer(address _to, uint256 _value) public notFrozen returns (bool success) {
require(tradable);
if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer( msg.sender, _to,  _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public notFrozen returns (bool success) {
require(!frozenAccounts[_from] && !frozenAccounts[_to]);
require(tradable);
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
balances[_from] -= _value;
balances[_to] += _value;
allowed[_from][msg.sender] -= _value;
Transfer( _from, _to,  _value);
return true;
} else {
return false;
}
}
function balanceOf(address _owner) constant public returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
Approval(msg.sender,  _spender, _value);
allowed[msg.sender][_spender] = _value;
return true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balances[_from] >= _value);
require(_value <= allowed[_from][msg.sender]);
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
}