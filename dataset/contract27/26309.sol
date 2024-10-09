pragma solidity ^0.4.19;
contract owned {
address public owner;
function owned() { owner = msg.sender; }
modifier onlyOwner {
if (msg.sender != owner) { revert(); }
_;
}
function changeOwner( address newowner ) onlyOwner {
owner = newowner;
}
function closedown() onlyOwner {
selfdestruct( owner );
}
}
interface BitEther {
function transfer(address to, uint256 value);
function balanceOf( address owner ) constant returns (uint);
}
contract BTTICO is owned {
uint public constant STARTTIME = 1518703200;
uint public constant ENDTIME = 1520010000;
uint public constant BTTPERETH = 680;
BitEther public tokenSC;
function BTTICO() {}
function setToken( address tok ) onlyOwner {
if ( tokenSC == address(0) )
tokenSC = BitEther(tok);
}
function() payable {
if (now < STARTTIME || now > ENDTIME)
revert();
uint qty =
div(mul(div(mul(msg.value, BTTPERETH),1000000000000000000),(bonus()+100)),100);
if (qty > tokenSC.balanceOf(address(this)) || qty < 1)
revert();
tokenSC.transfer( msg.sender, qty );
}
function claimUnsold() onlyOwner {
if ( now < ENDTIME )
revert();
tokenSC.transfer( owner, tokenSC.balanceOf(address(this)) );
}
function withdraw( uint amount ) onlyOwner returns (bool) {
if (amount <= this.balance)
return owner.send( amount );
return false;
}
function bonus() internal constant returns(uint) {
return 0;
}
function mul(uint256 a, uint256 b) constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) constant returns (uint256) {
uint256 c = a / b;
return c;
}
}