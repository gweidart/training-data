pragma solidity ^0.4.11;
contract BitcoinAvarice {
string public constant name = "Bitcoin Avarice";
string public constant symbol = "BTAV";
uint8 public constant decimals = 18;
uint256 public constant TOTAL_SUPPLY = 21000 * (10 ** uint256(decimals));
}