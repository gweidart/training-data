contract Dividend{
uint256 constant div = 1000;
uint256 public price = (0.01 ether);
uint256 public baseprice = price;
uint256 public previousprice = 0;
address public dev;
address public divholder;
address public current_start_divholder = divholder;
uint256 increase = 2000;
uint256 min = 1500;
uint256 minprofit = 1000;
uint256 public divpaid = 0;
function Dividend(){
dev = msg.sender;
}
event t(uint256 t);
function NewPrice() public  returns (uint256){
uint ret = price * (increase + 10000) / 10000;
return ret;
}
function Withdraw(){
_withdraw(true);
}
function _withdraw(bool devpay) internal {
if (divholder != current_start_divholder){
uint256 bal = address(this).balance;
uint256 pay = (bal * div) / 10000;
divholder.transfer(pay);
divpaid = divpaid + pay;
}
if (devpay){
dev.transfer(address(this).balance);
}
}
function Buy() payable{
var val = msg.value;
require(val >= price);
if (val > price){
msg.sender.transfer(val-price);
}
_withdraw(false);
if ((current_start_divholder != divholder) && divpaid < ((previousprice * (10000 + minprofit))/10000)){
uint256 nmake =  ((previousprice * (10000 + minprofit))/10000) - divpaid;
t(nmake / (1 finney));
divholder.transfer(nmake);
}
dev.transfer(address(this).balance);
divpaid = 0;
previousprice = price;
price = NewPrice();
divholder = msg.sender;
}
function() payable {
}
}