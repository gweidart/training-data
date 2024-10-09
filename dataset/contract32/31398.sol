pragma solidity ^0.4.17;
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
uint256 constant MAX_UINT256 = 2**256 - 1;
function transfer(address _to, uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
uint256 allowance = allowed[_from][msg.sender];
require(balances[_from] >= _value && allowance >= _value);
balances[_to] += _value;
balances[_from] -= _value;
if (allowance < MAX_UINT256) {
allowed[_from][msg.sender] -= _value;
}
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) view public returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender)
view public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}
contract CharitySpaceToken is StandardToken {
string public name;
uint8 public decimals;
string public symbol;
address public owner;
address private icoAddress;
function CharitySpaceToken(address _icoAddress, address _teamAddress, address _advisorsAddress, address _bountyAddress, address _companyAddress) public {
totalSupply =  20000000 * 10**18;
uint256 publicSaleSupply = 16000000 * 10**18;
uint256 teamSupply = 1500000 * 10**18;
uint256 advisorsSupply = 700000 * 10**18;
uint256 bountySupply = 800000 * 10**18;
uint256 companySupply = 1000000 * 10**18;
name = "charityTOKEN";
decimals = 18;
symbol = "CHT";
balances[_icoAddress] = publicSaleSupply;
Transfer(0, _icoAddress, publicSaleSupply);
balances[_teamAddress] = teamSupply;
Transfer(0, _teamAddress, teamSupply);
balances[_advisorsAddress] = advisorsSupply;
Transfer(0, _advisorsAddress, advisorsSupply);
balances[_bountyAddress] = bountySupply;
Transfer(0, _bountyAddress, bountySupply);
balances[_companyAddress] = companySupply;
Transfer(0, _companyAddress, companySupply);
owner = msg.sender;
icoAddress = _icoAddress;
}
function destroyUnsoldTokens() public {
require(msg.sender == icoAddress || msg.sender == owner);
uint256 value = balances[icoAddress];
totalSupply -= value;
balances[icoAddress] = 0;
}
}