pragma solidity ^0.4.19;
library SafeMath {
function safeMul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function safeSub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
}
contract ERC20Interface
{
function balanceOf(address tokenOwner) public constant returns (uint256 balance);
function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
function transfer(address to, uint256 tokens) public returns (bool success);
}
contract RewardContract
{
using SafeMath for uint256;
address public owner;
address public thisAddress;
address TokenContractAddress;
ERC20Interface TokenContract;
uint256 public TokenTotal;
uint256 public CLAIM_INTERVAL_DAYS;
uint    public NumberAddresses;
address public firstAddress;
address public recently_added_address;
uint    public timestamp_contract_start;
string  public debug1;
string  public debug2;
string  public debug3;
address public debug4;
uint256 public debug_wei;
struct Account
{
uint256 id;
uint256 amount_eth;
uint256 amount_token;
address prev_address;
uint256 last_claimed_day;
}
mapping(address => Account) public AccountStructs;
function RewardContract () public
{
owner                    = msg.sender;
timestamp_contract_start = now;
TokenContractAddress     = 0x26B1FBE292502da2C8fCdcCF9426304d0900b703;
CLAIM_INTERVAL_DAYS      = 2;
TokenContract            = ERC20Interface(TokenContractAddress);
NumberAddresses          = 0;
thisAddress              = address(this);
}
function percent(uint numerator, uint denominator, uint precision) public
constant returns(uint quotient) {
uint _numerator  = numerator * 10 ** (precision+1);
uint _quotient =  ((_numerator / denominator) + 5) / 10;
return ( _quotient);
}
function calc_wei_rewards( uint256 amountToken, uint256 TokenTotal, uint256 weiTotal ) public constant returns (uint256)
{
uint256 wei_reward = 0;
uint precision = 18;
uint faktor = 10 ** precision;
uint percent_big = percent(amountToken, TokenTotal, precision);
wei_reward = weiTotal * percent_big;
wei_reward = wei_reward / faktor;
return(wei_reward);
}
function claim_eth_by_address() public returns (bool)
{
bool ret;
uint256 wei_rewards;
if ( is_claim_period( now ) == true )
{
uint seconds_since_start = now - timestamp_contract_start;
uint days_since_start    = seconds_since_start / 86400;
if (AccountStructs[msg.sender].last_claimed_day != days_since_start)
{
wei_rewards = calc_wei_rewards( AccountStructs[msg.sender].amount_token, TokenTotal, this.balance );
debug_wei = wei_rewards;
AccountStructs[msg.sender].last_claimed_day = days_since_start;
AccountStructs[msg.sender].amount_eth = AccountStructs[msg.sender].amount_eth.safeAdd( wei_rewards ) ;
ret = true;
}
}
return(ret);
}
function confirm_token_deposit() public returns (bool)
{
bool    ret          = false;
uint256 amount_token = 0;
if ( is_claim_period( now ) == false )
{
if ( AccountStructs[msg.sender].id <= 0 )
{
NumberAddresses++;
if (NumberAddresses == 1) firstAddress  = msg.sender;
AccountStructs[msg.sender].id           = NumberAddresses;
AccountStructs[msg.sender].prev_address = recently_added_address;
recently_added_address                  = msg.sender;
}
amount_token = TokenContract.allowance( msg.sender, thisAddress );
TokenContract.transfer(thisAddress, amount_token);
if (amount_token > 0)
{
TokenTotal = TokenTotal.safeAdd(amount_token);
AccountStructs[msg.sender].amount_token = AccountStructs[msg.sender].amount_token.safeAdd( amount_token ) ;
ret = true;
}
}
else
{
revert();
}
return(ret);
}
function get_account_id( address _address ) public constant returns (uint256)
{
uint256 ret = AccountStructs[_address].id;
return (ret);
}
function get_account_balance_eth( address _address ) public constant returns (uint256)
{
uint256 ret = AccountStructs[_address].amount_eth;
return (ret);
}
function get_account_balance_token( address _address ) public constant returns (uint256)
{
uint256 ret = AccountStructs[_address].amount_token;
return (ret);
}
function () payable public
{
if ( is_claim_period( now ) == false )
{
}
else
{
revert();
}
}
function withdraw_token_and_eth() public returns (bool)
{
bool ret = false;
if ( is_claim_period( now ) == false )
{
uint amount_token = AccountStructs[msg.sender].amount_token;
uint amount_eth   = AccountStructs[msg.sender].amount_eth;
AccountStructs[msg.sender].amount_token = 0;
AccountStructs[msg.sender].amount_eth   = 0;
TokenTotal = TokenTotal.safeSub( amount_token );
TokenContract.transfer(msg.sender, amount_token );
msg.sender.transfer(amount_eth);
ret = true;
}
return (ret);
}
function is_claim_period( uint timestamp_to_check ) public constant returns (bool)
{
bool check = false;
uint seconds_since_start = timestamp_to_check - timestamp_contract_start;
uint days_since_start    = seconds_since_start / 86400;
if ( ( days_since_start % CLAIM_INTERVAL_DAYS ) == 0) check = true;
return( check );
}
function kill () public
{
if (msg.sender != owner) return;
uint256 balance = TokenContract.balanceOf(this);
assert(balance > 0);
TokenContract.transfer(owner, balance);
owner.transfer( this.balance );
selfdestruct(owner);
}
}