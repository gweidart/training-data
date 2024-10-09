pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract BITStationERC20  {
address public owner;
string public name;
string public symbol;
uint8 public decimals = 7;
uint256 public totalSupply;
bool public isLocked;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
mapping (address => bool) public whiteList;
event Transfer(address indexed from, address indexed to, uint256 value);
function  BITStationERC20() public {
totalSupply = 120000000000000000;
balanceOf[msg.sender] = 120000000000000000;
owner = msg.sender;
name = "BIT Station";
symbol = "BSTN";
isLocked=true;
whiteList[owner]=true;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public{
if (newOwner != address(0)) {
owner = newOwner;
whiteList[owner]=true;
}
}
function _transfer(address _from, address _to, uint _value) internal {
require(!isLocked||whiteList[msg.sender]);
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public
returns (bool success) {
require(!isLocked||whiteList[msg.sender]);
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
require(!isLocked);
allowance[msg.sender][_spender] = _value;
return true;
}
function addWhiteList(address _value) public onlyOwner
{
whiteList[_value]=true;
}
function delFromWhiteList(address _value) public onlyOwner
{
whiteList[_value]=false;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public
returns (bool success) {
require(!isLocked);
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function changeAssetsState(bool _value) public
returns (bool success){
require(msg.sender==owner);
isLocked =_value;
return true;
}
}