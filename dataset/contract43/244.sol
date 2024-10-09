pragma solidity ^0.4.15;
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract Owned {
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
address public owner;
function Owned() public {
owner = msg.sender;
}
address newOwner=0x0;
event OwnerUpdate(address _prevOwner, address _newOwner);
function changeOwner(address _newOwner) public onlyOwner {
require(_newOwner != owner);
newOwner = _newOwner;
}
function acceptOwnership() public{
require(msg.sender == newOwner);
OwnerUpdate(owner, newOwner);
owner = newOwner;
newOwner = 0x0;
}
}
contract Controlled is Owned{
function Controlled() public {
setExclude(msg.sender);
}
bool public transferEnabled = false;
bool lockFlag=true;
mapping(address => bool) locked;
mapping(address => bool) exclude;
function enableTransfer(bool _enable) public onlyOwner{
transferEnabled=_enable;
}
function disableLock(bool _enable) public onlyOwner returns (bool success){
lockFlag=_enable;
return true;
}
function addLock(address[] _addrs) public onlyOwner returns (bool success){
for (uint256 i = 0; i < _addrs.length; i++){
locked[_addrs[i]]=true;
}
return true;
}
function setExclude(address _addr) public onlyOwner returns (bool success){
exclude[_addr]=true;
return true;
}
function removeLock(address[] _addrs) public onlyOwner returns (bool success){
for (uint256 i = 0; i < _addrs.length; i++){
locked[_addrs[i]]=false;
}
return true;
}
modifier transferAllowed(address _addr) {
if (!exclude[_addr]) {
assert(transferEnabled);
if(lockFlag){
assert(!locked[_addr]);
}
}
_;
}
}
contract StandardToken is Token,Controlled {
function transfer(address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool success) {
if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) public transferAllowed(_from) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else { return false; }
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}
contract MESH is StandardToken {
function () public {
revert();
}
string public name = "MeshBox";
uint8 public decimals = 18;
string public symbol = "MESH";
string public version = 'v0.1';
uint256 public allocateEndTime;
mapping(address => uint256) nonces;
function MESH() public {
allocateEndTime = now + 1 days;
}
function transferProxy(address _from, address _to, uint256 _value, uint256 _feeMesh,
uint8 _v,bytes32 _r, bytes32 _s) public transferAllowed(_from) returns (bool){
if(balances[_from] < _feeMesh + _value) revert();
uint256 nonce = nonces[_from];
bytes32 h = keccak256(_from,_to,_value,_feeMesh,nonce,name);
if(_from != ecrecover(h,_v,_r,_s)) revert();
if(balances[_to] + _value < balances[_to]
|| balances[msg.sender] + _feeMesh < balances[msg.sender]) revert();
balances[_to] += _value;
Transfer(_from, _to, _value);
balances[msg.sender] += _feeMesh;
Transfer(_from, msg.sender, _feeMesh);
balances[_from] -= _value + _feeMesh;
nonces[_from] = nonce + 1;
return true;
}
function approveProxy(address _from, address _spender, uint256 _value,
uint8 _v,bytes32 _r, bytes32 _s) public returns (bool success) {
uint256 nonce = nonces[_from];
bytes32 hash = keccak256(_from,_spender,_value,nonce,name);
if(_from != ecrecover(hash,_v,_r,_s)) revert();
allowed[_from][_spender] = _value;
Approval(_from, _spender, _value);
nonces[_from] = nonce + 1;
return true;
}
function getNonce(address _addr) public constant returns (uint256){
return nonces[_addr];
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
return true;
}
function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if(!_spender.call(_extraData)) { revert(); }
return true;
}
function getBackToken(address _spender,address _to,uint256 _value) public onlyOwner{
if(!_spender.call(bytes4(bytes32(keccak256("transfer(address,uint256)"))), _to, _value)) { revert(); }
}
function allocateTokens(address[] _owners, uint256[] _values) public onlyOwner {
if(allocateEndTime < now) revert();
if(_owners.length != _values.length) revert();
for(uint256 i = 0; i < _owners.length ; i++){
address to = _owners[i];
uint256 value = _values[i];
if(totalSupply + value <= totalSupply || balances[to] + value <= balances[to]) revert();
totalSupply += value;
balances[to] += value;
}
}
}