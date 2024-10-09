pragma solidity ^0.4.20;
contract DSNote {
event LogNote(
bytes4   indexed  sig,
address  indexed  guy,
bytes32  indexed  foo,
bytes32  indexed  bar,
uint	 wad,
bytes    fax
) anonymous;
modifier note {
bytes32 foo;
bytes32 bar;
assembly {
foo := calldataload(4)
bar := calldataload(36)
}
LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
_;
}
}
contract DSAuthority {
function canCall(
address src, address dst, bytes4 sig
) public view returns (bool);
}
contract DSAuthEvents {
event LogSetAuthority (address indexed authority);
event LogSetOwner     (address indexed owner);
}
contract DSAuth is DSAuthEvents {
DSAuthority  public  authority;
address      public  owner;
function DSAuth() public {
owner = msg.sender;
LogSetOwner(msg.sender);
}
function setOwner(address owner_)
public
auth
{
owner = owner_;
LogSetOwner(owner);
}
function setAuthority(DSAuthority authority_)
public
auth
{
authority = authority_;
LogSetAuthority(authority);
}
modifier auth {
require(isAuthorized(msg.sender, msg.sig));
_;
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
if (src == address(this)) {
return true;
} else if (src == owner) {
return true;
} else if (authority == DSAuthority(0)) {
return false;
} else {
return authority.canCall(src, this, sig);
}
}
}
contract DSStop is DSAuth, DSNote {
bool public stopped;
modifier stoppable {
require (!stopped);
_;
}
function stop() public auth note {
stopped = true;
}
function start() public auth note {
stopped = false;
}
}
contract DSMath {
function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
require((z = x + y) >= x);
}
function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
require((z = x - y) <= x);
}
}
contract EIP20Interface {
uint256 public totalSupply;
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract DSTokenBase is EIP20Interface, DSMath {
mapping (address => uint256)                       _balances;
mapping (address => mapping (address => uint256))  _approvals;
function balanceOf(address _owner) public view returns (uint256 balance) {
return _balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool success){
_balances[msg.sender] = sub(_balances[msg.sender], _value);
_balances[_to] = add(_balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
if (_from != msg.sender) {
_approvals[_from][msg.sender] = sub(_approvals[_from][msg.sender], _value);
}
_balances[_from] = sub(_balances[_from], _value);
_balances[_to] = add(_balances[_to], _value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success){
_approvals[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining){
return _approvals[_owner][_spender];
}
}
contract FUXEToken is DSTokenBase, DSStop {
string   public  name = "FUXECoin";
string   public  symbol = "FUX";
uint256  public  decimals = 18;
function FUXEToken() public {
totalSupply = 100000000 * 10 ** uint256(decimals);
_balances[msg.sender] = totalSupply;
}
function transfer(address dst, uint wad) public stoppable note returns (bool) {
return super.transfer(dst, wad);
}
function transferFrom(
address src, address dst, uint wad
) public stoppable note returns (bool) {
return super.transferFrom(src, dst, wad);
}
function approve(address guy, uint wad) public stoppable note returns (bool) {
return super.approve(guy, wad);
}
}