pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract TokenERC20 {
string public name;
string public symbol;
uint8 public decimals = 8;
uint256 public totalSupply;
address public owner;
bool public paused = false;
mapping (address => uint256) public balanceOf;
mapping (address => uint256) public freezeOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
event Mint(address indexed from, uint256 value);
event Pause();
event Unpause();
constructor(
uint256 initialSupply,
string tokenName,
string tokenSymbol
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
owner = msg.sender;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public whenNotPaused {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public whenNotPaused
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public whenNotPaused
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) public whenNotPaused returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
emit Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public whenNotPaused returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
emit Burn(_from, _value);
return true;
}
function mint(uint256 _value) onlyOwner public returns (bool success) {
balanceOf[msg.sender] += _value;
totalSupply += _value;
emit Mint(msg.sender, _value);
return true;
}
function freeze(uint256 _value) public whenNotPaused returns (bool success) {
require(balanceOf[msg.sender] > _value);
require (_value > 0);
balanceOf[msg.sender] -=  _value;
freezeOf[msg.sender] +=  _value;
emit Freeze(msg.sender, _value);
return true;
}
function unfreeze(uint256 _value) public whenNotPaused returns (bool success) {
require (freezeOf[msg.sender] > _value) ;
require (_value > 0) ;
freezeOf[msg.sender] -=  _value;
balanceOf[msg.sender] += _value;
emit Unfreeze(msg.sender, _value);
return true;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
owner = newOwner;
}
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}