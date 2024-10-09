pragma solidity ^0.4.19;
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
owner = newOwner;
}
}
library AddressUtils {
function isContract(address addr) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(addr) }
return size > 0;
}
}
interface ERC165ReceiverInterface {
function tokensReceived(address _from, address _to, uint _amount) external returns (bool);
}
contract ERC165Query {
bytes4 constant InvalidID = 0xffffffff;
bytes4 constant ERC165ID = 0x01ffc9a7;
function doesContractImplementInterface(address _contract, bytes4 _interfaceId) internal view returns (bool) {
uint256 success;
uint256 result;
(success, result) = noThrowCall(_contract, ERC165ID);
if ((success==0)||(result==0)) {
return false;
}
(success, result) = noThrowCall(_contract, InvalidID);
if ((success==0)||(result!=0)) {
return false;
}
(success, result) = noThrowCall(_contract, _interfaceId);
if ((success==1)&&(result==1)) {
return true;
}
return false;
}
function noThrowCall(address _contract, bytes4 _interfaceId) constant internal returns (uint256 success, uint256 result) {
bytes4 erc165ID = ERC165ID;
assembly {
let x := mload(0x40)
mstore(x, erc165ID)
mstore(add(x, 0x04), _interfaceId)
success := staticcall(
30000,
_contract,
x,
0x20,
x,
0x20)
result := mload(x)
}
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic, ERC165Query {
using SafeMath for uint256;
using AddressUtils for address;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
if (_to.isContract()) {
ERC165ReceiverInterface i;
if(doesContractImplementInterface(_to, i.tokensReceived.selector))
{
ERC165ReceiverInterface app= ERC165ReceiverInterface(_to);
app.tokensReceived(msg.sender, _to, _value);
}
}
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
contract ReleasableToken is ERC20, Ownable {
address public releaseAgent;
bool public released = false;
mapping (address => bool) public transferAgents;
mapping(address => uint) public lock_addresses;
event AddLockAddress(address addr, uint lock_time);
modifier canTransfer(address _sender) {
if(!released) {
if(!transferAgents[_sender]) {
revert();
}
}
else {
if(now < lock_addresses[_sender]) {
revert();
}
}
_;
}
function ReleasableToken() public {
releaseAgent = msg.sender;
}
function addLockAddressInternal(address addr, uint lock_time) inReleaseState(false) internal {
if(addr == 0x0) revert();
lock_addresses[addr]= lock_time;
AddLockAddress(addr, lock_time);
}
function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
releaseAgent = addr;
}
function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
transferAgents[addr] = state;
}
modifier onlyReleaseAgent() {
if(msg.sender != releaseAgent) {
revert();
}
_;
}
function releaseTokenTransfer() public onlyReleaseAgent {
released = true;
}
modifier inReleaseState(bool releaseState) {
if(releaseState != released) {
revert();
}
_;
}
function transfer(address _to, uint _value) canTransfer(msg.sender) public returns (bool success) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) canTransfer(_from) public returns (bool success) {
return super.transferFrom(_from, _to, _value);
}
}
contract MintableToken is StandardToken, Ownable {
bool public mintingFinished = false;
mapping (address => bool) public mintAgents;
event MintingAgentChanged(address addr, bool state  );
event Mint(address indexed to, uint256 amount);
event MintFinished();
modifier onlyMintAgent() {
if(!mintAgents[msg.sender]) {
revert();
}
_;
}
modifier canMint() {
require(!mintingFinished);
_;
}
function setMintAgent(address addr, bool state) onlyOwner canMint public {
mintAgents[addr] = state;
MintingAgentChanged(addr, state);
}
function mint(address _to, uint256 _amount) onlyMintAgent canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyMintAgent public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract CrowdsaleToken is ReleasableToken, MintableToken {
string public name = "KINWA Token";
string public symbol = "KINWA";
uint public decimals = 8;
function CrowdsaleToken() public {
owner = msg.sender;
totalSupply_ = 0;
}
function releaseTokenTransfer() public onlyReleaseAgent {
mintingFinished = true;
super.releaseTokenTransfer();
}
function addLockAddress(address addr, uint lock_time) onlyMintAgent inReleaseState(false) public {
super.addLockAddressInternal(addr, lock_time);
}
}