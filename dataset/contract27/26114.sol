pragma solidity ^0.4.16;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract BurnableToken is StandardToken {
function burn(uint _value) public {
require(_value > 0);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
event Burn(address indexed burner, uint indexed value);
}
contract VirCoinToken is BurnableToken {
string public constant name = "VR Games Coin Token";
string public constant symbol = "VIR";
uint32 public constant decimals = 18;
uint256 public INITIAL_SUPPLY = 800000 * 1 ether;
function VirCoinToken() public {
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
}
}
contract Crowdsale is Ownable {
using SafeMath for uint;
address multisig;
uint restrictedPercent;
address restricted;
VirCoinToken public token = new VirCoinToken();
uint start;
uint period;
uint rate;
function Crowdsale() public {
multisig = 0x8317BD267d4F80105a4e634D85145eE37d24c7a9;
restricted = 0x862631C23626959b080e6F0A7972BA5e53ae0a88;
restrictedPercent = 10;
rate = 1000000000000000000000;
start = 1518566400;
period = 100;
}
function bytesToAddress(bytes source) internal pure returns(address) {
uint result;
uint mul = 1;
for(uint i = 20; i > 0; i--) {
result += uint8(source[i-1]) * mul;
mul = mul * 256;
}
return address(result);
}
modifier saleIsOn() {
require(now > start && now < start + period * 1 days);
_;
}
function createTokens() public saleIsOn payable {
multisig.transfer(msg.value);
uint tokens = rate.mul(msg.value).div(1 ether);
uint bonusTokens = 0;
if(now < start + (14 * 1 days)) {
bonusTokens = tokens.mul(15).div(100);
} else if(now >= start + (14 * 1 days) && now < start + (period * 1 days).div(3).mul(2)) {
bonusTokens = tokens.div(10);
} else if(now >= start + (period * 1 days).div(3).mul(2) && now < start + (period * 1 days).div(3).mul(3)) {
bonusTokens = tokens.div(20);
}
uint tokensWithBonus = tokens.add(bonusTokens);
token.transfer(msg.sender, tokensWithBonus);
uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
token.transfer(restricted, restrictedTokens);
if(msg.data.length == 20) {
address referer = bytesToAddress(bytes(msg.data));
require(referer != msg.sender);
uint refererTokens = tokens.mul(10).div(100);
token.transfer(referer, refererTokens);
}
}
function() external payable {
createTokens();
}
}