pragma solidity ^0.4.13;
contract Lottery {
struct Ticket {
uint128 offset;
uint128 value;
}
mapping (address => Ticket) public tickets;
mapping (address => bytes32) public commits;
uint256 public num_hosts;
uint256 public num_hosts_revealed;
uint256 public rng;
bool public cancelled;
uint256 public total_user_eth;
uint256 public total_user_eth_cap = 100 ether;
uint256 public host_percentage = 10;
uint256 public buy_end_time = 1503829813;
uint256 public commit_end_time = buy_end_time + 1 days;
uint256 public reveal_end_time = commit_end_time + 1 days;
function cancel_lottery() {
require(now > commit_end_time);
bool quorum_met = num_hosts >= 2;
bool all_hosts_revealed = num_hosts == num_hosts_revealed;
bool reveal_phase_ended = now > reveal_end_time;
require(!quorum_met || (!all_hosts_revealed && reveal_phase_ended));
cancelled = true;
}
function host_lottery(bytes32 commit) payable {
require(msg.value == total_user_eth);
require((now > buy_end_time) && (now <= commit_end_time));
require((commit != 0) && (commits[msg.sender] == 0));
commits[msg.sender] = commit;
num_hosts += 1;
}
function steal_reveal(address host, uint256 secret_random_number) {
require((now > buy_end_time) && (now <= commit_end_time));
require(commits[host] == keccak256(secret_random_number));
cancelled = true;
commits[host] = 0;
msg.sender.transfer(total_user_eth);
}
function host_reveal(uint256 secret_random_number) {
require((now > commit_end_time) && (now <= reveal_end_time));
require(commits[msg.sender] == keccak256(secret_random_number));
commits[msg.sender] = 0;
rng ^= secret_random_number;
num_hosts_revealed += 1;
msg.sender.transfer(total_user_eth);
}
function host_claim_earnings(address host) {
require(!cancelled);
require(num_hosts >= 2);
require(num_hosts == num_hosts_revealed);
host.transfer(total_user_eth * host_percentage / (num_hosts * 100));
}
function claim_winnings(address winner) {
require(!cancelled);
require(num_hosts >= 2);
require(num_hosts == num_hosts_revealed);
uint256 winning_number = rng % total_user_eth;
require((winning_number >= tickets[winner].offset) && (winning_number < tickets[winner].offset + tickets[winner].value));
winner.transfer(total_user_eth * (100 - host_percentage) / 100);
}
function withdraw(address user) {
require(cancelled);
require(tickets[user].value != 0);
uint256 eth_to_withdraw = tickets[user].value;
tickets[user].value = 0;
user.transfer(eth_to_withdraw);
}
function () payable {
require(now <= buy_end_time);
require(tickets[msg.sender].value == 0);
tickets[msg.sender].offset = uint128(total_user_eth);
tickets[msg.sender].value = uint128(msg.value);
total_user_eth += msg.value;
require(total_user_eth <= total_user_eth_cap);
}
}