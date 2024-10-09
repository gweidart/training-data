pragma solidity ^0.4.8;
contract ERC721 {
function implementsERC721() public pure returns (bool);
function totalSupply() public view returns (uint256 total);
function balanceOf(address _owner) public view returns (uint256 balance);
function approve(address _to, uint256 _tokenId) public returns(bool success);
function transferFrom(address _from, address _to, uint256 _tokenId) public returns(bool success);
function transfer(address _to, uint256 _tokenId) public returns(bool success);
event Transfer(address indexed from, address indexed to, uint256 amount);
event Approval(address indexed owner, address indexed approved, uint256 amount);
}
contract SingleTransferToken is ERC721 {
string public symbol = "STT";
string public name = "SingleTransferToken";
uint256 _totalSupply = 1;
uint256 currentPrice;
uint256 sellingPrice;
uint256 stepLimit = 1 ether;
event Transfer(address indexed from, address indexed to, uint256 amount);
address owner;
address public tokenOwner;
address allowedTo = address(0);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlySingle(uint256 amount){
require(amount == 1);
_;
}
function implementsERC721() public pure returns (bool)
{
return true;
}
function SingleTransferToken(string tokenName, string tokenSymbol, uint256 initialPrice, uint256 sLimit) public{
name = tokenName;
symbol = tokenSymbol;
owner = msg.sender;
tokenOwner = msg.sender;
stepLimit = sLimit;
sellingPrice = initialPrice;
currentPrice = initialPrice;
}
function totalSupply() constant public returns (uint256 total) {
total = _totalSupply;
}
function balanceOf(address _owner) constant public returns (uint256 balance) {
return _owner == tokenOwner ? 1 : 0;
}
function transfer(address _to, uint256 _amount) onlySingle(_amount) public returns (bool success) {
if(balanceOf(msg.sender) > 0){
tokenOwner = _to;
Transfer(msg.sender, _to, _amount);
success = true;
}else {
success = false;
}
}
function transferFrom(
address _from,
address _to,
uint256 _amount
) onlySingle(_amount) public returns (bool success) {
require(balanceOf(_from) > 0 && allowedTo == _to);
tokenOwner = _to;
Transfer(_from, _to, _amount);
success = true;
}
function approve(address _spender, uint256 _amount) public onlySingle(_amount) returns (bool success) {
require(tokenOwner == msg.sender);
allowedTo = _spender;
Approval(msg.sender, _spender, _amount);
success = true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return _owner == tokenOwner && allowedTo == _spender? 1 : 0;
}
function() public payable {
assert(tokenOwner != msg.sender);
assert(msg.value >= sellingPrice);
if(msg.value > sellingPrice){
msg.sender.transfer(msg.value - sellingPrice);
}
currentPrice = sellingPrice;
if(currentPrice >= stepLimit){
sellingPrice = (currentPrice * 120)/94;
}else{
sellingPrice = (currentPrice * 2 * 100)/94;
}
transferToken(tokenOwner, msg.sender);
}
function transferToken(address prevOwner, address newOwner) internal {
prevOwner.transfer((currentPrice*94)/100);
tokenOwner = newOwner;
Transfer(prevOwner, newOwner, 1);
}
function payout(address _to) onlyOwner public{
if(this.balance > 1 ether){
if(_to == address(0)){
owner.transfer(this.balance - 1 ether);
}else{
_to.transfer(this.balance - 1 ether);
}
}
}
}