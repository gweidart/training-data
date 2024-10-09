pragma solidity ^0.4.21;
contract Dividends{
uint256 constant TokenSupply = 10000000;
uint256 public TotalPaid = 0;
uint16 public Tax = 1250;
address dev;
bool public StopSell=false;
mapping (address => uint256) public MyTokens;
mapping (address => uint256) public DividendCollectSince;
mapping(address => uint256[2]) public SellOrder;
function GetSellOrderDetails(address who) public view returns (uint256, uint256){
return (SellOrder[who][0], SellOrder[who][1]);
}
function ViewMyTokens(address who) public view returns (uint256){
return MyTokens[who];
}
function ViewMyDivs(address who) public view returns (uint256){
uint256 tkns = MyTokens[who];
if (tkns==0){
return 0;
}
return (GetDividends(who, tkns));
}
function Bal() public view returns (uint256){
return (address(this).balance);
}
function Dividends() public {
dev = msg.sender;
MyTokens[msg.sender] =  8000000;
MyTokens[address(0x83c0Efc6d8B16D87BFe1335AB6BcAb3Ed3960285)] = 200000;
MyTokens[address(0x26581d1983ced8955C170eB4d3222DCd3845a092)] = 200000;
MyTokens[address(0x3130259deEdb3052E24FAD9d5E1f490CB8CCcaa0)] = 100000;
MyTokens[address(0x4f0d861281161f39c62B790995fb1e7a0B81B07b)] = 200000;
MyTokens[address(0x36E058332aE39efaD2315776B9c844E30d07388B)] =  20000;
MyTokens[address(0x1f2672E17fD7Ec4b52B7F40D41eC5C477fe85c0c)] =  40000;
MyTokens[address(0xedDaD54E9e1F8dd01e815d84b255998a0a901BbF)] =  20000;
MyTokens[address(0x0a3239799518E7F7F339867A4739282014b97Dcf)] = 500000;
MyTokens[address(0x29A9c76aD091c015C12081A1B201c3ea56884579)] = 600000;
MyTokens[address(0x0668deA6B5ec94D7Ce3C43Fe477888eee2FC1b2C)] = 100000;
MyTokens[address(0x0982a0bf061f3cec2a004b4d2c802F479099C971)] =  20000;
}
function GetDividends(address who, uint256 TokenAmount ) internal view  returns(uint256){
if (TokenAmount == 0){
return 0;
}
uint256 TotalContractIn = address(this).balance + TotalPaid;
uint256 MyBalance = sub(TotalContractIn, DividendCollectSince[who]);
return  ((MyBalance * TokenAmount) / (TokenSupply));
}
function EmergencyStopSell(bool setting) public {
require(msg.sender==dev);
StopSell=setting;
}
event Sold(address Buyer, address Seller, uint256 price, uint256 tokens);
function Buy(address who, uint256 price_max) public payable {
require(!StopSell);
require(who!=msg.sender && who!=tx.origin);
uint256[2] storage order = SellOrder[who];
uint256 amt_available = order[0];
uint256 price = order[1];
require(price <= price_max);
uint256 excess = 0;
if (amt_available == 0){
revert();
}
uint256 max = mul(amt_available, price);
uint256 currval = msg.value;
if (currval > max){
excess = (currval-max);
currval = max;
}
uint256 take = currval / price;
if (take == 0){
revert();
}
excess = excess + sub(currval, mul(take, price));
currval = sub(currval,sub(currval, mul(take, price)));
uint256 fee = (mul(Tax, currval))/10000;
MyTokens[who] = MyTokens[who] - take;
SellOrder[who][0] = SellOrder[who][0]-take;
MyTokens[msg.sender] = MyTokens[msg.sender] + take;
emit Sold(msg.sender, who, price, take);
dev.transfer(fee);
who.transfer(currval-fee);
if ((excess) > 0){
msg.sender.transfer(excess);
}
_withdraw(who, MyTokens[who]+take);
if (sub(MyTokens[msg.sender],take) > 0){
_withdraw(msg.sender,MyTokens[msg.sender]-take);
}
else{
_withdraw(msg.sender, 0);
}
}
function Withdraw() public {
_withdraw(msg.sender, MyTokens[msg.sender]);
}
event GiveETH(address who, uint256 yummy_eth);
function _withdraw(address who, uint256 amt) internal{
uint256 divs = GetDividends(who, amt);
TotalPaid = TotalPaid + divs;
DividendCollectSince[who] = sub(TotalPaid + address(this).balance, divs);
emit GiveETH(who, divs);
who.transfer(divs);
}
event SellOrderPlaced(address who, uint256 amt, uint256 price);
function PlaceSellOrder(uint256 amt, uint256 price) public {
if (amt > MyTokens[msg.sender]){
revert();
}
SellOrder[msg.sender] = [amt,price];
emit SellOrderPlaced(msg.sender, amt, price);
}
function ChangeTax(uint16 amt) public {
require (amt <= 2500);
require(msg.sender == dev);
Tax=amt;
}
function() public payable {
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
}