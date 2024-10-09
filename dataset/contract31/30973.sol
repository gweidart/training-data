pragma solidity ^0.4.18;
contract Dragon {
function transfer(address receiver, uint amount)returns(bool ok);
function balanceOf( address _address )returns(uint256);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
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
contract DragonLock is Ownable {
using SafeMath for uint;
address public dataentryclerk;
Dragon public tokenreward;
mapping ( address => uint ) public dragonBalance;
uint public TimeLock;
modifier onlyDataEntryClerk () {
require ( msg.sender == dataentryclerk );
_;
}
function DragonLock (){
tokenreward = Dragon (  0x814f67fa286f7572b041d041b1d99b432c9155ee );
TimeLock = now + 90 days;
owner = msg.sender;
dataentryclerk = msg.sender;
}
function withdrawDragons(){
require ( now > TimeLock );
uint bal = dragonBalance [ msg.sender ];
dragonBalance [ msg.sender ] = 0;
tokenreward.transfer ( msg.sender , bal );
}
function creditDragon ( address tokenholder, uint amount ) onlyDataEntryClerk {
require ( tokenholder != 0x00 );
dragonBalance [ tokenholder ] = dragonBalance [ tokenholder ].add(amount);
}
function resetDragonBalance ( address tokenholder, uint amount ) onlyOwner {
require ( tokenholder != 0x00 );
dragonBalance [ tokenholder ] = 0;
}
function transferOwnership ( address _newowner ) onlyOwner {
require ( _newowner != 0x00 );
owner = _newowner;
}
function transferDataEntryClerk ( address _dataentryclerk ) onlyOwner {
require ( _dataentryclerk != 0x00 );
dataentryclerk = _dataentryclerk;
}
}