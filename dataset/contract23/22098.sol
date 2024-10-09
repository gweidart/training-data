pragma solidity ^0.4.18;
contract ERC20TokenCPN
{
string public constant name = "STAR COUPON";
string public constant symbol = "CPN";
uint8 public constant decimals = 0;
uint internal amount;
struct agent
{
uint balance;
mapping (address => uint) allowed;
}
mapping (address => agent) internal agents;