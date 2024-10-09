pragma solidity ^0.4.24;
contract Mortal {
address owner;
constructor() public { owner = msg.sender; }
function kill() public { if (msg.sender == owner) selfdestruct(owner); }
}
contract Carving is Mortal {
uint16 initial1;
uint16 initial2;
constructor(uint16 _initial1, uint16 _initial2) public {
initial1 = _initial1;
initial2 = _initial2;
}
function getInitials() public view returns (uint16, uint16) {
return (initial1, initial2);
}
}