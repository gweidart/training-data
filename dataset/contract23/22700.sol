pragma solidity ^0.4.18;
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
contract Distributable is Ownable {
mapping(address => bool) public dealership;
event Trust(address dealer);
event Distrust(address dealer);
modifier onlyDealers() {
require(dealership[msg.sender]);
_;
}
function trust(address newDealer) public onlyOwner {
require(newDealer != address(0));
require(!dealership[newDealer]);
dealership[newDealer] = true;
Trust(newDealer);
}
function distrust(address dealer) public onlyOwner {
require(dealership[dealer]);
dealership[dealer] = false;
Distrust(dealer);
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
contract DistributionToken is StandardToken, Distributable {
uint256 public decimals = 18;
event Mint(address indexed dealer, address indexed to, uint256 value);
event Burn(address indexed dealer, address indexed from, uint256 value);
function mint(address _to, uint256 _value) public onlyDealers returns (bool) {
totalSupply_ = totalSupply_.add(_value);
balances[_to] = balances[_to].add(_value);
Mint(msg.sender, _to, _value);
Transfer(address(0), _to, _value);
return true;
}
function burn(address _from, uint256 _value) public onlyDealers returns (bool) {
totalSupply_ = totalSupply_.sub(_value);
balances[_from] = balances[_from].sub(_value);
Burn(msg.sender, _from, _value);
Transfer(_from, address(0), _value);
return true;
}
}
contract LeCarboneInitialToken is Ownable {
using SafeMath for uint256;
DistributionToken public token;
bool public initiated = false;
address public privateSaleAddress = 0x2F196AdBeD104ceB69C86BCD06625a9F1A6cb1aF;
uint256 public privateSaleAmount = 1800000;
address public publicSaleAddress = 0xC99c001a806015a1CEa0c9B5e7f72c3d05f2a7b6;
uint256 public publicSaleAmount = 7200000;
function LeCarboneInitialToken(DistributionToken _token) public {
require(_token != address(0));
token = _token;
}
function initial() onlyOwner public {
require(!initiated);
initiated = true;
uint256 decimals = token.decimals();
uint256 unitRatio = 10**decimals;
token.mint(privateSaleAddress, privateSaleAmount.mul(unitRatio));
token.mint(publicSaleAddress, publicSaleAmount.mul(unitRatio));
}
}