pragma solidity ^0.4.23;
contract DSAuthority {
function canCall(
address src, address dst, bytes4 sig
) public view returns (bool);
}
contract DSAuthEvents {
event LogSetAuthority (address indexed authority);
event LogSetOwner     (address indexed owner);
}
contract DSAuth is DSAuthEvents {
DSAuthority  public  authority;
address      public  owner;
constructor() public {
owner = msg.sender;
emit LogSetOwner(msg.sender);
}
function setOwner(address owner_)
public
auth
{
owner = owner_;
emit LogSetOwner(owner);
}
function setAuthority(DSAuthority authority_)
public
auth
{
authority = authority_;
emit LogSetAuthority(authority);
}
modifier auth {
require(isAuthorized(msg.sender, msg.sig));
_;
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
if (src == address(this)) {
return true;
} else if (src == owner) {
return true;
} else if (authority == DSAuthority(0)) {
return false;
} else {
return authority.canCall(src, this, sig);
}
}
}
contract DSMath {
function add(uint x, uint y) internal pure returns (uint z) {
require((z = x + y) >= x);
}
function sub(uint x, uint y) internal pure returns (uint z) {
require((z = x - y) <= x);
}
function mul(uint x, uint y) internal pure returns (uint z) {
require(y == 0 || (z = x * y) / y == x);
}
function min(uint x, uint y) internal pure returns (uint z) {
return x <= y ? x : y;
}
function max(uint x, uint y) internal pure returns (uint z) {
return x >= y ? x : y;
}
function imin(int x, int y) internal pure returns (int z) {
return x <= y ? x : y;
}
function imax(int x, int y) internal pure returns (int z) {
return x >= y ? x : y;
}
uint constant WAD = 10 ** 18;
uint constant RAY = 10 ** 27;
function wmul(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, y), WAD / 2) / WAD;
}
function rmul(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, y), RAY / 2) / RAY;
}
function wdiv(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, WAD), y / 2) / y;
}
function rdiv(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, RAY), y / 2) / y;
}
function rpow(uint x, uint n) internal pure returns (uint z) {
z = n % 2 != 0 ? x : RAY;
for (n /= 2; n != 0; n /= 2) {
x = rmul(x, x);
if (n % 2 != 0) {
z = rmul(z, x);
}
}
}
}
contract IkuraStorage is DSMath, DSAuth {
address[] ownerAddresses;
mapping(address => uint) coinBalances;
mapping(address => uint) tokenBalances;
mapping(address => mapping (address => uint)) coinAllowances;
uint _totalSupply = 0;
uint _transferFeeRate = 500;
uint8 _transferMinimumFee = 5;
address tokenAddress;
address multiSigAddress;
address authorityAddress;
constructor() public DSAuth() {
}
function changeToken(address tokenAddress_) public auth {
tokenAddress = tokenAddress_;
}
function changeAssociation(address multiSigAddress_) public auth {
multiSigAddress = multiSigAddress_;
}
function changeAuthority(address authorityAddress_) public auth {
authorityAddress = authorityAddress_;
}
function totalSupply() public view auth returns (uint) {
return _totalSupply;
}
function addTotalSupply(uint amount) public auth {
_totalSupply = add(_totalSupply, amount);
}
function subTotalSupply(uint amount) public auth {
_totalSupply = sub(_totalSupply, amount);
}
function transferFeeRate() public view auth returns (uint) {
return _transferFeeRate;
}
function setTransferFeeRate(uint newTransferFeeRate) public auth returns (bool) {
_transferFeeRate = newTransferFeeRate;
return true;
}
function transferMinimumFee() public view auth returns (uint8) {
return _transferMinimumFee;
}
function setTransferMinimumFee(uint8 newTransferMinimumFee) public auth {
_transferMinimumFee = newTransferMinimumFee;
}
function addOwnerAddress(address addr) internal returns (bool) {
ownerAddresses.push(addr);
return true;
}
function removeOwnerAddress(address addr) internal returns (bool) {
uint i = 0;
while (ownerAddresses[i] != addr) { i++; }
while (i < ownerAddresses.length - 1) {
ownerAddresses[i] = ownerAddresses[i + 1];
i++;
}
ownerAddresses.length--;
return true;
}
function primaryOwner() public view auth returns (address) {
return ownerAddresses[0];
}
function isOwnerAddress(address addr) public view auth returns (bool) {
for (uint i = 0; i < ownerAddresses.length; i++) {
if (ownerAddresses[i] == addr) return true;
}
return false;
}
function numOwnerAddress() public view auth returns (uint) {
return ownerAddresses.length;
}
function coinBalance(address addr) public view auth returns (uint) {
return coinBalances[addr];
}
function addCoinBalance(address addr, uint amount) public auth returns (bool) {
coinBalances[addr] = add(coinBalances[addr], amount);
return true;
}
function subCoinBalance(address addr, uint amount) public auth returns (bool) {
coinBalances[addr] = sub(coinBalances[addr], amount);
return true;
}
function tokenBalance(address addr) public view auth returns (uint) {
return tokenBalances[addr];
}
function addTokenBalance(address addr, uint amount) public auth returns (bool) {
tokenBalances[addr] = add(tokenBalances[addr], amount);
if (tokenBalances[addr] > 0 && !isOwnerAddress(addr)) {
addOwnerAddress(addr);
}
return true;
}
function subTokenBalance(address addr, uint amount) public auth returns (bool) {
tokenBalances[addr] = sub(tokenBalances[addr], amount);
if (tokenBalances[addr] <= 0) {
removeOwnerAddress(addr);
}
return true;
}
function coinAllowance(address owner_, address spender) public view auth returns (uint) {
return coinAllowances[owner_][spender];
}
function addCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
coinAllowances[owner_][spender] = add(coinAllowances[owner_][spender], amount);
return true;
}
function subCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
coinAllowances[owner_][spender] = sub(coinAllowances[owner_][spender], amount);
return true;
}
function setCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
coinAllowances[owner_][spender] = amount;
return true;
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
sig;
return  src == address(this) ||
src == owner ||
src == tokenAddress ||
src == authorityAddress ||
src == multiSigAddress;
}
}
contract IkuraTokenEvent {
event IkuraMint(address indexed owner, uint);
event IkuraBurn(address indexed owner, uint);
event IkuraTransferToken(address indexed from, address indexed to, uint value);
event IkuraTransferFee(address indexed from, address indexed to, address indexed owner, uint value);
event IkuraTransfer(address indexed from, address indexed to, uint value);
event IkuraApproval(address indexed owner, address indexed spender, uint value);
}
contract IkuraAssociation is DSMath, DSAuth {
uint public confirmTotalTokenThreshold = 50;
IkuraStorage _storage;
IkuraToken _token;
Proposal[] mintProposals;
Proposal[] burnProposals;
mapping (bytes32 => Proposal[]) proposals;
struct Proposal {
address proposer;
bytes32 digest;
bool executed;
uint createdAt;
uint expireAt;
address[] confirmers;
uint amount;
}
event MintProposalAdded(uint proposalId, address proposer, uint amount);
event MintConfirmed(uint proposalId, address confirmer, uint amount);
event MintExecuted(uint proposalId, address proposer, uint amount);
event BurnProposalAdded(uint proposalId, address proposer, uint amount);
event BurnConfirmed(uint proposalId, address confirmer, uint amount);
event BurnExecuted(uint proposalId, address proposer, uint amount);
constructor() public {
proposals[keccak256('mint')] = mintProposals;
proposals[keccak256('burn')] = burnProposals;
}
function changeStorage(IkuraStorage newStorage) public auth returns (bool) {
_storage = newStorage;
return true;
}
function changeToken(IkuraToken token_) public auth returns (bool) {
_token = token_;
return true;
}
function newProposal(bytes32 type_, address proposer, uint amount, bytes transationBytecode) public returns (uint) {
uint proposalId = proposals[type_].length++;
Proposal storage proposal = proposals[type_][proposalId];
proposal.proposer = proposer;
proposal.amount = amount;
proposal.digest = keccak256(proposer, amount, transationBytecode);
proposal.executed = false;
proposal.createdAt = now;
proposal.expireAt = proposal.createdAt + 86400;
if (type_ == keccak256('mint')) emit MintProposalAdded(proposalId, proposer, amount);
if (type_ == keccak256('burn')) emit BurnProposalAdded(proposalId, proposer, amount);
confirmProposal(type_, proposer, proposalId);
return proposalId;
}
function confirmProposal(bytes32 type_, address confirmer, uint proposalId) public {
Proposal storage proposal = proposals[type_][proposalId];
require(!hasConfirmed(type_, confirmer, proposalId));
proposal.confirmers.push(confirmer);
if (type_ == keccak256('mint')) emit MintConfirmed(proposalId, confirmer, proposal.amount);
if (type_ == keccak256('burn')) emit BurnConfirmed(proposalId, confirmer, proposal.amount);
if (isProposalExecutable(type_, proposalId, proposal.proposer, '')) {
proposal.executed = true;
if (type_ == keccak256('mint')) executeMintProposal(proposalId);
if (type_ == keccak256('burn')) executeBurnProposal(proposalId);
}
}
function hasConfirmed(bytes32 type_, address addr, uint proposalId) internal view returns (bool) {
Proposal storage proposal = proposals[type_][proposalId];
uint length = proposal.confirmers.length;
for (uint i = 0; i < length; i++) {
if (proposal.confirmers[i] == addr) return true;
}
return false;
}
function confirmedTotalToken(bytes32 type_, uint proposalId) internal view returns (uint) {
Proposal storage proposal = proposals[type_][proposalId];
uint length = proposal.confirmers.length;
uint total = 0;
for (uint i = 0; i < length; i++) {
total = add(total, _storage.tokenBalance(proposal.confirmers[i]));
}
return total;
}
function proposalExpireAt(bytes32 type_, uint proposalId) public view returns (uint) {
Proposal storage proposal = proposals[type_][proposalId];
return proposal.expireAt;
}
function isProposalExecutable(bytes32 type_, uint proposalId, address proposer, bytes transactionBytecode) internal view returns (bool) {
Proposal storage proposal = proposals[type_][proposalId];
if (_storage.numOwnerAddress() < 2) {
return true;
}
return  proposal.digest == keccak256(proposer, proposal.amount, transactionBytecode) &&
isProposalNotExpired(type_, proposalId) &&
mul(100, confirmedTotalToken(type_, proposalId)) / _storage.totalSupply() > confirmTotalTokenThreshold;
}
function numberOfProposals(bytes32 type_) public constant returns (uint) {
return proposals[type_].length;
}
function numberOfActiveProposals(bytes32 type_) public view returns (uint) {
uint numActiveProposal = 0;
for(uint i = 0; i < proposals[type_].length; i++) {
if (isProposalNotExpired(type_, i)) {
numActiveProposal++;
}
}
return numActiveProposal;
}
function isProposalNotExpired(bytes32 type_, uint proposalId) internal view returns (bool) {
Proposal storage proposal = proposals[type_][proposalId];
return  !proposal.executed &&
now < proposal.expireAt;
}
function executeMintProposal(uint proposalId) internal returns (bool) {
Proposal storage proposal = proposals[keccak256('mint')][proposalId];
require(proposal.amount > 0);
emit MintExecuted(proposalId, proposal.proposer, proposal.amount);
_storage.addTotalSupply(proposal.amount);
_storage.addCoinBalance(proposal.proposer, proposal.amount);
_storage.addTokenBalance(proposal.proposer, proposal.amount);
return true;
}
function executeBurnProposal(uint proposalId) internal returns (bool) {
Proposal storage proposal = proposals[keccak256('burn')][proposalId];
require(proposal.amount > 0);
require(_storage.coinBalance(proposal.proposer) >= proposal.amount);
require(_storage.tokenBalance(proposal.proposer) >= proposal.amount);
emit BurnExecuted(proposalId, proposal.proposer, proposal.amount);
_storage.subTotalSupply(proposal.amount);
_storage.subCoinBalance(proposal.proposer, proposal.amount);
_storage.subTokenBalance(proposal.proposer, proposal.amount);
return true;
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
sig;
return  src == address(this) ||
src == owner ||
src == address(_token);
}
}
library ProposalLibrary {
struct Entity {
IkuraStorage _storage;
IkuraAssociation _association;
}
function changeStorage(Entity storage self, address storage_) internal {
self._storage = IkuraStorage(storage_);
}
function changeAssociation(Entity storage self, address association_) internal {
self._association = IkuraAssociation(association_);
}
function mint(Entity storage self, address sender, uint amount) public returns (bool) {
require(amount > 0);
self._association.newProposal(keccak256('mint'), sender, amount, '');
return true;
}
function burn(Entity storage self, address sender, uint amount) public returns (bool) {
require(amount > 0);
require(self._storage.coinBalance(sender) >= amount);
require(self._storage.tokenBalance(sender) >= amount);
self._association.newProposal(keccak256('burn'), sender, amount, '');
return true;
}
function confirmProposal(Entity storage self, address sender, bytes32 type_, uint proposalId) public {
self._association.confirmProposal(type_, sender, proposalId);
}
function numberOfProposals(Entity storage self, bytes32 type_) public view returns (uint) {
return self._association.numberOfProposals(type_);
}
}
contract IkuraToken is IkuraTokenEvent, DSMath, DSAuth {
uint _transferFeeRate = 0;
uint8 _transferMinimumFee = 0;
uint _logicVersion = 2;
IkuraStorage _storage;
IkuraAssociation _association;
constructor() DSAuth() public {
}
function totalSupply(address sender) public view returns (uint) {
sender;
return _storage.totalSupply();
}
function balanceOf(address sender, address addr) public view returns (uint) {
sender;
return _storage.coinBalance(addr);
}
function transfer(address sender, address to, uint amount) public auth returns (bool success) {
uint fee = transferFee(sender, sender, to, amount);
uint totalAmount = add(amount, fee);
require(_storage.coinBalance(sender) >= totalAmount);
require(amount > 0);
_storage.subCoinBalance(sender, totalAmount);
_storage.addCoinBalance(to, amount);
if (fee > 0) {
address owner = selectOwnerAddressForTransactionFee(sender);
_storage.addCoinBalance(owner, fee);
}
return true;
}
function transferFrom(address sender, address from, address to, uint amount) public auth returns (bool success) {
uint fee = transferFee(sender, from, to, amount);
require(_storage.coinBalance(from) >= amount);
require(_storage.coinAllowance(from, sender) >= amount);
require(amount > 0);
require(add(_storage.coinBalance(to), amount) > _storage.coinBalance(to));
if (fee > 0) {
require(_storage.coinBalance(sender) >= fee);
address owner = selectOwnerAddressForTransactionFee(sender);
_storage.subCoinBalance(sender, fee);
_storage.addCoinBalance(owner, fee);
}
_storage.subCoinBalance(from, amount);
_storage.subCoinAllowance(from, sender, amount);
_storage.addCoinBalance(to, amount);
return true;
}
function approve(address sender, address spender, uint amount) public auth returns (bool success) {
_storage.setCoinAllowance(sender, spender, amount);
return true;
}
function allowance(address sender, address owner, address spender) public view returns (uint remaining) {
sender;
return _storage.coinAllowance(owner, spender);
}
function tokenBalanceOf(address sender, address owner) public view returns (uint balance) {
sender;
return _storage.tokenBalance(owner);
}
function transferToken(address sender, address to, uint amount) public auth returns (bool success) {
require(_storage.tokenBalance(sender) >= amount);
require(amount > 0);
require(add(_storage.tokenBalance(to), amount) > _storage.tokenBalance(to));
_storage.subTokenBalance(sender, amount);
_storage.addTokenBalance(to, amount);
emit IkuraTransferToken(sender, to, amount);
return true;
}
function transferFee(address sender, address from, address to, uint amount) public view returns (uint) {
sender; from; to;
if (_transferFeeRate > 0) {
uint denominator = 1000000;
uint numerator = mul(amount, _transferFeeRate);
uint fee = numerator / denominator;
uint remainder = sub(numerator, mul(denominator, fee));
if (remainder > 0) {
fee++;
}
if (fee < _transferMinimumFee) {
fee = _transferMinimumFee;
}
return fee;
} else {
return 0;
}
}
function transferFeeRate(address sender) public view returns (uint) {
sender;
return _transferFeeRate;
}
function transferMinimumFee(address sender) public view returns (uint8) {
sender;
return _transferMinimumFee;
}
function selectOwnerAddressForTransactionFee(address sender) public view returns (address) {
sender;
return _storage.primaryOwner();
}
function mint(address sender, uint amount) public auth returns (bool) {
require(amount > 0);
_association.newProposal(keccak256('mint'), sender, amount, '');
return true;
}
function burn(address sender, uint amount) public auth returns (bool) {
require(amount > 0);
require(_storage.coinBalance(sender) >= amount);
require(_storage.tokenBalance(sender) >= amount);
_association.newProposal(keccak256('burn'), sender, amount, '');
return true;
}
function confirmProposal(address sender, bytes32 type_, uint proposalId) public auth {
_association.confirmProposal(type_, sender, proposalId);
}
function numberOfProposals(bytes32 type_) public view returns (uint) {
return _association.numberOfProposals(type_);
}
function changeAssociation(address association_) public auth returns (bool) {
_association = IkuraAssociation(association_);
return true;
}
function changeStorage(address storage_) public auth returns (bool) {
_storage = IkuraStorage(storage_);
return true;
}
function logicVersion(address sender) public view returns (uint) {
sender;
return _logicVersion;
}
}