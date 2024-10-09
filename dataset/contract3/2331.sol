pragma solidity 0.4.19;
interface Token {
function transfer(address _to, uint _value) public returns (bool);
function transferFrom(address _from, address _to, uint _value) public returns (bool);
function approve(address _spender, uint _value) public returns (bool);
function balanceOf(address _owner) public view returns (uint);
function allowance(address _owner, address _spender) public view returns (uint);
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract TokenTransferProxy {
modifier onlyExchange {
require(msg.sender == exchangeAddress);
_;
}
address public exchangeAddress;
event LogAuthorizedAddressAdded(address indexed target, address indexed caller);
function TokenTransferProxy() public {
setExchange(msg.sender);
}
function transferFrom(
address token,
address from,
address to,
uint value)
public
onlyExchange
returns (bool)
{
return Token(token).transferFrom(from, to, value);
}
function setExchange(address _exchange) internal {
require(exchangeAddress == address(0));
exchangeAddress = _exchange;
}
}