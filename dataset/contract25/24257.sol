pragma solidity 0.4.18;
contract Protocol108 {
uint public version = 1;
uint length = 6480;
uint offset;
address public executor;
uint public cycle;
uint public volume;
function Protocol108() public {
}
function initialize() public payable {
assert(cycle == 0);
update();
}
function execute() public payable {
assert(cycle > 0);
assert(offset + length > now);
update();
}
function withdraw() public {
assert(cycle > 0);
assert(offset + length <= now);
require(msg.sender == executor);
cycle = 0;
executor.transfer(this.balance);
}
function update() private {
validate(msg.value);
offset = now;
executor = msg.sender;
cycle++;
volume += msg.value;
}
function validate(uint sequence) public constant returns (bool) {
require(sequence > 0);
return true;
}
function countdown() public constant returns (uint) {
if(cycle == 0) {
return length;
}
uint n = now;
if(offset + length > n) {
return offset + length - n;
}
return 0;
}
function() public payable {
if(cycle == 0) {
initialize();
}
else if(offset + length > now) {
execute();
}
else if(this.balance > 0) {
withdraw();
}
else {
revert();
}
}
}
contract Protocol108v2 is Protocol108 {
uint public version = 2;
function Protocol108v2() Protocol108() public {
}
function validate(uint sequence) public constant returns (bool) {
uint c = countdown();
require(
c < 60 && (
sequence == 4815162342
|| sequence == 48151623420
|| sequence == 481516234200
) ||
c < 240 && (
sequence == 4815162342000
|| sequence == 48151623420000
|| sequence == 481516234200000
) || (
sequence == 4815162342000000
|| sequence == 48151623420000000
|| sequence == 481516234200000000
|| sequence == 4815162342000000000
|| sequence == 48151623420000000000
|| sequence == 481516234200000000000
|| seqSearch(sequence, 12, 56) != -1
)
);
return true;
}
function seqSearch(uint sequence, uint offset, uint length) private constant returns (int) {
for(uint i = offset; i < offset + length; i++) {
if(sequence == 4815162342 * 10 ** i) {
return int(i);
}
}
return -1;
}
}