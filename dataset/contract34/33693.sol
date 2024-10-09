pragma solidity ^0.4.13;
contract ERC20 {
function transfer(address _to, uint256 _value) returns (bool success);
function balanceOf(address _owner) constant returns (uint256 balance);
}
contract QUANTFund {
mapping (address => uint256) public balances;
bool public bought_tokens = false;
uint256 public contract_eth_value;
uint256 constant public max_raised_amount = 200 ether;
bytes32 hash_pwd = 0xe1ccf0005757f598f4ff97410bc0d3ff7248f92b17ed522a0f649dbde89dfc02;
address public sale = 0x0;
address constant public creator = 0xEE06BdDafFA56a303718DE53A5bc347EfbE4C68f;
function perform_withdraw(address tokenAddress) {
require(bought_tokens);
ERC20 token = ERC20(tokenAddress);
uint256 contract_token_balance = token.balanceOf(address(this));
require(contract_token_balance == 0);
uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
contract_eth_value -= balances[msg.sender];
balances[msg.sender] = 0;
require(!token.transfer(msg.sender, tokens_to_withdraw));
}
function refund_me() {
require(!bought_tokens);
uint256 eth_to_withdraw = balances[msg.sender];
balances[msg.sender] = 0;
msg.sender.transfer(eth_to_withdraw);
}
function buy_the_tokens(string _password) {
require(!bought_tokens);
require(sale != 0x0);
require(hash_pwd == keccak256(_password));
bought_tokens = true;
contract_eth_value = this.balance;
sale.transfer(contract_eth_value);
}
function change_sale_address(address _sale, string _password) {
require(hash_pwd == keccak256(_password));
require(sale == 0x0);
require(!bought_tokens);
sale = _sale;
}
function () payable {
require(this.balance < max_raised_amount);
require(!bought_tokens);
uint fee = msg.value/200;
creator.transfer(fee);
balances[msg.sender] += (msg.value-fee);
}
}