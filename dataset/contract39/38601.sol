pragma solidity ^0.4.11;
contract Interface {
function registerArtwork (address _contract, bytes32 _SHA256Hash, uint256 _editionSize, string _title, string _fileLink, uint256 _ownerCommission, address _artist, bool _indexed, bool _ouroboros);
function isSHA256HashRegistered (bytes32 _SHA256Hash) returns (bool _registered);
function isFactoryApproved (address _factory) returns (bool _approved);
function issuePatrons (address _to, uint256 _amount);
function approveFactoryContract (address _factoryContractAddress, bool _approved);
function changeOwner (address newOwner);
function offerPieceForSaleByAddress (address _contract, uint256 _price);
function offerPieceForSale (uint256 _price);
function fillBidByAddress (address _contract);
function fillBid();
function cancelSaleByAddress (address _contract);
function cancelSale();
function offerIndexedPieceForSaleByAddress (address _contract, uint256 _index, uint256 _price);
function offerIndexedPieceForSale(uint256 _index, uint256 _price);
function fillIndexedBidByAddress (address _contract, uint256 _index);
function fillIndexedBid (uint256 _index);
function cancelIndexedSaleByAddress (address _contract);
function cancelIndexedSale();
function transferByAddress (address _contract, uint256 _amount, address _to);
function transferIndexedByAddress (address _contract, uint256 _index, address _to);
function approveByAddress (address _contract, address _spender, uint256 _amount);
function approveIndexedByAddress (address _contract, address _spender, uint256 _index);
function burnByAddress (address _contract, uint256 _amount);
function burnFromByAddress (address _contract, uint256 _amount, address _from);
function burnIndexedByAddress (address _contract, uint256 _index);
function burnIndexedFromByAddress (address _contract, address _from, uint256 _index);
function totalSupply() constant returns (uint256 totalSupply);
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
function burn(uint256 _amount) returns (bool success);
function burnFrom(address _from, uint256 _amount) returns (bool success);
function transferIndexed (address _to, uint256 __index) returns (bool success);
function transferFromIndexed (address _from, address _to, uint256 _index) returns (bool success);
function approveIndexed (address _spender, uint256 _index) returns (bool success);
function burnIndexed (uint256 _index);
function burnIndexedFrom (address _owner, uint256 _index);
}
contract Registrar {
string public constant symbol = "ART";
string public constant name = "Patron - Ethart Network Token";
uint8 public constant decimals = 18;
uint256 _totalPatronSupply;
event Transfer(address indexed _from, address _to, uint256 _value);
event Approval(address indexed _owner, address _spender, uint256 _value);
event Burn(address indexed _owner, uint256 _amount);
mapping(address => uint256) public balances;
event NewArtwork(address _contract, bytes32 _SHA256Hash, uint256 _editionSize, string _title, string _fileLink, uint256 _ownerCommission, address _artist, bool _indexed, bool _ouroboros);
mapping(address => mapping (address => uint256)) allowed;
modifier onlyPayloadSize(uint size)
{
require(msg.data.length >= size + 4);
_;
}
function totalSupply() constant returns (uint256 totalPatronSupply) {
totalPatronSupply = _totalPatronSupply;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) returns (bool success) {
if (balances[msg.sender] >= _amount
&& _amount > 0
&& balances[_to] + _amount > balances[_to]
&& _to != 0x0)
{
balances[msg.sender] -= _amount;
balances[_to] += _amount;
Transfer(msg.sender, _to, _amount);
return true;
}
else { return false;}
}
function transferFrom( address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) returns (bool success)
{
if (balances[_from] >= _amount
&& allowed[_from][msg.sender] >= _amount
&& _amount > 0
&& balances[_to] + _amount > balances[_to]
&& _to != 0x0)
{
balances[_from] -= _amount;
allowed[_from][msg.sender] -= _amount;
balances[_to] += _amount;
Transfer(_from, _to, _amount);
return true;
} else {return false;}
}
function approve(address _spender, uint256 _amount) returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function burn(uint256 _amount) returns (bool success) {
if (balances[msg.sender] >= _amount) {
balances[msg.sender] -= _amount;
_totalPatronSupply -= _amount;
Burn(msg.sender, _amount);
return true;
}
else {throw;}
}
function burnFrom(address _from, uint256 _value) onlyPayloadSize(2 * 32) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
_totalPatronSupply -= _value;
Burn(_from, _value);
return true;
}
else {throw;}
}
function mul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
mapping (bytes32 => address) public SHA256HashRegister;
mapping (address => bool) public approvedFactories;
mapping (address => bool) public approvedContracts;
mapping (address => address) public referred;
mapping (address => bool) public cantSetReferrer;
struct artwork {
bytes32 SHA256Hash;
uint256 editionSize;
string title;
string fileLink;
uint256 ownerCommission;
address artist;
address factory;
bool isIndexed;
bool isOuroboros;}
mapping (address => artwork) public artworkRegister;
mapping(address => mapping (uint256 => address)) public artistsArtworks;
mapping(address => uint256) public artistsArtworkCount;
uint256 public artworkCount;
mapping (uint256 => address) public artworkIndex;
mapping (address => uint256) public pendingWithdrawals;
uint256 public totalPendingWithdrawals;
address public owner;
uint256 public donationMultiplier;
uint256 public patronRewardMultiplier;
uint256 public ethartRevenueReward;
uint256 public ethartArtReward;
uint256 public referrerReward;
modifier onlyBy (address _account)
{
require(msg.sender == _account);
_;
}
modifier registeredFactoriesOnly ()
{
require(approvedFactories[msg.sender]);
_;
}
modifier approvedContractsOnly ()
{
require(approvedContracts[msg.sender]);
_;
}
function setReferrer (address _referrer)
{
if (referred[msg.sender] == 0x0 && !cantSetReferrer[msg.sender] && _referrer != msg.sender)
{
referred[msg.sender] = _referrer;
}
}
function getReferrer (address _artist) returns (address _referrer)
{
return referred[_artist];
}
function setReferrerReward (uint256 _referrerReward) onlyBy (owner)
{
uint a;
if (_referrerReward > 10000 - ethartRevenueReward) {throw;}
a = 10000 / _referrerReward;
if (a * _referrerReward != 10000) {throw;}
referrerReward = _referrerReward;
}
function getReferrerReward () returns (uint256 _referrerReward)
{
return referrerReward;
}
function Registrar () {
owner = msg.sender;
donationMultiplier = 100;
patronRewardMultiplier = 25000;
ethartRevenueReward = 250;
ethartArtReward = 250;
referrerReward = 1000;
}
function setPatronReward (uint256 _donationMultiplier) onlyBy (owner)
{
donationMultiplier = _donationMultiplier;
patronRewardMultiplier = ethartRevenueReward * _donationMultiplier;
if (patronRewardMultiplier / donationMultiplier > ethartRevenueReward) {throw;}
}
function setEthartRevenueReward (uint256 _ethartRevenueReward) onlyBy (owner)
{
uint256 a;
if (_ethartRevenueReward >1000) {throw;}
a = 10000 / _ethartRevenueReward;
if (a * _ethartRevenueReward < 10000) {throw;}
ethartRevenueReward = _ethartRevenueReward;
}
function getEthartRevenueReward () returns (uint256 _ethartRevenueReward)
{
return ethartRevenueReward;
}
function setEthartArtReward (uint256 _ethartArtReward) onlyBy (owner)
{
uint256 a;
if (_ethartArtReward >1000) {throw;}
a = 10000 / _ethartArtReward;
if (a * _ethartArtReward < 10000) {throw;}
ethartArtReward = _ethartArtReward;
}
function getEthartArtReward () returns (uint256 _ethartArtReward)
{
return ethartArtReward;
}
function changeOwner (address newOwner) onlyBy (owner)
{
owner = newOwner;
}
function issuePatrons (address _to, uint256 _amount) approvedContractsOnly
{
balances[_to] += _amount / 10000 * patronRewardMultiplier;
_totalPatronSupply += _amount / 10000 * patronRewardMultiplier;
}
function setDonationReward (uint256 _multiplier) onlyBy (owner)
{
donationMultiplier = _multiplier;
}
function donate () payable
{
balances[msg.sender] += msg.value * donationMultiplier;
_totalPatronSupply += msg.value * donationMultiplier;
}
function registerArtwork (address _contract, bytes32 _SHA256Hash, uint256 _editionSize, string _title, string _fileLink, uint256 _ownerCommission, address _artist, bool _indexed, bool _ouroboros) registeredFactoriesOnly
{
if (SHA256HashRegister[_SHA256Hash] == 0x0) {
SHA256HashRegister[_SHA256Hash] = _contract;
approvedContracts[_contract] = true;
cantSetReferrer[_artist] = true;
artworkRegister[_contract].SHA256Hash = _SHA256Hash;
artworkRegister[_contract].editionSize = _editionSize;
artworkRegister[_contract].title = _title;
artworkRegister[_contract].fileLink = _fileLink;
artworkRegister[_contract].ownerCommission = _ownerCommission;
artworkRegister[_contract].artist = _artist;
artworkRegister[_contract].factory = msg.sender;
artworkRegister[_contract].isIndexed = _indexed;
artworkRegister[_contract].isOuroboros = _ouroboros;
artworkIndex[artworkCount] = _contract;
artistsArtworks[_artist][artistsArtworkCount[_artist]] = _contract;
artistsArtworkCount[_artist]++;
NewArtwork (_contract, _SHA256Hash, _editionSize, _title, _fileLink, _ownerCommission, _artist, _indexed, _ouroboros);
artworkCount++;
}
else {throw;}
}
function isSHA256HashRegistered (bytes32 _SHA256Hash) returns (bool _registered)
{
if (SHA256HashRegister[_SHA256Hash] == 0x0)
{return false;}
else {return true;}
}
function approveFactoryContract (address _factoryContractAddress, bool _approved) onlyBy (owner)
{
approvedFactories[_factoryContractAddress] = _approved;
}
function asyncSend (address _payee, uint256 _amount) approvedContractsOnly
{
pendingWithdrawals[_payee] = add(pendingWithdrawals[_payee], _amount);
totalPendingWithdrawals = add(totalPendingWithdrawals, _amount);
}
function withdrawPaymentsRegistrar (address _dest, uint256 _payment) onlyBy (owner)
{
if (_payment == 0) {
throw;
}
if (this.balance < _payment) {
throw;
}
totalPendingWithdrawals = sub(totalPendingWithdrawals, _payment);
pendingWithdrawals[this] = sub(pendingWithdrawals[this], _payment);
if (!_dest.send(_payment)) {
throw;
}
}
function withdrawPayments() {
address payee = msg.sender;
uint256 payment = pendingWithdrawals[payee];
if (payment == 0) {
throw;
}
if (this.balance < payment) {
throw;
}
totalPendingWithdrawals = sub(totalPendingWithdrawals, payment);
pendingWithdrawals[payee] = 0;
if (!payee.send(payment)) {
throw;
}
}
function transferByAddress (address _contract, uint256 _amount, address _to) onlyBy (owner)
{
Interface c = Interface(_contract);
c.transfer(_to, _amount);
}
function transferIndexedByAddress (address _contract, uint256 _index, address _to) onlyBy (owner)
{
Interface c = Interface(_contract);
c.transferIndexed(_to, _index);
}
function approveByAddress (address _contract, address _spender, uint256 _amount) onlyBy (owner)
{
Interface c = Interface(_contract);
c.approve(_spender, _amount);
}
function approveIndexedByAddress (address _contract, address _spender, uint256 _index) onlyBy (owner)
{
Interface c = Interface(_contract);
c.approveIndexed(_spender, _index);
}
function burnByAddress (address _contract, uint256 _amount) onlyBy (owner)
{
Interface c = Interface(_contract);
c.burn(_amount);
}
function burnFromByAddress (address _contract, uint256 _amount, address _from) onlyBy (owner)
{
Interface c = Interface(_contract);
c.burnFrom (_from, _amount);
}
function burnIndexedByAddress (address _contract, uint256 _index) onlyBy (owner)
{
Interface c = Interface(_contract);
c.burnIndexed(_index);
}
function burnIndexedFromByAddress (address _contract, address _from, uint256 _index) onlyBy (owner)
{
Interface c = Interface(_contract);
c.burnIndexedFrom(_from, _index);
}
function offerPieceForSaleByAddress (address _contract, uint256 _price) onlyBy (owner)
{
Interface c = Interface(_contract);
c.offerPieceForSale(_price);
}
function fillBidByAddress (address _contract) onlyBy (owner)
{
Interface c = Interface(_contract);
c.fillBid();
}
function cancelSaleByAddress (address _contract) onlyBy (owner)
{
Interface c = Interface(_contract);
c.cancelSale();
}
function offerIndexedPieceForSaleByAddress (address _contract, uint256 _index, uint256 _price) onlyBy (owner)
{
Interface c = Interface(_contract);
c.offerIndexedPieceForSale(_index, _price);
}
function fillIndexedBidByAddress (address _contract, uint256 _index) onlyBy (owner)
{
Interface c = Interface(_contract);
c.fillIndexedBid(_index);
}
function cancelIndexedSaleByAddress (address _contract) onlyBy (owner)
{
Interface c = Interface(_contract);
c.cancelIndexedSale();
}
function() payable
{
if (!approvedContracts[msg.sender]) {throw;}
}
}