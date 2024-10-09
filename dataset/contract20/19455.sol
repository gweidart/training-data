pragma solidity ^0.4.18;
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
contract FreezeList is Ownable {
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
function FreezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic, FreezeList  {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
modifier onlyPayloadSize(uint size) {
require(!(msg.data.length < size + 4));
_;
}
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
require(frozenAccount[msg.sender] == false);
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
function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) returns (bool) {
require(frozenAccount[_from] == false);
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
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
contract BurnableToken is StandardToken{
bool public isBurn = false;
event Burn(address indexed from, uint256 value);
function burn(uint256 _value) onlyOwner public returns (bool success) {
if (isBurn == true)
{
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(msg.sender, _value);
return true;
}
else{
return false;
}
}
event SetBurnStart(bool _isBurnStart);
function setBurnStart(bool _isBurnStart) onlyOwner public {
isBurn = _isBurnStart;
}
}
contract PointToken is BurnableToken {
string public name;
string public symbol;
uint public decimals;
address public auditor;
uint256 public assetSize;
modifier onlyAuditor() {
require(msg.sender == auditor);
_;
}
event Issue(uint amount);
event AuditorTransferred(address indexed previousAuditor, address indexed newAuditor);
function PointToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {
owner = msg.sender;
auditor = msg.sender;
totalSupply_ = _initialSupply;
assetSize = _initialSupply;
name = _name;
symbol = _symbol;
decimals = _decimals;
balances[owner] = _initialSupply;
}
function issue(uint amount) public onlyOwner {
require(totalSupply_ + amount > totalSupply_);
require(assetSize >= totalSupply_ + amount);
require(balances[owner] + amount > balances[owner]);
balances[owner] += amount;
totalSupply_ += amount;
Issue(amount);
}
function SetAuditedAssetSize(uint256 auditedAssetSize) public onlyAuditor{
assetSize = auditedAssetSize;
}
function transferAuditor(address newAuditor) public onlyAuditor {
require(newAuditor != address(0));
AuditorTransferred(auditor, newAuditor);
auditor = newAuditor;
}
}