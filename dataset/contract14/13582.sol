pragma solidity ^0.4.23;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
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
contract Ownable {
address internal owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor() public {
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
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
event MintStarted();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() public onlyOwner returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
function startMinting() public onlyOwner returns (bool) {
mintingFinished = false;
emit MintStarted();
return true;
}
}
contract KassotBasicToken is MintableToken {
string public constant name = "Kassot Token";
string public constant symbol = "KATOK";
uint8 public constant decimals = 18;
uint public constant decimalMultiply = 1000000000000000000;
}
contract KassotToken is ERC20, Ownable {
using SafeMath for uint;
bool public saleFinished = false;
address internal multisig;
address internal restricted;
uint public restrictedPercent;
uint public hardcap;
uint public softcap;
uint public firstBonusPercent;
uint public secondBonusPercent;
uint public thirdBonusPercent;
uint public rate;
uint public currentRound;
bool public allowRefund = false;
KassotBasicToken internal token = new KassotBasicToken();
mapping (uint => mapping (address => uint)) public balances;
mapping(uint => uint) internal bonuses;
mapping(uint => uint) internal amounts;
constructor(address _multisig, address _restricted) public {
multisig = _multisig;
restricted = _restricted;
restrictedPercent = 10;
hardcap = 900 * 1 ether;
softcap = 30 * 1 ether;
rate = 112600 * token.decimalMultiply();
currentRound = 1;
firstBonusPercent = 50;
secondBonusPercent = 25;
thirdBonusPercent = 10;
}
modifier saleIsOn() {
require(!saleFinished);
_;
}
modifier isUnderHardCap() {
require(address(this).balance <= hardcap);
_;
}
function name() public view returns (string) {
return token.name();
}
function symbol() public view returns (string) {
return token.symbol();
}
function decimals() public view returns (uint8) {
return token.decimals();
}
function totalSupply() public view returns (uint256) {
return token.totalSupply();
}
function transfer(address _to, uint256 _value) public returns (bool) {
return token.transfer(_to, _value);
}
function balanceOf(address _owner) public view returns (uint256) {
return token.balanceOf(_owner);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
return token.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public returns (bool) {
return token.approve(_spender, _value);
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return token.allowance(_owner, _spender);
}
function setMultisig(address _multisig) public onlyOwner returns (bool) {
multisig = _multisig;
return true;
}
function setRestricted(address _restricted) public onlyOwner returns (bool) {
restricted = _restricted;
return true;
}
function setRestrictedPercent(uint _restrictedPercent) public onlyOwner returns (bool) {
restrictedPercent = _restrictedPercent;
return true;
}
function setHardcap(uint _hardcap) public onlyOwner returns (bool) {
hardcap = _hardcap;
return true;
}
function setSoftcap(uint _softcap) public onlyOwner returns (bool) {
softcap = _softcap;
return true;
}
function setRate(uint _rate) public onlyOwner returns (bool) {
rate = _rate;
return true;
}
function setCurrentRound(uint _currentRound) public onlyOwner returns (bool) {
currentRound = _currentRound;
return true;
}
function setFirstBonusPercent(uint _firstBonusPercent) public onlyOwner returns (bool) {
firstBonusPercent = _firstBonusPercent;
return true;
}
function setSecondBonusPercent(uint _secondBonusPercent) public onlyOwner returns (bool) {
secondBonusPercent = _secondBonusPercent;
return true;
}
function setThirdBonusPercent(uint _thirdBonusPercent) public onlyOwner returns (bool) {
thirdBonusPercent = _thirdBonusPercent;
return true;
}
function getMultisig() public view onlyOwner returns (address) {
return multisig;
}
function getRestricted() public view onlyOwner returns (address) {
return restricted;
}
function refund() public {
require(allowRefund);
uint value = balances[currentRound][msg.sender];
balances[currentRound][msg.sender] = 0;
msg.sender.transfer(value);
}
function finishSale() public onlyOwner {
if (address(this).balance > softcap) {
multisig.transfer(address(this).balance);
uint issuedTokenSupply = token.totalSupply();
uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100);
token.mint(restricted, restrictedTokens);
} else {
allowRefund = true;
}
token.finishMinting();
saleFinished = true;
}
function startSale() public onlyOwner {
token.startMinting();
allowRefund = false;
saleFinished = false;
}
function calculateTokens(uint _amount, uint _stage, uint _stageAmount) public returns (uint) {
bonuses[1] = firstBonusPercent;
bonuses[2] = secondBonusPercent;
bonuses[3] = thirdBonusPercent;
bonuses[4] = 0;
amounts[1] = 0;
amounts[2] = 0;
amounts[3] = 0;
amounts[4] = 0;
int amount = int(_amount);
uint i = _stage;
while (amount > 0) {
if (i > 3) {
amounts[i] = uint(amount);
break;
}
if (amount - int(_stageAmount) > 0) {
amounts[i] = _stageAmount;
amount -= int(_stageAmount);
i++;
} else {
amounts[i] = uint(amount);
break;
}
}
uint tokens = 0;
uint bonusTokens = 0;
uint _tokens = 0;
for (i = _stage; i <= 4; i++) {
if (amounts[i] == 0) {
break;
}
_tokens = rate.mul(amounts[i]).div(1 ether);
bonusTokens = _tokens * bonuses[i] / 100;
tokens += _tokens + bonusTokens;
}
return tokens;
}
function createTokens() public isUnderHardCap saleIsOn payable {
uint amount = msg.value;
uint tokens = 0;
uint stageAmount = hardcap.div(4);
if (address(this).balance <= stageAmount) {
tokens = calculateTokens(amount, 1, stageAmount);
} else if (address(this).balance <= stageAmount * 2) {
tokens = calculateTokens(amount, 2, stageAmount);
} else if (address(this).balance <= stageAmount * 3) {
tokens = calculateTokens(amount, 3, stageAmount);
} else {
tokens = calculateTokens(amount, 4, stageAmount);
}
token.mint(msg.sender, tokens);
balances[currentRound][msg.sender] = balances[currentRound][msg.sender].add(amount);
}
function() external payable {
createTokens();
}
}