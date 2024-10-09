pragma solidity  0.4.21;
library SafeMath {
function mul(uint a, uint b) internal pure returns(uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function sub(uint a, uint b) internal pure  returns(uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal  pure returns(uint) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
}
contract ERC20 {
uint public totalSupply;
function balanceOf(address who) public view returns(uint);
function allowance(address owner, address spender) public view returns(uint);
function transfer(address to, uint value) public returns(bool ok);
function transferFrom(address from, address to, uint value) public returns(bool ok);
function approve(address spender, uint value) public returns(bool ok);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract MultiToken is ERC20, Ownable {
using SafeMath for uint;
string public name;
string public symbol;
uint public decimals;
string public version;
uint public totalSupply;
uint public tokenPrice;
bool public exchangeEnabled;
bool public codeExportEnabled;
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowed;
function MultiToken(uint _initialSupply,
string _tokenName,
uint _decimalUnits,
string _tokenSymbol,
string _version,
uint _tokenPrice
) public
{
totalSupply = _initialSupply * (10**_decimalUnits);
name = _tokenName;
symbol = _tokenSymbol;
decimals = _decimalUnits;
version = _version;
tokenPrice = _tokenPrice;
balances[0xeadA6cDDC45656d0E72089997eE3d6D4383Bce89] = totalSupply;
codeExportEnabled = true;
exchangeEnabled = true;
}
event TransferSold(address indexed to, uint value);
event TokenExchangeEnabled(address caller, uint exchangeCost);
event TokenExportEnabled(address caller, uint enableCost);
function swapTokens() public payable {
require(exchangeEnabled);
uint tokensToSend;
tokensToSend = (msg.value * (10**decimals)) / tokenPrice;
require(balances[owner] >= tokensToSend);
balances[msg.sender] += tokensToSend;
balances[owner] -= tokensToSend;
owner.transfer(msg.value);
emit Transfer(owner, msg.sender, tokensToSend);
emit TransferSold(msg.sender, tokensToSend);
}
function mintToken(address _target, uint256 _mintedAmount) public onlyOwner() {
balances[_target] += _mintedAmount;
totalSupply += _mintedAmount;
emit Transfer(0, _target, _mintedAmount);
}
function transfer(address _to, uint _value) public returns(bool) {
require(_to != address(0));
require(balances[msg.sender] >= _value);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public  returns(bool success) {
require(_to != address(0));
require(balances[_from] >= _value);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns(uint balance) {
return balances[_owner];
}
function approve(address _spender, uint _value) public returns(bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns(uint remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}