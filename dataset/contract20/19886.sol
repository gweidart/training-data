pragma solidity ^0.4.18;
contract TokenController {
bytes4 public constant INTERFACE = bytes4(keccak256("TokenController"));
function allowTransfer(address _sender, address _from, address _to, uint256 _value, bytes _purpose) public returns (bool);
}
contract YesController is TokenController {
public returns (bool)
{
return true;
}
}
contract NoController is TokenController {
public returns (bool)
{
return false;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract SaleController is TokenController, Ownable {
address public seller = 0;
function changeSeller(address _newSeller)
onlyOwner public
{
seller = _newSeller;
}
public returns (bool)
{
return _from == seller || _from == owner;
}
}