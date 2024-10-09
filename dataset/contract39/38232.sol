pragma solidity ^0.4.13;
contract ERC20 {
function totalSupply() constant returns (uint totalSupply);
function balanceOf(address _owner) constant returns (uint balance);
function transfer(address _to, uint _value) returns (bool success);
function transferFrom(address _from, address _to, uint _value) returns (bool success);
function approve(address _spender, uint _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint remaining);
}
contract IERC20Token {
function name() public constant returns (string name) { name; }
function symbol() public constant returns (string symbol) { symbol; }
function decimals() public constant returns (uint8 decimals) { decimals; }
function totalSupply() public constant returns (uint256 totalSupply) { totalSupply; }
function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
}
contract ITokenChanger {
function changeableTokenCount() public constant returns (uint16 count);
function changeableToken(uint16 _tokenIndex) public constant returns (address tokenAddress);
function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public constant returns (uint256 amount);
function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 amount);
}
contract IOwned {
function owner() public constant returns (address owner) { owner; }
function transferOwnership(address _newOwner) public;
function acceptOwnership() public;
}
contract ITokenHolder is IOwned {
function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}
contract ISmartToken is ITokenHolder, IERC20Token {
function disableTransfers(bool _disable) public;
function issue(address _to, uint256 _amount) public;
function destroy(address _from, uint256 _amount) public;
}
contract IBancorChanger is ITokenChanger {
function token() public constant returns (ISmartToken _token) { _token; }
function getReserveBalance(IERC20Token _reserveToken) public constant returns (uint256 balance);
}
contract IEtherToken is ITokenHolder, IERC20Token {
function deposit() public payable;
function withdraw(uint256 _amount) public;
}
contract MarginBanc {
address public owner;
IBancorChanger public tokenChanger;
IEtherToken public etherToken;
ERC20  public  bnt;
ISmartToken public smartToken;
struct position {
uint openTime;
uint closeTime;
uint256 amountETH;
uint256 amountBNT;
}
mapping (address => uint256) public positions;
event LongClosed(address indexed by, uint256 amount);
function MarginBanc() {
owner = msg.sender;
tokenChanger = IBancorChanger(0xCA83bD8c4C7B1c0409B25FbD7e70B1ef57629fF4);
etherToken =  IEtherToken(0xD76b5c2A23ef78368d8E34288B5b65D616B746aE);
bnt = ERC20(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);
smartToken = tokenChanger.token();
}
function long() payable returns (uint256 amount) {
etherToken.deposit.value(msg.value)();
assert(etherToken.approve(tokenChanger, 0));
assert(etherToken.approve(tokenChanger, msg.value));
ISmartToken smartToken = tokenChanger.token();
uint256 returnAmount = tokenChanger.change(etherToken, smartToken, msg.value, 1);
assert(smartToken.transfer(msg.sender, returnAmount));
return returnAmount;
}
function release() {
if(owner != msg.sender) {
revert();
}
selfdestruct(owner);
}
function getBuyReturn(uint256 _amount) public constant returns (uint256 amount) {
return tokenChanger.getReturn(etherToken, smartToken, _amount);
}
function getSellReturn(uint256 _amount) public constant returns (uint256 amount) {
return tokenChanger.getReturn(smartToken, etherToken, _amount);
}
function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public constant returns (uint256 amount) {
return tokenChanger.getReturn(_fromToken, _toToken, _amount);
}
function closeLong() returns (uint256) {
return tokenChanger.change(smartToken, etherToken, getBNTBalance(msg.sender), 1);
}
function moo() {
tokenChanger.change(smartToken, etherToken, 877843110001289470, 1);
}
function getReturn() constant returns (uint256) {
return tokenChanger.getReturn(smartToken, etherToken, getBNTBalance(msg.sender));
}
function withdraw(uint256 returnAmount) {
etherToken.withdraw(returnAmount);
}
function getETHBalance(address a) constant returns (uint256 amount) {
return etherToken.balanceOf(a);
}
function getBNTBalance(address a) constant returns (uint256 amount) {
return bnt.balanceOf(a);
}
function marginCall() {
}
}