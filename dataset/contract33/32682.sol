pragma solidity ^0.4.18;
contract WETH {
event Approval(address indexed src, address indexed guy, uint wad);
event Transfer(address indexed src, address indexed dst, uint wad);
event Deposit(address indexed dst, uint wad);
event Withdraw(address indexed src, uint wad);
mapping (address => uint)                       public  balanceOf;
mapping (address => mapping (address => uint))  public  allowance;
function() public payable {
deposit();
}
function deposit() public payable {
balanceOf[msg.sender] += msg.value;
Deposit(msg.sender, msg.value);
}
function withdraw(uint wad) public {
require(balanceOf[msg.sender] >= wad);
balanceOf[msg.sender] -= wad;
msg.sender.transfer(wad);
Withdraw(msg.sender, wad);
}
function totalSupply() public view returns (uint) {
return this.balance;
}
function approve(address guy, uint wad) public returns (bool) {
allowance[msg.sender][guy] = wad;
Approval(msg.sender, guy, wad);
return true;
}
function transfer(address dst, uint wad) public returns (bool) {
return transferFrom(msg.sender, dst, wad);
}
function transferFrom(
address src, address dst, uint wad
) public returns (bool) {
require(balanceOf[src] >= wad);
if (src != msg.sender && allowance[src][dst] != uint(-1)) {
require(allowance[src][msg.sender] >= wad);
allowance[src][msg.sender] -= wad;
}
balanceOf[src] -= wad;
balanceOf[dst] += wad;
Transfer(src, dst, wad);
return true;
}
}