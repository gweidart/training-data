pragma solidity ^0.4.15;
interface tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)
public;
}
contract Biotoken  {
string public constant symbol = "BIOB";
string public constant name = "Biobeans";
uint8 public constant decimals = 1;
address public owner;
uint256 _totalSupply = 100000;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function Biotoken() {
owner = msg.sender;
balances[owner] = _totalSupply;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balances[_from] >= _value);
require(balances[_to] + _value > balances[_to]);
uint previousBalances = balances[_from] + balances[_to];
balances[_from] -= _value;
balances[_to] += _value;
Transfer(_from, _to, _value);
assert(balances[_from] + balances[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
_transfer(_from, _to, _value);
return true;
}
}