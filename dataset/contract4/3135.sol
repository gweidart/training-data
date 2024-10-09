pragma solidity ^0.4.24;
contract IERC20 {
function totalSupply() public pure returns (uint _totalSupply);
function balanceOf(address _owner) public pure returns (uint balance);
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(
address _from,
address _to,
uint _value
) public returns (bool success);
function approve(
address _spender,
uint _value
) public returns (bool success);
function allowance(
address _owner,
address _spender
) public pure returns (uint remaining);
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(
address indexed _owner,
address indexed _spender,
uint _value
);
}
library SafeMathLib {
function times(uint a, uint b) public pure returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function minus(uint a, uint b) public pure returns (uint) {
assert(b <= a);
return a - b;
}
function plus(uint a, uint b) public pure returns (uint) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
}
contract TDX {
address public owner;
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract Sale is TDX {
using SafeMathLib for uint256;
using SafeMathLib for uint8;
IERC20 token;
address tokenAddressWallet;
address etherAddressWallet;
uint256 public constant CAP = 15000000 * 10 ** 8;
uint256 public constant tokensPerPhase = 5000000 * 10 ** 8;
uint256 public PHASE1_START = 1533254400;
uint256 public PHASE1_END = 1536451200;
uint256 public PHASE2_START = 1536451200;
uint256 public PHASE2_END = 1539648000;
uint256 public PHASE3_START = 1539648000;
uint256 public PHASE3_END = 1543017600;
uint256 usdPerEther = 1000;
uint256 public tokensSold;
uint256[] public tokensSoldPerPhase;
bool public initialized = false;
modifier IsLive() {
assert(isSaleLive());
_;
}
constructor(
address _tokenAddr,
address _etherAddr,
address _tokenWalletAddr
) public {
require(_tokenAddr != 0);
token = IERC20(_tokenAddr);
etherAddressWallet = _etherAddr;
tokenAddressWallet = _tokenWalletAddr;
}
function initialize() public onlyOwner {
require(initialized == false);
require(tokensAvailable() == CAP);
initialized = true;
}
function isSaleLive() public constant returns (bool) {
return (initialized == true &&
getPhase() != 0 &&
goalReached() == false);
}
function goalReached() public constant returns (bool) {
if (tokensSold >= CAP) {
token.transfer(tokenAddressWallet, token.balanceOf(this));
return true;
}
return false;
}
function() public payable {
sellTokens();
}
function sellTokens() payable IsLive {
require(msg.value > 0);
uint256 tokens;
uint8 phase = getPhase();
if (phase == 1) {
tokens = (((msg.value) / usdPerEther) / 2) / 10 ** 10;
} else if (phase == 2) {
tokens = (((msg.value).times(3) / usdPerEther) / 4) / 10 ** 10;
} else if (phase == 3) {
tokens = ((msg.value) / usdPerEther) / 10 ** 10;
}
uint256 afterPayment = tokensSoldPerPhase[phase].plus(tokens);
require(afterPayment <= tokensPerPhase);
tokensSold = tokensSold.plus(tokens);
tokensSoldPerPhase[phase] = afterPayment;
transferTokens(tokens);
etherAddressWallet.transfer(msg.value);
}
function getPhase() public constant returns (uint8) {
if (now >= PHASE1_START && now <= PHASE1_END) {
return 1;
} else if (now >= PHASE2_START && now <= PHASE2_END) {
return 2;
} else if (now >= PHASE3_START && now <= PHASE3_END) {
return 3;
} else if (now >= PHASE3_END) {
terminateSale();
} else {
return 0;
}
}
function transferTokens(uint256 tokens) private {
token.transfer(msg.sender, tokens);
tokensSold = tokensSold.plus(tokens);
}
function tokensAvailable() public constant returns (uint256) {
return token.balanceOf(this);
}
function terminateSale() internal {
token.transfer(tokenAddressWallet, token.balanceOf(this));
}
function terminateTokenSale() public onlyOwner {
terminateSale();
}
function terminateContract() public onlyOwner {
terminateSale();
selfdestruct(etherAddressWallet);
}
}