pragma solidity ^0.4.21;
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
contract DSNote {
event LogNote(
bytes4   indexed  sig,
address  indexed  guy,
bytes32  indexed  foo,
bytes32  indexed  bar,
uint              wad,
bytes             fax
) anonymous;
modifier note {
bytes32 foo;
bytes32 bar;
assembly {
foo := calldataload(4)
bar := calldataload(36)
}
LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
_;
}
}
contract DSStop is DSNote, DSAuth {
bool public stopped;
modifier stoppable {
require(!stopped);
_;
}
function stop() public auth note {
stopped = true;
}
function start() public auth note {
stopped = false;
}
}
contract ERC20Events {
event Approval(address indexed src, address indexed guy, uint wad);
event Transfer(address indexed src, address indexed dst, uint wad);
}
contract ERC20 is ERC20Events {
function totalSupply() public view returns (uint);
function balanceOf(address guy) public view returns (uint);
function allowance(address src, address guy) public view returns (uint);
function approve(address guy, uint wad) public returns (bool);
function transfer(address dst, uint wad) public returns (bool);
function transferFrom(
address src, address dst, uint wad
) public returns (bool);
}
contract DSTokenBase is ERC20, DSMath {
uint256                                            _supply;
mapping (address => uint256)                       _balances;
mapping (address => mapping (address => uint256))  _approvals;
function DSTokenBase(uint supply) public {
_balances[msg.sender] = supply;
_supply = supply;
}
function totalSupply() public view returns (uint) {
return _supply;
}
function balanceOf(address src) public view returns (uint) {
return _balances[src];
}
function allowance(address src, address guy) public view returns (uint) {
return _approvals[src][guy];
}
function transfer(address dst, uint wad) public returns (bool) {
return transferFrom(msg.sender, dst, wad);
}
function transferFrom(address src, address dst, uint wad)
public
returns (bool)
{
if (src != msg.sender) {
_approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
}
_balances[src] = sub(_balances[src], wad);
_balances[dst] = add(_balances[dst], wad);
Transfer(src, dst, wad);
return true;
}
function approve(address guy, uint wad) public returns (bool) {
_approvals[msg.sender][guy] = wad;
Approval(msg.sender, guy, wad);
return true;
}
}
contract DSToken is DSTokenBase(0), DSStop {
bytes32  public  symbol;
uint256  public  decimals = 18;
function DSToken(bytes32 symbol_) public {
symbol = symbol_;
}
event Mint(address indexed guy, uint wad);
event Burn(address indexed guy, uint wad);
function approve(address guy) public stoppable returns (bool) {
return super.approve(guy, uint(-1));
}
function approve(address guy, uint wad) public stoppable returns (bool) {
return super.approve(guy, wad);
}
function transferFrom(address src, address dst, uint wad)
public
stoppable
returns (bool)
{
if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
_approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
}
_balances[src] = sub(_balances[src], wad);
_balances[dst] = add(_balances[dst], wad);
Transfer(src, dst, wad);
return true;
}
function push(address dst, uint wad) public {
transferFrom(msg.sender, dst, wad);
}
function pull(address src, uint wad) public {
transferFrom(src, msg.sender, wad);
}
function move(address src, address dst, uint wad) public {
transferFrom(src, dst, wad);
}
function mint(uint wad) public {
mint(msg.sender, wad);
}
function burn(uint wad) public {
burn(msg.sender, wad);
}
function mint(address guy, uint wad) public auth stoppable {
_balances[guy] = add(_balances[guy], wad);
_supply = add(_supply, wad);
Mint(guy, wad);
}
function burn(address guy, uint wad) public auth stoppable {
if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
_approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
}
_balances[guy] = sub(_balances[guy], wad);
_supply = sub(_supply, wad);
Burn(guy, wad);
}
bytes32   public  name = "";
function setName(bytes32 name_) public auth {
name = name_;
}
}
contract DSThing is DSAuth, DSNote, DSMath {
function S(string s) internal pure returns (bytes4) {
return bytes4(keccak256(s));
}
}
contract DSValue is DSThing {
bool    has;
bytes32 val;
function peek() public view returns (bytes32, bool) {
return (val,has);
}
function read() public view returns (bytes32) {
bytes32 wut; bool haz;
(wut, haz) = peek();
assert(haz);
return wut;
}
function poke(bytes32 wut) public note auth {
val = wut;
has = true;
}
function void() public note auth {
has = false;
}
}
contract SaiLPC is DSThing {
ERC20    public  ref;
ERC20    public  alt;
DSValue  public  pip;
uint256  public  gap;
DSToken  public  lps;
function SaiLPC(ERC20 ref_, ERC20 alt_, DSValue pip_, DSToken lps_) public {
ref = ref_;
alt = alt_;
pip = pip_;
lps = lps_;
gap = WAD;
}
function jump(uint wad) public note auth {
assert(wad != 0);
gap = wad;
}
function tag() public view returns (uint) {
return uint(pip.read());
}
function pie() public view returns (uint) {
return add(ref.balanceOf(this), wmul(alt.balanceOf(this), tag()));
}
function per() public view returns (uint) {
return lps.totalSupply() == 0
? RAY
: rdiv(lps.totalSupply(), pie());
}
function pool(ERC20 gem, uint wad) public note auth {
require(gem == alt || gem == ref);
uint jam = (gem == ref) ? wad : wmul(wad, tag());
uint ink = rmul(jam, per());
lps.mint(ink);
lps.push(msg.sender, ink);
gem.transferFrom(msg.sender, this, wad);
}
function exit(ERC20 gem, uint wad) public note auth {
require(gem == alt || gem == ref);
uint jam = (gem == ref) ? wad : wmul(wad, tag());
uint ink = rmul(jam, per());
ink = (jam == pie())? ink : wmul(gap, ink);
lps.pull(msg.sender, ink);
lps.burn(ink);
gem.transfer(msg.sender, wad);
}
function take(ERC20 gem, uint wad) public note auth {
require(gem == alt || gem == ref);
uint jam = (gem == ref) ? wdiv(wad, tag()) : wmul(wad, tag());
jam = wmul(gap, jam);
ERC20 pay = (gem == ref) ? alt : ref;
pay.transferFrom(msg.sender, this, jam);
gem.transfer(msg.sender, wad);
}
}
interface KyberReserveInterface {
function() payable;
function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) external view returns(uint);
function withdraw(ERC20 token, uint amount, address destination) external returns(bool);
function getBalance(ERC20 token) external view returns(uint);
}
interface WETHInterface {
function() external payable;
function deposit() external payable;
function withdraw(uint wad) external;
}
contract WETH is WETHInterface, ERC20 { }
contract LPCReserveWrapper is DSThing {
ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
KyberReserveInterface public reserve;
WETH public weth;
ERC20 public dai;
SaiLPC public lpc;
function LPCReserveWrapper(KyberReserveInterface reserve_, WETH weth_, ERC20 dai_, SaiLPC lpc_) public {
assert(address(reserve_) != 0);
assert(address(weth_) != 0);
assert(address(dai_) != 0);
assert(address(lpc_) != 0);
reserve = reserve_;
weth = weth_;
lpc = lpc_;
dai = dai_;
}
function switchLPC(SaiLPC lpc_) public note auth {
assert(address(lpc_) != 0);
lpc = lpc_;
}
function switchReserve(KyberReserveInterface reserve_) public note auth {
assert(address(reserve_) != 0);
reserve = reserve_;
}
function() public payable { }
function withdrawFromReserve(ERC20 token, uint amount) internal returns (bool success) {
if (token == weth) {
require(reserve.withdraw(ETH_TOKEN_ADDRESS, amount, this));
weth.deposit.value(amount)();
} else {
require(reserve.withdraw(token, amount, this));
}
return true;
}
function transferToReserve(ERC20 token, uint amount) internal returns (bool success) {
if (token == weth) {
weth.withdraw(amount);
reserve.transfer(amount);
} else {
require(token.transfer(reserve, amount));
}
return true;
}
function approveToken(ERC20 token, address who, uint wad) public note auth {
require(token.approve(who, wad));
}
function take(ERC20 token, uint wad) public note auth {
require(token == weth || token == dai);
require(lpc.ref() == dai);
require(lpc.alt() == weth);
uint amountToWithdraw = (token == dai) ? wdiv(wad, lpc.tag()) : wmul(wad, lpc.tag());
require(withdrawFromReserve((token == dai) ? weth : dai, amountToWithdraw));
lpc.take(token, wad);
require(transferToReserve(token, wad));
}
function withdraw(ERC20 token, uint amount, address destination) public note auth {
if (token == ETH_TOKEN_ADDRESS) {
destination.transfer(amount);
} else {
require(token.transfer(destination, amount));
}
}
}