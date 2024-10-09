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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
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
emit Transfer(msg.sender, _to, _value);
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
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract CappedToken is MintableToken {
uint256 public cap;
function CappedToken(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
require(totalSupply_.add(_amount) <= cap);
return super.mint(_to, _amount);
}
}
contract CitizenOneCoin is CappedToken {
string public name = "CITIZEN COIN";
string public symbol = "XCO";
uint8 public decimals = 18;
uint256 public cap;
address contributor1 = 0x276A50d31c3D0B38DFDE3422b8b9406858De4713;
address contributor2 = 0xEc7f7071b567bB712EEE3c028c8fC1D926f5032D;
address contributor3 = 0x920139b051C6381648D69D816447f7e3bC8F3c0F;
address contributor4 = 0x1Df3da5f535289e6da5E3ad3FA0293612b35765C;
address contributor5 = 0x93294f64bA8a7db37B554013a6c5D7519171C2Ce;
address contributor6 = 0xFFf43D46810B0521Da0fEcfccF13440015e27B6E;
address contributor7 = 0x8740BDEdf235af5093b2e6d4100671538c0266E1;
address contributor8 = 0x297F01F821323C5e85Cd51e10A892d2373ce12c4;
address contributor9 = 0xbfd638491453A933E1BF164ABFC3202fD564F4A7;
address contributor10 = 0x97E6342702554A79ad0Bd70362eD61a831F1cC59;
function CitizenOneCoin(uint256 _cap)  CappedToken  (_cap) public {
require(_cap > 0);
cap = _cap;
mint(contributor1, 500000e18);
mint(contributor2, 500000e18);
mint(contributor3, 500000e18);
mint(contributor4, 500000e18);
mint(contributor5, 500000e18);
mint(contributor6, 500000e18);
mint(contributor7, 500000e18);
mint(contributor8, 500000e18);
mint(contributor9, 500000e18);
mint(contributor10, 500000e18);
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
require(totalSupply_.add(_amount) <= cap);
return super.mint(_to, _amount);
}
function pushCap(uint _newCap) onlyOwner  public {
cap = cap.add(_newCap);
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public returns (bool) {
paused = true;
emit Pause();
return true;
}
function unpause() onlyOwner whenPaused public returns (bool) {
paused = false;
emit Unpause();
return true;
}
}
contract CitizenOne is Pausable {
using SafeMath for uint256;
address public publicityAddress;
CappedToken public token;
address public wallet;
uint256 public rate;
uint256 public cap;
bool public isFinalized;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
event Finalized();
function CitizenOne(uint256 _rate, address _wallet, uint256 _cap ) public payable {
require(_rate > 0);
require(_wallet != address(0));
require(_wallet != 0x0);
require(_cap > 0);
token = createTokenContract();
cap = _cap * (10**18);
rate = _rate;
wallet = _wallet;
publicityAddress    = _wallet;
token.mint(publicityAddress, 10000000e18);
}
function createTokenContract() internal returns (CappedToken) {
return new CitizenOneCoin(500000000e18);
}
function () public payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable whenNotPaused {
require(beneficiary != 0x0);
require(validPurchase());
uint256 weiAmount = msg.value;
weiRaised = weiRaised.add(weiAmount);
uint256 tokens = weiAmount.mul(rate);
token.mint(beneficiary, tokens);
emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function changeRate (uint256 _rate) onlyOwner public {
rate = _rate;
}
function transferTokenOwnership(address _newOwner) onlyOwner public {
token.transferOwnership(_newOwner);
}
function validPurchase() internal constant returns (bool) {
uint256 weiAmount = weiRaised.add(msg.value);
bool withinCap = weiAmount.mul(rate) <= cap;
return withinCap;
}
function finalize() onlyOwner public {
require(!isFinalized);
require(hasEnded());
token.finishMinting();
emit Finalized();
isFinalized = true;
}
function hasEnded() public constant returns (bool) {
bool capReached = (weiRaised.mul(rate) >= cap);
return capReached;
}
}