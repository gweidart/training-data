pragma solidity 0.4.16;
contract ControllerInterface {
bool public paused;
address public nutzAddr;
function babzBalanceOf(address _owner) constant returns (uint256);
function activeSupply() constant returns (uint256);
function burnPool() constant returns (uint256);
function powerPool() constant returns (uint256);
function totalSupply() constant returns (uint256);
function allowance(address _owner, address _spender) constant returns (uint256);
function approve(address _owner, address _spender, uint256 _amountBabz) public;
function transfer(address _from, address _to, uint256 _amountBabz, bytes _data) public;
function transferFrom(address _sender, address _from, address _to, uint256 _amountBabz, bytes _data) public;
function floor() constant returns (uint256);
function ceiling() constant returns (uint256);
function purchase(address _sender, uint256 _value, uint256 _price) public returns (uint256);
function sell(address _from, uint256 _price, uint256 _amountBabz);
function powerBalanceOf(address _owner) constant returns (uint256);
function outstandingPower() constant returns (uint256);
function authorizedPower() constant returns (uint256);
function powerTotalSupply() constant returns (uint256);
function powerUp(address _sender, address _from, uint256 _amountBabz) public;
function downTick(address _owner, uint256 _now) public;
function createDownRequest(address _owner, uint256 _amountPower) public;
function downs(address _owner) constant public returns(uint256, uint256, uint256);
function downtime() constant returns (uint256);
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract ERC20Basic {
function totalSupply() constant returns (uint256);
function balanceOf(address _owner) constant returns (uint256);
function transfer(address _to, uint256 _value) returns (bool);
event Transfer(address indexed from, address indexed to, uint value);
}
contract Power is Ownable, ERC20Basic {
event Slashing(address indexed holder, uint value, bytes32 data);
string public name = "Acebusters Power";
string public symbol = "ABP";
uint256 public decimals = 12;
function balanceOf(address _holder) constant returns (uint256) {
return ControllerInterface(owner).powerBalanceOf(_holder);
}
function totalSupply() constant returns (uint256) {
return ControllerInterface(owner).powerTotalSupply();
}
function activeSupply() constant returns (uint256) {
return ControllerInterface(owner).outstandingPower();
}
function slashPower(address _holder, uint256 _value, bytes32 _data) public onlyOwner {
Slashing(_holder, _value, _data);
}
function powerUp(address _holder, uint256 _value) public onlyOwner {
Transfer(address(0), _holder, _value);
}
function transfer(address _to, uint256 _amountPower) public returns (bool success) {
require(_to == address(0));
ControllerInterface(owner).createDownRequest(msg.sender, _amountPower);
Transfer(msg.sender, address(0), _amountPower);
return true;
}
function downtime() public returns (uint256) {
ControllerInterface(owner).downtime;
}
function downTick(address _owner) public {
ControllerInterface(owner).downTick(_owner, now);
}
function downs(address _owner) constant public returns (uint256, uint256, uint256) {
return ControllerInterface(owner).downs(_owner);
}
}