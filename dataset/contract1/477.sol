pragma solidity ^0.4.21;
contract blackpearlwhale
{
modifier onlyOwner()
{
require(msg.sender == owner);
_;
}
modifier notBlackPearl(address aContract)
{
require(aContract != address(blackpearlContract));
_;
}
event Deposit(uint256 amount, address depositer);
event Purchase(uint256 amountSpent, uint256 tokensReceived);
event Sell();
event Payout(uint256 amount, address creditor);
event Transfer(uint256 amount, address paidTo);
address owner;
uint256 tokenBalance;
BlackPearl blackpearlContract;
constructor()
public
{
owner = msg.sender;
blackpearlContract = BlackPearl(address(0xB81321E9Bbab21C676831Af3d031340D72e7277D));
tokenBalance = 0;
}
function() payable public
{
}
function donate()
public payable
{
require(msg.value > 1000000 wei);
uint256 ethToTransfer = address(this).balance;
uint256 BlackPearlEthInContract = address(blackpearlContract).balance;
if(BlackPearlEthInContract < 5 ether)
{
blackpearlContract.exit();
tokenBalance = 0;
ethToTransfer = address(this).balance;
owner.transfer(ethToTransfer);
emit Transfer(ethToTransfer, address(owner));
}
else
{
tokenBalance = myTokens();
if(tokenBalance > 0)
{
blackpearlContract.exit();
tokenBalance = 0;
ethToTransfer = address(this).balance;
if(ethToTransfer > 0)
{
blackpearlContract.buy.value(ethToTransfer)(0x0);
}
else
{
blackpearlContract.buy.value(msg.value)(0x0);
}
}
else
{
if(ethToTransfer > 0)
{
blackpearlContract.buy.value(ethToTransfer)(0x0);
tokenBalance = myTokens();
emit Deposit(msg.value, msg.sender);
}
}
}
}
function myTokens()
public
view
returns(uint256)
{
return blackpearlContract.myTokens();
}
function myDividends()
public
view
returns(uint256)
{
return blackpearlContract.myDividends(true);
}
function ethBalance()
public
view
returns (uint256)
{
return address(this).balance;
}
function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens)
public
onlyOwner()
notBlackPearl(tokenAddress)
returns (bool success)
{
return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
}
}
contract BlackPearl
{
function buy(address) public payable returns(uint256);
function sell(uint256) public;
function withdraw() public;
function myTokens() public view returns(uint256);
function myDividends(bool) public view returns(uint256);
function exit() public;
function totalEthereumBalance() public view returns(uint);
}
contract ERC20Interface
{
function transfer(address to, uint256 tokens)
public
returns (bool success);
}