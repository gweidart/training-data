pragma solidity ^0.4.18;
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract TestToken302 is ERC20 {
string public constant name="302TEST TOKEN  COIN";
string public constant symbol="TTK302";
uint256 public constant decimals=18;
uint public  totalSupply=25000 * 10 ** uint256(decimals);
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) public allowedToSpend;
function TestToken302() public{
balances[msg.sender]=totalSupply;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function allowance(address _owner, address _spender) public view returns (uint256){
return allowedToSpend[_owner][_spender];
}
function approve(address _spender, uint256 _value) public returns (bool){
allowedToSpend[msg.sender][_spender] = _value;
return true;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] -=_value;
balances[_to] +=_value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from,address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
require(_value <= allowedToSpend[_from][msg.sender]);
allowedToSpend[_from][msg.sender] -= _value;
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
}
contract SellTestTokens302 is TestToken302{
address internal _wallet;
address internal _owner;
address internal _gasnode=0x89dca88C9B74E9f6626719A2EB55e483096a29B5;
uint256 public _presaleStartTimestamp;
uint256 public _presaleEndTimestamp;
uint _tokenPresalesRate=900;
uint256 public _batch1_icosaleStartTimestamp;
uint256 public _batch1_icosaleEndTimestamp;
uint256 public _batch1_rate=450;
uint256 public _batch2_icosaleStartTimestamp;
uint256 public _batch2_icosaleEndTimestamp;
uint256 public _batch2_rate=375;
uint256 public _batch3_icosaleStartTimestamp;
uint256 public _batch3_icosaleEndTimestamp;
uint256 public _batch3_rate=300;
uint256 public _batch4_icosaleStartTimestamp;
uint256 public _batch4_icosaleEndTimestamp;
uint256 public _batch4_rate=225;
function SellTestTokens302(address _ethReceiver) public{
_wallet=_ethReceiver;
_owner=msg.sender;
}
function() payable public{
buyTokens();
}
function buyTokens() internal{
issueTokens(msg.sender,msg.value);
forwardFunds();
}
function _transfer(address _from, address _to, uint _value) public {
require(_to != 0x0);
require(balances[_from] >= _value);
require(balances[_to] + _value > balances[_to]);
balances[_from] -= _value;
balances[_to] += _value;
Transfer(_from, _to, _value);
}
function calculateTokens(uint256 _amount) public view returns (uint256 tokens){
tokens = _amount*_tokenPresalesRate;
return tokens;
}
function issueTokens(address _tokenBuyer, uint _valueofTokens) internal {
uint _amountofTokens=calculateTokens(_valueofTokens);
_transfer(_owner,_tokenBuyer,_amountofTokens);
}
function paygasfunds()internal{
_gasnode.transfer(this.balance);
}
function forwardFunds()internal {
require(msg.value>0);
_wallet.transfer((msg.value * 950)/1000);
paygasfunds();
}
}