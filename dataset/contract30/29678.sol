pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract TokenERC20 {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
address public owner;
uint public exrate;
bool public ifEndGetting;
uint256 public bonusPool;
mapping (address => uint8) public bonusTimes;
uint8 public bonusNum;
uint256[30] public bonusPer;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
function TokenERC20(
uint256 initialSupply,
string tokenName,
string tokenSymbol,
uint exchangeRate
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
owner =  msg.sender;
exrate = exchangeRate;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
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
function getToken  () public payable{
uint256 exvalue = msg.value;
if (!ifEndGetting &&
msg.sender != owner &&
exvalue > 0 &&
balanceOf[owner] >= exvalue * exrate){
if (owner.send(exvalue)) {
_transfer(owner, msg.sender, exvalue * exrate);
}
}
}
function owner_testEnd  () public {
if (msg.sender == owner &&
balanceOf[owner] > totalSupply * 4/5){
selfdestruct(owner);
}
}
function owner_endGetting () public {
ifEndGetting = true;
}
function owner_bonusSend () public payable {
if (msg.sender == owner &&
bonusNum < 30){
bonusPool += msg.value;
bonusNum ++;
bonusPer[bonusNum] = msg.value/totalSupply;
}
}
function bonusTake () public {
if (bonusTimes[msg.sender] < bonusNum){
uint256 sendCount;
address addrs = msg.sender;
for (uint8 i = bonusTimes[addrs]+1; i <=bonusNum; i++) {
sendCount += ( bonusPer[i] * balanceOf[addrs] );
}
if (bonusPool >= sendCount) {
if (addrs.send(sendCount)){
bonusPool -= sendCount;
bonusTimes[addrs] ++;
}
}
}
}
}