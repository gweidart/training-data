pragma solidity 0.4.24;
contract owned {
address public owner;
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
owner = newOwner;
}
}
contract TokenERC20 is owned {
address public deployer;
string public name = "CALL IN";
string public symbol = "CIC";
uint8 public decimals = 4;
uint256 public totalSupply;
mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;
event Approval(address indexed owner, address indexed spender, uint value);
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
constructor() public {
deployer = msg.sender;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(
address _from,
address _to,
uint256 _value
) public returns (bool success) {
require(allowance[_from][msg.sender] >= _value);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(
address _spender,
uint256 _value
) public returns (bool success) {
allowance[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function burn(uint256 _value) public onlyOwner returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
emit Burn(msg.sender, _value);
return true;
}
}
contract MyAdvancedToken is TokenERC20 {
mapping(address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
constructor() public TokenERC20() {}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
}
function mintToken(address target, uint256 mintedAmount) public onlyOwner {
uint tempSupply = totalSupply;
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
require(totalSupply >= tempSupply);
emit Transfer(0, this, mintedAmount);
emit Transfer(this, target, mintedAmount);
}
function freezeAccount(address target, bool freeze) public onlyOwner {
frozenAccount[target] = freeze;
emit FrozenFunds(target, freeze);
}
function() public payable {
require(false);
}
}
contract CIC is MyAdvancedToken {
mapping(address => uint) public lockdate;
mapping(address => uint) public lockTokenBalance;
event LockToken(address account, uint amount, uint unixtime);
constructor() public MyAdvancedToken() {}
function getLockBalance(address account) internal returns (uint) {
if (now >= lockdate[account]) {
lockdate[account] = 0;
lockTokenBalance[account] = 0;
}
return lockTokenBalance[account];
}
function _transfer(address _from, address _to, uint _value) internal {
uint usableBalance = balanceOf[_from] - getLockBalance(_from);
require(balanceOf[_from] >= usableBalance);
require(_to != 0x0);
require(usableBalance >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
}
function lockTokenToDate(
address account,
uint amount,
uint unixtime
) public onlyOwner {
require(unixtime >= lockdate[account]);
require(unixtime >= now);
if (balanceOf[account] >= amount) {
lockdate[account] = unixtime;
lockTokenBalance[account] = amount;
emit LockToken(account, amount, unixtime);
}
}
function lockTokenDays(address account, uint amount, uint _days) public {
uint unixtime = _days * 1 days + now;
lockTokenToDate(account, amount, unixtime);
}
function burn(uint256 _value) public onlyOwner returns (bool success) {
uint usableBalance = balanceOf[msg.sender] - getLockBalance(msg.sender);
require(balanceOf[msg.sender] >= usableBalance);
require(usableBalance >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
emit Burn(msg.sender, _value);
return true;
}
}