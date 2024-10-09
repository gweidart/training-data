pragma solidity ^0.4.13;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue)
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue)
returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract RealEstateConnect is StandardToken, Ownable {
string  public  constant name       = "Real Estate Connect";
string  public  constant symbol     = "REDI";
uint    public  constant decimals   = 18;
address private          admin;
bool    public           transferEnabled   = true;
function RealEstateConnect() {
totalSupply = 32000000000000000000000000000 ;
balances[msg.sender] = totalSupply;
Transfer(address(0x0), msg.sender, totalSupply);
admin = msg.sender;
transferOwnership(admin);
}
modifier onlyWhenTransferEnabled() {
if( ! transferEnabled   ) {
require( msg.sender == admin || msg.sender == owner );
}
_;
}
function setTransferEnabled( bool _transferEnabled ) {
require( msg.sender == admin );
transferEnabled = _transferEnabled;
}
function setAdmin(address _admin){
require( msg.sender == admin );
admin = _admin;
}
function transfer(address _to, uint _value)
onlyWhenTransferEnabled
returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value)
onlyWhenTransferEnabled
returns (bool) {
return super.transferFrom(_from, _to, _value);
}
event Burn(address indexed _burner, uint _value);
function burn(uint _value) onlyWhenTransferEnabled
returns (bool){
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(msg.sender, _value);
Transfer(msg.sender, address(0x0), _value);
return true;
}
function burnFrom(address _from, uint256 _value)
onlyWhenTransferEnabled
returns (bool) {
assert( transferFrom( _from, msg.sender, _value ) );
return burn(_value);
}
}