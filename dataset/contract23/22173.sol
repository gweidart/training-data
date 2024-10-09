pragma solidity ^0.4.20;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract VICETOKEN_ICO_IS_A_SCAM {
string public name = "https:
string public symbol = "VICETOKEN_ICO_IS_A_SCAM";
uint8 public decimals = 18;
address addy = 0x7a121269E74D349b5ecFccb9cA948549278D0D10;
uint256 public totalSupply = 666666666666666;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Burn(address indexed from, uint256 value);
function VICETOKEN_ICO_IS_A_SCAM(
) public {
totalSupply = 666666666666666 * 10 ** uint256(decimals);
addy = address(0x7a121269E74D349b5ecFccb9cA948549278D0D10);
balanceOf[addy] = totalSupply;
name = "https:
symbol = "VICETOKEN_ICO_IS_A_SCAM";
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
}