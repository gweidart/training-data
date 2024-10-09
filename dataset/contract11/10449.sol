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
pragma solidity ^0.4.13;
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
contract IkuraAuthority is DSAuthority, DSAuth {
IkuraStorage tokenStorage;
mapping(bytes4 => bool) actionsWithToken;
mapping(bytes4 => bool) actionsForbidden;
constructor() public DSAuth() {
}
function changeStorage(address storage_) public auth {
tokenStorage = IkuraStorage(storage_);
actionsWithToken[stringToSig('mint(uint256)')] = true;
actionsWithToken[stringToSig('burn(uint256)')] = true;
actionsWithToken[stringToSig('confirmProposal(string, uint256)')] = true;
actionsWithToken[stringToSig('numberOfProposals(string)')] = true;
actionsForbidden[stringToSig('forbiddenAction()')] = true;
}
function canCall(address src, address dst, bytes4 sig) public constant returns (bool) {
if (actionsWithToken[sig]) return canCallWithAssociation(src, dst);
if (actionsForbidden[sig]) return canCallWithNoOne();
return canCallDefault(src);
}
function canCallDefault(address src) internal view returns (bool) {
return tokenStorage.isOwnerAddress(src);
}
function canCallWithAssociation(address src, address dst) internal view returns (bool) {
dst;
return tokenStorage.isOwnerAddress(src) &&
(tokenStorage.numOwnerAddress() == 1 || tokenStorage.tokenBalance(src) > 0);
}
function canCallWithNoOne() internal pure returns (bool) {
return false;
}
function stringToSig(string str) internal pure returns (bytes4) {
return bytes4(keccak256(str));
}
}