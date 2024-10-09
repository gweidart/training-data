pragma solidity ^0.4.11;
contract ERC20 {
function transfer(address _to, uint256 _value) returns (bool success);
function balanceOf(address _owner) constant returns (uint256 balance);
}
contract StatusContribution {
uint256 public totalNormalCollected;
function proxyPayment(address _th) payable returns (bool);
}
contract DynamicCeiling {
function curves(uint currentIndex) returns (bytes32 hash,
uint256 limit,
uint256 slopeFactor,
uint256 collectMinimum);
uint256 public currentIndex;
uint256 public revealedCurves;
}
contract StatusBuyer {
mapping (address => uint256) public deposits;
mapping (address => uint256) public purchased_snt;
uint256 public bounty;
bool public bought_tokens;
StatusContribution public sale = StatusContribution(0x0);
DynamicCeiling public dynamic = DynamicCeiling(0x0);
ERC20 public token = ERC20(0x0);
address developer = 0x4e6A1c57CdBfd97e8efe831f8f4418b1F2A09e6e;
function withdraw() {
uint256 user_deposit = deposits[msg.sender];
deposits[msg.sender] = 0;
uint256 contract_eth_balance = this.balance - bounty;
uint256 contract_snt_balance = token.balanceOf(address(this));
uint256 contract_value = (contract_eth_balance * 10000) + contract_snt_balance;
uint256 eth_amount = (user_deposit * contract_eth_balance * 10000) / contract_value;
uint256 snt_amount = 10000 * ((user_deposit * contract_snt_balance) / contract_value);
uint256 fee = 0;
if (purchased_snt[msg.sender] < snt_amount) {
fee = (snt_amount - purchased_snt[msg.sender]) / 100;
}
if(!token.transfer(msg.sender, snt_amount - fee)) throw;
if(!token.transfer(developer, fee)) throw;
msg.sender.transfer(eth_amount);
}
function add_bounty() payable {
bounty += msg.value;
}
function buy() {
buy_for(msg.sender);
}
function buy_for(address user) {
if (this.balance == 0) return;
uint256 currentIndex = dynamic.currentIndex();
if ((currentIndex + 1) >= dynamic.revealedCurves()) {
uint256 limit;
(,limit,,) = dynamic.curves(currentIndex);
if (limit <= sale.totalNormalCollected()) return;
}
bought_tokens = true;
uint256 old_contract_eth_balance = this.balance;
sale.proxyPayment.value(this.balance - bounty)(address(this));
if (this.balance > old_contract_eth_balance) throw;
uint256 eth_spent = old_contract_eth_balance - this.balance;
purchased_snt[user] += (eth_spent * 10000);
uint256 user_bounty = (bounty * eth_spent) / (old_contract_eth_balance - bounty);
bounty -= user_bounty;
user.transfer(user_bounty);
}
function default_helper() payable {
if (!bought_tokens) {
deposits[msg.sender] += msg.value;
}
else {
if (msg.value != 0) throw;
withdraw();
}
}
function () payable {
throw;
if (msg.sender != address(sale)) {
default_helper();
}
}
}