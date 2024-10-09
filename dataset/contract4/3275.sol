pragma solidity ^0.4.23;
interface PlayerBookReceiverInterface {
function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external;
function receivePlayerNameList(uint256 _pID, bytes32 _name) external;
}
contract PlayerBook {
using NameFilter for string;
using SafeMath for uint256;
address private communityAddr = 0x82B0721A8c142C6203F4cF58f80629E15b02a504;
uint256 public registrationFee_ = 10 finney;
mapping(uint256 => PlayerBookReceiverInterface) public games_;
mapping(address => bytes32) public gameNames_;
mapping(address => uint256) public gameIDs_;
uint256 public gID_;
uint256 public pID_;
mapping (address => uint256) public pIDxAddr_;
mapping (bytes32 => uint256) public pIDxName_;
mapping (uint256 => Player) public plyr_;
mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;
mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_;
struct Player {
address addr;
bytes32 name;
uint256 laff;
uint256 names;
}
constructor()
public
{
plyr_[1].addr = 0x2f70dA23098d845CeB84f771129D04A79A9dB68B;
plyr_[1].name = "daddy";
plyr_[1].names = 1;
pIDxAddr_[0x2f70dA23098d845CeB84f771129D04A79A9dB68B] = 1;
pIDxName_["daddy"] = 1;
plyrNames_[1]["daddy"] = true;
plyrNameList_[1][1] = "daddy";
plyr_[2].addr = 0x55636a5fD4A78d86415B72e09E131D9D0e095e57;
plyr_[2].name = "suoha";
plyr_[2].names = 1;
pIDxAddr_[0x55636a5fD4A78d86415B72e09E131D9D0e095e57] = 2;
pIDxName_["suoha"] = 2;
plyrNames_[2]["suoha"] = true;
plyrNameList_[2][1] = "suoha";
plyr_[3].addr = 0xe948b1fF4e02cf8fa0A5Cc479b98E52022Aa5acF;
plyr_[3].name = "nodumb";
plyr_[3].names = 1;
pIDxAddr_[0xe948b1fF4e02cf8fa0A5Cc479b98E52022Aa5acF] = 3;
pIDxName_["nodumb"] = 3;
plyrNames_[3]["nodumb"] = true;
plyrNameList_[3][1] = "nodumb";
plyr_[4].addr = 0x8cFD216Eb0a305Af16f838396DFD6BDeDecd0689;
plyr_[4].name = "dddos";
plyr_[4].names = 1;
pIDxAddr_[0x8cFD216Eb0a305Af16f838396DFD6BDeDecd0689] = 4;
pIDxName_["dddos"] = 4;
plyrNames_[4]["dddos"] = true;
plyrNameList_[4][1] = "dddos";
pID_ = 4;
}
* @dev prevents contracts from interacting with fomo3d
modifier isHuman() {
address _addr = msg.sender;
uint256 _codeLength;
assembly {_codeLength := extcodesize(_addr)}
require(_codeLength == 0, "sorry humans only");
_;
}
modifier onlyCommunity()
{
require(msg.sender == communityAddr, "msg sender is not the community");
_;
}
modifier isRegisteredGame()
{
require(gameIDs_[msg.sender] != 0);
_;
}
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
function checkIfNameValid(string _nameStr)
public
view
returns(bool)
{
bytes32 _name = _nameStr.nameFilter();
if (pIDxName_[_name] == 0)
return (true);
else
return (false);
}
* @dev registers a name.  UI will always display the last name you registered.
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
* @param _affCode affiliate ID, address, or name of who refered you
* @param _all set to true if you want this to push your info to all games
* (this might cost a lot of gas)
function registerNameXID(string _nameString, uint256 _affCode, bool _all)
isHuman()
public
payable
{
require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
bytes32 _name = NameFilter.nameFilter(_nameString);
address _addr = msg.sender;
bool _isNewPlayer = determinePID(_addr);
uint256 _pID = pIDxAddr_[_addr];
if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID)
{
plyr_[_pID].laff = _affCode;
} else if (_affCode == _pID) {
_affCode = 0;
}
registerNameCore(_pID, _addr, _affCode, _name, _isNewPlayer, _all);
}
function registerNameXaddr(string _nameString, address _affCode, bool _all)
isHuman()
public
payable
{
require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
bytes32 _name = NameFilter.nameFilter(_nameString);
address _addr = msg.sender;
bool _isNewPlayer = determinePID(_addr);
uint256 _pID = pIDxAddr_[_addr];
uint256 _affID;
if (_affCode != address(0) && _affCode != _addr)
{
_affID = pIDxAddr_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
}
function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
isHuman()
public
payable
{
require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
bytes32 _name = NameFilter.nameFilter(_nameString);
address _addr = msg.sender;
bool _isNewPlayer = determinePID(_addr);
uint256 _pID = pIDxAddr_[_addr];
uint256 _affID;
if (_affCode != "" && _affCode != _name)
{
_affID = pIDxName_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
}
* @dev players, if you registered a profile, before a game was released, or
* set the all bool to false when you registered, use this function to push
* your profile to a single game.  also, if you've  updated your name, you
* can use this to push your name to games of your choosing.
* -functionhash- 0x81c5b206
* @param _gameID game id
function addMeToGame(uint256 _gameID)
isHuman()
public
{
require(_gameID <= gID_, "silly player, that game doesn't exist yet");
address _addr = msg.sender;
uint256 _pID = pIDxAddr_[_addr];
require(_pID != 0, "hey there buddy, you dont even have an account");
uint256 _totalNames = plyr_[_pID].names;
games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);
if (_totalNames > 1)
for (uint256 ii = 1; ii <= _totalNames; ii++)
games_[_gameID].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
}
* @dev players, use this to push your player profile to all registered games.
* -functionhash- 0x0c6940ea
function addMeToAllGames()
isHuman()
public
{
address _addr = msg.sender;
uint256 _pID = pIDxAddr_[_addr];
require(_pID != 0, "hey there buddy, you dont even have an account");
uint256 _laff = plyr_[_pID].laff;
uint256 _totalNames = plyr_[_pID].names;
bytes32 _name = plyr_[_pID].name;
for (uint256 i = 1; i <= gID_; i++)
{
games_[i].receivePlayerInfo(_pID, _addr, _name, _laff);
if (_totalNames > 1)
for (uint256 ii = 1; ii <= _totalNames; ii++)
games_[i].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
}
}
* @dev players use this to change back to one of your old names.  tip, you'll
* still need to push that info to existing games.
* -functionhash- 0xb9291296
* @param _nameString the name you want to use
function useMyOldName(string _nameString)
isHuman()
public
{
bytes32 _name = _nameString.nameFilter();
uint256 _pID = pIDxAddr_[msg.sender];
require(plyrNames_[_pID][_name] == true, "umm... thats not a name you own");
plyr_[_pID].name = _name;
}
function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer, bool _all)
private
{
if (pIDxName_[_name] != 0)
require(plyrNames_[_pID][_name] == true, "sorry that names already taken");
plyr_[_pID].name = _name;
pIDxName_[_name] = _pID;
if (plyrNames_[_pID][_name] == false)
{
plyrNames_[_pID][_name] = true;
plyr_[_pID].names++;
plyrNameList_[_pID][plyr_[_pID].names] = _name;
}
communityAddr.transfer(address(this).balance);
if (_all == true)
for (uint256 i = 1; i <= gID_; i++)
games_[i].receivePlayerInfo(_pID, _addr, _name, _affID);
emit onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, msg.value, now);
}
function determinePID(address _addr)
private
returns (bool)
{
if (pIDxAddr_[_addr] == 0)
{
pID_++;
pIDxAddr_[_addr] = pID_;
plyr_[pID_].addr = _addr;
return (true);
} else {
return (false);
}
}
function getPlayerID(address _addr)
isRegisteredGame()
external
returns (uint256)
{
determinePID(_addr);
return (pIDxAddr_[_addr]);
}
function getPlayerName(uint256 _pID)
external
view
returns (bytes32)
{
return (plyr_[_pID].name);
}
function getPlayerLAff(uint256 _pID)
external
view
returns (uint256)
{
return (plyr_[_pID].laff);
}
function getPlayerAddr(uint256 _pID)
external
view
returns (address)
{
return (plyr_[_pID].addr);
}
function getNameFee()
external
view
returns (uint256)
{
return(registrationFee_);
}
function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all)
isRegisteredGame()
external
payable
returns(bool, uint256)
{
require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
bool _isNewPlayer = determinePID(_addr);
uint256 _pID = pIDxAddr_[_addr];
uint256 _affID = _affCode;
if (_affID != 0 && _affID != plyr_[_pID].laff && _affID != _pID)
{
plyr_[_pID].laff = _affID;
} else if (_affID == _pID) {
_affID = 0;
}
registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
return(_isNewPlayer, _affID);
}
function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all)
isRegisteredGame()
external
payable
returns(bool, uint256)
{
require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
bool _isNewPlayer = determinePID(_addr);
uint256 _pID = pIDxAddr_[_addr];
uint256 _affID;
if (_affCode != address(0) && _affCode != _addr)
{
_affID = pIDxAddr_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
return(_isNewPlayer, _affID);
}
function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all)
isRegisteredGame()
external
payable
returns(bool, uint256)
{
require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
bool _isNewPlayer = determinePID(_addr);
uint256 _pID = pIDxAddr_[_addr];
uint256 _affID;
if (_affCode != "" && _affCode != _name)
{
_affID = pIDxName_[_affCode];
if (_affID != plyr_[_pID].laff)
{
plyr_[_pID].laff = _affID;
}
}
registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
return(_isNewPlayer, _affID);
}
function addGame(address _gameAddress, string _gameNameStr)
onlyCommunity()
public
{
require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");
gID_++;
bytes32 _name = _gameNameStr.nameFilter();
gameIDs_[_gameAddress] = gID_;
gameNames_[_gameAddress] = _name;
games_[gID_] = PlayerBookReceiverInterface(_gameAddress);
games_[gID_].receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name, 0);
games_[gID_].receivePlayerInfo(2, plyr_[2].addr, plyr_[2].name, 0);
games_[gID_].receivePlayerInfo(3, plyr_[3].addr, plyr_[3].name, 0);
games_[gID_].receivePlayerInfo(4, plyr_[4].addr, plyr_[4].name, 0);
}
function setRegistrationFee(uint256 _fee)
onlyCommunity()
public
{
registrationFee_ = _fee;
}
}
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
* change notes:  original SafeMath library from OpenZeppelin modified by dddos
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