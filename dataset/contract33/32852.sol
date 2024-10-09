contract Disbursement {
address public owner;
address public receiver;
uint public disbursementPeriod;
uint public startDate;
uint public withdrawnTokens;
Token public token;
modifier isOwner() {
if (msg.sender != owner)
revert();
_;
}
modifier isReceiver() {
if (msg.sender != receiver)
revert();
_;
}
modifier isSetUp() {
if (address(token) == 0)
revert();
_;
}
function Disbursement(address _receiver, uint _disbursementPeriod, uint _startDate)
public
{
if (_receiver == 0 || _disbursementPeriod == 0)
revert();
owner = msg.sender;
receiver = _receiver;
disbursementPeriod = _disbursementPeriod;
startDate = _startDate;
if (startDate == 0)
startDate = now;
}
function setup(address _token)
public
isOwner
{
if (address(token) != 0 || address(_token) == 0)
revert();
token = Token(_token);
}
function withdraw(address _to, uint256 _value)
public
isReceiver
isSetUp
{
uint maxTokens = calcMaxWithdraw();
if (_value > maxTokens)
revert();
withdrawnTokens += _value;
token.transfer(_to, _value);
}
function calcMaxWithdraw()
public
constant
returns (uint)
{
uint maxTokens = (token.balanceOf(this) + withdrawnTokens) * (now - startDate) / disbursementPeriod;
if (withdrawnTokens >= maxTokens || startDate > now)
return 0;
return maxTokens - withdrawnTokens;
}
}
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}