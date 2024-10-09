pragma solidity ^0.4.21;
contract owned {
address public owner;
function owned() public { owner = msg.sender; }
function changeOwner( address newowner ) public onlyOwner {
owner = newowner;
}
modifier onlyOwner {
if (msg.sender != owner) { revert(); }
_;
}
}
contract Tesoro is owned {
event Result( string hexprivkey, string magicnumber );
string public pubaddr = "0xff982b2a62eb872d01eb98761f1ff66f6055a8e6";
string public magicnumsig = "0x28c599e8564c4e477fe69c712df9a6ad232b2dbadf77ffd9e406f1d5fa32ef7509ec26fa7fd559217ecd0d47ca04bb2d40613d0ad0b8aec2ea545baae9f763571b";
function Tesoro() public {}
function publish( string _hexprivkey, string _magicnumber )
onlyOwner public {
emit Result( _hexprivkey, _magicnumber );
}
}