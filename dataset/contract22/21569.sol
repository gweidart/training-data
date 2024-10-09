pragma solidity ^0.4.18;
contract Bhinneka {
string public name = "Bhinneka Tunggal Ika";
string public symbol = "BTI";
uint public decimals = 18;
address public owner;
uint256 totalBhinneka;
uint256 totalToken;
bool public hault = false;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address _from, uint256 _value);
event Approval(address _from, address _to, uint256 _value);
function Bhinneka (
address _BTIclan
) public {
owner = msg.sender;
balances[msg.sender] = 167000000 * (10 ** decimals);
totalBhinneka = 267000000 * (10 ** decimals);
balances[_BTIclan] = safeAdd(balances[_BTIclan], 53125000 * (10 ** decimals));
}
function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4) ;
_;
}
modifier onlyowner {
require (owner == msg.sender);
_;
}
function tokensup(uint256 _value) onlyowner public{
totalBhinneka = safeAdd(totalBhinneka, _value * (10 ** decimals));
balances[owner] = safeAdd(balances[owner], _value * (10 ** decimals));
}
function Bhinnekamint( address _client, uint _value, uint _type) onlyowner public {
uint numBTI;
require(totalToken <= totalBhinneka);
if(_type == 1){
numBTI = _value * 6000 * (10 ** decimals);
}
else if (_type == 2){
numBTI = _value * 5000 * (10 ** decimals);
}
balances[owner] = safeSub(balances[owner], numBTI);
balances[_client] = safeAdd(balances[_client], numBTI);
totalToken = safeAdd(totalToken, numBTI);
Transfer(owner, _client, numBTI);
}
function BTImint( address _client, uint256 _value) onlyowner public {
require(totalToken <= totalBhinneka);
uint256 numBTI = _value * ( 10 ** decimals);
balances[owner] = safeSub(balances[owner], numBTI);
balances[_client] = safeAdd(balances[_client], numBTI);
totalToken = safeAdd(totalToken, numBTI);
Transfer(owner, _client, numBTI);
}
function transfer(address _to, uint256 _value) public returns (bool success) {
require(!hault);
require(balances[msg.sender] >= _value);
balances[msg.sender] = safeSub(balances[msg.sender],_value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
revert();
}
require(!hault);
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from],_value);
allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value)
public
returns (bool)
{
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender)
constant
public
returns (uint256)
{
return allowed[_owner][_spender];
}
function balanceOf(address _from) public view returns (uint balance) {
return balances[_from];
}
function totalSupply() public view returns (uint Supply){
return totalBhinneka;
}
function pauseable() public onlyowner {
hault = true;
}
function unpause() public onlyowner {
hault = false;
}
function burn(uint256 _value) onlyowner public returns (bool success) {
require (balances[msg.sender] >= _value);
balances[msg.sender] = safeSub(balances[msg.sender], _value);
totalBhinneka = safeSub(totalBhinneka, _value);
Burn(msg.sender, _value);
return true;
}
}