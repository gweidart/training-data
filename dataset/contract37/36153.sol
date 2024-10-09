pragma solidity ^0.4.11;
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract TokenRegistry is Ownable {
address[] public tokens;
mapping (string => address) tokenSymbolMap;
function registerToken(address _token, string _symbol)
public
onlyOwner {
require(_token != address(0));
require(!isTokenRegisteredBySymbol(_symbol));
require(!isTokenRegistered(_token));
tokens.push(_token);
tokenSymbolMap[_symbol] = _token;
}
function unregisterToken(address _token, string _symbol)
public
onlyOwner {
require(tokenSymbolMap[_symbol] == _token);
delete tokenSymbolMap[_symbol];
for (uint i = 0; i < tokens.length; i++) {
if (tokens[i] == _token) {
tokens[i] == tokens[tokens.length - 1];
tokens.length --;
break;
}
}
}
function isTokenRegisteredBySymbol(string symbol)
public
constant
returns (bool) {
return tokenSymbolMap[symbol] != address(0);
}
function isTokenRegistered(address _token)
public
constant
returns (bool) {
for (uint i = 0; i < tokens.length; i++) {
if (tokens[i] == _token) {
return true;
}
}
return false;
}
function getAddressBySymbol(string symbol)
public
constant
returns (address) {
return tokenSymbolMap[symbol];
}
}