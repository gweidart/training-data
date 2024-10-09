pragma solidity ^0.4.4;
string public name= "Bether Crypto Currency";
uint8 public decimals= 18;
string public symbol= "BETHR";
string public version = 'H1.0';
uint256 public unitsOneEthCanBuy;
uint256 public totalEthInWei;
address public fundsWallet;
function BetherCryptocurrency() {
balances[msg.sender] = 1000000000000000000000000000;
totalSupply = 1000000000000000000000000000;
name = "BETHER Crypto Currency";
decimals = 18;
symbol = "BETHR";
unitsOneEthCanBuy = 100000;
fundsWallet = msg.sender;
}
function() payable{
totalEthInWei = totalEthInWei + msg.value;
uint256 amount = msg.value * unitsOneEthCanBuy;
if (balances[fundsWallet] < amount) {
return;
}
balances[fundsWallet] = balances[fundsWallet] - amount;
balances[msg.sender] = balances[msg.sender] + amount;
Transfer(fundsWallet, msg.sender, amount);
fundsWallet.transfer(msg.value);
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
return true;
}
}