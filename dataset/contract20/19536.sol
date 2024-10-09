pragma solidity ^0.4.20;
contract kektest {
function kek(address) public view returns(bytes32) {
address _ethaddy = msg.sender;
return (keccak256(_ethaddy));
}
}