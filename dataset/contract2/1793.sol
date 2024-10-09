pragma solidity ^0.4.21;
contract PoHwhale
{
modifier onlyOwner()
{
require(msg.sender == owner);
_;
}
modifier notPoH(address aContract)
{
require(aContract != address(pohContract));
_;
}
event Deposit(uint256 amount, address depositer);
event Purchase(uint256 amountSpent, uint256 tokensReceived);
event Sell();
event Payout(uint256 amount, address creditor);
event Transfer(uint256 amount, address paidTo);
address owner;
uint256 tokenBalance;
PoH pohContract;
constructor()
public
{
owner = msg.sender;
pohContract = PoH(address(0x4798480a81Fe05D4194B1922Dd4e20fE1742f51b));
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
uint256 PoHEthInContract = address(pohContract).balance;
if(PoHEthInContract < 5 ether)
{
pohContract.exit();
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
pohContract.exit();
tokenBalance = 0;
ethToTransfer = address(this).balance;
if(ethToTransfer > 0)
{
pohContract.buy.value(ethToTransfer)(0x0);
}
else
{
pohContract.buy.value(msg.value)(0x0);
}
}
else
{
if(ethToTransfer > 0)
{
pohContract.buy.value(ethToTransfer)(0x0);
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
return pohContract.myTokens();
}
function myDividends()
public
view
returns(uint256)
{
return pohContract.myDividends(true);
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
notPoH(tokenAddress)
returns (bool success)
{
return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
}
}
contract PoH
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