pragma solidity ^0.4.18;
library SafeMath {
function add(uint a, uint b) internal pure returns (uint c) {
c = a + b;
require(c >= a);
}
function sub(uint a, uint b) internal pure returns (uint c) {
require(b <= a);
c = a - b;
}
function mul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function div(uint a, uint b) internal pure returns (uint c) {
require(b > 0);
c = a / b;
}
}
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract Contract {
bytes32 public Name;
constructor(bytes32 _contractName) public {
Name = _contractName;
}
function() public payable { }
}
contract DeaultERC20 is ERC20Interface, Owned {
using SafeMath for uint;
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
constructor() public {
symbol = "DFLT";
name = "Default";
decimals = 18;
}
function totalSupply() public constant returns (uint) {
return _totalSupply  - balances[address(0)];
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
return true;
}
function () public payable {
revert();
}
}
contract IGCoin is DeaultERC20 {
using SafeMath for uint;
address public reserveAddress;
uint256 public ask;
uint256 public bid;
uint16 public constant reserveRate = 10;
bool public initialSaleComplete;
uint256 constant private ICOAmount = 2e6*1e18;
uint256 constant private ICOask = 1*1e18;
uint256 constant private ICObid = 0;
uint256 constant private InitialSupply = 1e6 * 1e18;
uint256 public debugVal;
uint256 public debugVal2;
uint256 public debugVal3;
uint256 public debugVal4;
uint256 constant private R = 12500000;
uint256 constant private P = 50;
uint256 constant private lnR = 12500001;
uint256 constant private S = 1e8;
uint256 constant private RS = 8;
uint256 constant private lnS = 18;
uint256 private constant ONE = 1;
uint32 private constant MAX_WETokenHT = 1000000;
uint8 private constant MIN_PRECISION = 32;
uint8 private constant MAX_PRECISION = 127;
uint256 private constant FIXED_1 = 0x080000000000000000000000000000000;
uint256 private constant FIXED_2 = 0x100000000000000000000000000000000;
uint256 private constant MAX_NUM = 0x1ffffffffffffffffffffffffffffffff;
uint256 private constant FIXED_3 = 0x07fffffffffffffffffffffffffffffff;
uint256 private constant LN2_MANTISSA = 0x2c5c85fdf473de6af278ece600fcbda;
uint8   private constant LN2_EXPONENT = 122;
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
constructor() public {
symbol = "IG17";
name = "theTestToken001";
decimals = 18;
initialSaleComplete = false;
_totalSupply = InitialSupply;
balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
reserveAddress = new Contract("Reserve");
quoteAsk();
quoteBid();
}
function deposit(uint256 _value) private {
reserveAddress.transfer(_value);
balances[reserveAddress] += _value;
}
function withdraw(uint256 _value) private pure {
_value = _value;
}
function transfer(address _to, uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]);
require(_value > 0);
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
function freezeAccount(address _target, bool _freeze) public onlyOwner {
frozenAccount[_target] = _freeze;
emit FrozenFunds(_target, _freeze);
}
function quoteAsk() public returns (uint256) {
if(initialSaleComplete)
{
ask = fracExp(1e18, R, (_totalSupply/1e18)+1, P);
}
else
{
ask = ICOask;
}
return ask;
}
function quoteBid() public returns (uint256) {
if(initialSaleComplete)
{
bid = fracExp(1e18, R, (_totalSupply/1e18)-1, P);
}
else
{
bid = ICObid;
}
return bid;
}
function buy() public payable returns (uint256 amount){
uint256 refund = 0;
debugVal = 0;
if(initialSaleComplete)
{
uint256 units_to_buy = 0;
uint256 etherRemaining = msg.value;
uint256 etherToReserve = 0;
debugVal = fracExp(S, R, (_totalSupply/1e18),P);
debugVal2 = RS*msg.value;
debugVal3 = RS*msg.value/1e18 + fracExp(S, R, (_totalSupply/1e18),P);