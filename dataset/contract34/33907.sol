contract Transferable {
function transfer(address to, uint256 value) public returns (bool);
}
contract DevTeamContract{
struct Transaction{
address _to;
uint256 amount;
uint256 oldAmount;
uint256 registrationBlock;
address from;
}
modifier isHuman() {
var sndr = msg.sender;
var orgn = tx.origin;
if(sndr != orgn){
revert();
}
else{
_;
}
}
modifier isOwner() {
if(owners[msg.sender]>0){
_;
}
else{
revert();
}
}
uint256 public pendingAmount = 0;
uint256 public constant  WAIT_BLOCKS = 15000;
uint256 constant MINIMUM_CONFIRMATION_COUNT = 3;
uint256 constant USER1_CODE = 1;
address constant USER1_ACCOUNT1 = 0x383125Faf0c83671D42Ac941BDc33cd38131a9d1;
address constant USER1_ACCOUNT2 = 0x77E6a4a8d482045fF42C803977AF6f5b429152c8;
address constant USER1_ACCOUNT3 = 0x862d9A8018D4A6A9875e1c52540C0367EB0D77a8;
uint256 constant USER_PAT_CODE = 2;
address constant USER_PAT_ACCOUNT1 = 0x19aC51538453126D027e49E7997a3a24FBfb6010;
address constant USER_PAT_ACCOUNT2 = 0x987BC45e8eC6C9D3b620326Dd26313BC4F8a7D81;
uint256 constant USER_JRKP_CODE = 4;
address constant USER_JRKP_ACCOUNT1 = 0x2C4a6B54718821b4eA6700086E8FcC4651289cBC;
address constant USER_JRKP_ACCOUNT2 = 0x5f55c525C21Fe54D826a63Fc27EaCf35AA9B1481;
uint256 constant USER_MBL_CODE = 8;
address constant USER_MBL_ACCOUNT1 = 0x678C66747e96258EFCDE4AF5f6b408dC00D68c42;
address constant USER_MBL_ACCOUNT2 = 0xb6407A53E41B09cf35a25c55e18bFFf2163879b5;
uint256 constant USER_DEV_CODE = 16;
address constant USER_DEV_ACCOUNT1 = 0x94DA43C587c515AD30eA86a208603a7586D2C25F;
address constant USER_DEV_ACCOUNT2 = 0x189891d02445D87e70d515fD2159416f023B0087;
mapping (address => uint256) public owners;
mapping (uint256 => uint256) public confirmations;
Transaction[] public transactions  ;
function DevTeamContract() public{
SetupAccounts();
}
function GetNow() public constant returns(uint256){
return block.number;
}
function SetupAccounts() public{
owners[USER1_ACCOUNT1] = USER1_CODE;
owners[USER1_ACCOUNT2] = USER1_CODE;
owners[USER1_ACCOUNT3] = USER1_CODE;
owners[USER_PAT_ACCOUNT1] = USER_PAT_CODE;
owners[USER_PAT_ACCOUNT2] = USER_PAT_CODE;
owners[USER_DEV_ACCOUNT1] = USER_DEV_CODE;
owners[USER_DEV_ACCOUNT2] = USER_DEV_CODE;
owners[USER_JRKP_ACCOUNT1] = USER_JRKP_CODE;
owners[USER_JRKP_ACCOUNT2] = USER_JRKP_CODE;
owners[USER_MBL_ACCOUNT1] = USER_MBL_CODE;
owners[USER_MBL_ACCOUNT2] = USER_MBL_CODE;
}
function getTotalAmount() constant public returns(uint256){
return (this.balance);
}
function getTotalNumberOfTransactions() constant public returns(uint256){
return (transactions.length);
}
function countConfirmations(uint256 i) constant public returns(uint256){
uint256 counter = 0;
uint256 tmp = 0;
tmp = confirmations[i];
if(tmp%2==0){
return 0;
}
while(tmp>0){
counter = counter + tmp%2 ;
tmp = tmp/2;
}
return counter;
}
function recieveFunds() payable public{
}
function RegisterTransaction(address _to,uint256 amount) isHuman isOwner public{
if(owners[msg.sender]>0 && amount+pendingAmount<=this.balance){
transactions.push(Transaction(_to,amount,amount,this.GetNow(),address(0)));
pendingAmount = amount+pendingAmount;
}
}
function RegisterTokenTransaction(address _to,uint256 amount,address _from) isHuman isOwner public{
if(owners[msg.sender]>0 && amount+pendingAmount<=this.balance){
transactions.push(Transaction(_to,amount,amount,this.GetNow(),_from));
pendingAmount = amount+pendingAmount;
}
}
function ConfirmTransaction(uint256 i)  isHuman isOwner public{
confirmations[i] = confirmations[i] | owners[msg.sender];
}
function ReverseConfirmTransaction(uint256 i)  isHuman isOwner public{
confirmations[i] = confirmations[i] & (~owners[msg.sender]);
}
function ProcessTransaction(uint256 i) isHuman isOwner public{
uint256 tmp;
if(owners[msg.sender]>0){
if(this.countConfirmations(i)>=MINIMUM_CONFIRMATION_COUNT
&& transactions[i].amount > 0){
if(transactions[i].from==address(0)){
tmp = transactions[i].amount;
transactions[i].amount = 0;
transactions[i].oldAmount = tmp;
transactions[i]._to.transfer(tmp);
pendingAmount = pendingAmount -tmp;
}
else{
var token = Transferable(transactions[i].from);
tmp = transactions[i].amount;
transactions[i].amount = 0;
transactions[i].oldAmount = tmp;
token.transfer(transactions[i]._to,tmp);
}
}
else{
if(transactions[i].registrationBlock<this.GetNow()-WAIT_BLOCKS ){
tmp = transactions[i].amount;
pendingAmount = pendingAmount -tmp;
transactions[i].amount = 0;
}
else{
assert(false);
}
}
}
}
}