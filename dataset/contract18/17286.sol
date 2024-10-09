pragma solidity ^0.4.21;
contract controlled{
address public owner;
uint256 public tokenFrozenUntilBlock;
uint256 public tokenFrozenSinceBlock;
uint256 public blockLock;
mapping (address => bool) restrictedAddresses;
function Constructor() public{
owner = 0x24bF9FeCA8894A78d231f525c054048F5932dc6B;
tokenFrozenSinceBlock = (2 ** 256) - 1;
tokenFrozenUntilBlock = 0;
blockLock = 5571500;
}
function transferOwnership (address newOwner) onlyOwner public{
owner = newOwner;
}
function editRestrictedAddress(address _restrictedAddress, bool _restrict) public onlyOwner{
if(!restrictedAddresses[_restrictedAddress] && _restrict){
restrictedAddresses[_restrictedAddress] = _restrict;
}
else if(restrictedAddresses[_restrictedAddress] && !_restrict){
restrictedAddresses[_restrictedAddress] = _restrict;
}
else{
revert();
}
}
modifier onlyOwner{
require(msg.sender == owner);
_;
}
modifier instForbiddenAddress(address _to){
require(_to != 0x0);
require(_to != address(this));
require(!restrictedAddresses[_to]);
require(!restrictedAddresses[msg.sender]);
_;
}
modifier unfrozenToken{
require(block.number >= blockLock || msg.sender == owner);
require(block.number >= tokenFrozenUntilBlock);
require(block.number <= tokenFrozenSinceBlock);
_;
}
}
contract blocktrade is controlled{
string public name = "blocktrade";
string public symbol = "BTT";
uint8 public decimals = 18;
uint256 public initialSupply = 57746762*(10**18);
uint256 public supply;
string public tokenFrozenUntilNotice;
string public tokenFrozenSinceNotice;
bool public airDropFinished;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
event TokenFrozenUntil(uint256 _frozenUntilBlock, string _reason);
event TokenFrozenSince(uint256 _frozenSinceBlock, string _reason);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Burn(address indexed from, uint256 value);
function Constructor() public{
supply = 57746762*(10**18);
airDropFinished = false;
balances[owner] = 57746762*(10**18);
}
function tokenName() constant public returns(string _tokenName){
return name;
}
function tokenSymbol() constant public returns(string _tokenSymbol){
return symbol;
}
function tokenDecimals() constant public returns(uint8 _tokenDecimals){
return decimals;
}
function totalSupply() constant public returns(uint256 _totalSupply){
return supply;
}
function balanceOf(address _tokenOwner) constant public returns(uint256 accountBalance){
return balances[_tokenOwner];
}
function allowance(address _owner, address _spender) constant public returns(uint256 remaining) {
return allowances[_owner][_spender];
}
function getFreezeUntilDetails() constant public returns(uint256 frozenUntilBlock, string notice){
return(tokenFrozenUntilBlock, tokenFrozenUntilNotice);
}
function getFreezeSinceDetails() constant public returns(uint frozenSinceBlock, string notice){
return(tokenFrozenSinceBlock, tokenFrozenSinceNotice);
}
function isRestrictedAddress(address _queryAddress) constant public returns(bool answer){
return restrictedAddresses[_queryAddress];
}
function transfer(address _to, uint256 _value) unfrozenToken instForbiddenAddress(_to) public returns(bool success){
require(balances[msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]) ;
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) unfrozenToken public returns (bool success){
allowances[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) unfrozenToken instForbiddenAddress(_to) public returns(bool success){
require(balances[_from] >= _value);
require(balances[_to] + _value >= balances[_to]);
require(_value <= allowances[_from][msg.sender]);
balances[_from] -= _value;
balances[_to] += _value;
allowances[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
}
function burn(uint256 _value) onlyOwner public returns(bool success){
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
supply -= _value;
emit Burn(msg.sender, _value);
return true;
}
function freezeTransfersUntil(uint256 _frozenUntilBlock, string _freezeNotice) onlyOwner public returns(bool success){
tokenFrozenUntilBlock = _frozenUntilBlock;
tokenFrozenUntilNotice = _freezeNotice;
emit TokenFrozenUntil(_frozenUntilBlock, _freezeNotice);
return true;
}
function freezeTransfersSince(uint256 _frozenSinceBlock, string _freezeNotice) onlyOwner public returns(bool success){
tokenFrozenSinceBlock = _frozenSinceBlock;
tokenFrozenSinceNotice = _freezeNotice;
emit TokenFrozenSince(_frozenSinceBlock, _freezeNotice);
return true;
}
function unfreezeTransfersUntil(string _unfreezeNotice) onlyOwner public returns(bool success){
tokenFrozenUntilBlock = 0;
tokenFrozenUntilNotice = _unfreezeNotice;
emit TokenFrozenUntil(0, _unfreezeNotice);
return true;
}
function unfreezeTransfersSince(string _unfreezeNotice) onlyOwner public returns(bool success){
tokenFrozenSinceBlock = (2 ** 256) - 1;
tokenFrozenSinceNotice = _unfreezeNotice;
emit TokenFrozenSince((2 ** 256) - 1, _unfreezeNotice);
return true;
}
function airDrop(address _beneficiary, uint256 _tokens) onlyOwner public returns(bool success){
require(!airDropFinished);
balances[owner] -= _tokens;
balances[_beneficiary] += _tokens;
return true;
}
function endAirDrop() onlyOwner public returns(bool success){
require(!airDropFinished);
airDropFinished = true;
return true;
}
}