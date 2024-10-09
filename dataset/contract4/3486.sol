pragma solidity ^0.4.18;
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
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract CSCToken is Ownable, ERC20Basic {
using SafeMath for uint256;
string public constant name     = "Crypto Service Capital Token";
string public constant symbol   = "CSCT";
uint8  public constant decimals = 18;
bool public mintingFinished = false;
mapping(address => uint256) public balances;
address[] public holders;
event Mint(address indexed to, uint256 amount);
event MintFinished();
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
if (balances[_to] == 0) {
holders.push(_to);
}
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
function transfer(address, uint256) public returns (bool) {
revert();
return false;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
modifier canMint() {
require(!mintingFinished);
_;
}
}