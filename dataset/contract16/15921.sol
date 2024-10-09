pragma solidity ^0.4.21;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address _who) public view returns (uint256);
function transfer(address _to, uint256 _value) public returns (bool);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
contract ERC20 is ERC20Basic {
function allowance(address _owner, address _spender) public view returns (uint256);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
function approve(address _spender, uint256 _value) public returns (bool);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract TeamFund is Ownable {
ERC20Basic public vnetToken;
string public description;
event Donate(address indexed _from, uint256 _amount);
constructor(ERC20Basic _token) public {
vnetToken = _token;
description = "Balance is locked by the VNETToken contract until 2021-6-30 23:59:59 UTC +0";
}
function () public payable {
emit Donate(msg.sender, msg.value);
}
function withdrawVNET(address _to, uint256 _amount) external onlyOwner {
assert(vnetToken.transfer(_to, _amount));
}
function rescueTokens(ERC20Basic _token) external onlyOwner {
uint256 balance = _token.balanceOf(this);
assert(_token.transfer(owner, balance));
}
function withdrawEther() external onlyOwner {
owner.transfer(address(this).balance);
}
}