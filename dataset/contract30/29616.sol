pragma solidity ^0.4.18;
library SafeMathMod {
function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
require((c = a - b) < a);
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
require((c = a + b) > a);
}
}
contract Token {
using SafeMathMod for uint256;
string constant public name = "Smart City Token";
string constant public symbol = "SCT";
uint8 constant public decimals = 18;
uint256 public totalSupply;
address public presaleAddress;
address public crowdsaleAddress;
bool public crowdsaleSuccessful;
uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event TransferFrom(address indexed _spender, address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Mint(address indexed _to, uint256 _value, uint256 _totalSupply);
event Burn(address indexed _from, uint256 _value, uint256 _totalSupply);
function Token(address _presaleAddress, address _crowdsaleAddress) public {
totalSupply = 0;
presaleAddress = _presaleAddress;
crowdsaleAddress = _crowdsaleAddress;
}
function transfer(address _to, uint256 _value) public returns (bool success) {
require(crowdsaleSuccessful);
require(_to != address(0));
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
Transfer(msg.sender, _to, _value);
success = true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(crowdsaleSuccessful);
require(_to != address(0));
require(_to != address(this));
uint256 allowed = allowance[_from][msg.sender];
require(_value <= allowed || _from == msg.sender);
balanceOf[_to] = balanceOf[_to].add(_value);
balanceOf[_from] = balanceOf[_from].sub(_value);
if (allowed != MAX_UINT256 && _from != msg.sender) {
allowance[_from][msg.sender] = allowed.sub(_value);
}
Transfer(_from, _to, _value);
success = true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require(_spender != address(0));
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
success = true;
}
function mintTokens(address _to, uint256 _value) external returns(bool success) {
require(msg.sender == presaleAddress || msg.sender == crowdsaleAddress);
balanceOf[_to] = balanceOf[_to].add(_value);
totalSupply = totalSupply.add(_value);
Mint(_to,  _value, totalSupply);
success = true;
}
function burnAllTokens(address _address) external returns(bool success) {
require(msg.sender == crowdsaleAddress);
uint256 amount = balanceOf[_address];
balanceOf[_address] = 0;
totalSupply = totalSupply.sub(amount);
Burn(_address,  amount, totalSupply);
success = true;
}
function crowdsaleSucceeded() public {
require(msg.sender == crowdsaleAddress);
crowdsaleSuccessful = true;
}
function() public payable {revert();}
}