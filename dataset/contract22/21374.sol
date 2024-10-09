pragma solidity ^0.4.18;
contract ERC20Interface {
function name() public constant returns (string);
function symbol() public constant returns (string);
function decimals() public constant returns (uint);
function totalSupply() public constant returns (uint256);
function balanceOf(address _owner) public constant returns (uint256);
function transfer(address _to, uint256 _value) public returns (bool);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
function approve(address _spender, uint256 _value) public returns (bool);
function allowance(address _owner, address _spender) public constant returns (uint256);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract Owned {
address owner;
bool isLock = true;
mapping(address => bool) whitelisted;
function Owned() public {
owner = msg.sender;
whitelisted[owner] = true;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier isUnlock () {
if (isLock){
require(whitelisted[msg.sender] == true);
}
_;
}
function addWhitelist(address _white) public onlyOwner {
whitelisted[_white] = true;
}
function removeWhitelist(address _white) public onlyOwner {
whitelisted[_white] = false;
}
function checkWhitelist(address _addr) public view returns (bool) {
return whitelisted[_addr];
}
function unlockToken() public onlyOwner returns (bool) {
isLock = false;
return isLock;
}
}
contract Utils {
function Utils() public {
}
modifier validAddress(address _address) {
require(_address != 0x0);
_;
}
function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {
uint256 z = _x + _y;
require(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
require(_x >= _y);
return _x - _y;
}
}
contract Moviecoin is ERC20Interface, Owned, Utils {
string name_ = 'Dayibi';
string  symbol_ = 'DYB';
uint8 decimals_ = 8;
uint256 totalSupply_ = 10 ** 18;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function Moviecoin() public {
balances[msg.sender] = totalSupply_;
Transfer(0x0, msg.sender, totalSupply_);
}
function name() public constant returns (string){
return name_;
}
function setName(string _name) public onlyOwner {
name_ = _name;
}
function symbol() public constant returns (string){
return symbol_;
}
function setSymbol(string _symbol) public onlyOwner {
symbol_ = _symbol;
}
function decimals() public constant returns (uint){
return decimals_;
}
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function balanceOf(address _owner) public constant returns (uint256) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public isUnlock returns (bool) {
require(_value <= balances[msg.sender]);
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public isUnlock returns (bool) {
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = safeSub(balances[_from], _value);
balances[_to] = safeAdd(balances[_to], _value);
allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public isUnlock validAddress(_spender) returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function () public payable {
revert();
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
}