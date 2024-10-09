pragma solidity ^0.4.24;
contract TheDivine{
bytes32 immotal;
mapping (address => uint256) internal nonce;
event NewRand(address _sender, uint256 _complex, bytes32 _randomValue);
constructor() public {
immotal = keccak256(abi.encode(this));
}
function rand() public returns(bytes32 result){
uint256 complex = (nonce[msg.sender] % 11) + 10;
result = keccak256(abi.encode(immotal, nonce[msg.sender]++));
for(uint256 c = 0; c < complex; c++){
result = keccak256(abi.encode(result));
}
immotal = result;
emit NewRand(msg.sender, complex, result);
return;
}
function () public payable {
revert();
}
}