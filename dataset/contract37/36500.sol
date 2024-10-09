pragma solidity ^0.4.15;
contract Token {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else { return false; }
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
}
contract SnipCoin is StandardToken {
string public tokenName;
uint public decimals;
string public tokenSymbol;
uint public totalEthReceivedInWei;
uint public totalUsdReceived;
string public version = "1.0";
address public saleWalletAddress;
address public ownerAddress;
uint private constant DECIMALS_MULTIPLIER = 1000000000000000000;
uint private constant WEI_IN_ETHER = 1000 * 1000 * 1000 * 1000 * 1000 * 1000;
uint private constant WEI_TO_USD_EXCHANGE_RATE = WEI_IN_ETHER / 255;
function initializeSaleWalletAddress()
{
saleWalletAddress = 0x686f152dad6490df93b267e319f875a684bd26e2;
}
function initializeEthReceived()
{
totalEthReceivedInWei = 14500 * WEI_IN_ETHER;
}
function initializeUsdReceived()
{
totalUsdReceived = 4000000;
}
function getBalance(address addr) returns(uint)
{
return balances[addr];
}
function SnipCoin()
{
initializeSaleWalletAddress();
initializeEthReceived();
initializeUsdReceived();
totalSupply = 10000000000;
balances[msg.sender] = totalSupply * DECIMALS_MULTIPLIER;
tokenName = "SnipCoin";
decimals = 18;
tokenSymbol = "SNP";
}
function sendCoin(address receiver, uint amount) returns(bool sufficient)
{
if (balances[msg.sender] < amount) return false;
balances[msg.sender] -= amount;
balances[receiver] += amount;
Transfer(msg.sender, receiver, amount);
return true;
}
function () payable
{
if (!saleWalletAddress.send(msg.value)) revert();
totalEthReceivedInWei = totalEthReceivedInWei + msg.value;
totalUsdReceived = totalUsdReceived + msg.value / WEI_TO_USD_EXCHANGE_RATE;
}
}