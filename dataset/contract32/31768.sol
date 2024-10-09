pragma solidity ^0.4.17;
contract ERC20 {
function totalSupply() public view returns (uint supply);
function balanceOf( address who ) public view returns (uint value);
function allowance( address owner, address spender ) public view returns (uint _allowance);
function transfer( address to, uint value) public returns (bool ok);
function transferFrom( address from, address to, uint value) public returns (bool ok);
function approve( address spender, uint value ) public returns (bool ok);
event Transfer( address indexed from, address indexed to, uint value);
event Approval( address indexed owner, address indexed spender, uint value);
}
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
function DSAuth() public {
owner = msg.sender;
LogSetOwner(msg.sender);
}
function setOwner(address owner_)
public
auth
{
owner = owner_;
LogSetOwner(owner);
}
function setAuthority(DSAuthority authority_)
public
auth
{
authority = authority_;
LogSetAuthority(authority);
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
contract APMath {
function safeAdd(uint x, uint y) internal pure returns (uint z) {
require((z = x + y) >= x);
}
function safeSub(uint x, uint y) internal pure returns (uint z) {
require((z = x - y) <= x);
}
function safeMul(uint x, uint y) internal pure returns (uint z) {
require(y == 0 || (z = x * y) / y == x);
}
function safeMin(uint x, uint y) internal pure returns (uint z) {
return x <= y ? x : y;
}
function safeMax(uint x, uint y) internal pure returns (uint z) {
return x >= y ? x : y;
}
function safeMin(int x, int y) internal pure returns (int z) {
return x <= y ? x : y;
}
function safeMax(int x, int y) internal pure returns (int z) {
return x >= y ? x : y;
}
uint constant WAD = 10 ** 18;
uint constant RAY = 10 ** 27;
function safeWmul(uint x, uint y) internal pure returns (uint z) {
z = safeAdd(safeMul(x, y), WAD / 2) / WAD;
}
function safeRmul(uint x, uint y) internal pure returns (uint z) {
z = safeAdd(safeMul(x, y), RAY / 2) / RAY;
}
function safeWdiv(uint x, uint y) internal pure returns (uint z) {
z = safeAdd(safeMul(x, WAD), y / 2) / y;
}
function safeRdiv(uint x, uint y) internal pure returns (uint z) {
z = safeAdd(safeMul(x, RAY), y / 2) / y;
}
function rpow(uint x, uint n) internal pure returns (uint z) {
z = n % 2 != 0 ? x : RAY;
for (n /= 2; n != 0; n /= 2) {
x = safeRmul(x, x);
if (n % 2 != 0) {
z = safeRmul(z, x);
}
}
}
}
contract DrivezyPrivateCoinSharedStorage is DSAuth {
uint _totalSupply = 0;
mapping(address => bool) ownerAddresses;
address[] public ownerAddressLUT;
mapping(address => bool) trustedContractAddresses;
address[] public trustedAddressLUT;
mapping(address => bool) approvedAddresses;
address[] public approvedAddressLUT;
mapping(bytes4 => bool) actionsAlwaysPermitted;
event AddOwnerAddress(address indexed senderAddress, address indexed userAddress);
event RemoveOwnerAddress(address indexed senderAddress, address indexed userAddress);
event AddTrustedContractAddress(address indexed senderAddress, address indexed userAddress);
event RemoveTrustedContractAddress(address indexed senderAddress, address indexed userAddress);
function addOwnerAddress(address addr) auth public returns (bool) {
ownerAddresses[addr] = true;
ownerAddressLUT.push(addr);
AddOwnerAddress(msg.sender, addr);
return true;
}
function addTrustedContractAddress(address addr) auth public returns (bool) {
trustedContractAddresses[addr] = true;
trustedAddressLUT.push(addr);
AddTrustedContractAddress(msg.sender, addr);
return true;
}
function addApprovedAddress(address addr) auth public returns (bool) {
approvedAddresses[addr] = true;
approvedAddressLUT.push(addr);
return true;
}
function removeOwnerAddress(address addr) auth public returns (bool) {
ownerAddresses[addr] = false;
RemoveOwnerAddress(msg.sender, addr);
return true;
}
function removeTrustedContractAddress(address addr) auth public returns (bool) {
trustedContractAddresses[addr] = false;
RemoveTrustedContractAddress(msg.sender, addr);
return true;
}
function removeApprovedAddress(address addr) auth public returns (bool) {
approvedAddresses[addr] = false;
return true;
}
function isOwnerAddress(address addr) public constant returns (bool) {
return ownerAddresses[addr];
}
function isApprovedAddress(address addr) public constant returns (bool) {
return approvedAddresses[addr];
}
function isTrustedContractAddress(address addr) public constant returns (bool) {
return trustedContractAddresses[addr];
}
function ownerAddressSize() public constant returns (uint) {
return ownerAddressLUT.length;
}
function ownerAddressInLUT(uint index) public constant returns (address) {
return ownerAddressLUT[index];
}
function trustedAddressSize() public constant returns (uint) {
return trustedAddressLUT.length;
}
function trustedAddressInLUT(uint index) public constant returns (address) {
return trustedAddressLUT[index];
}
function approvedAddressSize() public constant returns (uint) {
return approvedAddressLUT.length;
}
function approvedAddressInLUT(uint index) public constant returns (address) {
return approvedAddressLUT[index];
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
return src == address(this) || src == owner || isOwnerAddress(src) || isTrustedContractAddress(src) || actionsAlwaysPermitted[sig];
}
}
contract DrivezyPrivateCoinStorage is DSAuth {
uint _totalSupply = 0;
mapping(address => uint) coinBalances;
mapping(address => mapping (address => uint)) coinAllowances;
DrivezyPrivateCoinSharedStorage public sharedStorage;
mapping(bytes4 => bool) actionsAlwaysPermitted;
bool public transferBetweenUsers;
function totalSupply() external constant returns (uint) {
return _totalSupply;
}
function setTotalSupply(uint amount) auth external returns (bool) {
_totalSupply = amount;
return true;
}
function coinBalanceOf(address addr) external constant returns (uint) {
return coinBalances[addr];
}
function coinAllowanceOf(address _owner, address spender) external constant returns (uint) {
return coinAllowances[_owner][spender];
}
function setCoinBalance(address addr, uint amount) auth external returns (bool) {
coinBalances[addr] = amount;
return true;
}
function setCoinAllowance(address _owner, address spender, uint value) auth external returns (bool) {
coinAllowances[_owner][spender] = value;
return true;
}
function setSharedStorage(address addr) auth public returns (bool) {
sharedStorage = DrivezyPrivateCoinSharedStorage(addr);
return true;
}
function allowTransferBetweenUsers() auth public returns (bool) {
transferBetweenUsers = true;
return true;
}
function disallowTransferBetweenUsers() auth public returns (bool) {
transferBetweenUsers = false;
return true;
}
function canTransferBetweenUsers() public view returns (bool) {
return transferBetweenUsers;
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
return actionsAlwaysPermitted[sig] || src == address(this) || src == owner || sharedStorage.isOwnerAddress(src) || sharedStorage.isTrustedContractAddress(src);
}
}
contract DrivezyPrivateCoinAcceptableContract {
function receiveToken(address addr, uint amount) public returns (bool);
function isDrivezyPrivateTokenAcceptable() public pure returns (bool);
}
contract DrivezyPrivateCoinImplementation is DSAuth, APMath {
DrivezyPrivateCoinStorage public coinStorage;
DrivezyPrivateCoinSharedStorage public sharedStorage;
DrivezyPrivateCoin public coin;
event SetStorage(address indexed senderAddress, address indexed contractAddress);
event SetSharedStorage(address indexed senderAddress, address indexed contractAddress);
event SetCoin(address indexed senderAddress, address indexed contractAddress);
event Mint(address indexed senderAddress, address indexed receiverAddress, uint amount);
event Burn(address indexed senderAddress, address indexed receiverAddress, uint amount);
event AddApprovedAddress(address indexed senderAddress, address indexed userAddress);
event RemoveApprovedAddress(address indexed senderAddress, address indexed userAddress);
function totalSupply() auth public view returns (uint) {
return coinStorage.totalSupply();
}
function balanceOf(address addr) auth public view returns (uint) {
return coinStorage.coinBalanceOf(addr);
}
function transfer(address sender, address to, uint amount) auth public returns (bool) {
require(coinStorage.coinBalanceOf(sender) >= amount);
require(amount > 0);
require(canTransfer(sender, to));
coinStorage.setCoinBalance(sender, safeSub(coinStorage.coinBalanceOf(sender), amount));
coinStorage.setCoinBalance(to, safeAdd(coinStorage.coinBalanceOf(to), amount));
if (isContract(to)) {
DrivezyPrivateCoinAcceptableContract receiver = DrivezyPrivateCoinAcceptableContract(to);
if (receiver.isDrivezyPrivateTokenAcceptable()) {
require(receiver.receiveToken(sender, amount));
}
}
return true;
}
function transferFrom(address sender, address from, address to, uint amount) auth public returns (bool) {
require(coinStorage.coinAllowanceOf(sender, from) >= amount);
transfer(from, to, amount);
coinStorage.setCoinAllowance(from, sender, safeSub(coinStorage.coinAllowanceOf(sender, from), amount));
return true;
}
function approve(address sender, address spender, uint amount) auth public returns (bool) {
coinStorage.setCoinAllowance(sender, spender, amount);
return true;
}
function allowance(address owner, address spender) auth public constant returns (uint) {
return coinStorage.coinAllowanceOf(owner, spender);
}
function setStorage(address addr) auth public returns (bool) {
coinStorage = DrivezyPrivateCoinStorage(addr);
SetStorage(msg.sender, addr);
return true;
}
function setSharedStorage(address addr) auth public returns (bool) {
sharedStorage = DrivezyPrivateCoinSharedStorage(addr);
SetSharedStorage(msg.sender, addr);
return true;
}
function setCoin(address addr) auth public returns (bool) {
coin = DrivezyPrivateCoin(addr);
SetCoin(msg.sender, addr);
return true;
}
function mint(address receiver, uint amount) auth public returns (bool) {
require(amount > 0);
coinStorage.setTotalSupply(safeAdd(coinStorage.totalSupply(), amount));
addApprovedAddress(address(this));
coinStorage.setCoinBalance(address(this), safeAdd(coinStorage.coinBalanceOf(address(this)), amount));
require(coin.transfer(receiver, amount));
Mint(msg.sender, receiver, amount);
return true;
}
function burn(address receiver, uint amount) auth public returns (bool) {
require(amount > 0);
require(coinStorage.coinBalanceOf(receiver) >= amount);
approve(address(this), receiver, amount);
addApprovedAddress(address(this));
require(coin.transferFrom(receiver, address(this), amount));
coinStorage.setTotalSupply(safeSub(coinStorage.totalSupply(), amount));
coinStorage.setCoinBalance(address(this), safeSub(coinStorage.coinBalanceOf(address(this)), amount));
Burn(msg.sender, receiver, amount);
return true;
}
function addApprovedAddress(address addr) auth public returns (bool) {
sharedStorage.addApprovedAddress(addr);
AddApprovedAddress(msg.sender, addr);
return true;
}
function removeApprovedAddress(address addr) auth public returns (bool) {
sharedStorage.removeApprovedAddress(addr);
RemoveApprovedAddress(msg.sender, addr);
return true;
}
function allowTransferBetweenUsers() auth public returns (bool) {
coinStorage.allowTransferBetweenUsers();
return true;
}
function disallowTransferBetweenUsers() auth public returns (bool) {
coinStorage.disallowTransferBetweenUsers();
return true;
}
function canCall(address src, address dst, bytes4 sig) public constant returns (bool) {
dst;
sig;
return src == owner || sharedStorage.isOwnerAddress(src) || sharedStorage.isTrustedContractAddress(src) || src == address(coin);
}
function canTransfer(address from, address to) internal constant returns (bool) {
require(sharedStorage.isOwnerAddress(to) || sharedStorage.isApprovedAddress(to));
require(coinStorage.canTransferBetweenUsers() || sharedStorage.isOwnerAddress(from) || sharedStorage.isTrustedContractAddress(from) || sharedStorage.isOwnerAddress(to) || sharedStorage.isTrustedContractAddress(to));
return true;
}
function isAuthorized(address src, bytes4 sig) internal constant returns (bool) {
return canCall(src, address(this), sig);
}
function isContract(address addr) public view returns (bool result) {
uint length;
assembly {
length := extcodesize(addr)
}
return (length > 0);
}
function isDrivezyPrivateTokenAcceptable() public pure returns (bool result) {
return false;
}
}
contract DrivezyPrivateCoin is ERC20, DSAuth {
string public name = "Uni 0.1.0";
string public symbol = "ORI";
uint8 public decimals = 6;
event SetImplementation(address indexed senderAddress, address indexed contractAddress);
DrivezyPrivateCoinImplementation public implementation;
function totalSupply() public constant returns (uint) {
return implementation.totalSupply();
}
function balanceOf(address addr) public constant returns (uint) {
return implementation.balanceOf(addr);
}
function transfer(address to, uint amount) public returns (bool) {
if (implementation.transfer(msg.sender, to, amount)) {
Transfer(msg.sender, to, amount);
return true;
} else {
return false;
}
}
function transferFrom(address from, address to, uint amount) public returns (bool) {
if (implementation.transferFrom(msg.sender, from, to, amount)) {
Transfer(from, to, amount);
return true;
} else {
return false;
}
}
function approve(address spender, uint amount) public returns (bool) {
if (implementation.approve(msg.sender, spender, amount)) {
Approval(msg.sender, spender, amount);
return true;
} else {
return false;
}
}
function allowance(address addr, address spender) public constant returns (uint) {
return implementation.allowance(addr, spender);
}
function setImplementation(address addr) auth public returns (bool) {
implementation = DrivezyPrivateCoinImplementation(addr);
SetImplementation(msg.sender, addr);
return true;
}
function isAuthorized(address src, bytes4 sig) internal constant returns (bool) {
return src == address(this) ||
src == owner ||
(implementation != DrivezyPrivateCoinImplementation(0) && implementation.canCall(src, address(this), sig));
}
}
contract DrivezyPrivateDecemberCoin is DrivezyPrivateCoin {
string public name = "Rental Coins 1.0 1st private offering";
string public symbol = "RC1";
uint8 public decimals = 6;
}