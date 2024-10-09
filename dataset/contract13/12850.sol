pragma solidity ^0.4.23;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor () public {
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
contract Bitwords is Ownable {
mapping(address => uint) public advertiserBalances;
address public bitwordsWithdrawlAddress = 0xe4eecf51618e1ec3c07837e8bee39f0a33d1eb2b;
uint public bitwordsCutOutof100 = 30;
function() public payable {
advertiserBalances[msg.sender] += msg.value;
emit Deposit(msg.sender, msg.value);
}
function setBitwordsWithdrawlAddress (address newAddress) onlyOwner public {
bitwordsWithdrawlAddress = newAddress;
}
function setBitwordsCut (uint cut) onlyOwner public {
require(cut <= 30, "cut cannot be more than 30%");
bitwordsCutOutof100 = cut;
}
function chargeAdvertiser (address advertiser, uint clicks, uint cpc, address publisher) onlyOwner public {
uint cost = clicks * cpc;
if (advertiserBalances[advertiser] - cost <= 0) return;
if (bitwordsCutOutof100 > 30) return;
advertiserBalances[advertiser] -= cost;
uint publisherCut = cost * (100 - bitwordsCutOutof100) / 100;
uint bitwordsCut = cost - publisherCut;
publisher.transfer(publisherCut);
bitwordsWithdrawlAddress.transfer(bitwordsCut);
emit PayoutToPublisher(publisher, publisherCut);
emit DeductFromAdvertiser(advertiser, cost);
}
function refundAdveriser (uint amount) public {
require(advertiserBalances[msg.sender] - amount >= 0, "Insufficient balance");
advertiserBalances[msg.sender] -= amount;
msg.sender.transfer(amount);
emit RefundAdvertiser(msg.sender, amount);
}
event Deposit(address indexed _from, uint _value);
event DeductFromAdvertiser(address indexed _to, uint _value);
event PayoutToPublisher(address indexed _to, uint _value);
event RefundAdvertiser(address indexed _from, uint _value);
}