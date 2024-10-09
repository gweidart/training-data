pragma solidity ^0.4.15;
contract IOwnership {
function isOwner(address _account) constant returns (bool);
function getOwner() constant returns (address);
}
contract Ownership is IOwnership {
address internal owner;
function Ownership() {
owner = msg.sender;
}
modifier only_owner() {
require(msg.sender == owner);
_;
}
function isOwner(address _account) public constant returns (bool) {
return _account == owner;
}
function getOwner() public constant returns (address) {
return owner;
}
}
contract ITransferableOwnership {
function transferOwnership(address _newOwner);
}
contract TransferableOwnership is ITransferableOwnership, Ownership {
function transferOwnership(address _newOwner) public only_owner {
owner = _newOwner;
}
}
contract IPausable {
function isPaused() constant returns (bool);
function pause();
function resume();
}
contract ITokenRetriever {
function retrieveTokens(address _tokenContract);
}
contract TokenRetriever is ITokenRetriever {
function retrieveTokens(address _tokenContract) public {
IToken tokenInstance = IToken(_tokenContract);
uint tokenBalance = tokenInstance.balanceOf(this);
if (tokenBalance > 0) {
tokenInstance.transfer(msg.sender, tokenBalance);
}
}
}
contract ITokenObserver {
function notifyTokensReceived(address _from, uint _value);
}
contract TokenObserver is ITokenObserver {
function notifyTokensReceived(address _from, uint _value) public {
onTokensReceived(msg.sender, _from, _value);
}
function onTokensReceived(address _token, address _from, uint _value) internal;
}
contract IToken {
function totalSupply() constant returns (uint);
function balanceOf(address _owner) constant returns (uint);
function transfer(address _to, uint _value) returns (bool);
function transferFrom(address _from, address _to, uint _value) returns (bool);
function approve(address _spender, uint _value) returns (bool);
function allowance(address _owner, address _spender) constant returns (uint);
}
contract IManagedToken is IToken {
function isLocked() constant returns (bool);
function lock() returns (bool);
function unlock() returns (bool);
function issue(address _to, uint _value) returns (bool);
function burn(address _from, uint _value) returns (bool);
}
contract ITokenChanger {
function isToken(address _token) constant returns (bool);
function getLeftToken() constant returns (address);
function getRightToken() constant returns (address);
function getFee() constant returns (uint);
function getRate() constant returns (uint);
function getPrecision() constant returns (uint);
function calculateFee(uint _value) constant returns (uint);
}
contract TokenChanger is ITokenChanger, IPausable {
IManagedToken private tokenLeft;
IManagedToken private tokenRight;
uint private rate;
uint private fee;
uint private precision;
bool private paused;
bool private burn;
modifier is_token(address _token) {
require(_token == address(tokenLeft) || _token == address(tokenRight));
_;
}
function TokenChanger(address _tokenLeft, address _tokenRight, uint _rate, uint _fee, uint _decimals, bool _paused, bool _burn) {
tokenLeft = IManagedToken(_tokenLeft);
tokenRight = IManagedToken(_tokenRight);
rate = _rate;
fee = _fee;
precision = _decimals > 0 ? 10**_decimals : 1;
paused = _paused;
burn = _burn;
}
function isToken(address _token) public constant returns (bool) {
return _token == address(tokenLeft) || _token == address(tokenRight);
}
function getLeftToken() public constant returns (address) {
return tokenLeft;
}
function getRightToken() public constant returns (address) {
return tokenRight;
}
function getFee() public constant returns (uint) {
return fee;
}
function getRate() public constant returns (uint) {
return rate;
}
function getPrecision() public constant returns (uint) {
return precision;
}
function isPaused() public constant returns (bool) {
return paused;
}
function pause() public {
paused = true;
}
function resume() public {
paused = false;
}
function calculateFee(uint _value) public constant returns (uint) {
return fee == 0 ? 0 : _value * fee / precision;
}
function convert(address _from, address _sender, uint _value) internal {
require(!paused);
require(_value > 0);
uint amountToIssue;
if (_from == address(tokenLeft)) {
amountToIssue = _value * rate / precision;
tokenRight.issue(_sender, amountToIssue - calculateFee(amountToIssue));
if (burn) {
tokenLeft.burn(this, _value);
}
}
else if (_from == address(tokenRight)) {
amountToIssue = _value * precision / rate;
tokenLeft.issue(_sender, amountToIssue - calculateFee(amountToIssue));
if (burn) {
tokenRight.burn(this, _value);
}
}
}
}
contract DRPTokenChanger is TokenChanger, TokenObserver, TransferableOwnership, TokenRetriever {
function DRPTokenChanger(address _drps, address _drpu)
TokenChanger(_drps, _drpu, 20000, 100, 4, false, true) {}
function pause() public only_owner {
super.pause();
}
function resume() public only_owner {
super.resume();
}
function onTokensReceived(address _token, address _from, uint _value) internal is_token(_token) {
require(_token == msg.sender);
convert(_token, _from, _value);
}
function retrieveTokens(address _tokenContract) public only_owner {
super.retrieveTokens(_tokenContract);
}
function () payable {
revert();
}
}