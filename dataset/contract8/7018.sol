pragma solidity ^0.4.21;
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract BntyTokenInterface {
function destroyTokens(address _owner, uint _amount) public returns (bool);
function changeController(address newController) public;
}
contract BntyController is Ownable {
address public stakingContract;
address public Bounty0xToken;
modifier onlyStakingContract() {
require(msg.sender == stakingContract);
_;
}
constructor(address _stakingContract, address _Bounty0xToken) public {
stakingContract = _stakingContract;
Bounty0xToken = _Bounty0xToken;
}
function changeStakingContract(address _stakingContract) onlyOwner public {
stakingContract = _stakingContract;
}
function destroyTokensInBntyTokenContract(address _owner, uint _amount) onlyStakingContract public returns (bool) {
require(BntyTokenInterface(Bounty0xToken).destroyTokens(_owner, _amount));
return true;
}
function changeControllerInBntyTokenContract(address newController) onlyOwner public {
BntyTokenInterface(Bounty0xToken).changeController(newController);
}
}