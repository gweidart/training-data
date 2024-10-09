pragma solidity ^0.4.21;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;
emit OwnershipTransferred(owner, newOwner);
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Destructible is Ownable {
function Destructible() public payable { }
function destroy() onlyOwner public {
selfdestruct(owner);
}
function destroyAndSend(address _recipient) onlyOwner public {
selfdestruct(_recipient);
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
contract LOCToken is StandardToken, Ownable, Pausable, Destructible
{
using SafeMath for uint;
string public constant name = "Leooy Coin";
string public constant symbol = "LOC";
uint public constant decimals = 18;
uint constant million = 1000000e18;
uint constant totalToken = 10000*million;
uint constant nThirdPartyPlatform = 1000*million;
uint constant nPlatformAutonomy = 5100*million;
uint constant nResearchGroup = 500*million;
uint constant nMarketing = 1000*million;
uint constant nInvEnterprise = 1000*million;
uint constant nAngelInvestment = 900*million;
uint constant nCultureTravelFoundation = 500*million;
address public ThirdPartyPlatformAddr;
address public PlatformAutonomyAddr;
address public ResearchGroupAddr;
address public MarketingAddr;
address public InvEnterpriseAddr;
address public AngelInvestmentAddr;
address public CultureTravelFoundationAddr;
function LOCToken() public
{
totalSupply = totalToken;
ThirdPartyPlatformAddr      = 0xf39ba36840c25a900f9a0c903cf7861ba1673d63;
PlatformAutonomyAddr        = 0x4909ecabedf1ff2e2a640f2ca09428a24246e525;
ResearchGroupAddr           = 0xe28cbac113c5b6c0f0d04d30cb331cc797b36bc8;
MarketingAddr               = 0x3834df1dff2ba13e1b17e5379729d8ee153c4b4a;
InvEnterpriseAddr           = 0x8E01f889AaA0ef9B64B5171fA963aEadcda6457D;
AngelInvestmentAddr         = 0x4CD907655B90330a483086DAB8509fBe60E04E4E;
CultureTravelFoundationAddr = 0x1fC577A65c718A424577292e7eF559CEF3a34829;
balances[msg.sender] = 0;
balances[ThirdPartyPlatformAddr]      = nThirdPartyPlatform;
balances[PlatformAutonomyAddr]        = nPlatformAutonomy;
balances[ResearchGroupAddr]           = nResearchGroup;
balances[MarketingAddr]               = nMarketing;
balances[InvEnterpriseAddr]           = nInvEnterprise;
balances[AngelInvestmentAddr]         = nAngelInvestment;
balances[CultureTravelFoundationAddr] = nCultureTravelFoundation;
}
}