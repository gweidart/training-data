pragma solidity ^0.4.24;
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
constructor() public {
owner = msg.sender;
emit LogSetOwner(msg.sender);
}
function setOwner(address owner_)
public
auth
{
owner = owner_;
emit LogSetOwner(owner);
}
function setAuthority(DSAuthority authority_)
public
auth
{
authority = authority_;
emit LogSetAuthority(authority);
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
contract DSNote {
event LogNote(
bytes4   indexed  sig,
address  indexed  guy,
bytes32  indexed  foo,
bytes32  indexed  bar,
uint              wad,
bytes             fax
) anonymous;
modifier note {
bytes32 foo;
bytes32 bar;
assembly {
foo := calldataload(4)
bar := calldataload(36)
}
emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
_;
}
}
contract DSStop is DSNote, DSAuth {
bool public stopped;
modifier stoppable {
require(!stopped);
_;
}
function stop() public auth note {
stopped = true;
}
function start() public auth note {
stopped = false;
}
}
contract ERC20Events {
event Approval(address indexed src, address indexed guy, uint wad);
event Transfer(address indexed src, address indexed dst, uint wad);
}
contract ERC20 is ERC20Events {
function totalSupply() public view returns (uint);
function balanceOf(address guy) public view returns (uint);
function allowance(address src, address guy) public view returns (uint);
function approve(address guy, uint wad) public returns (bool);
function transfer(address dst, uint wad) public returns (bool);
function transferFrom(
address src, address dst, uint wad
) public returns (bool);
}
contract TokenController {
function proxyPayment(address _owner) payable public returns (bool);
function onTransfer(address _from, address _to, uint _amount) public returns (bool);
function onApprove(address _owner, address _spender, uint _amount) public returns (bool);
}
contract Controlled {
modifier onlyController { if (msg.sender != controller) throw; _; }
address public controller;
constructor() public { controller = msg.sender;}
function changeController(address _newController) onlyController public {
controller = _newController;
}
}
contract TransferController is DSStop, TokenController {
function changeController(address _token, address _newController) public auth {
Controlled(_token).changeController(_newController);
}
function proxyPayment(address _owner) payable public returns (bool)
{
return false;
}
function onTransfer(address _from, address _to, uint _amount) public returns (bool)
{
return stopped;
}
function onApprove(address _owner, address _spender, uint _amount) public returns (bool)
{
return true;
}
}