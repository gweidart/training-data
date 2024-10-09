pragma solidity ^0.4.23;
contract Ownable {
address private owner;
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(
msg.sender == owner,
'Only the administrator can change this'
);
_;
}
}
contract Blockchainedlove is Ownable {
string public partner_1_name;
string public partner_2_name;
string public contract_date;
string public declaration;
bool public is_active;
constructor() public {
partner_1_name = 'Avery';
partner_2_name = 'Jordan';
contract_date = '11 January 2018';
declaration = 'This smart contract has been prepared and deployed by Blockchained.Love - it is stored permanently on the Ethereum blockchain and cannot be deleted. The status of the smart contract, represented by the value of the is_active variable, an only be changed by Blockchained.Love following explicit consent from both persons mentioned in the document.';
is_active = true;
}
function updateStatus(bool _status) public onlyOwner {
is_active = _status;
emit StatusChanged(is_active);
}
event StatusChanged(bool NewStatus);
}