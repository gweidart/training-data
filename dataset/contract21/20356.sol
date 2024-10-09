pragma solidity ^0.4.21;
contract Items{
address owner;
address helper = 0x690F34053ddC11bdFF95D44bdfEb6B0b83CBAb58;
uint16 public DevFee = 500;
uint16 public HelperPortion = 5000;
uint16 public PriceIncrease = 2000;
struct Item{
address Owner;
uint256 Price;
}
mapping(uint256 => Item) Market;
uint256 public NextItemID = 0;
event ItemBought(address owner, uint256 id, uint256 newprice);
function Items() public {
owner = msg.sender;
AddMultipleItems(0.006666 ether, 36);
Market[0].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[0].Price = 53280000000000000;
Market[1].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[1].Price = 26640000000000000;
Market[2].Owner = 0xb080b202b921d0d1fd804d0071615eb09e326aac;
Market[2].Price = 854280000000000000;
Market[3].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[3].Price = 26640000000000000;
Market[4].Owner = 0xb080b202b921d0d1fd804d0071615eb09e326aac;
Market[4].Price = 213120000000000000;
Market[5].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[5].Price = 13320000000000000;
Market[6].Owner = 0xd33614943bcaadb857a58ff7c36157f21643df36;
Market[6].Price = 26640000000000000;
Market[7].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[7].Price = 53280000000000000;
Market[8].Owner = 0xd33614943bcaadb857a58ff7c36157f21643df36;
Market[8].Price = 26640000000000000;
Market[9].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[9].Price = 53280000000000000;
Market[10].Owner = 0x0960069855bd812717e5a8f63c302b4e43bad89f;
Market[10].Price = 13320000000000000;
Market[11].Owner = 0xd3dead0690e4df17e4de54be642ca967ccf082b8;
Market[11].Price = 13320000000000000;
Market[12].Owner = 0xc34434842b9dc9cab4e4727298a166be765b4f32;
Market[12].Price = 13320000000000000;
Market[13].Owner = 0xc34434842b9dc9cab4e4727298a166be765b4f32;
Market[13].Price = 13320000000000000;
Market[14].Owner = 0x874c6f81c14f01c0cb9006a98213803cd7af745f;
Market[14].Price = 53280000000000000;
Market[15].Owner = 0xd33614943bcaadb857a58ff7c36157f21643df36;
Market[15].Price = 26640000000000000;
Market[16].Owner = 0x3130259deedb3052e24fad9d5e1f490cb8cccaa0;
Market[16].Price = 13320000000000000;
}
function ItemInfo(uint256 id) public view returns (uint256 ItemPrice, address CurrentOwner){
return (Market[id].Price, Market[id].Owner);
}
function AddItem(uint256 price) public {
require(price != 0);
require(msg.sender == owner);
Item memory ItemToAdd = Item(0x0, price);
Market[NextItemID] = ItemToAdd;
NextItemID = add(NextItemID, 1);
}
function AddMultipleItems(uint256 price, uint8 howmuch) public {
require(msg.sender == owner);
require(price != 0);
require(howmuch != 255);
uint8 i=0;
for (i; i<howmuch; i++){
AddItem(price);
}
}
function BuyItem(uint256 id) payable public{
Item storage MyItem = Market[id];
require(MyItem.Price != 0);
require(msg.value >= MyItem.Price);
uint256 ValueLeft = DoDev(MyItem.Price);
uint256 Excess = sub(msg.value, MyItem.Price);
if (Excess > 0){
msg.sender.transfer(Excess);
}
address target = MyItem.Owner;
if (target == 0x0){
target = owner;
}
target.transfer(ValueLeft);
MyItem.Price = mul(MyItem.Price, (uint256(PriceIncrease) + uint256(10000)))/10000;
MyItem.Owner = msg.sender;
emit ItemBought(msg.sender, id, MyItem.Price);
}
function DoDev(uint256 val) internal returns (uint256){
uint256 tval = (mul(val, DevFee)) / 10000;
uint256 hval = (mul(tval, HelperPortion)) / 10000;
uint256 dval = sub(tval, hval);
owner.transfer(dval);
helper.transfer(hval);
return (sub(val,tval));
}
function SetDevFee(uint16 tfee) public {
require(msg.sender == owner);
require(tfee <= 650);
DevFee = tfee;
}
function SetHFee(uint16 hfee) public  {
require(msg.sender == owner);
require(hfee <= 10000);
HelperPortion = hfee;
}
function SetPriceIncrease(uint16 increase) public  {
require(msg.sender == owner);
PriceIncrease = increase;
}
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}