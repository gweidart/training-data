pragma solidity ^0.4.11;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract LimitedTransferToken is ERC20 {
modifier canTransfer(address _sender, uint256 _value) {
require(_value <= transferableTokens(_sender, uint64(now)));
_;
}
function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) public returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) public returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
return balanceOf(holder);
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue)
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue)
returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
library Math {
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
}
contract VestedToken is StandardToken, LimitedTransferToken {
uint256 MAX_GRANTS_PER_ADDRESS = 20;
struct TokenGrant {
address granter;
uint256 value;
uint64 cliff;
uint64 vesting;
uint64 start;
bool revokable;
bool burnsOnRevoke;
}
mapping (address => TokenGrant[]) public grants;
event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint256 grantId);
function grantVestedTokens(
address _to,
uint256 _value,
uint64 _start,
uint64 _cliff,
uint64 _vesting,
bool _revokable,
bool _burnsOnRevoke
) public {
require(_cliff >= _start && _vesting >= _cliff);
require(tokenGrantsCount(_to) < MAX_GRANTS_PER_ADDRESS);
uint256 count = grants[_to].push(
TokenGrant(
_revokable ? msg.sender : 0,
_value,
_cliff,
_vesting,
_start,
_revokable,
_burnsOnRevoke
)
);
transfer(_to, _value);
NewTokenGrant(msg.sender, _to, _value, count - 1);
}
function revokeTokenGrant(address _holder, uint256 _grantId) public {
TokenGrant storage grant = grants[_holder][_grantId];
require(grant.revokable);
require(grant.granter == msg.sender);
address receiver = grant.burnsOnRevoke ? 0xdead : msg.sender;
uint256 nonVested = nonVestedTokens(grant, uint64(now));
delete grants[_holder][_grantId];
grants[_holder][_grantId] = grants[_holder][grants[_holder].length.sub(1)];
grants[_holder].length -= 1;
balances[receiver] = balances[receiver].add(nonVested);
balances[_holder] = balances[_holder].sub(nonVested);
Transfer(_holder, receiver, nonVested);
}
function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
uint256 grantIndex = tokenGrantsCount(holder);
if (grantIndex == 0) return super.transferableTokens(holder, time);
uint256 nonVested = 0;
for (uint256 i = 0; i < grantIndex; i++) {
nonVested = SafeMath.add(nonVested, nonVestedTokens(grants[holder][i], time));
}
uint256 vestedTransferable = SafeMath.sub(balanceOf(holder), nonVested);
return Math.min256(vestedTransferable, super.transferableTokens(holder, time));
}
function tokenGrantsCount(address _holder) public constant returns (uint256 index) {
return grants[_holder].length;
}
function calculateVestedTokens(
uint256 tokens,
uint256 time,
uint256 start,
uint256 cliff,
uint256 vesting) public constant returns (uint256)
{
if (time < cliff) return 0;
if (time >= vesting) return tokens;
uint256 vestedTokens = SafeMath.div(
SafeMath.mul(
tokens,
SafeMath.sub(time, start)
),
SafeMath.sub(vesting, start)
);
return vestedTokens;
}
function tokenGrant(address _holder, uint256 _grantId) public constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {
TokenGrant storage grant = grants[_holder][_grantId];
granter = grant.granter;
value = grant.value;
start = grant.start;
cliff = grant.cliff;
vesting = grant.vesting;
revokable = grant.revokable;
burnsOnRevoke = grant.burnsOnRevoke;
vested = vestedTokens(grant, uint64(now));
}
function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
return calculateVestedTokens(
grant.value,
uint256(time),
uint256(grant.start),
uint256(grant.cliff),
uint256(grant.vesting)
);
}
function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
return grant.value.sub(vestedTokens(grant, time));
}
function lastTokenIsTransferableDate(address holder) public constant returns (uint64 date) {
date = uint64(now);
uint256 grantIndex = grants[holder].length;
for (uint256 i = 0; i < grantIndex; i++) {
date = Math.max64(grants[holder][i].vesting, date);
}
}
}
contract FreezoneToken is VestedToken {
string public name = "Free Crypto Economic Zone";
string public symbol = "FRZ";
uint public decimals = 18;
uint public INITIAL_SUPPLY = 1000000000 * (10 ** decimals);
uint64 start = uint64(now);
uint64 vesting;
bool revokable = false;
bool burnsOnRevoke = false;
address multisig = 0x5c15741C7ABb1b0E8FB0BD41b5ed8c17219926A1;
function FreezoneToken() {
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
vesting = uint64(start + 1 years);
grantVestedTokens(multisig,100000000 * (10 ** decimals),start,vesting,vesting,revokable,burnsOnRevoke);
vesting = uint64(start + 1.5 years);
grantVestedTokens(multisig,50000000 * (10 ** decimals),start,vesting,vesting,revokable,burnsOnRevoke);
vesting = uint64(start + 2 years);
grantVestedTokens(multisig,50000000 * (10 ** decimals),start,vesting,vesting,revokable,burnsOnRevoke);
vesting = uint64(start + 2.5 years);
grantVestedTokens(multisig,50000000 * (10 ** decimals),start,vesting,vesting,revokable,burnsOnRevoke);
vesting = uint64(start + 3 years);
grantVestedTokens(multisig,50000000 * (10 ** decimals),start,vesting,vesting,revokable,burnsOnRevoke);
}
}