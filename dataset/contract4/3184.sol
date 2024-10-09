pragma solidity ^0.4.24;
interface HourglassInterface {
function() payable external;
function buy(address _playerAddress) payable external returns(uint256);
function sell(uint256 _amountOfTokens) external;
function reinvest() external;
function withdraw() external;
function exit() external;
function dividendsOf(address _playerAddress) external view returns(uint256);
function balanceOf(address _playerAddress) external view returns(uint256);
function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
function stakingRequirement() external view returns(uint256);
}
contract Divies {
using SafeMath for uint256;
using UintCompressor for uint256;
HourglassInterface constant P3Dcontract_ = HourglassInterface(0x02BcdFc1654eC070BA7DEe9aA496151fa93e0fA3);
uint256 public pusherTracker_ = 100;
mapping (address => Pusher) public pushers_;
struct Pusher
{
uint256 tracker;
uint256 time;
}
uint256 public rateLimiter_;
modifier isHuman() {
address _addr = msg.sender;
uint256 _codeLength;
assembly {_codeLength := extcodesize(_addr)}
require(_codeLength == 0, "sorry humans only");
_;
}
function balances()
public
view
returns(uint256)
{
return (address(this).balance);
}
function deposit()
external
payable
{
}
function() external payable {}
event onDistribute(
address pusher,
uint256 startingBalance,
uint256 masternodePayout,
uint256 finalBalance,
uint256 compressedData
);
[0-14] - timestamp
[15-29] - caller pusher tracker
[30-44] - global pusher tracker
[45-46] - percent
[47] - greedy
function distribute(uint256 _percent)
public
isHuman()
{
require(_percent > 0 && _percent < 100, "please pick a percent between 1 and 99");
address _pusher = msg.sender;
uint256 _bal = address(this).balance;
uint256 _mnPayout;
uint256 _compressedData;
if (
pushers_[_pusher].tracker <= pusherTracker_.sub(100) &&
pushers_[_pusher].time.add(1 hours) < now
)
{
pushers_[_pusher].tracker = pusherTracker_;
pusherTracker_++;
if (P3Dcontract_.balanceOf(_pusher) >= P3Dcontract_.stakingRequirement())
_mnPayout = (_bal / 10) / 3;
uint256 _stop = (_bal.mul(100 - _percent)) / 100;
P3Dcontract_.buy.value(_bal)(_pusher);
P3Dcontract_.sell(P3Dcontract_.balanceOf(address(this)));
uint256 _tracker = P3Dcontract_.dividendsOf(address(this));
while (_tracker >= _stop)
{
P3Dcontract_.reinvest();
P3Dcontract_.sell(P3Dcontract_.balanceOf(address(this)));
_tracker = (_tracker.mul(81)) / 100;
}
P3Dcontract_.withdraw();
} else {
_compressedData = _compressedData.insert(1, 47, 47);
}
pushers_[_pusher].time = now;
_compressedData = _compressedData.insert(now, 0, 14);
_compressedData = _compressedData.insert(pushers_[_pusher].tracker, 15, 29);
_compressedData = _compressedData.insert(pusherTracker_, 30, 44);
_compressedData = _compressedData.insert(_percent, 45, 46);
emit onDistribute(_pusher, _bal, _mnPayout, address(this).balance, _compressedData);
}
}
* @title -UintCompressor- v0.1.9
library UintCompressor {
using SafeMath for *;
function insert(uint256 _var, uint256 _include, uint256 _start, uint256 _end)
internal
pure
returns(uint256)
{
require(_end < 77 && _start < 77, "start/end must be less than 77");
require(_end >= _start, "end must be >= start");
_end = exponent(_end).mul(10);
_start = exponent(_start);
require(_include < (_end / _start));
if (_include > 0)
_include = _include.mul(_start);
return((_var.sub((_var / _start).mul(_start))).add(_include).add((_var / _end).mul(_end)));
}
function extract(uint256 _input, uint256 _start, uint256 _end)
internal
pure
returns(uint256)
{
require(_end < 77 && _start < 77, "start/end must be less than 77");
require(_end >= _start, "end must be >= start");
_end = exponent(_end).mul(10);
_start = exponent(_start);
return((((_input / _start).mul(_start)).sub((_input / _end).mul(_end))) / _start);
}
function exponent(uint256 _position)
private
pure
returns(uint256)
{
return((10).pwr(_position));
}
}
* @title SafeMath v0.1.9
* @dev Math operations with safety checks that throw on error
* change notes:  original SafeMath library from OpenZeppelin modified by Inventor
* - added sqrt
* - added sq
* - added pwr
* - changed asserts to requires with error log outputs
* - removed div, its useless
library SafeMath {
* @dev Multiplies two numbers, throws on overflow.
function mul(uint256 a, uint256 b)
internal
pure
returns (uint256 c)
{
if (a == 0) {
return 0;
}
c = a * b;
require(c / a == b, "SafeMath mul failed");
return c;
}
* @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
function sub(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
require(b <= a, "SafeMath sub failed");
return a - b;
}
* @dev Adds two numbers, throws on overflow.
function add(uint256 a, uint256 b)
internal
pure
returns (uint256 c)
{
c = a + b;
require(c >= a, "SafeMath add failed");
return c;
}
* @dev gives square root of given x.
function sqrt(uint256 x)
internal
pure
returns (uint256 y)
{
uint256 z = ((add(x,1)) / 2);
y = x;
while (z < y)
{
y = z;
z = ((add((x / z),z)) / 2);
}
}
* @dev gives square. multiplies x by x
function sq(uint256 x)
internal
pure
returns (uint256)
{
return (mul(x,x));
}
* @dev x to the power of y
function pwr(uint256 x, uint256 y)
internal
pure
returns (uint256)
{
if (x==0)
return (0);
else if (y==0)
return (1);
else
{
uint256 z = x;
for (uint256 i=1; i < y; i++)
z = mul(z,x);
return (z);
}
}
}