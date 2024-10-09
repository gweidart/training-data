pragma solidity ^0.4.24;
contract Coinevents {
event onNewName
(
uint256 indexed playerID,
address indexed playerAddress,
bytes32 indexed playerName,
bool isNewPlayer,
uint256 affiliateID,
address affiliateAddress,
bytes32 affiliateName,
uint256 amountPaid,
uint256 timeStamp
);
event onBuy (
address playerAddress,
uint256 begin,
uint256 end,
uint256 round,
bytes32 playerName
);
event onWithdraw
(
uint256 indexed playerID,
address playerAddress,
bytes32 playerName,
uint256 ethOut,
uint256 timeStamp
);
event onSettle(
uint256 rid,
uint256 ticketsout,
address winner,
uint256 luckynum,
uint256 jackpot
);
event onActivate(
uint256 rid
);
}
contract LuckyCoin is Coinevents{
using SafeMath for *;
using NameFilter for string;
function buyTicket( uint256 _pID, uint256 _affID, uint256 _tickets)
private
{
function updateTicketVault(uint256 _pID, uint256 _rIDlast) private{
uint256 _gen = (plyrRnds_[_pID][_rIDlast].luckytickets.mul(round_[_rIDlast].mask / _headtickets)).sub(plyrRnds_[_pID][_rIDlast].mask);
uint256 _jackpot = 0;
if (judgeWin(_rIDlast, _pID) && address(round_[_rIDlast].winner) == 0) {
_jackpot = round_[_rIDlast].jackpot;
round_[_rIDlast].winner = msg.sender;
}
plyr_[_pID].gen = _gen.add(plyr_[_pID].gen);
plyr_[_pID].win = _jackpot.add(plyr_[_pID].win);
plyrRnds_[_pID][_rIDlast].mask = plyrRnds_[_pID][_rIDlast].mask.add(_gen);
}
function managePlayer(uint256 _pID)
private
{
if (plyr_[_pID].lrnd != 0)
updateTicketVault(_pID, plyr_[_pID].lrnd);
plyr_[_pID].lrnd = rID_;
}
function calcTicketEarnings(uint256 _pID, uint256 _rIDlast)
private
view
returns(uint256)
{
return (plyrRnds_[_pID][_rIDlast].luckytickets.mul(round_[_rIDlast].mask / _headtickets)).sub(plyrRnds_[_pID][_rIDlast].mask);
}
function activate()
isHuman()
public
payable
{
require(msg.sender == activate_addr1 ||
msg.sender == activate_addr2);
require(activated_ == false, "LuckyCoin already activated");
require(msg.value == jackpot, "activate game need 10 ether");
if (rID_ != 0) {
require(round_[rID_].tickets >= round_[rID_].lucknum, "nobody win");
}
activated_ = true;
rID_ ++;
round_[rID_].start = now;
round_[rID_].end = now + rndGap_;
round_[rID_].jackpot = msg.value;
emit onActivate(rID_);
}
function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
external
{
require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
if (pIDxAddr_[_addr] != _pID)
pIDxAddr_[_addr] = _pID;
if (pIDxName_[_name] != _pID)
pIDxName_[_name] = _pID;
if (plyr_[_pID].addr != _addr)
plyr_[_pID].addr = _addr;
if (plyr_[_pID].name != _name)
plyr_[_pID].name = _name;
if (plyr_[_pID].laff != _laff)
plyr_[_pID].laff = _laff;
if (plyrNames_[_pID][_name] == false)
plyrNames_[_pID][_name] = true;
}
function receivePlayerNameList(uint256 _pID, bytes32 _name)
external
{
require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
if(plyrNames_[_pID][_name] == false)
plyrNames_[_pID][_name] = true;
}
function determinePID()
private
{
uint256 _pID = pIDxAddr_[msg.sender];
if (_pID == 0)
{
_pID = PlayerBook.getPlayerID(msg.sender);
bytes32 _name = PlayerBook.getPlayerName(_pID);
uint256 _laff = PlayerBook.getPlayerLAff(_pID);
pIDxAddr_[msg.sender] = _pID;
plyr_[_pID].addr = msg.sender;
if (_name != "")
{
pIDxName_[_name] = _pID;
plyr_[_pID].name = _name;
plyrNames_[_pID][_name] = true;
}
if (_laff != 0 && _laff != _pID)
plyr_[_pID].laff = _laff;
}
}
function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
isHuman()
public
payable
{
bytes32 _name = _nameString.nameFilter();
address _addr = msg.sender;
uint256 _paid = msg.value;
(bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
uint256 _pID = pIDxAddr_[_addr];
emit Coinevents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
}
function registerNameXaddr(string _nameString, address _affCode, bool _all)
isHuman()
public
payable
{
bytes32 _name = _nameString.nameFilter();
address _addr = msg.sender;
uint256 _paid = msg.value;
(bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
uint256 _pID = pIDxAddr_[_addr];
emit Coinevents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
}
function getTimeLeft()
public
view
returns(uint256)
{
uint256 _rID = rID_;
uint256 _now = now;
if (_now < round_[_rID].end){
return( (round_[_rID].end).sub(_now) );
}
else
return(0);
}
function getCurrentRoundInfo()
public
view
returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bool)
{
uint256 _rID = rID_;
return
(
rID_,
round_[_rID].tickets,
round_[_rID].start,
round_[_rID].end,
round_[_rID].jackpot,
round_[_rID].nextpot,
round_[_rID].lucknum,
round_[_rID].mask,
round_[_rID].playernums,
round_[_rID].winner,
round_[_rID].ended
);
}
function getPlayerInfoByAddress(address _addr)
public
view
returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, uint256)
{
uint256 _rID = rID_;
if (_addr == address(0))
{
_addr == msg.sender;
}
uint256 _pID = pIDxAddr_[_addr];
uint256 _lrnd =  plyr_[_pID].lrnd;
uint256 _jackpot = 0;
if (judgeWin(_lrnd, _pID) && address(round_[_lrnd].winner) == 0){
_jackpot = round_[_lrnd].jackpot;
}
return
(
_pID,
plyr_[_pID].name,
plyrRnds_[_pID][_rID].tickets,
plyr_[_pID].win.add(_jackpot),
plyr_[_pID].gen.add(calcTicketEarnings(_pID, _lrnd)),
plyr_[_pID].aff,
plyrRnds_[_pID][_rID].eth,
plyrRnds_[_pID][_rID].affnums
);
}
function randNums() public view returns(uint256) {
return uint256(keccak256(block.difficulty, now, block.coinbase)) % ticketstotal_ + 1;
}
function judgeWin(uint256 _rid, uint256 _pID)private view returns(bool){
uint256 _group = (round_[_rid].lucknum -1) / grouptotal_;
uint256 _temp = round_[_rid].lucknum % grouptotal_;
if (_temp == 0){
_temp = grouptotal_;
}
if (orders[_rid][_pID][_group] & (2 **(_temp-1)) == 2 **(_temp-1)){
return true;
}else{
return false;
}
}
function searchtickets()public view returns(uint256, uint256, uint256, uint256,uint256, uint256){
uint256 _pID = pIDxAddr_[msg.sender];
return (
orders[rID_][_pID][0],
orders[rID_][_pID][1],
orders[rID_][_pID][2],
orders[rID_][_pID][3],
orders[rID_][_pID][4],
orders[rID_][_pID][5]
);
}
function searchTicketsXaddr(address addr) public view returns(uint256, uint256, uint256, uint256,uint256, uint256){
uint256 _pID = pIDxAddr_[addr];
return (
orders[rID_][_pID][0],
orders[rID_][_pID][1],
orders[rID_][_pID][2],
orders[rID_][_pID][3],
orders[rID_][_pID][4],
orders[rID_][_pID][5]
);
}
}
library Coindatasets {
struct EventReturns {
uint256 compressedData;
uint256 compressedIDs;
address winnerAddr;
bytes32 winnerName;
uint256 amountWon;
uint256 newPot;
uint256 genAmount;
uint256 potAmount;
}
struct Round {
uint256 tickets;
bool ended;
uint256 jackpot;
uint256 start;
uint256 end;
address winner;
uint256 mask;
uint256 found;
uint256 lucknum;
uint256 nextpot;
uint256 blocknum;
uint256 playernums;
}
struct Player {
address addr;
bytes32 name;
uint256 win;
uint256 gen;
uint256 aff;
uint256 lrnd;
uint256 laff;
uint256 luckytickets;
}
struct PotSplit {
uint256 community;
uint256 gen;
uint256 laff;
}
struct PlayerRounds {
uint256 eth;
uint256 tickets;
uint256 mask;
uint256 affnums;
uint256 luckytickets;
}
}
interface PlayerBookInterface {
function getPlayerID(address _addr) external returns (uint256);
function getPlayerName(uint256 _pID) external view returns (bytes32);
function getPlayerLAff(uint256 _pID) external view returns (uint256);
function getPlayerAddr(uint256 _pID) external view returns (address);
function getNameFee() external view returns (uint256);
function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}
library NameFilter {
function nameFilter(string _input)
internal
pure
returns(bytes32)
{
bytes memory _temp = bytes(_input);
uint256 _length = _temp.length;
require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
if (_temp[0] == 0x30)
{
require(_temp[1] != 0x78, "string cannot start with 0x");
require(_temp[1] != 0x58, "string cannot start with 0X");
}
bool _hasNonNumber;
for (uint256 i = 0; i < _length; i++)
{
if (_temp[i] > 0x40 && _temp[i] < 0x5b)
{
_temp[i] = byte(uint(_temp[i]) + 32);
if (_hasNonNumber == false)
_hasNonNumber = true;
} else {
require
(
_temp[i] == 0x20 ||
(_temp[i] > 0x60 && _temp[i] < 0x7b) ||
(_temp[i] > 0x2f && _temp[i] < 0x3a),
"string contains invalid characters"
);
if (_temp[i] == 0x20)
require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
_hasNonNumber = true;
}
}
require(_hasNonNumber == true, "string cannot be only numbers");
bytes32 _ret;
assembly {
_ret := mload(add(_temp, 32))
}
return (_ret);
}
}
library SafeMath {
function mul(uint256 a, uint256 b)
internal
pure
returns (uint256 c)
{
if (a == 0) {
return 0;
}
c = a * b;
require(c / a == b);
return c;
}
function sub(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
require(b <= a);
return a - b;
}
function add(uint256 a, uint256 b)
internal
pure
returns (uint256 c)
{
c = a + b;
require(c >= a);
return c;
}
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
function sq(uint256 x)
internal
pure
returns (uint256)
{
return (mul(x,x));
}
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