pragma solidity ^0.4.4;
contract Owned {
address public owner;
function Owned() { owner = msg.sender; }
function delegate(address _owner) onlyOwner
{ owner = _owner; }
modifier onlyOwner { if (msg.sender != owner) throw; _; }
}
contract Mortal is Owned {
function kill() onlyOwner
{ suicide(owner); }
}
contract Comission is Mortal {
address public ledger;
bytes32 public taxman;
uint    public taxPerc;
function Comission(address _ledger, bytes32 _taxman, uint _taxPerc) {
ledger  = _ledger;
taxman  = _taxman;
taxPerc = _taxPerc;
}
function process(bytes32 _destination) payable returns (bool) {
if (msg.value < 100) throw;
var tax = msg.value * taxPerc / 100;
var refill = bytes4(sha3("refill(bytes32)"));
if ( !ledger.call.value(tax)(refill, taxman)
|| !ledger.call.value(msg.value - tax)(refill, _destination)
) throw;
return true;
}
}
contract Invoice is Mortal {
address   public signer;
uint      public closeBlock;
Comission public comission;
string    public description;
bytes32   public beneficiary;
uint      public value;
function Invoice(address _comission,
string  _description,
bytes32 _beneficiary,
uint    _value) {
comission   = Comission(_comission);
description = _description;
beneficiary = _beneficiary;
value       = _value;
}
function withdraw() onlyOwner {
if (closeBlock != 0) {
if (!comission.process.value(value)(beneficiary)) throw;
}
}
function () payable {
if (msg.value != value
|| closeBlock != 0) throw;
closeBlock = block.number;
signer = msg.sender;
PaymentReceived();
}
event PaymentReceived();
}
library CreatorInvoice {
function create(address _comission, string _description, bytes32 _beneficiary, uint256 _value) returns (Invoice)
{ return new Invoice(_comission, _description, _beneficiary, _value); }
function version() constant returns (string)
{ return "v0.5.0 (a9ea4c6c)"; }
function abi() constant returns (string)
{ return '[{"constant":true,"inputs":[],"name":"signer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"beneficiary","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"comission","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"value","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"description","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"closeBlock","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_comission","type":"address"},{"name":"_description","type":"string"},{"name":"_beneficiary","type":"bytes32"},{"name":"_value","type":"uint256"}],"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[],"name":"PaymentReceived","type":"event"}]'; }
}