pragma solidity 0.4.19;
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
uint256 public totalSupply;
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract FemaleToken is MintableToken {
string public name = "Female Token";
string public symbol = "FEM";
uint public decimals = 18;
bool public tradingStarted = false;
modifier hasStartedTrading() {
require(tradingStarted);
_;
}
function startTrading() public onlyOwner {
tradingStarted = true;
}
function transfer(address _to, uint _value) public hasStartedTrading returns (bool) {
super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) public hasStartedTrading returns (bool) {
super.transferFrom(_from, _to, _value);
}
}
contract FemaleTokenSale is Ownable {
using SafeMath for uint;
event TokenSold(address recipient, uint ether_amount, uint pay_amount);
event AuthorizedCreate(address recipient, uint pay_amount);
event MainSaleClosed();
FemaleToken public token = new FemaleToken();
address public multisigVault = 0xB80F274a7596D4Dc995f032e24Cb55B3902399F5;
uint hardcap = 100000 ether;
uint public rate = 1000;
uint restrictedPercent = 20;
uint public fiatDeposits = 0;
uint public startTime = 1514764800;
uint public endTime = 1517356800;
uint public bonusTime = 1518220800;
mapping(address => bool) femalestate;
modifier saleIsOn() {
require(now > startTime && now < endTime);
_;
}
modifier isUnderHardCap() {
require(multisigVault.balance + fiatDeposits <= hardcap);
_;
}
function bonusRate(uint initwei) internal view returns (uint){
uint bonRate;
uint calcRate = initwei.div(100000000000000000);
if (calcRate > 50 ) bonRate = 150 * rate / 100;
else if (calcRate <1) bonRate = rate;
else {
bonRate = calcRate.mul(rate) / 100;
bonRate += rate;
}
return bonRate;
}
function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
uint256 weiAmount = msg.value;
uint bonusTokensRate = bonusRate(weiAmount);
uint tokens = bonusTokensRate.mul(weiAmount);
token.mint(recipient, tokens);
require(multisigVault.send(msg.value));
TokenSold(recipient, msg.value, tokens);
femalestate[msg.sender]= false;
}
function altCreateTokens(address recipient, uint fiatdeposit) public isUnderHardCap saleIsOn onlyOwner {
require(recipient != address(0));
require(fiatdeposit > 0);
fiatDeposits += fiatdeposit;
uint bonusTokensRate = bonusRate(fiatdeposit);
uint tokens = bonusTokensRate.mul(fiatdeposit);
token.mint(recipient, tokens);
AuthorizedCreate(recipient, tokens);
femalestate[recipient]= false;
}
function finishMinting() public onlyOwner {
require(now > bonusTime);
uint issuedTokenSupply = token.totalSupply();
uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
token.mint(multisigVault, restrictedTokens);
token.finishMinting();
token.startTrading();
token.transferOwnership(owner);
MainSaleClosed();
}
function doubleBonus(address adr) public onlyOwner {
require (now > endTime && now < bonusTime);
if (!femalestate[adr]) {
femalestate[adr]= true;
uint unittoken = token.balanceOf(adr);
uint doubletoken = unittoken.mul(2);
if (unittoken < doubletoken) {token.mint(adr, unittoken);}
}
}
function doubleBonusArray(address[] adr) public onlyOwner {
uint i = 0;
while (i < adr.length) {
doubleBonus(adr[i]);
i++;
}
}
function retrieveTokens(address _token) public onlyOwner {
ERC20 alttoken = ERC20(_token);
alttoken.transfer(multisigVault, alttoken.balanceOf(this));
}
function() external payable {
createTokens(msg.sender);
}
}