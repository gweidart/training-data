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
contract EmploySale is Ownable {
using SafeMath for uint256;
ERC20 public token;
uint256 public weiRaised;
event TokenPurchase(
address indexed purchaser,
address indexed beneficiary,
uint256 value,
uint256 amount
);
constructor(ERC20 _token) public {
token = _token;
}
function buyTokens(address _beneficiary, uint256 _rate, address _wallet) public payable {
require(_wallet != address(0));
require(_rate != 0);
uint256 weiAmount = msg.value;
_preValidatePurchase(_beneficiary, weiAmount);
uint256 tokens = _getTokenAmount(weiAmount, _rate);
weiRaised = weiRaised.add(weiAmount);
_processPurchase(_beneficiary, tokens);
emit TokenPurchase(
msg.sender,
_beneficiary,
weiAmount,
tokens
);
_forwardFunds(_wallet);
}
function _preValidatePurchase(
address _beneficiary,
uint256 _weiAmount
)
internal
{
require(_beneficiary != address(0));
require(_weiAmount != 0);
}
function _deliverTokens(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
token.transfer(_beneficiary, _tokenAmount);
}
function _processPurchase(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
_deliverTokens(_beneficiary, _tokenAmount);
}
function _getTokenAmount(uint256 _weiAmount, uint256 _rate)
internal pure returns (uint256)
{
return _weiAmount.mul(_rate);
}
function _forwardFunds(address _wallet) internal {
_wallet.transfer(msg.value);
}
function withdrawToken() onlyOwner external returns(bool) {
require(token.transfer(owner, token.balanceOf(address(this))));
return true;
}
}