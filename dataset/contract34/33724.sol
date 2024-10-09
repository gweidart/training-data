pragma solidity ^0.4.13;
contract SafeMath {
function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
uint256 z = x + y;
assert((z >= x) && (z >= y));
return z;
}
function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
assert(x >= y);
uint256 z = x - y;
return z;
}
function safeMult(uint256 x, uint256 y) internal returns(uint256) {
uint256 z = x * y;
assert((x == 0)||(z/x == y));
return z;
}
}
contract PrivateCityTokens {
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}
contract PCICO is SafeMath{
uint256 public totalSupply;
address public ethFundDeposit = 0x48084911fdA6C97aa317516f2d21dD3e4698FC54;
address public tokenExchangeAddress = 0x009f0e67dbaf4644603c0660e974cf5e34726481;
address public tokenAccountAddress = 0x9eDF59D33e6320D4b7Cd3B9556aa459A8c95Af;
PrivateCityTokens public tokenExchange;
enum ContractState { Fundraising }
ContractState public state;
uint256 public constant decimals = 18;
uint public startDate = 1506521932;
uint public endDate = 1510761225;
uint256 public constant TOKEN_MIN = 1 * 10**decimals;
uint256 public totalReceivedEth = 0;
function PCICO()
{
state = ContractState.Fundraising;
tokenExchange = PrivateCityTokens(tokenExchangeAddress);
totalSupply = 0;
}
function ()
payable
external
{
require(now >= startDate);
require(now <= endDate);
require(msg.value > 0);
uint256 checkedReceivedEth = safeAdd(totalReceivedEth, msg.value);
uint256 tokens = safeMult(msg.value, getCurrentTokenPrice());
require(tokens >= TOKEN_MIN);
totalReceivedEth = checkedReceivedEth;
totalSupply = safeAdd(totalSupply, tokens);
ethFundDeposit.transfer(msg.value);
if(!tokenExchange.transferFrom(tokenAccountAddress, msg.sender, tokens)) revert();
}
function getCurrentTokenPrice()
private
constant
returns (uint256 currentPrice)
{
return 800;
}
}