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
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract CAStoreContract is Ownable {
using SafeMath for uint;
event DataStored(bytes32 field1, bytes32 field2, bytes32 field3, bytes32 field4);
function storeData
(bytes32[] fields1, bytes32[] fields2, bytes32[] fields3, bytes32[] fields4)
public onlyOwner {
for (uint i = 0; i < fields1.length; i++) {
emit DataStored(fields1[i], fields2[i], fields3[i], fields4[i]);
}
}
}