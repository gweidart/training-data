pragma solidity ^0.4.23;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract TokenWithDates {
function getBatch(address _address , uint _batch) public constant returns(uint _quant,uint _age);
function getFirstBatch(address _address) public constant returns(uint _quant,uint _age);
function resetBatches(address _address);
function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
mapping(address => uint) public maxIndex;
mapping(address => uint) public minIndex;
uint8 public decimals;
}
contract JeiCoinSwapper {
string public version = "v1.5";
address public rootAddress;
address public Owner;
bool public locked;
address public tokenAdd;
address public tokenSpender;
TokenWithDates public token;
uint fortNight = 15;
mapping(address => uint) public lastFortnightPayed;
uint public initialDate;
uint[] public yearlyInterest;
modifier onlyOwner() {
if ( msg.sender != rootAddress && msg.sender != Owner ) revert();
_;
}
modifier onlyRoot() {
if ( msg.sender != rootAddress ) revert();
_;
}
modifier isUnlocked() {
require(!locked);
_;
}
event Batch(uint batchAmount , uint batchAge , uint totalAmount);
event Message(string message);
constructor() public {
rootAddress = msg.sender;
Owner = msg.sender;
tokenAdd = address(0x9da0D98c9d051c594038eb3267fBd0FAf3Da9e48);
tokenSpender = address(0xAd50cACa8cD726600840E745D0AE6B6E78861dBc);
token = TokenWithDates(tokenAdd);
initialDate = now;
yearlyInterest.push(70);
yearlyInterest.push(50);
yearlyInterest.push(20);
yearlyInterest.push(10);
}
function payInterests() isUnlocked public {
if (fortnightsFromLast() == 0) {
emit Message("0 fortnights passed");
return;
}
uint amountToPay = calculateInterest(msg.sender);
if (amountToPay == 0) {
emit Message("There are not 150 tokens with interests to pay");
return;
}
lastFortnightPayed[msg.sender] = now;
require(token.transferFrom(tokenSpender,msg.sender,amountToPay));
}
function getBatch(address _address , uint _index) public view returns (uint _quant , uint _age) {
return (token.getBatch(_address,_index));
}
function getFirstBatch(address _address) public view returns (uint _quant , uint _age) {
return (token.getFirstBatch(_address));
}
function calculateInterest(address _address) private returns (uint _amount) {
uint totalAmount = 0;
uint tokenCounted;
uint intBatch;
uint batchInterest;
uint batchAmount;
uint batchDate;
for (uint i = token.minIndex(_address); i < token.maxIndex(_address); i++) {
( batchAmount , batchDate) = token.getBatch(_address,i);
intBatch = interest(batchDate);
batchInterest = batchAmount * intBatch / 1 ether / 100;
if (intBatch > 0) tokenCounted += batchAmount;
totalAmount += batchInterest;
emit Batch(
batchAmount,
secToDays(softSub(now,batchDate)),
batchInterest
);
}
if ( tokenCounted >= 150 ether ) return totalAmount; else return 0;
}
function interest(uint _batchDate) private view returns (uint _interest) {
uint _age = secToDays(softSub(now,_batchDate));
while ( _age >= 106 ) {
_age = _age - 103;
}
if (_age < 3 ) return 0;
if (_age > 91) return 0;
uint _tokenFortnights = _age / fortNight;
uint _fortnightsFromLast = fortnightsFromLast();
if ( _tokenFortnights > _fortnightsFromLast ) _tokenFortnights = _fortnightsFromLast;
uint yearsNow = secToDays(now - initialDate) / 365;
if (yearsNow > 3) yearsNow = 3;
_interest = 1 ether * yearlyInterest[yearsNow] * _tokenFortnights / 24 ;
}
function secToDays(uint _time) private pure returns(uint _days) {
return _time / 60 / 60 / 24;
}
function fortnightsFromLast() public view returns(uint _fortnights) {
_fortnights = secToDays(softSub(now,initialDate)) / fortNight;
_fortnights = softSub(_fortnights, secToDays(softSub(lastFortnightPayed[msg.sender],initialDate)) / fortNight);
}
function safeAdd(uint x, uint y) private pure returns (uint z) {
require((z = x + y) >= x);
}
function softSub(uint x, uint y) private pure returns (uint z) {
z = x - y;
if (z > x ) z = 0;
}
}