pragma solidity ^0.4.24;
contract F3Devents {
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
event onEndTx
(
uint256 compressedData,
uint256 compressedIDs,
bytes32 playerName,
address playerAddress,
uint256 ethIn,
uint256 keysBought,
address winnerAddr,
bytes32 winnerName,
uint256 amountWon,
uint256 newPot,
uint256 P3DAmount,
uint256 genAmount,
uint256 potAmount,
uint256 airDropPot
);
event onWithdraw
(
uint256 indexed playerID,
address playerAddress,
bytes32 playerName,
uint256 ethOut,
uint256 timeStamp
);
event onWithdrawAndDistribute
(
address playerAddress,
bytes32 playerName,
uint256 ethOut,
uint256 compressedData,
uint256 compressedIDs,
address winnerAddr,
bytes32 winnerName,
uint256 amountWon,
uint256 newPot,
uint256 P3DAmount,
uint256 genAmount
);
event onBuyAndDistribute
(
address playerAddress,
bytes32 playerName,
uint256 ethIn,
uint256 compressedData,
uint256 compressedIDs,
address winnerAddr,
bytes32 winnerName,
uint256 amountWon,
uint256 newPot,
uint256 P3DAmount,
uint256 genAmount
);
event onReLoadAndDistribute
(
address playerAddress,
bytes32 playerName,
uint256 compressedData,
uint256 compressedIDs,
address winnerAddr,
bytes32 winnerName,
uint256 amountWon,
uint256 newPot,
uint256 P3DAmount,
uint256 genAmount
);
event onAffiliatePayout
(
uint256 indexed affiliateID,
address affiliateAddress,
bytes32 affiliateName,
uint256 indexed roundID,
uint256 indexed buyerID,
uint256 amount,
uint256 timeStamp
);
event onPotSwapDeposit
(
uint256 roundID,
uint256 amountAddedToPot
);
}
contract modularShort is F3Devents {}
contract FoMo3Dshort is modularShort {
using SafeMath for *;
using NameFilter for string;
using F3DKeysCalcShort for uint256;
PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xee83e20C6AEab2284685Efe0B5ffb250bE5480bf);
address private admin = msg.sender;
string constant public name = "FOMO Short";
string constant public symbol = "SHORT";
uint256 private rndExtra_ = 1 seconds;
uint256 private rndGap_ = 1 seconds;
uint256 constant private rndInit_ = 5 minutes;
uint256 constant private rndInc_ = 10 seconds;
uint256 constant private rndMax_ = 5 minutes;
uint256 public airDropPot_;
uint256 public airDropTracker_ = 0;
uint256 public rID_;
mapping (address => uint256) public pIDxAddr_;
mapping (bytes32 => uint256) public pIDxName_;
mapping (uint256 => F3Ddatasets.Player) public plyr_;
mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;
mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;
mapping (uint256 => F3Ddatasets.Round) public round_;
mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;
mapping (uint256 => F3Ddatasets.TeamFee) public fees_;
mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;
constructor()
public
{
fees_[0] = F3Ddatasets.TeamFee(30,6);
fees_[1] = F3Ddatasets.TeamFee(43,0);
fees_[2] = F3Ddatasets.TeamFee(56,10);
fees_[3] = F3Ddatasets.TeamFee(43,8);
potSplit_[0] = F3Ddatasets.PotSplit(15,10);
potSplit_[1] = F3Ddatasets.PotSplit(25,0);
potSplit_[2] = F3Ddatasets.PotSplit(20,20);
potSplit_[3] = F3Ddatasets.PotSplit(30,10);
}
* @dev used to make sure no one can interact with contract until it has
* been activated.
modifier isActivated() {
require(activated_ == true, "its not ready yet.  check ?eta in discord");
_;
}
* @dev prevents contracts from interacting with fomo3d
modifier isHuman() {
address _addr = msg.sender;
uint256 _codeLength;
assembly {_codeLength := extcodesize(_addr)}
require(_codeLength == 0, "sorry humans only");
_;
}
* @dev sets boundaries for incoming tx
modifier isWithinLimits(uint256 _eth) {
require(_eth >= 1000000000, "pocket lint: not a valid currency");
require(_eth <= 100000000000000000000000, "no vitalik, no");
_;
}
* @dev emergency buy uses last stored affiliate ID and team snek
function()
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{
F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
uint256 _pID = pIDxAddr_[msg.sender];
buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
}
* @dev converts all incoming ethereum to keys.
* -functionhash- 0x8f38f309 (using ID for affiliate)
* -functionhash- 0x98a0871d (using address for affiliate)
* -functionhash- 0xa65b37a1 (using name for affiliate)
* @param _affCode the ID/address/name of the player who gets the affiliate fee
* @param _team what team is the player playing for?
function buyXid(uint256 _affCode, uint256 _team)
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{
F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
uint256 _pID = pIDxAddr_[msg.sender];
if (_affCode == 0 || _affCode == _pID)
{
_affCode = plyr_[_pID].laff;
} else if (_affCode != plyr_[_pID].laff) {
plyr_[_pID].laff = _affCode;
}
_team = verifyTeam(_team);
buyCore(_pID, _affCode, _team, _eventData_);
}
function buyXaddr(address _affCode, uint256 _team)
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{
F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
uint256 _pID = pIDxAddr_[msg.sender];
uint256 _affID;
if (_affCode == address(0) || _affCode == msg.sender)
{
_affID = plyr_[_pID].laff;
} else {
_affID = pIDxAddr_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
_team = verifyTeam(_team);
buyCore(_pID, _affID, _team, _eventData_);
}
function buyXname(bytes32 _affCode, uint256 _team)
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{
F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
uint256 _pID = pIDxAddr_[msg.sender];
uint256 _affID;
if (_affCode == '' || _affCode == plyr_[_pID].name)
{
_affID = plyr_[_pID].laff;
} else {
_affID = pIDxName_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
_team = verifyTeam(_team);
buyCore(_pID, _affID, _team, _eventData_);
}
* @dev essentially the same as buy, but instead of you sending ether
* from your wallet, it uses your unwithdrawn earnings.
* -functionhash- 0x349cdcac (using ID for affiliate)
* -functionhash- 0x82bfc739 (using address for affiliate)
* -functionhash- 0x079ce327 (using name for affiliate)
* @param _affCode the ID/address/name of the player who gets the affiliate fee
* @param _team what team is the player playing for?
* @param _eth amount of earnings to use (remainder returned to gen vault)
function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{
F3Ddatasets.EventReturns memory _eventData_;
uint256 _pID = pIDxAddr_[msg.sender];
if (_affCode == 0 || _affCode == _pID)
{
_affCode = plyr_[_pID].laff;
} else if (_affCode != plyr_[_pID].laff) {
plyr_[_pID].laff = _affCode;
}
_team = verifyTeam(_team);
reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
}
function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{
F3Ddatasets.EventReturns memory _eventData_;
uint256 _pID = pIDxAddr_[msg.sender];
uint256 _affID;
if (_affCode == address(0) || _affCode == msg.sender)
{
_affID = plyr_[_pID].laff;
} else {
_affID = pIDxAddr_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
_team = verifyTeam(_team);
reLoadCore(_pID, _affID, _team, _eth, _eventData_);
}
function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{
F3Ddatasets.EventReturns memory _eventData_;
uint256 _pID = pIDxAddr_[msg.sender];
uint256 _affID;
if (_affCode == '' || _affCode == plyr_[_pID].name)
{
_affID = plyr_[_pID].laff;
} else {
_affID = pIDxName_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
_team = verifyTeam(_team);
reLoadCore(_pID, _affID, _team, _eth, _eventData_);
}
* @dev withdraws all of your earnings.
* -functionhash- 0x3ccfd60b
function withdraw()
isActivated()
isHuman()
public
{
uint256 _rID = rID_;
uint256 _now = now;
uint256 _pID = pIDxAddr_[msg.sender];
uint256 _eth;
if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
{
F3Ddatasets.EventReturns memory _eventData_;
round_[_rID].ended = true;
_eventData_ = endRound(_eventData_);
_eth = withdrawEarnings(_pID);
if (_eth > 0)
plyr_[_pID].addr.transfer(_eth);
_eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
emit F3Devents.onWithdrawAndDistribute
(
msg.sender,
plyr_[_pID].name,
_eth,
_eventData_.compressedData,
_eventData_.compressedIDs,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.P3DAmount,
_eventData_.genAmount
);
} else {
_eth = withdrawEarnings(_pID);
if (_eth > 0)
plyr_[_pID].addr.transfer(_eth);
emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
}
}
* @dev use these to register names.  they are just wrappers that will send the
* registration requests to the PlayerBook contract.  So registering here is the
* same as registering there.  UI will always display the last name you registered.
* but you will still own all previously registered names to use as affiliate
* links.
* - must pay a registration fee.
* - name must be unique
* - names will be converted to lowercase
* - name cannot start or end with a space
* - cannot have more than 1 space in a row
* - cannot be only numbers
* - cannot start with 0x
* - name must be at least 1 char
* - max length of 32 characters long
* - allowed characters: a-z, 0-9, and space
* -functionhash- 0x921dec21 (using ID for affiliate)
* -functionhash- 0x3ddd4698 (using address for affiliate)
* -functionhash- 0x685ffd83 (using name for affiliate)
* @param _nameString players desired name
* @param _affCode affiliate ID, address, or name of who referred you
* @param _all set to true if you want this to push your info to all games
* (this might cost a lot of gas)
function registerNameXID(string _nameString, uint256 _affCode, bool _all)
isHuman()
public
payable
{
bytes32 _name = _nameString.nameFilter();
address _addr = msg.sender;
uint256 _paid = msg.value;
(bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
uint256 _pID = pIDxAddr_[_addr];
emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
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
emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
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
emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
}
* @dev return the price buyer will pay for next 1 individual key.
* -functionhash- 0x018a25e8
* @return price for next key bought (in wei format)
function getBuyPrice()
public
view
returns(uint256)
{
uint256 _rID = rID_;
uint256 _now = now;
if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
else
return ( 75000000000000 );
}
* @dev returns time left.  dont spam this, you'll ddos yourself from your node
* provider
* -functionhash- 0xc7e284b8
* @return time left in seconds
function getTimeLeft()
public
view
returns(uint256)
{
uint256 _rID = rID_;
uint256 _now = now;
if (_now < round_[_rID].end)
if (_now > round_[_rID].strt + rndGap_)
return( (round_[_rID].end).sub(_now) );
else
return( (round_[_rID].strt + rndGap_).sub(_now) );
else
return(0);
}
* @dev returns player earnings per vaults
* -functionhash- 0x63066434
* @return winnings vault
* @return general vault
* @return affiliate vault
function getPlayerVaults(uint256 _pID)
public
view
returns(uint256 ,uint256, uint256)
{
uint256 _rID = rID_;
if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
{
if (round_[_rID].plyr == _pID)
{
return
(
(plyr_[_pID].win).add( ((round_[_rID].pot).mul(48)) / 100 ),
(plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
plyr_[_pID].aff
);
} else {
return
(
plyr_[_pID].win,
(plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
plyr_[_pID].aff
);
}
} else {
return
(
plyr_[_pID].win,
(plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
plyr_[_pID].aff
);
}
}
* solidity hates stack limits.  this lets us avoid that hate
function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
private
view
returns(uint256)
{
return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
}
* @dev returns all current round info needed for front end
* -functionhash- 0x747dff42
* @return eth invested during ICO phase
* @return round id
* @return total keys for round
* @return time round ends
* @return time round started
* @return current pot
* @return current team ID & player ID in lead
* @return current player in leads address
* @return current player in leads name
* @return whales eth in for round
* @return bears eth in for round
* @return sneks eth in for round
* @return bulls eth in for round
* @return airdrop tracker # & airdrop pot
function getCurrentRoundInfo()
public
view
returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
{
uint256 _rID = rID_;
return
(
round_[_rID].ico,
_rID,
round_[_rID].keys,
round_[_rID].end,
round_[_rID].strt,
round_[_rID].pot,
(round_[_rID].team + (round_[_rID].plyr * 10)),
plyr_[round_[_rID].plyr].addr,
plyr_[round_[_rID].plyr].name,
rndTmEth_[_rID][0],
rndTmEth_[_rID][1],
rndTmEth_[_rID][2],
rndTmEth_[_rID][3],
airDropTracker_ + (airDropPot_ * 1000)
);
}
* @dev returns player info based on address.  if no address is given, it will
* use msg.sender
* -functionhash- 0xee0b5d8b
* @param _addr address of the player you want to lookup
* @return player ID
* @return player name
* @return keys owned (current round)
* @return winnings vault
* @return general vault
* @return affiliate vault
* @return player round eth
function getPlayerInfoByAddress(address _addr)
public
view
returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
{
uint256 _rID = rID_;
if (_addr == address(0))
{
_addr == msg.sender;
}
uint256 _pID = pIDxAddr_[_addr];
return
(
_pID,
plyr_[_pID].name,
plyrRnds_[_pID][_rID].keys,
plyr_[_pID].win,
(plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
plyr_[_pID].aff,
plyrRnds_[_pID][_rID].eth
);
}
* @dev logic runs whenever a buy order is executed.  determines how to handle
* incoming eth depending on if we are in an active round or not
function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
{
uint256 _rID = rID_;
uint256 _now = now;
if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
{
core(_rID, _pID, msg.value, _affID, _team, _eventData_);
} else {
if (_now > round_[_rID].end && round_[_rID].ended == false)
{
round_[_rID].ended = true;
_eventData_ = endRound(_eventData_);
_eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
emit F3Devents.onBuyAndDistribute
(
msg.sender,
plyr_[_pID].name,
msg.value,
_eventData_.compressedData,
_eventData_.compressedIDs,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.P3DAmount,
_eventData_.genAmount
);
}
plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
}
}
* @dev logic runs whenever a reload order is executed.  determines how to handle
* incoming eth depending on if we are in an active round or not
function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
private
{
uint256 _rID = rID_;
uint256 _now = now;
if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
{
plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
core(_rID, _pID, _eth, _affID, _team, _eventData_);
} else if (_now > round_[_rID].end && round_[_rID].ended == false) {
round_[_rID].ended = true;
_eventData_ = endRound(_eventData_);
_eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
emit F3Devents.onReLoadAndDistribute
(
msg.sender,
plyr_[_pID].name,
_eventData_.compressedData,
_eventData_.compressedIDs,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.P3DAmount,
_eventData_.genAmount
);
}
}
* @dev this is the core logic for any buy/reload that happens while a round
* is live.
function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
{
if (plyrRnds_[_pID][_rID].keys == 0)
_eventData_ = managePlayer(_pID, _eventData_);
if (_eth > 1000000000)
{
uint256 _keys = (round_[_rID].eth).keysRec(_eth);
if (_keys >= 1000000000000000000)
{
updateTimer(_keys, _rID);
if (round_[_rID].plyr != _pID)
round_[_rID].plyr = _pID;
if (round_[_rID].team != _team)
round_[_rID].team = _team;
_eventData_.compressedData = _eventData_.compressedData + 100;
}
if (_eth >= 100000000000000000)
{
airDropTracker_++;
if (airdrop() == true)
{
uint256 _prize;
if (_eth >= 10000000000000000000)
{
_prize = ((airDropPot_).mul(75)) / 100;
plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
airDropPot_ = (airDropPot_).sub(_prize);
_eventData_.compressedData += 300000000000000000000000000000000;
} else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
_prize = ((airDropPot_).mul(50)) / 100;
plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
airDropPot_ = (airDropPot_).sub(_prize);
_eventData_.compressedData += 200000000000000000000000000000000;
} else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
_prize = ((airDropPot_).mul(25)) / 100;
plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
airDropPot_ = (airDropPot_).sub(_prize);
_eventData_.compressedData += 300000000000000000000000000000000;
}
_eventData_.compressedData += 10000000000000000000000000000000;
_eventData_.compressedData += _prize * 1000000000000000000000000000000000;
airDropTracker_ = 0;
}
}
_eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
round_[_rID].keys = _keys.add(round_[_rID].keys);
round_[_rID].eth = _eth.add(round_[_rID].eth);
rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);
_eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
_eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);
endTx(_pID, _team, _eth, _keys, _eventData_);
}
}
* @dev calculates unmasked earnings (just calculates, does not update mask)
* @return earnings in wei format
function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
private
view
returns(uint256)
{
return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
}
* @dev returns the amount of keys you would get given an amount of eth.
* -functionhash- 0xce89c80c
* @param _rID round ID you want price for
* @param _eth amount of eth sent in
* @return keys received
function calcKeysReceived(uint256 _rID, uint256 _eth)
public
view
returns(uint256)
{
uint256 _now = now;
if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
return ( (round_[_rID].eth).keysRec(_eth) );
else
return ( (_eth).keys() );
}
* @dev returns current eth price for X keys.
* -functionhash- 0xcf808000
* @param _keys number of keys desired (in 18 decimal format)
* @return amount of eth needed to send
function iWantXKeys(uint256 _keys)
public
view
returns(uint256)
{
uint256 _rID = rID_;
uint256 _now = now;
if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
else
return ( (_keys).eth() );
}
* @dev receives name/player info from names contract
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
* @dev receives entire player name list
function receivePlayerNameList(uint256 _pID, bytes32 _name)
external
{
require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
if(plyrNames_[_pID][_name] == false)
plyrNames_[_pID][_name] = true;
}
* @dev gets existing or registers new pID.  use this when a player may be new
* @return pID
function determinePID(F3Ddatasets.EventReturns memory _eventData_)
private
returns (F3Ddatasets.EventReturns)
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
_eventData_.compressedData = _eventData_.compressedData + 1;
}
return (_eventData_);
}
* @dev checks to make sure user picked a valid team.  if not sets team
* to default (sneks)
function verifyTeam(uint256 _team)
private
pure
returns (uint256)
{
if (_team < 0 || _team > 3)
return(2);
else
return(_team);
}
* @dev decides if round end needs to be run & new round started.  and if
* player unmasked earnings from previously played rounds need to be moved.
function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
private
returns (F3Ddatasets.EventReturns)
{
if (plyr_[_pID].lrnd != 0)
updateGenVault(_pID, plyr_[_pID].lrnd);
plyr_[_pID].lrnd = rID_;
_eventData_.compressedData = _eventData_.compressedData + 10;
return(_eventData_);
}
* @dev ends the round. manages paying out winner/splitting up pot
function endRound(F3Ddatasets.EventReturns memory _eventData_)
private
returns (F3Ddatasets.EventReturns)
{
uint256 _rID = rID_;
uint256 _winPID = round_[_rID].plyr;
uint256 _winTID = round_[_rID].team;
uint256 _pot = round_[_rID].pot;
uint256 _win = (_pot.mul(48)) / 100;
uint256 _com = (_pot / 50);
uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);
uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
if (_dust > 0)
{
_gen = _gen.sub(_dust);
_res = _res.add(_dust);
}
plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
round_[_rID].pot = _pot.add(_com);
round_[_rID].pot = _pot.add(_p3d);
round_[_rID].mask = _ppt.add(round_[_rID].mask);
_eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
_eventData_.winnerAddr = plyr_[_winPID].addr;
_eventData_.winnerName = plyr_[_winPID].name;
_eventData_.amountWon = _win;
_eventData_.genAmount = _gen;
_eventData_.P3DAmount = _p3d;
_eventData_.newPot = _res;
rID_++;
_rID++;
round_[_rID].strt = now;
round_[_rID].end = now.add(rndInit_).add(rndGap_);
round_[_rID].pot = _res;
return(_eventData_);
}
* @dev moves any unmasked earnings to gen vault.  updates earnings mask
function updateGenVault(uint256 _pID, uint256 _rIDlast)
private
{
uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
if (_earnings > 0)
{
plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
}
}
* @dev updates round timer based on number of whole keys bought.
function updateTimer(uint256 _keys, uint256 _rID)
private
{
uint256 _now = now;
uint256 _newTime;
if (_now > round_[_rID].end && round_[_rID].plyr == 0)
_newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
else
_newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
if (_newTime < (rndMax_).add(_now))
round_[_rID].end = _newTime;
else
round_[_rID].end = rndMax_.add(_now);
}
* @dev generates a random number between 0-99 and checks to see if thats
* resulted in an airdrop win
* @return do we have a winner?
function airdrop()
private
view
returns(bool)
{
uint256 seed = uint256(keccak256(abi.encodePacked(
(block.timestamp).add
(block.difficulty).add
((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
(block.gaslimit).add
((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
(block.number)
)));
if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
return(true);
else
return(false);
}
* @dev distributes eth based on fees to com, aff, and p3d
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
returns(F3Ddatasets.EventReturns)
{
uint256 _p1 = _eth / 100;
uint256 _com = _eth / 50;
_com = _com.add(_p1);
uint256 _p3d;
if (!address(admin).call.value(_com)())
{
_p3d = _com;
_com = 0;
}
uint256 _aff = _eth / 10;
if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_p3d = _aff;
}
_p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
if (_p3d > 0)
{
uint256 _potAmount = _p3d;
round_[_rID].pot = round_[_rID].pot.add(_potAmount);
_eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
}
return(_eventData_);
}
function potSwap()
external
payable
{
uint256 _rID = rID_ + 1;
round_[_rID].pot = round_[_rID].pot.add(msg.value);
emit F3Devents.onPotSwapDeposit(_rID, msg.value);
}
* @dev distributes eth based on fees to gen and pot
function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
private
returns(F3Ddatasets.EventReturns)
{
uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;
uint256 _air = (_eth / 100);
airDropPot_ = airDropPot_.add(_air);
_eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));
uint256 _pot = _eth.sub(_gen);
uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
if (_dust > 0)
_gen = _gen.sub(_dust);
round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
_eventData_.genAmount = _gen.add(_eventData_.genAmount);
_eventData_.potAmount = _pot;
return(_eventData_);
}
* @dev updates masks for round and player when keys are bought
* @return dust left over
function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
private
returns(uint256)
{
earnings masks are a tricky thing for people to wrap their minds around.
the basic thing to understand here.  is were going to have a global
tracker based on profit per share for each round, that increases in
relevant proportion to the increase in share supply.
the player will have an additional mask that basically says "based
on the rounds mask, my shares, and how much i've already withdrawn,
how much is still owed to me?"
uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
round_[_rID].mask = _ppt.add(round_[_rID].mask);
uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
}
* @dev adds up unmasked earnings, & vault earnings, sets them all to 0
* @return earnings in wei format
function withdrawEarnings(uint256 _pID)
private
returns(uint256)
{
updateGenVault(_pID, plyr_[_pID].lrnd);
uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
if (_earnings > 0)
{
plyr_[_pID].win = 0;
plyr_[_pID].gen = 0;
plyr_[_pID].aff = 0;
}
return(_earnings);
}
* @dev prepares compression data and fires event for buy or reload tx's
function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
private
{
_eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
emit F3Devents.onEndTx
(
_eventData_.compressedData,
_eventData_.compressedIDs,
plyr_[_pID].name,
msg.sender,
_eth,
_keys,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.P3DAmount,
_eventData_.genAmount,
_eventData_.potAmount,
airDropPot_
);
}
* use function that will activate the contract.  we do this so devs
bool public activated_ = false;
function activate()
public
{
require(msg.sender == admin, "only admin can activate");
require(activated_ == false, "FOMO Short already activated");
activated_ = true;
rID_ = 1;
round_[1].strt = now + rndExtra_ - rndGap_;
round_[1].end = now + rndInit_ + rndExtra_;
}
}
library F3Ddatasets {
struct EventReturns {
uint256 compressedData;
uint256 compressedIDs;
address winnerAddr;
bytes32 winnerName;
uint256 amountWon;
uint256 newPot;
uint256 P3DAmount;
uint256 genAmount;
uint256 potAmount;
}
struct Player {
address addr;
bytes32 name;
uint256 win;
uint256 gen;
uint256 aff;
uint256 lrnd;
uint256 laff;
}
struct PlayerRounds {
uint256 eth;
uint256 keys;
uint256 mask;
uint256 ico;
}
struct Round {
uint256 plyr;
uint256 team;
uint256 end;
bool ended;
uint256 strt;
uint256 keys;
uint256 eth;
uint256 pot;
uint256 mask;
uint256 ico;
uint256 icoGen;
uint256 icoAvg;
}
struct TeamFee {
uint256 gen;
uint256 p3d;
}
struct PotSplit {
uint256 gen;
uint256 p3d;
}
}
library F3DKeysCalcShort {
using SafeMath for *;
* @dev calculates number of keys received given X eth
* @param _curEth current amount of eth in contract
* @param _newEth eth being spent
* @return amount of ticket purchased
function keysRec(uint256 _curEth, uint256 _newEth)
internal
pure
returns (uint256)
{
return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
}
* @dev calculates amount of eth received if you sold X keys
* @param _curKeys current amount of keys that exist
* @param _sellKeys amount of keys you wish to sell
* @return amount of eth received
function ethRec(uint256 _curKeys, uint256 _sellKeys)
internal
pure
returns (uint256)
{
return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
}
* @dev calculates how many keys would exist with given an amount of eth
* @param _eth eth "in contract"
* @return number of keys that would exist
function keys(uint256 _eth)
internal
pure
returns(uint256)
{
return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
}
* @dev calculates how much eth would be in contract given a number of keys
* @param _keys number of keys "in contract"
* @return eth that would exists
function eth(uint256 _keys)
internal
pure
returns(uint256)
{
return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
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
* @title -Name Filter- v0.1.9
* ┌┬┐┌─┐┌─┐┌┬┐   ╦╦ ╦╔═╗╔╦╗  ┌─┐┬─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐
*  │ ├┤ ├─┤│││   ║║ ║╚═╗ ║   ├─┘├┬┘├┤ └─┐├┤ │││ │ └─┐
*  ┴ └─┘┴ ┴┴ ┴  ╚╝╚═╝╚═╝ ╩   ┴  ┴└─└─┘└─┘└─┘┘└┘ ┴ └─┘
*                                  _____                      _____
*                                 (, /     /)       /) /)    (, /      /)          /)
*          ┌─┐                      /   _ (/_
*          ├─┤                  ___/___(/_/(__(_/_(/_(/_   ___/__/_)_(/_(_(_/ (_(_(_
*          ┴ ┴                /   /          .-/ _____   (__ /
*                            (__ /          (_/ (, /                                      /)™
*                                                 /  __  __ __ __  _   __ __  _  _/_ _  _(/
* ┌─┐┬─┐┌─┐┌┬┐┬ ┬┌─┐┌┬┐                          /__/ (_(__(_)/ (_/_)_(_)/ (_(_(_(__(/_(_(_
* ├─┘├┬┘│ │ │││ ││   │                      (__ /              .-/  © Jekyll Island Inc. 2018
* ┴  ┴└─└─┘─┴┘└─┘└─┘ ┴                                        (_/
*              _       __    _      ____      ____  _   _    _____  ____  ___
*=============| |\ |  / /\  | |\/| | |_ =====| |_  | | | |    | |  | |_  | |_)==============*
*=============|_| \| /_/--\ |_|  | |_|__=====|_|   |_| |_|__  |_|  |_|__ |_| \==============*
*
* ╔═╗┌─┐┌┐┌┌┬┐┬─┐┌─┐┌─┐┌┬┐  ╔═╗┌─┐┌┬┐┌─┐ ┌──────────┐
* ║  │ ││││ │ ├┬┘├─┤│   │   ║  │ │ ││├┤  │ Inventor │
* ╚═╝└─┘┘└┘ ┴ ┴└─┴ ┴└─┘ ┴   ╚═╝└─┘─┴┘└─┘ └──────────┘
library NameFilter {
* @dev filters name strings
* -converts uppercase to lower case.
* -makes sure it does not start/end with a space
* -makes sure it does not contain multiple spaces in a row
* -cannot be only numbers
* -cannot start with 0x
* -restricts characters to A-Z, a-z, 0-9, and space.
* @return reprocessed string in bytes32 format
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