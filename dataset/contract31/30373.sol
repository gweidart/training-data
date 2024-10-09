pragma solidity ^0.4.18;
contract owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public {
if (msg.sender != owner) return;
owner = newOwner;
}
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract Dudecoin is owned {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
uint256 public buyPrice;
uint public amountRaised;
uint public deadline;
uint duration;
bool closed = false;
uint256 initialSupply = 10000000000;
string tokenName = "Dudecoin";
string tokenSymbol = "DUDE";
uint256 initBuyPrice_inWei = 1000000000000;
uint durationInMinutes = 259200;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
event Burn(address indexed from, uint256 value);
function Dudecoin() public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[this] = initialSupply * 8 * (10 ** uint256(decimals - 1));
balanceOf[msg.sender] = initialSupply * 2 * (10 ** uint256(decimals - 1));
name = tokenName;
symbol = tokenSymbol;
buyPrice = initBuyPrice_inWei;
amountRaised = 0;
duration = durationInMinutes;
deadline = now + duration * 1 minutes;
}
modifier afterDeadline() { if (now >= deadline) _; }
function postDeadline()
public
afterDeadline
{
owner.transfer(amountRaised);
amountRaised = 0;
closed = true;
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
Approval(msg.sender, _spender, _value);
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
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
function setPrices(uint256 newBuyPrice)
public
onlyOwner
{
if (msg.sender != owner) return;
buyPrice = newBuyPrice;
}
function () payable public {
require(!closed);
uint256 amount = (msg.value * 1 ether) / buyPrice;
require(balanceOf[this] >= amount);
balanceOf[msg.sender] += amount;
balanceOf[this] -= amount;
Transfer(this, msg.sender, amount);
amountRaised += msg.value;
if (amountRaised >= 0.5 * 1 ether) {
owner.transfer(amountRaised);
amountRaised = 0;
}
}
function totalSupply() public constant returns (uint256)
{
return totalSupply;
}
function balanceOf(address tokenOwner) public constant returns (uint balance)
{
return balanceOf[tokenOwner];
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining)
{
return allowance[tokenOwner][spender];
}
}