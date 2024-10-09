pragma solidity ^0.4.7;
contract Broker {
enum State { Created, Validated, Locked, Inactive }
State public state;
enum FileState {
Created,
Invalidated
}
struct File{
bytes32 purpose;
string name;
string ipfshash;
FileState state;
}
struct Item{
string name;
uint   price;
string detail;
File[] documents;
}
Item public item;
address public seller;
address public buyer;
address public broker;
uint    public brokerFee;
uint    public developerfee = 0.1 finney;
uint    minimumdeveloperfee = 0.1 finney;
address developer = 0x001973f023e4c03ef60ea34084b63e7790d463e595;
address creator = 0x0;
modifier onlyBuyer() {
require(msg.sender == buyer);
_;
}
modifier onlySeller() {
require(msg.sender == seller);
_;
}
modifier onlyCreator() {
require(msg.sender == creator);
_;
}
modifier onlyBroker() {
require(msg.sender == broker);
_;
}
modifier inState(State _state) {
require(state == _state);
_;
}
modifier condition(bool _condition) {
require(_condition);
_;
}
event Aborted();
event PurchaseConfirmed();
event ItemReceived();
event Validated();
function Broker(bool isbroker) {
if(creator==address(0)){
if(isbroker)
broker = msg.sender;
else
seller = msg.sender;
creator = msg.sender;
state = State.Created;
brokerFee = 50;
}
}
function joinAsBuyer(){
if(buyer==address(0)){
buyer = msg.sender;
}
}
function joinAsBroker(){
if(broker==address(0)){
broker = msg.sender;
}
}
function createOrSet(string name, uint price, string detail)
inState(State.Created)
onlyCreator
{
require(price > minimumdeveloperfee);
item.name = name;
item.price = price;
item.detail = detail;
developerfee = (price/1000)<minimumdeveloperfee ? minimumdeveloperfee : (price/1000);
}
function getBroker()
constant returns(address, uint)
{
return (broker, brokerFee);
}
function getSeller()
constant returns(address)
{
return (seller);
}
function setBroker(address _address, uint fee)
{
brokerFee = fee;
broker = _address;
}
function setBrokerFee(uint fee)
{
brokerFee = fee;
}
function setSeller(address _address)
{
seller = _address;
}
function parseAddr(string _a) internal returns (address){
bytes memory tmp = bytes(_a);
uint160 iaddr = 0;
uint160 b1;
uint160 b2;
for (uint i=2; i<2+2*20; i+=2){
iaddr *= 256;
b1 = uint160(tmp[i]);
b2 = uint160(tmp[i+1]);
if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
iaddr += (b1*16+b2);
}
return address(iaddr);
}
function addDocument(bytes32 _purpose, string _name, string _ipfshash)
{
require(state != State.Inactive);
require(state != State.Locked);
item.documents.push( File({
purpose:_purpose, name:_name, ipfshash:_ipfshash, state:FileState.Created}
)
);
}
function deleteDocument(uint index)
{
require(state != State.Inactive);
require(state != State.Locked);
if(index<item.documents.length){
item.documents[index].state = FileState.Invalidated;
}
}
function validate()
onlyBroker
inState(State.Created)
{
Validated();
state = State.Validated;
}
function abort()
onlySeller
inState(State.Created)
{
Aborted();
state = State.Inactive;
seller.transfer(this.balance);
}
function abortByBroker()
onlyBroker
{
require(state != State.Inactive);
state = State.Inactive;
Aborted();
buyer.transfer(this.balance);
}
function confirmPurchase()
inState(State.Validated)
condition(msg.value == item.price)
payable
{
state = State.Locked;
buyer = msg.sender;
PurchaseConfirmed();
}
function confirmReceived()
onlyBroker
inState(State.Locked)
{
state = State.Inactive;
seller.transfer(this.balance-brokerFee-developerfee);
broker.transfer(brokerFee);
developer.transfer(developerfee);
ItemReceived();
}
function getInfo() constant returns (State, string, uint, string, uint, uint){
return (state, item.name, item.price, item.detail, item.documents.length, developerfee);
}
function getFileAt(uint index) constant returns(uint, bytes32, string, string, FileState){
return (index,
item.documents[index].purpose,
item.documents[index].name,
item.documents[index].ipfshash,
item.documents[index].state);
}
}