pragma solidity 0.4.18;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) view public returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) view public returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
bool public freezeTransferToken = false;
modifier onlyPayloadSize(uint size) {
assert(msg.data.length >= size + 4);
_;
}
modifier canTransfer() {
require(!freezeTransferToken);
_;
}
function transfer(address _to, uint256 _value)canTransfer onlyPayloadSize(2 * 32) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) view public returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value)canTransfer public returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() public{
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public{
require(newOwner != address(0));
owner = newOwner;
}
}
contract BurnableToken is StandardToken {
function burn(uint _value) public {
require(_value > 0);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
event Burn(address indexed burner, uint indexed value);
}
contract Switch is BurnableToken, Ownable {
using SafeMath for uint;
address public walletFromTeam;
address public walletForBounty;
address public walletForCommunity;
address public walletForPresale;
uint public percentForBounty;
uint public percentForTeam;
uint public percentForCommunity;
string public constant name = "Switch";
string public constant symbol = "SWI";
uint32 public constant decimals = 18;
uint256 public INITIAL_TOKEN_FROM_COMPAIN = 1200000000*1 ether;
uint public tokenForTeam;
uint public tokenForBounty;
uint public tokenForComunity;
function Switch()public{
walletFromTeam = 0xe49ab1399d63DD2A9eb4805d62EC40B0aBB6f6Ab;
walletForBounty = 0xf60302a485E34873238098FF33E840B7DaD83854;
walletForCommunity = 0xFf5A48d893E1EaF9Ea128aA3d4b5AfE2b6282Cb1;
walletForPresale = 0xEAD962f2788e4Cef655b88A8E5a56fdAa8993895;
percentForTeam = 35;
percentForBounty = 5;
percentForCommunity =5;
totalSupply = INITIAL_TOKEN_FROM_COMPAIN;
tokenForTeam = INITIAL_TOKEN_FROM_COMPAIN.mul(percentForTeam).div(100);
balances[walletFromTeam] = tokenForTeam;
transferFrom(this,walletFromTeam, 0);
tokenForComunity = INITIAL_TOKEN_FROM_COMPAIN.mul(percentForCommunity).div(100);
balances[walletForCommunity] = tokenForComunity;
transferFrom(this,walletForCommunity, 0);
tokenForBounty = INITIAL_TOKEN_FROM_COMPAIN.mul(percentForBounty).div(100);
balances[walletForBounty] = tokenForBounty;
transferFrom(this,walletForBounty, 0);
uint tokenForAirdrop;
tokenForAirdrop = INITIAL_TOKEN_FROM_COMPAIN.mul(55).div(100);
balances[walletForPresale] = tokenForAirdrop;
transferFrom(this,walletForPresale, 0);
}
function freezeTransfer()onlyOwner public{
freezeTransferToken = true;
}
function unFreezeTransfer()onlyOwner public{
freezeTransferToken = false;
}
}