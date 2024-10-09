pragma solidity 0.4.24;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
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
contract BountyVault is Ownable {
using SafeMath for uint256;
ERC20 public token_call;
ERC20 public token_callg;
event BountyWithdrawn(address indexed bountyWallet, uint256 token_call, uint256 token_callg);
constructor (ERC20 _token_call, ERC20 _token_callg) public {
require(_token_call != address(0));
require(_token_callg != address(0));
token_call = _token_call;
token_callg = _token_callg;
}
function () public payable {
}
function withdrawBounty(address bountyWallet) public onlyOwner {
require(bountyWallet != address(0));
uint call_balance = token_call.balanceOf(this);
uint callg_balance = token_callg.balanceOf(this);
token_call.transfer(bountyWallet, call_balance);
token_callg.transfer(bountyWallet, callg_balance);
emit BountyWithdrawn(bountyWallet, call_balance, callg_balance);
}
}