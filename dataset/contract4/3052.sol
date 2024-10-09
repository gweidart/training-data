pragma solidity ^0.4.21;
contract tokenInterface {
uint256 public totalSupply;
uint8 public decimals;
function transfer(
address _to,
uint256 _value
) public returns (bool success);
function transferFrom(
address _from,
address _to,
uint256 _value
) public returns (bool success);
function approve(
address _spender,
uint256 _value
) public returns (bool success);
}
contract Owned {
address public owner;
address public newOwner;
event OwnerUpdate(address _prevOwner, address _newOwner);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner() {
assert(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != owner);
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnerUpdate(owner, newOwner);
owner = newOwner;
newOwner = 0x0;
}
event Pause();
event Unpause();
bool public paused = true;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() public onlyOwner whenNotPaused {
paused = true;
emit Pause();
}
function unpause() public onlyOwner whenPaused {
paused = false;
emit Unpause();
}
}
contract airDrop is Owned {
tokenInterface private tokenLedger;
function withdrawAirDrop(
address[] lucky,
uint256 value
) public onlyOwner whenNotPaused returns (bool success) {
uint i;
for (i = 0; i < lucky.length; i++) {
if (!tokenLedger.transfer(lucky[i], value)) {
revert();
}
}
return true;
}
function applyToken(
address token
) public onlyOwner whenPaused returns (bool success) {
tokenLedger = tokenInterface(token);
return true;
}
function tokenDecimals() public view returns (uint8 dec) {
return tokenLedger.decimals();
}
function tokenTotalSupply() public view returns (uint256) {
return tokenLedger.totalSupply();
}
function kill() public onlyOwner {
selfdestruct(owner);
}
}