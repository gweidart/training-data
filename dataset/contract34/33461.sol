pragma solidity ^0.4.18;
contract Hash {
address owner;
function Hash() public {
owner = msg.sender;
}
function() internal {
revert();
}
function hashString(string dataString) public pure returns(bytes32){
return(keccak256(dataString));
}
function hashBytes(bytes dataBytes) public pure returns(bytes32){
return(keccak256(dataBytes));
}
function selfDestruct() public {
if (msg.sender == owner) {
selfdestruct(owner);
}
}
}