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
contract BuildersCoin is MintableToken {
string public constant name = 'Builders Coin';
string public constant symbol = 'BLD';
uint32 public constant decimals = 18;
address public saleAgent;
bool public transferLocked = true;
modifier notLocked() {
require(msg.sender == owner || msg.sender == saleAgent || !transferLocked);
_;
}
modifier onlyOwnerOrSaleAgent() {
require(msg.sender == owner || msg.sender == saleAgent);
_;
}
function setSaleAgent(address newSaleAgnet) public {
require(msg.sender == owner || msg.sender == saleAgent);
saleAgent = newSaleAgnet;
}
function unlockTransfer() onlyOwnerOrSaleAgent public {
if (transferLocked) {
transferLocked = false;
}
}
function mint(address _to, uint256 _amount) onlyOwnerOrSaleAgent canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() public onlyOwnerOrSaleAgent returns (bool) {
unlockTransfer();
return super.finishMinting();
}
function transfer(address _to, uint256 _value) public notLocked returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address from, address to, uint256 value) public notLocked returns (bool) {
return super.transferFrom(from, to, value);
}
}
contract Presale is Ownable {
using SafeMath for uint;
uint public price;
uint public start;
uint public end;
uint public duration;
uint public softcap = 157000000000000000000;
uint public hardcap;
uint public minInvestmentLimit;
uint public investedWei;
uint public directMintLimit;
uint public mintedDirectly;
uint public devLimit = 3500000000000000000;
bool public softcapReached;
bool public hardcapReached;
bool public refundIsAvailable;
bool public devWithdrawn;
address public directMintAgent;
address public wallet;
address public devWallet = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
BuildersCoin public token;
mapping(address => uint) public balances;
event SoftcapReached();
event HardcapReached();
event RefundIsAvailable();
modifier onlyOwnerOrDirectMintAgent() {
require(msg.sender == owner || msg.sender == directMintAgent);
_;
}
function setDirectMintAgent(address _directMintAgent) public onlyOwner {
directMintAgent = _directMintAgent;
}
function setDirectMintLimit(uint _directMintLimit) public onlyOwner {
directMintLimit = _directMintLimit;
}
function setMinInvestmentLimit(uint _minInvestmentLimit) public onlyOwner {
minInvestmentLimit = _minInvestmentLimit;
}
function setPrice(uint _price) public onlyOwner {
price = _price;
}
function setToken(address _token) public onlyOwner {
token = BuildersCoin(_token);
}
function setWallet(address _wallet) public onlyOwner {
wallet = _wallet;
}
function setStart(uint _start) public onlyOwner {
start = _start;
}
function setDuration(uint _duration) public onlyOwner {
duration = _duration;
end = start.add(_duration.mul(1 days));
}
function setHardcap(uint _hardcap) public onlyOwner {
hardcap = _hardcap;
}
function mintAndTransfer(address _to, uint _tokens) internal {
token.mint(this, _tokens);
token.transfer(_to, _tokens);
}
function mint(address _to, uint _investedWei) internal {
require(_investedWei >= minInvestmentLimit && !hardcapReached && now >= start && now < end);
uint tokens = _investedWei.mul(price).div(1 ether);
mintAndTransfer(_to, tokens);
balances[_to] = balances[_to].add(_investedWei);
investedWei = investedWei.add(_investedWei);
if (investedWei >= softcap && ! softcapReached) {
SoftcapReached();
softcapReached = true;
}
if (investedWei >= hardcap) {
HardcapReached();
hardcapReached = true;
}
}
function directMint(address _to, uint _tokens) public onlyOwnerOrDirectMintAgent {
mintedDirectly = mintedDirectly.add(_tokens);
require(mintedDirectly <= directMintLimit);
mintAndTransfer(_to, _tokens);
}
function refund() public {
require(refundIsAvailable && balances[msg.sender] > 0);
uint value = balances[msg.sender];
balances[msg.sender] = 0;
msg.sender.transfer(value);
}
function withdraw() public onlyOwner {
require(softcapReached);
widthrawDev();
wallet.transfer(this.balance);
}
function widthrawDev() public {
require(softcapReached);
require(msg.sender == devWallet || msg.sender == owner);
if (!devWithdrawn) {
devWithdrawn = true;
devWallet.transfer(devLimit);
}
}
function retrieveTokens(address _to, address _anotherToken) public onlyOwner {
ERC20 alienToken = ERC20(_anotherToken);
alienToken.transfer(_to, alienToken.balanceOf(this));
}
function finish() public onlyOwner {
if (investedWei < softcap) {
RefundIsAvailable();
refundIsAvailable = true;
} else {
withdraw();
}
}
function () external payable {
mint(msg.sender, msg.value);
}
}
contract Configurator is Ownable {
BuildersCoin public token;
Presale public presale;
function deploy() public onlyOwner {
token = new BuildersCoin();
presale = new Presale();
presale.setPrice(1400000000000000000000);
presale.setMinInvestmentLimit(100000000000000000);
presale.setDirectMintLimit(1000000000000000000000000);
presale.setHardcap(357142857000000000000);
presale.setStart(1521543600);
presale.setDuration(30);
presale.setWallet(0x8617f1ba539d45dcefbb18c40141e861abf288b7);
presale.setToken(token);
token.setSaleAgent(presale);
address manager = 0x9DFF939e27e992Ac8635291263c3aa41654f3228;
token.transferOwnership(manager);
presale.transferOwnership(manager);
}
}