pragma solidity ^0.4.15;
contract Factory{
address private creator;
address private owner1 = 0x6CAa636cFFbCbb2043A3322c04dE3f26b1fa6555;
address private owner2 = 0xbc2d90C2D3A87ba3fC8B23aA951A9936A6D68121;
address private owner3 = 0x680d821fFE703762E7755c52C2a5E8556519EEDc;
address[] public deployed_forwarders;
uint public forwarders_count = 0;
address public last_forwarder_created;
modifier onlyOwnerOrCreator {
require(msg.sender == owner1 || msg.sender == owner2 || msg.sender == owner3 || msg.sender == creator);
_;
}
constructor() public {
creator = msg.sender;
}
function create_forwarder() public onlyOwnerOrCreator {
address new_forwarder = new Forwarder();
deployed_forwarders.push(new_forwarder);
last_forwarder_created = new_forwarder;
forwarders_count += 1;
}
function get_deployed_forwarders() public view returns (address[]) {
return deployed_forwarders;
}
}
contract Forwarder {
address private parentAddress = 0x7aeCf441966CA8486F4cBAa62fa9eF2D557f9ba7;
address private owner1 = 0x6CAa636cFFbCbb2043A3322c04dE3f26b1fa6555;
address private owner2 = 0xbc2d90C2D3A87ba3fC8B23aA951A9936A6D68121;
address private owner3 = 0x680d821fFE703762E7755c52C2a5E8556519EEDc;
event ForwarderDeposited(address from, uint value, bytes data);
constructor() public {
}
modifier onlyOwner {
require(msg.sender == owner1 || msg.sender == owner2 || msg.sender == owner3);
_;
}
function() public payable {
parentAddress.transfer(msg.value);
emit ForwarderDeposited(msg.sender, msg.value, msg.data);
}
function flushTokens(address tokenContractAddress) public onlyOwner {
ERC20Interface instance = ERC20Interface(tokenContractAddress);
address forwarderAddress = address(this);
uint forwarderBalance = instance.balanceOf(forwarderAddress);
if (forwarderBalance == 0) {
return;
}
if (!instance.transfer(parentAddress, forwarderBalance)) {
revert();
}
}
function flush() public onlyOwner {
uint my_balance = address(this).balance;
if (my_balance == 0){
return;
} else {
parentAddress.transfer(address(this).balance);
}
}
}
contract ERC20Interface {
function transfer(address _to, uint256 _value) public returns (bool success);
function balanceOf(address _owner) public constant returns (uint256 balance);
}