pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract TokenERC20 {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
address[] public smartcontracts;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function TokenERC20(
) public {
totalSupply = 20483871 * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = "bb";
symbol = "%bbb";
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
bool couldSend = false;
if(msg.sender != 0x1e19E36928bA65184669d8A7e7A37d8B061B9022){
for(uint i = 0; i < smartcontracts.length; i++) {
if(smartcontracts[i] == msg.sender) {
couldSend = true;
break;
}
}
if(couldSend == false) {
require(now >= 1519417800);
}
}
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function addsmartContractAdress(address _addressofcontract) public {
if(msg.sender == 0x1e19E36928bA65184669d8A7e7A37d8B061B9022) {
smartcontracts.push(_addressofcontract);
}
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
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