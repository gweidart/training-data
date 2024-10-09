library SafeMath {
function mul(uint256 a, uint256 b) constant public returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) constant public returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) constant public returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) constant public returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
if(msg.sender == owner){
_;
}
else{
revert();
}
}
function transferOwnership(address newOwner) onlyOwner public{
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant public returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant public returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
function balanceOf(address _owner) constant public returns (uint256 balance) {
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
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
if(!mintingFinished){
_;
}
else{
revert();
}
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function finishMinting() onlyOwner public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract CoinI{
uint256 public totalSupply ;
}
contract IcoI{
function getAllTimes() public constant returns(uint256,uint256,uint256);
function getCabCoinsAmount()  public constant returns(uint256);
uint256 public minimumGoal;
}
contract StatsContract is Ownable{
CoinI public coin;
IcoI  public ico;
address public dev;
function setAddresses(address devA,address coinA, address icoA) onlyOwner public{
ico = IcoI(icoA);
dev = devA;
coin = CoinI(coinA);
}
function getStats() constant returns (address,address,uint256,uint256,uint256,uint256,uint256,uint256){
address[2] memory adr;
adr[0] =  address(coin);
adr[1] = address(ico);
var (toStart,toEndPhase,toEndAll) = ico.getAllTimes();
var amountSold = coin.totalSupply()/(10**18);
var maxSupply = ico.minimumGoal()/(10**18);
var ethRised = (adr[1].balance + dev.balance)/(10**15);
return (adr[0], adr[1], toStart, toEndPhase, toEndAll, amountSold, maxSupply, ethRised);
}
}