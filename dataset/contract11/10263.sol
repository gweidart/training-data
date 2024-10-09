pragma solidity ^0.4.23;
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
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
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
contract BurnableERC20 is ERC20 {
function burn(uint256 amount) public returns (bool burned);
}
contract NokuTokenBurner is Pausable {
using SafeMath for uint256;
event LogNokuTokenBurnerCreated(address indexed caller, address indexed wallet);
event LogBurningPercentageChanged(address indexed caller, uint256 indexed burningPercentage);
address public wallet;
uint256 public burningPercentage;
uint256 public burnedTokens;
uint256 public transferredTokens;
constructor(address _wallet) public {
require(_wallet != address(0), "_wallet is zero");
wallet = _wallet;
burningPercentage = 100;
emit LogNokuTokenBurnerCreated(msg.sender, _wallet);
}
function setBurningPercentage(uint256 _burningPercentage) public onlyOwner {
require(0 <= _burningPercentage && _burningPercentage <= 100, "_burningPercentage not in [0, 100]");
require(_burningPercentage != burningPercentage, "_burningPercentage equal to current one");
burningPercentage = _burningPercentage;
emit LogBurningPercentageChanged(msg.sender, _burningPercentage);
}
function tokenReceived(address _token, uint256 _amount) public whenNotPaused {
require(_token != address(0), "_token is zero");
require(_amount > 0, "_amount is zero");
uint256 amountToBurn = _amount.mul(burningPercentage).div(100);
if (amountToBurn > 0) {
assert(BurnableERC20(_token).burn(amountToBurn));
burnedTokens = burnedTokens.add(amountToBurn);
}
uint256 amountToTransfer = _amount.sub(amountToBurn);
if (amountToTransfer > 0) {
assert(BurnableERC20(_token).transfer(wallet, amountToTransfer));
transferredTokens = transferredTokens.add(amountToTransfer);
}
}
}