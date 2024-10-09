pragma solidity ^0.4.18;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
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
contract Pausable is Ownable {
using SafeMath for uint256;
event Pause();
event Unpause();
bool public paused = false;
address public crowdsale;
mapping (address => uint256) public frozen;
uint public unfreezeTimestamp;
function Pausable() public {
unfreezeTimestamp = now + 60 days;
}
function setUnfreezeTimestamp(uint _unfreezeTimestamp) onlyOwner public {
require(now < _unfreezeTimestamp);
unfreezeTimestamp = _unfreezeTimestamp;
}
function increaseFrozen(address _owner,uint256 _incrementalAmount) public returns (bool)  {
require(msg.sender == crowdsale || msg.sender == owner);
require(_incrementalAmount>0);
frozen[_owner] = frozen[_owner].add(_incrementalAmount);
return true;
}
function decreaseFrozen(address _owner,uint256 _incrementalAmount) public returns (bool)  {
require(msg.sender == crowdsale || msg.sender == owner);
require(_incrementalAmount>0);
frozen[_owner] = frozen[_owner].sub(_incrementalAmount);
return true;
}
function setCrowdsale(address _crowdsale) onlyOwner public {
crowdsale=_crowdsale;
}
modifier frozenTransferCheck(address _to, uint256 _value, uint256 balance) {
if (now < unfreezeTimestamp){
require(_value <= balance.sub(frozen[msg.sender]) );
}
_;
}
modifier frozenTransferFromCheck(address _from, address _to, uint256 _value, uint256 balance) {
if(now < unfreezeTimestamp) {
require(_value <= balance.sub(frozen[_from]) );
}
_;
}
modifier whenNotPaused() {
require(!paused || msg.sender == crowdsale);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
require(msg.sender != address(0));
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
require(msg.sender != address(0));
paused = false;
Unpause();
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
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
event Burn(address indexed burner, uint256 value);
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
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
}
contract PausableToken is StandardToken, Pausable {
using SafeMath for uint256;
function transfer(address _to, uint256 _value) public whenNotPaused frozenTransferCheck(_to, _value, balances[msg.sender]) returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused frozenTransferFromCheck(_from, _to, _value, balances[_from]) returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract StocksBetToken is PausableToken {
string public constant name = "StocksBet";
string public constant symbol = "STBT";
uint public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 125000000*(10**decimals);
function StocksBetToken() public {
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
Transfer(0x0, msg.sender, INITIAL_SUPPLY);
}
}