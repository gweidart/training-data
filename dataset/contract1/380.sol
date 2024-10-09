pragma solidity ^0.4.19;
contract ERC20 {
function totalSupply() public constant returns (uint supply);
function balanceOf(address _owner) public constant returns (uint balance);
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
function approve(address _spender, uint _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint remaining);
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract ODCToken is ERC20 {
uint public _totalSupply = 100*10**26;
uint8 constant public decimals = 18;
string constant public name = "OdcToken";
string constant public symbol = "ODC";
mapping (address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
function ODCToken() public {
balances[msg.sender] = _totalSupply;
Transfer(address(0), msg.sender, _totalSupply);
}
function totalSupply() public constant returns (uint supply) {
return _totalSupply;
}
function balanceOf(address _owner) public constant returns (uint) {
return balances[_owner];
}
function transfer(address _to, uint _value) public returns (bool) {
if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
uint constant MAX_UINT = 2**256 - 1;
function transferFrom(address _from, address _to, uint _value)
public
returns (bool)
{
uint allowance = allowed[_from][msg.sender];
if (balances[_from] >= _value
&& allowance >= _value
&& balances[_to] + _value >= balances[_to]
) {
balances[_to] += _value;
balances[_from] -= _value;
if (allowance < MAX_UINT) {
allowed[_from][msg.sender] -= _value;
}
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function approve(address _spender, uint _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint) {
return allowed[_owner][_spender];
}
function () public {
revert();
}
}