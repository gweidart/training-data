pragma solidity ^0.4.9;
contract SafeMath {
function safeMul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
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
function assert(bool assertion) internal {
if (!assertion) throw;
}
}
contract Token {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
uint public decimals;
string public name;
}
contract StandardToken is Token {
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
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
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
}
contract ReserveToken is StandardToken, SafeMath {
address public minter;
function ReserveToken() {
minter = msg.sender;
}
function create(address account, uint amount) {
if (msg.sender != minter) throw;
balances[account] = safeAdd(balances[account], amount);
totalSupply = safeAdd(totalSupply, amount);
}
function destroy(address account, uint amount) {
if (msg.sender != minter) throw;
if (balances[account] < amount) throw;
balances[account] = safeSub(balances[account], amount);
totalSupply = safeSub(totalSupply, amount);
}
}
contract MicroDex is SafeMath {
bool locked;
mapping (address => mapping (address => uint)) public tokens;
mapping (address => mapping (bytes32 => bool)) public orders;
mapping (address => mapping (bytes32 => uint)) public orderFills;
event Order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user);
event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give);
event Deposit(address token, address user, uint amount, uint balance);
event Withdraw(address token, address user, uint amount, uint balance);
function MicroDex( ) {
if(locked)revert();
locked = true;
}
function() {
throw;
}
function deposit() public payable {
tokens[0][msg.sender] = safeAdd(tokens[0][msg.sender],msg.value);
Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
}
function withdraw(uint amount) public {
require(tokens[0][msg.sender] >= amount);
tokens[0][msg.sender] = safeSub(tokens[0][msg.sender],amount);
msg.sender.transfer(amount);
Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
}
function depositToken(address from, address token, uint amount) {
if (token==0) throw;
if (!Token(token).transferFrom(from, this, amount)) throw;
tokens[token][from] = safeAdd(tokens[token][from], amount);
Deposit(token, from, amount, tokens[token][from]);
}
function withdrawToken(address token, uint amount) {
if (token==0) throw;
if (tokens[token][msg.sender] < amount) throw;
tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
if (!Token(token).transfer(msg.sender, amount)) throw;
Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
}
function balanceOf(address token, address user) constant returns (uint) {
return tokens[token][user];
}
function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) {
bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
orders[msg.sender][hash] = true;
Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender);
}
function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) {
bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
if (!(
(orders[user][hash] || ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash),v,r,s) == user) &&
block.number <= expires &&
safeAdd(orderFills[user][hash], amount) <= amountGet
)) throw;
tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);
orderFills[user][hash] = safeAdd(orderFills[user][hash], amount);
Trade(tokenGet, amount, tokenGive, amountGive * amount / amountGet, user, msg.sender);
}
function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private {
tokens[tokenGet][msg.sender] = safeSub(tokens[tokenGet][msg.sender], amount);
tokens[tokenGet][user] = safeAdd(tokens[tokenGet][user], amount);
tokens[tokenGive][user] = safeSub(tokens[tokenGive][user], safeMul(amountGive, amount) / amountGet);
tokens[tokenGive][msg.sender] = safeAdd(tokens[tokenGive][msg.sender], safeMul(amountGive, amount) / amountGet);
}
function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) constant returns(bool) {
if (!(
tokens[tokenGet][sender] >= amount &&
availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) >= amount
)) return false;
return true;
}
function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint) {
bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
if (!(
(orders[user][hash] || ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash),v,r,s) == user) &&
block.number <= expires
)) return 0;
uint available1 = safeSub(amountGet, orderFills[user][hash]);
uint available2 = safeMul(tokens[tokenGive][user], amountGet) / amountGive;
if (available1<available2) return available1;
return available2;
}
function amountFilled(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint) {
bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
return orderFills[user][hash];
}
function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) {
bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
if (!(orders[msg.sender][hash] || ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash),v,r,s) == msg.sender)) throw;
orderFills[msg.sender][hash] = amountGet;
Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
}
function receiveApproval(address from, uint256 tokens, address token, bytes data) public returns (bool) {
byte action_id = data[0];
if(action_id == 0x1)
{
depositToken(from, token, tokens );
return true;
}
return false;
}
}