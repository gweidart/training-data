pragma solidity ^0.4.24;
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
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
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
}
contract AddressList is Ownable {
mapping(address => uint8) public whitelist;
address operator_;
constructor(address _operator) public{
require(_operator != address(0));
operator_ = _operator;
}
modifier onlyOps() {
require((msg.sender == operator_) || (msg.sender == owner));
_;
}
event OperatorTransferred(address indexed newOperator);
function transferOperator(address newOperator) public onlyOwner {
operator_ = newOperator;
emit OperatorTransferred(operator_);
}
function operator() public view returns (address) {
return operator_;
}
event WhitelistUpdated(address indexed account, uint8 phase);
function updateWhitelist(address _account, uint8 _phase) external onlyOps returns (bool) {
require(_account != address(0));
require(_phase <= 2);
whitelist[_account] = _phase;
emit WhitelistUpdated(_account, _phase);
return true;
}
}