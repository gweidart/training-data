pragma solidity ^0.4.24;
contract Zhoan {
string public token_name;
address private admin_add;
uint8 private decimals = 18;
uint private present_money=0;
uint256 private max_circulation;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping(address => uint) public contract_users;
constructor(uint limit,string symbol) public {
admin_add=msg.sender;
max_circulation=limit * 10 ** uint256(decimals);
contract_users[admin_add]=max_circulation;
token_name = symbol;
}
function setPresentMoney (uint money) public{
address opt_user=msg.sender;
if(opt_user == admin_add){
present_money = money;
}
}
function addNewUser(address newUser) public{
address opt_user=msg.sender;
if(opt_user == admin_add){
transfer_opt(admin_add,newUser,present_money);
}
}
function userTransfer(address from,address to,uint256 value) public{
transfer_opt(from,to,value);
}
function adminSendMoneyToUser(address to,uint256 value) public{
address opt_add=msg.sender;
if(opt_add == admin_add){
transfer_opt(admin_add,to,value);
}
}
function burnAccountMoeny(address add,uint256 value) public{
address opt_add=msg.sender;
require(opt_add == admin_add);
require(contract_users[add]>value);
contract_users[add]-=value;
max_circulation -=value;
}
function transfer_opt(address from,address to,uint value) private{
require(to != 0x0);
require(contract_users[from] >= value);
require(contract_users[to] + value >= contract_users[to]);
uint previousBalances = contract_users[from] + contract_users[to];
contract_users[from] -= value;
contract_users[to] += value;
emit Transfer(from,to,value);
assert(contract_users[from] + contract_users[to] == previousBalances);
}
function queryBalance(address add) public view returns(uint){
return contract_users[add];
}
function surplus() public view returns(uint,uint){
return (contract_users[admin_add],max_circulation);
}
}