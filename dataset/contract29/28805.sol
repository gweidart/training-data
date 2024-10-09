pragma solidity ^0.4.19;
contract Ownable {
address public owner;
function Ownable() internal {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
owner = newOwner;
}
}
contract TariInvestment is Ownable {
address public investmentAddress = 0x33eFC5120D99a63bdF990013ECaBbd6c900803CE;
address public majorPartnerAddress = 0x8f0592bDCeE38774d93bC1fd2c97ee6540385356;
address public minorPartnerAddress = 0xC787C3f6F75D7195361b64318CE019f90507f806;
mapping(address => uint) public balances;
uint public totalInvestment;
uint public availableRefunds;
uint public refundingDeadline;
uint public withdrawal_gas;
enum State{Open, Refunding}
State public state = State.Open;
function TariInvestment() public {
refundingDeadline = now + 4 days;
set_withdrawal_gas(1000);
}
function() payable public {
require(state == State.Open);
balances[msg.sender] += msg.value;
totalInvestment += msg.value;
}
function execute_transfer(uint transfer_amount, uint gas_amount) public onlyOwner {
require(state == State.Open);
uint major_fee = transfer_amount * 15 / 1000;
uint minor_fee = transfer_amount * 10 / 1000;
require(majorPartnerAddress.call.gas(gas_amount).value(major_fee)());
require(minorPartnerAddress.call.gas(gas_amount).value(minor_fee)());
require(investmentAddress.call.gas(gas_amount).value(transfer_amount - major_fee - minor_fee)());
}
function execute_transfer_all(uint gas_amount) public onlyOwner {
execute_transfer(this.balance, gas_amount);
}
function withdraw() public {
if (state != State.Refunding) {
require(refundingDeadline <= now);
state = State.Refunding;
availableRefunds = this.balance;
}
uint withdrawal = availableRefunds * balances[msg.sender] / totalInvestment;
balances[msg.sender] = 0;
require(msg.sender.call.gas(withdrawal_gas).value(withdrawal)());
}
function enable_refunds() public onlyOwner {
state = State.Refunding;
}
function set_withdrawal_gas(uint gas_amount) public onlyOwner {
withdrawal_gas = gas_amount;
}
}