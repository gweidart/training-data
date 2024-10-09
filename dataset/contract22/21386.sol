pragma solidity ^ 0.4.17;
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
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract DeployTokenContract is Ownable {
address public commissionAddress;
uint public deploymentCost;
uint public tokenOnlyDeploymentCost;
uint public exchangeEnableCost;
uint public codeExportCost;
MultiToken multiToken;
event TokenDeployed(address newToken, uint amountPaid);
event ExchangeEnabled(address token, uint amountPaid);
event CodeExportEnabled(address sender);
function deployMultiToken () public returns (address) {
MultiToken token;
token = new MultiToken();
TokenDeployed(token, 0);
return token;
}
function enableCodeExport(address _token) public payable {
require(msg.value == codeExportCost);
require(_token != address(0));
multiToken = MultiToken(_token);
if (!multiToken.enableCodeExport())
revert();
commissionAddress.transfer(msg.value);
CodeExportEnabled(msg.sender);
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
address public parentContract;
bool public codeExportEnabled;
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowed;
modifier onlyAuthorized() {
if (msg.sender != parentContract)
revert();
_;
}
function MultiToken() public
{
totalSupply = 10000 * (10**8);
name = "ICO";
symbol = "ICO";
decimals = 8;
version = "1.0";
tokenPrice = 1 ether / 100;
codeExportEnabled = true;
exchangeEnabled = true;
balances[owner] = totalSupply;
parentContract = msg.sender;
}
event TransferSold(address indexed to, uint value);
function enableExchange(uint _tokenPrice) public onlyAuthorized() returns(bool) {
exchangeEnabled = true;
tokenPrice = _tokenPrice;
return true;
}
function enableCodeExport() public onlyAuthorized() returns(bool) {
codeExportEnabled = true;
return true;
}
function swapTokens() public payable {
require(exchangeEnabled);
uint tokensToSend;
tokensToSend = (msg.value * (10**decimals)) / tokenPrice;
require(balances[owner] >= tokensToSend);
balances[msg.sender] += tokensToSend;
balances[owner] -= tokensToSend;
Transfer(owner, msg.sender, tokensToSend);
TransferSold(msg.sender, tokensToSend);
}
function mintToken(address _target, uint256 _mintedAmount) public onlyOwner() {
balances[_target] += _mintedAmount;
totalSupply += _mintedAmount;
Transfer(0, _target, _mintedAmount);
}
function transfer(address _to, uint _value) public returns(bool) {
require(_to != address(0));
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public  returns(bool success) {
require(_to != address(0));
require(balances[_from] >= _value);
require(_value <= allowed[_from][msg.sender]);
balances[_from] -= _value;
balances[_to] += _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns(uint balance) {
return balances[_owner];
}
function approve(address _spender, uint _value) public returns(bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns(uint remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}