pragma solidity ^0.4.13;
contract Exchange {
}
contract Token {
}
contract TokenStoreBalances {
function() public payable {
revert();
}
function tokenBalance(address user, address token) public constant returns (uint) {
uint256 tokenCode;
assembly { tokenCode := extcodesize(token) }
if(tokenCode > 0 && token.call(bytes4(0x70a08231), user)) {
return Token(token).balanceOf(user);
} else {
return 0;
}
}
function allBalances(address exchange, address user, address[] tokens) external constant returns (uint[]) {
Exchange ex = Exchange(exchange);
uint[] memory balances = new uint[](tokens.length * 2);
for(uint i = 0; i < tokens.length; i++) {
uint j = i * 2;
balances[j] = ex.balanceOf(tokens[i], user);
if(tokens[i] != address(0x0)) {
balances[j + 1] = tokenBalance(user, tokens[i]);
} else {
balances[j + 1] = user.balance;
}
}
return balances;
}
}