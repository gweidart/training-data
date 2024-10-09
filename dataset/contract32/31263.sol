pragma solidity ^0.4.17;
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
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Authorizable is Ownable {
mapping(address => bool) public authorized;
event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);
function Authorizable() public {
AuthorizationSet(msg.sender, true);
authorized[msg.sender] = true;
}
modifier onlyAuthorized() {
require(authorized[msg.sender]);
_;
}
function setAuthorized(address addressAuthorized, bool authorization) public onlyOwner {
require(authorized[addressAuthorized] != authorization);
AuthorizationSet(addressAuthorized, authorization);
authorized[addressAuthorized] = authorization;
}
}
contract WhiteList is Authorizable {
mapping(address => bool) whiteListed;
event WhiteListSet(address indexed addressWhiteListed, bool indexed whiteListStatus);
function WhiteList() public {
WhiteListSet(msg.sender, true);
whiteListed[msg.sender] = true;
}
modifier onlyWhiteListed() {
require(whiteListed[msg.sender]);
_;
}
function isWhiteListed(address _address) public view returns (bool) {
return whiteListed[_address];
}
function setWhiteListed(address addressWhiteListed, bool whiteListStatus) public onlyAuthorized {
require(whiteListed[addressWhiteListed] != whiteListStatus);
WhiteListSet(addressWhiteListed, whiteListStatus);
whiteListed[addressWhiteListed] = whiteListStatus;
}
}
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
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
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
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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
contract TreasureBox {
StandardToken token;
address public beneficiary;
uint public releaseTime;
function TreasureBox(StandardToken _token, address _beneficiary, uint _releaseTime) public {
require(_beneficiary != address(0));
token = StandardToken(_token);
beneficiary = _beneficiary;
releaseTime = _releaseTime;
}
function claim() external {
require(available());
require(amount() > 0);
token.transfer(beneficiary, amount());
}
function available() public view returns (bool) {
return (now >= releaseTime);
}
function amount() public view returns (uint256) {
return token.balanceOf(this);
}
}
contract AirDropper is Authorizable {
mapping(address => bool) public isAnExchanger;
mapping(address => bool) public isTreasureBox;
mapping(address => address) public airDropDestinations;
StandardToken token;
event SetDestination(address _address, address _destination);
event SetExchanger(address _address, bool _isExchanger);
function AirDropper(StandardToken _token) public {
token = _token;
}
function getToken() public view returns(StandardToken) {
return token;
}
function setAirDropDestination(address _destination) external {
require(_destination != msg.sender);
airDropDestinations[msg.sender] = _destination;
SetDestination(msg.sender, _destination);
}
function setTreasureBox (address _address, bool _status) public onlyAuthorized {
require(_address != address(0));
require(isTreasureBox[_address] != _status);
isTreasureBox[_address] = _status;
}
function setExchanger(address _address, bool _isExchanger) external onlyAuthorized {
require(_address != address(0));
require(isAnExchanger[_address] != _isExchanger);
isAnExchanger[_address] = _isExchanger;
SetExchanger(_address, _isExchanger);
}
function multiTransfer(address[] _address, uint[] _value) public returns (bool) {
for (uint i = 0; i < _address.length; i++) {
token.transferFrom(msg.sender, _address[i], _value[i]);
}
return true;
}
}
contract ZMINE is StandardToken, Ownable {
string public name = "ZMINE Token";
string public symbol = "ZMN";
uint8 public decimals = 18;
uint256 public totalSupply = 1000000000000000000000000000;
function ZMINE() public {
balances[owner] = totalSupply;
Transfer(address(0x0), owner, totalSupply);
}
function burn(uint _amount) external onlyOwner {
require(balances[owner] >= _amount);
balances[owner] = balances[owner] - _amount;
totalSupply = totalSupply - _amount;
Transfer(owner, address(0x0), _amount);
}
}
contract RateContract is Authorizable {
uint public rate = 6000000000000000000000;
event UpdateRate(uint _oldRate, uint _newRate);
function updateRate(uint _rate) public onlyAuthorized {
require(rate != _rate);
UpdateRate(rate, _rate);
rate = _rate;
}
function getRate() public view returns (uint) {
return rate;
}
}
contract FounderThreader is Ownable {
using SafeMath for uint;
event TokenTransferForFounder(address _recipient, uint _value, address box1, address box2);
AirDropper public airdropper;
uint public hardCap = 300000000000000000000000000;
uint public remain = 300000000000000000000000000;
uint public minTx = 100000000000000000000;
mapping(address => bool) isFounder;
function FounderThreader (AirDropper _airdropper, address[] _founders) public {
airdropper = AirDropper(_airdropper);
for (uint i = 0; i < _founders.length; i++) {
isFounder[_founders[i]] = true;
}
}
function transferFor(address _recipient, uint _tokens) external onlyOwner {
require(_recipient != address(0));
require(_tokens >= minTx);
require(isFounder[_recipient]);
StandardToken token = StandardToken(airdropper.getToken());
TreasureBox box1 = new TreasureBox(token, _recipient, 1533088800);
TreasureBox box2 = new TreasureBox(token, _recipient, 1548986400);
airdropper.setTreasureBox(box1, true);
airdropper.setTreasureBox(box2, true);
token.transferFrom(owner, _recipient, _tokens.mul(33).div(100));
token.transferFrom(owner, box1, _tokens.mul(33).div(100));
token.transferFrom(owner, box2, _tokens.mul(34).div(100));
remain = remain.sub(_tokens);
TokenTransferForFounder(_recipient, _tokens, box1, box2);
}
}
contract PreSale is Ownable {
using SafeMath for uint;
event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
event TokenSold(address _recipient, uint _tokens);
ZMINE public token;
WhiteList whitelist;
uint public hardCap = 300000000000000000000000000;
uint public remain = 300000000000000000000000000;
uint public startDate = 1512525600;
uint public stopDate = 1517364000;
uint public minTx = 100000000000000000000;
uint public maxTx = 100000000000000000000000;
RateContract rateContract;
function PreSale (ZMINE _token, RateContract _rateContract, WhiteList _whitelist) public {
token = ZMINE(_token);
rateContract = RateContract(_rateContract);
whitelist = WhiteList(_whitelist);
}
function transferFor(address _recipient, uint _tokens) external onlyOwner {
require(_recipient != address(0));
require(available());
remain = remain.sub(_tokens);
token.transferFrom(owner, _recipient, _tokens);
TokenSold(_recipient, _tokens);
}
function sale(address _recipient, uint _value, uint _rate) private {
require(_recipient != address(0));
require(available());
require(isWhiteListed(_recipient));
require(_value >= minTx && _value <= maxTx);
uint tokens = _rate.mul(_value).div(1000000000000000000);
remain = remain.sub(tokens);
token.transferFrom(owner, _recipient, tokens);
owner.transfer(_value);
TokenSold(_recipient, _value, tokens, _rate);
}
function rate() public view returns (uint) {
return rateContract.getRate();
}
function available() public view returns (bool) {
return (now > startDate && now < stopDate);
}
function isWhiteListed(address _address) public view returns (bool) {
return whitelist.isWhiteListed(_address);
}
function() external payable {
sale(msg.sender, msg.value, rate());
}
}
contract PublicSale is Ownable {
using SafeMath for uint;
event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
event IncreaseHardCap(uint _amount);
ZMINE public token;
WhiteList whitelistPublic;
WhiteList whitelistPRE;
uint public hardCap = 400000000000000000000000000;
uint public remain = 400000000000000000000000000;
uint public startDate = 1515376800;
uint public stopDate = 1517364000;
uint public minTx = 1000000000000000000;
uint public maxTx = 100000000000000000000000;
RateContract rateContract;
function PublicSale(ZMINE _token, RateContract _rateContract, WhiteList _whitelistPRE, WhiteList _whitelistPublic) public {
token = ZMINE(_token);
rateContract = RateContract(_rateContract);
whitelistPRE = WhiteList(_whitelistPRE);
whitelistPublic = WhiteList(_whitelistPublic);
}
function increaseHardCap(uint _amount) external onlyOwner {
require(_amount <= 300000000000000000000000000);
hardCap = hardCap.add(_amount);
remain = remain.add(_amount);
IncreaseHardCap(_amount);
}
function sale(address _recipient, uint _value, uint _rate) private {
require(available());
require(isWhiteListed(_recipient));
require(_value >= minTx && _value <= maxTx);
uint tokens = _rate.mul(_value).div(1000000000000000000);
remain = remain.sub(tokens);
token.transferFrom(owner, _recipient, tokens);
owner.transfer(_value);
TokenSold(_recipient, _value, tokens, _rate);
}
function rate() public view returns (uint) {
return rateContract.getRate();
}
function available () public view returns (bool) {
return (now > startDate && now < stopDate);
}
function isWhiteListed (address _address) public view returns(bool) {
return (whitelistPRE.isWhiteListed(_address) || (whitelistPublic.isWhiteListed(_address)));
}
function() external payable {
sale(msg.sender, msg.value, rate());
}
}