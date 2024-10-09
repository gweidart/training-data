library SafeMath {
function mul(uint256 a, uint256 b) constant public returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) constant public returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) constant public returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) constant public returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
if(msg.sender == owner){
_;
}
else{
revert();
}
}
}