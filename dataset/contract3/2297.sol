pragma solidity ^0.4.11;
contract Ownable {
address public owner;
constructor() public {
owner = 0xbcAaf63962841589df1191bCE0B08abCEfD37223;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract Token {
function transfer(address to, uint value) public returns (bool);
}
contract BITXMultiTransfer is Ownable {
Token bitx = Token(0xff2b3353c3015E9f1FBF95B9Bda23F58Aa7cE007);
function multisend(address[] _to, uint256[] _value)
public returns (bool _success) {
assert(_to.length == _value.length);
assert(_to.length <= 150);
for (uint8 i = 0; i < _to.length; i++) {
assert(bitx.transfer(_to[i], _value[i]) == true);
}
return true;
}
}