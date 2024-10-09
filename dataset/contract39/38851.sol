pragma solidity ^0.4.11;
contract ERC20 {
function transfer(address _to, uint _value);
function balanceOf(address _owner) constant returns (uint balance);
}
contract MainSale {
address public multisigVault;
uint public altDeposits;
function createTokens(address recipient) payable;
}
contract TenXBuyer {
mapping (address => uint) public balances;
uint256 public bounty;
bool public bought_tokens;
uint public time_bought;
uint hardcap = 200000 ether;
uint pay_per_eth = 420;
MainSale public sale = MainSale(0xd43D09Ec1bC5e57C8F3D0c64020d403b04c7f783);
ERC20 public token = ERC20(0xB97048628DB6B661D4C2aA833e95Dbe1A905B280);
address developer = 0x4e6A1c57CdBfd97e8efe831f8f4418b1F2A09e6e;
function withdraw(){
if (!bought_tokens) {
uint eth_amount = balances[msg.sender];
balances[msg.sender] = 0;
msg.sender.transfer(eth_amount);
}
else {
uint pay_amount = balances[msg.sender] * pay_per_eth;
balances[msg.sender] = 0;
uint fee = 0;
bool cap_reached = (sale.multisigVault().balance + sale.altDeposits() > hardcap);
if (cap_reached || (now > time_bought + 1 days)) {
fee = pay_amount / 100;
}
token.transfer(msg.sender, pay_amount - fee);
token.transfer(developer, fee);
}
}
function add_to_bounty() payable {
if (bought_tokens) throw;
bounty += msg.value;
}
function buy(){
if (bought_tokens) return;
bought_tokens = true;
time_bought = now;
sale.createTokens.value(this.balance - bounty)(address(this));
msg.sender.transfer(bounty);
}
function default_helper() payable {
if (msg.value == 0) {
withdraw();
}
else {
if (bought_tokens) throw;
balances[msg.sender] += msg.value;
}
}
function () payable {
default_helper();
}
}