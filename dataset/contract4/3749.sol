pragma solidity 0.4.22;
contract EIP20Interface {
function totalSupply() constant returns (uint256 supply);
is replaced with:
uint256 public totalSupply;
This automatically creates a getter function for the totalSupply.
This is moved to the base contract since public getter functions are not
currently recognised as an implementation of the matching abstract
function by the compiler.
uint256 public totalSupply;
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract EIP20 is EIP20Interface {
uint256 constant internal MAX_UINT256 = 2**256 - 1;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowed;
NOTE:
The following variables are OPTIONAL vanities. One does not have to include them.
They allow one to customise the token contract & in no way influences the core functionality.
Some wallets/interfaces might not even bother to look at this information.
string public name;
uint8  public decimals;
string public symbol;
function transfer(address _to, uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
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
emit Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
* @dev Increase the amount of tokens that an owner allowed to a spender.
* approve should be called when allowed[_spender] == 0. To increment
* allowed value is better to use this function to avoid 2 calls (and wait until
* the first transaction is mined)
* From MonolithDAO Token.sol
* @param _spender The address which will spend the funds.
* @param _addedValue The amount of tokens to increase the allowance by.
function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
require(allowed[msg.sender][_spender] + _addedValue > allowed[msg.sender][_spender]);
allowed[msg.sender][_spender] += _addedValue;
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
* @dev Decrease the amount of tokens that an owner allowed to a spender.
* approve should be called when allowed[_spender] == 0. To decrement
* allowed value is better to use this function to avoid 2 calls (and wait until
* the first transaction is mined)
* From MonolithDAO Token.sol
* @param _spender The address which will spend the funds.
* @param _subtractedValue The amount of tokens to decrease the allowance by.
function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
if (_subtractedValue > allowed[msg.sender][_spender]) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] -= _subtractedValue;
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Owned {
address internal owner;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address newOwner) public onlyOwner {
owner = newOwner;
}
}
contract Proof is Owned {
string public proofAddr;
function setProofAddr(string proofaddr) public onlyOwner {
proofAddr = proofaddr;
}
}
contract Stoppable is Owned {
bool public stopped = false;
modifier isRunning() {
require(!stopped);
_;
}
function stop() public onlyOwner isRunning {
stopped = true;
}
}
contract SECT is EIP20, Owned, Proof, Stoppable {
string public coinbase = "Ampil landed  and EIP999 is still in the eye of typhoon";
constructor () public {
name = "SECBIT";
symbol = "SECT";
decimals = 18;
totalSupply = (10**9) * (10**uint256(decimals));
balances[msg.sender] = totalSupply;
owner = msg.sender;
}
function transfer(address _to, uint256 _value) public isRunning returns (bool success) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public isRunning returns (bool success) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public isRunning returns (bool success) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint256 _addedValue) public isRunning returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint256 _subtractedValue) public isRunning returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
function setProofAddr(string proofaddr) public isRunning {
super.setProofAddr(proofaddr);
}
}