pragma solidity ^0.4.24;
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) public constant returns (uint);
function transfer(address to, uint value) public;
event Transfer(address indexed from, address indexed to, uint value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint);
function transferFrom(address from, address to, uint value) public;
function approve(address spender, uint value) public;
event Approval(address indexed owner, address indexed spender, uint value);
}
contract Airdrop {
function doAirdrop(address _tokenAddr, address[] dests, uint256[] values) public
returns (uint256) {
uint256 i = 0;
while (i < dests.length) {
ERC20(_tokenAddr).transferFrom(msg.sender,dests[i], values[i]);
i += 1;
}
return(i);
}
}