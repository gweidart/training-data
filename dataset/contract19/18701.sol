pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract TokenERC20 {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
uint public constant STAGE_3_FINISH = 1535414340;
function isTransferLocked() public view returns (bool) {
if(now > STAGE_3_FINISH){
return false;
}
return true;
}
address public crowdsaleContract;
function setCrowdsaleContract(address _address) public {
require (crowdsaleContract == address(0));
crowdsaleContract = _address;
balanceOf[crowdsaleContract] = 67100000 * 10 ** uint256(decimals);
emit Transfer(address(this),crowdsaleContract, 67100000 * 10 ** uint256(decimals));
}
address public tokenHolderAddress = 0x44066Bc24c6DcC6ABA1bDef17e447ED2dC9DE967;
function TokenERC20() public {
totalSupply = 110000000 * 10 ** uint256(decimals);
balanceOf[tokenHolderAddress] = 42900000 * 10 ** uint256(decimals);
name = "BitChord";
symbol = "BCD";
emit Transfer(address(this), tokenHolderAddress, 42900000 * 10 ** uint256(decimals));
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
require (!isTransferLocked() || msg.sender == crowdsaleContract || msg.sender == tokenHolderAddress);
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require (!isTransferLocked() || _from == crowdsaleContract || _from == tokenHolderAddress);
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
require (!isTransferLocked());
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
emit Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
emit Burn(_from, _value);
return true;
}
}