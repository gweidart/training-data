pragma solidity ^0.4.18;
contract ctf {
address public owner;
uint private flag;
function ctf(uint _flag) public {
owner = msg.sender;
flag = _flag;
}
function change_flag(uint newflag) public {
require(msg.sender == owner);
flag = newflag;
}
function() payable public {
return;
}
function kill(address _to) public {
require(msg.sender == owner);
selfdestruct(_to);
}
}