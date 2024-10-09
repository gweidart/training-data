pragma solidity ^0.4.19;
contract ERC20_token {
uint256 public totalSupply;
event Transfer(address indexed _from, address indexed _to, uint256 _value, string _text);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
uint256 constant private MAX_UINT256 = 2**256 - 1;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowed;
string public name;
uint8  public decimals = 18;
string public symbol;
address owner;
uint256 public buyPrice;
uint private weiToEther = 10 ** 18;
constructor (
uint256 _initialSupply,
uint256 _buyPrice,
string _tokenName,
string _tokenSymbol
) public {
totalSupply = _initialSupply * 10 ** uint256(decimals);
balances[msg.sender] = totalSupply;
name = _tokenName;
symbol = _tokenSymbol;
owner = msg.sender;
buyPrice = _buyPrice;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value, string _text) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value, _text);
return true;
}
function transferFrom(address _from, address _to, uint256 _value, string _text) public returns (bool success) {
uint256 allowance = allowed[_from][msg.sender];
require(balances[_from] >= _value && allowance >= _value);
balances[_to] += _value;
balances[_from] -= _value;
if (allowance < MAX_UINT256) {
allowed[_from][msg.sender] -= _value;
}
emit Transfer(_from, _to, _value, _text);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function setPrice(uint _price) public onlyOwner {
buyPrice = _price;
}
function buy() public payable {
uint amount;
amount = msg.value * buyPrice * 10 ** uint256(decimals) / weiToEther;
require(balances[owner] >= amount);
balances[msg.sender] += amount;
balances[owner] -= amount;
emit Transfer(msg.sender, owner, amount, 'Buy token');
}
function withdraw(uint amount) public onlyOwner {
owner.transfer(amount * weiToEther);
}
}