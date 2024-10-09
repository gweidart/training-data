pragma solidity 0.4.24;
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract Token{
function transfer(address to, uint value) public returns (bool);
function decimals() public returns (uint);
}
contract Airdrop is Ownable {
function multisend(address _tokenAddr, address[] _to, uint256[] _value) public onlyOwner
returns (bool _success) {
assert(_to.length == _value.length);
assert(_to.length <= 150);
uint decimals = Token(_tokenAddr).decimals();
for (uint8 i = 0; i < _to.length; i++) {
assert((Token(_tokenAddr).transfer(_to[i], _value[i] * (10 ** decimals))) == true);
}
return true;
}
}