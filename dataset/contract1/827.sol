pragma solidity ^0.4.18;
contract OwnableContractInterface {
event OwnershipTransferred(address indexed _from, address indexed _to);
function transferOwnership(address _newOwner) public ;
function acceptOwnership() public;
}
contract ContractOwnershipBurn {
function ContractOwnershipBurn() public  {
}
function burnOwnership(address contractAddress ) public   {
OwnableContractInterface(contractAddress).acceptOwnership() ;
}
}