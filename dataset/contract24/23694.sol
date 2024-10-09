pragma solidity ^0.4.18;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event SetPaused(bool paused);
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() public onlyOwner whenNotPaused returns (bool) {
paused = true;
SetPaused(paused);
return true;
}
function unpause() public onlyOwner whenPaused returns (bool) {
paused = false;
SetPaused(paused);
return true;
}
}
contract EtherbotsPrivileges is Pausable {
event ContractUpgrade(address newContract);
}
contract ERC721 {
bytes4 internal constant INTERFACE_SIGNATURE_ERC165 =
bytes4(keccak256("supportsInterface(bytes4)"));
bytes4 internal constant INTERFACE_SIGNATURE_ERC721 =
bytes4(keccak256("ownerOf(uint256)")) ^
bytes4(keccak256("countOfDeeds()")) ^
bytes4(keccak256("countOfDeedsByOwner(address)")) ^
bytes4(keccak256("deedOfOwnerByIndex(address,uint256)")) ^
bytes4(keccak256("approve(address,uint256)")) ^
bytes4(keccak256("takeOwnership(uint256)"));
function supportsInterface(bytes4 _interfaceID) external pure returns (bool);
function ownerOf(uint256 _deedId) public view returns (address _owner);
function countOfDeeds() external view returns (uint256 _count);
function countOfDeedsByOwner(address _owner) external view returns (uint256 _count);
function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);
event Transfer(address indexed from, address indexed to, uint256 indexed deedId);
event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);
function approve(address _to, uint256 _deedId) external payable;
function takeOwnership(uint256 _deedId) external payable;
}
contract ERC721Metadata is ERC721 {
bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata =
bytes4(keccak256("name()")) ^
bytes4(keccak256("symbol()")) ^
bytes4(keccak256("deedUri(uint256)"));
function name() public pure returns (string n);
function symbol() public pure returns (string s);
event Forge(address owner, uint256 partID, Part part);
event Transfer(address from, address to, uint256 tokenId);
struct Part {
uint32 tokenId;
uint8 partType;
uint8 partSubType;
uint8 rarity;
uint8 element;
uint32 battlesLastDay;
uint32 experience;
uint32 forgeTime;
uint32 battlesLastReset;
}
uint8 constant DEFENCE = 1;
uint8 constant MELEE = 2;
uint8 constant BODY = 3;
uint8 constant TURRET = 4;
uint8 constant STANDARD = 1;
uint8 constant SHADOW = 2;
uint8 constant GOLD = 3;
struct User {
uint32 numShards;
uint32 experience;
uint8[32] perks;
}
mapping ( address => User ) public addressToUser;
Part[] parts;
mapping (uint256 => address) public partIndexToOwner;
mapping (address => uint256) addressToTokensOwned;
mapping (uint256 => address) public partIndexToApproved;
address auction;
address[] approvedBattles;
function getUserByAddress(address _user) public view returns (uint32, uint8[32]) {
return (addressToUser[_user].experience, addressToUser[_user].perks);
}
function _transfer(address _from, address _to, uint256 _tokenId) internal {
addressToTokensOwned[_to]++;
partIndexToOwner[_tokenId] = _to;
if (_from != address(0)) {
addressToTokensOwned[_from]--;
delete partIndexToApproved[_tokenId];
}
Transfer(_from, _to, _tokenId);
}
function getPartById(uint _id) external view returns (
uint32 tokenId,
uint8 partType,
uint8 partSubType,
uint8 rarity,
uint8 element,
uint32 battlesLastDay,
uint32 experience,
uint32 forgeTime,
uint32 battlesLastReset
) {
Part memory p = parts[_id];
return (p.tokenId, p.partType, p.partSubType, p.rarity, p.element, p.battlesLastDay, p.experience, p.forgeTime, p.battlesLastReset);
}
function substring(string str, uint startIndex, uint endIndex) internal pure returns (string) {
bytes memory strBytes = bytes(str);
bytes memory result = new bytes(endIndex-startIndex);
for (uint i = startIndex; i < endIndex; i++) {
result[i-startIndex] = strBytes[i];
}
return string(result);
}
function stringToUint32(string s) internal pure returns (uint32) {
bytes memory b = bytes(s);
uint result = 0;
for (uint i = 0; i < b.length; i++) {
if (b[i] >= 48 && b[i] <= 57) {
result = result * 10 + (uint(b[i]) - 48);
}
}
return uint32(result);
}
function stringToUint8(string s) internal pure returns (uint8) {
return uint8(stringToUint32(s));
}
function uintToString(uint v) internal pure returns (string) {
uint maxlength = 100;
bytes memory reversed = new bytes(maxlength);
uint i = 0;
while (v != 0) {
uint remainder = v % 10;
v = v / 10;
reversed[i++] = byte(48 + remainder);
}
bytes memory s = new bytes(i);
for (uint j = 0; j < i; j++) {
s[j] = reversed[i - j - 1];
}
string memory str = string(s);
return str;
}
}
contract EtherbotsNFT is EtherbotsBase, ERC721Enumerable, ERC721Original {
function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
return (_interfaceID == ERC721Original.INTERFACE_SIGNATURE_ERC721Original) ||
(_interfaceID == ERC721.INTERFACE_SIGNATURE_ERC721) ||
(_interfaceID == ERC721Metadata.INTERFACE_SIGNATURE_ERC721Metadata) ||
(_interfaceID == ERC721Enumerable.INTERFACE_SIGNATURE_ERC721Enumerable);
}
function implementsERC721() public pure returns (bool) {
return true;
}
function name() public pure returns (string _name) {
return "Etherbots";
}
function symbol() public pure returns (string _smbol) {
return "ETHBOT";
}
function totalSupply() public view returns (uint) {
return parts.length;
}
function countOfDeeds() external view returns (uint256) {
return parts.length;
}
function owns(address _owner, uint256 _tokenId) public view returns (bool) {
return (partIndexToOwner[_tokenId] == _owner);
}
function ownsAll(address _owner, uint256[] _tokenIds) public view returns (bool) {
require(_tokenIds.length > 0);
for (uint i = 0; i < _tokenIds.length; i++) {
if (partIndexToOwner[_tokenIds[i]] != _owner) {
return false;
}
}
return true;
}
function _approve(uint256 _tokenId, address _approved) internal {
partIndexToApproved[_tokenId] = _approved;
}
function _approvedFor(address _newOwner, uint256 _tokenId) internal view returns (bool) {
return (partIndexToApproved[_tokenId] == _newOwner);
}
function ownerByIndex(uint256 _index) external view returns (address _owner){
return partIndexToOwner[_index];
}
function balanceOf(address _owner) public view returns (uint256 count) {
return addressToTokensOwned[_owner];
}
function countOfDeedsByOwner(address _owner) external view returns (uint256) {
return balanceOf(_owner);
}
function transfer(address _to, uint256 _tokenId) public whenNotPaused payable {
require(msg.value == 0);
require(_to != address(0));
require(_to != address(this));
require(_to != address(auction));
for (uint j = 0; j < approvedBattles.length; j++) {
require(_to != approvedBattles[j]);
}
require(owns(msg.sender, _tokenId));
_transfer(msg.sender, _to, _tokenId);
}
function transferAll(address _to, uint256[] _tokenIds) public whenNotPaused payable {
require(msg.value == 0);
require(_to != address(0));
require(_to != address(this));
require(_to != address(auction));
for (uint j = 0; j < approvedBattles.length; j++) {
require(_to != approvedBattles[j]);
}
require(ownsAll(msg.sender, _tokenIds));
for (uint k = 0; k < _tokenIds.length; k++) {
_transfer(msg.sender, _to, _tokenIds[k]);
}
}
function approve(address _to, uint256 _deedId) external whenNotPaused payable {
require(msg.value == 0);
require(owns(msg.sender, _deedId));
partIndexToApproved[_deedId] = _to;
Approval(msg.sender, _to, _deedId);
}
function approveMany(address _to, uint256[] _tokenIds) external whenNotPaused payable {
for (uint i = 0; i < _tokenIds.length; i++) {
uint _tokenId = _tokenIds[i];
require(owns(msg.sender, _tokenId));
partIndexToApproved[_tokenId] = _to;
Approval(msg.sender, _to, _tokenId);
}
}
function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
require(_to != address(0));
require(_to != address(this));
require(partIndexToApproved[_tokenId] == msg.sender);
require(owns(_from, _tokenId));
_transfer(_from, _to, _tokenId);
}
function ownerOf(uint256 _deedId) public view returns (address _owner) {
_owner = partIndexToOwner[_deedId];
require(_owner != address(0));
}
function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
uint256 totalParts = totalSupply();
return tokensOfOwnerWithinRange(_owner, 0, totalParts);
}
function tokensOfOwnerWithinRange(address _owner, uint _start, uint _numToSearch) public view returns(uint256[] ownerTokens) {
uint256 tokenCount = balanceOf(_owner);
uint256[] memory tmpResult = new uint256[](tokenCount);
if (tokenCount == 0) {
return tmpResult;
}
uint256 resultIndex = 0;
for (uint partId = _start; partId < _start + _numToSearch; partId++) {
if (partIndexToOwner[partId] == _owner) {
tmpResult[resultIndex] = partId;
resultIndex++;
if (resultIndex == tokenCount) {
break;
}
}
}
uint resultLength = resultIndex;
uint256[] memory result = new uint256[](resultLength);
for (uint i=0; i<resultLength; i++) {
result[i] = tmpResult[i];
}
return result;
}
function getPartsOfOwner(address _owner) external view returns(bytes24[]) {
uint256 totalParts = totalSupply();
return getPartsOfOwnerWithinRange(_owner, 0, totalParts);
}
function getPartsOfOwnerWithinRange(address _owner, uint _start, uint _numToSearch) public view returns(bytes24[]) {
uint256 tokenCount = balanceOf(_owner);
uint resultIndex = 0;
bytes24[] memory result = new bytes24[](tokenCount);
for (uint partId = _start; partId < _start + _numToSearch; partId++) {
if (partIndexToOwner[partId] == _owner) {
result[resultIndex] = _partToBytes(parts[partId]);
resultIndex++;
}
}
return result;
}
function _partToBytes(Part p) internal pure returns (bytes24 b) {
b = bytes24(p.tokenId);
b = b << 8;
b = b | bytes24(p.partType);
b = b << 8;
b = b | bytes24(p.partSubType);
b = b << 8;
b = b | bytes24(p.rarity);
b = b << 8;
b = b | bytes24(p.element);
b = b << 32;
b = b | bytes24(p.battlesLastDay);
b = b << 32;
b = b | bytes24(p.experience);
b = b << 32;
b = b | bytes24(p.forgeTime);
b = b << 32;
b = b | bytes24(p.battlesLastReset);
}
uint32 constant FIRST_LEVEL = 1000;
uint32 constant INCREMENT = 1000;
function getLevel(uint32 _exp) public pure returns(uint32) {
uint32 c = 0;
for (uint32 i = FIRST_LEVEL; i <= FIRST_LEVEL + _exp; i += c * INCREMENT) {
c++;
}
return c;
}
string metadataBase = "https:
function setMetadataBase(string _base) external onlyOwner {
metadataBase = _base;
}
function _metadata(uint256 _id) internal view returns(string) {
Part memory p = parts[_id];
return strConcat(strConcat(
metadataBase,
uintToString(uint(p.partType)),
"/",
uintToString(uint(p.partSubType)),
"/"
), uintToString(uint(p.rarity)), "", "", "");
}
function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
bytes memory _ba = bytes(_a);
bytes memory _bb = bytes(_b);
bytes memory _bc = bytes(_c);
bytes memory _bd = bytes(_d);
bytes memory _be = bytes(_e);
string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
bytes memory babcde = bytes(abcde);
uint k = 0;
for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
return string(babcde);
}
_createPart(_partArray, _owner);
partsMinted++;
}
}
contract NewCratePreSale {
mapping (address => uint[]) public userToRobots;
function _migrate(uint _index) external onlyOwner {
bytes4 selector = bytes4(keccak256("setData()"));
address a = migrators[_index];
require(a.delegatecall(selector));
}
address[6] migrators = [
0x700FeBD9360ac0A0a72F371615427Bec4E4454E5,
0x72Cc898de0A4EAC49c46ccb990379099461342f6,
0xc3cC48da3B8168154e0f14Bf0446C7a93613F0A7,
0x4cC96f2Ddf6844323ae0d8461d418a4D473b9AC3,
0xa52bFcb5FF599e29EE2B9130F1575BaBaa27de0A,
0xe503b42AabdA22974e2A8B75Fa87E010e1B13584
];
function NewCratePreSale() public payable {
owner = msg.sender;
oldAppreciationRateWei = 100000000000000;
appreciationRateWei = oldAppreciationRateWei;
oldPrice = 232600000000000000;
currentPrice = oldPrice;
oldCratesSold = 1075;
cratesSold = oldCratesSold;
}
uint256 constant public MAX_CRATES_TO_SELL = 3900;
uint256 constant public PRESALE_END_TIMESTAMP = 1518699600;
uint256 public appreciationRateWei;
uint32 public cratesSold;
uint256 public currentPrice;
uint32 public oldCratesSold;
uint256 public oldPrice;
uint256 public oldAppreciationRateWei;
mapping (address => uint[]) public addressToPurchasedBlocks;
mapping (address => uint) public expiredCrates;
function openAll() public {
uint len = addressToPurchasedBlocks[msg.sender].length;
require(len > 0);
uint8 count = 0;
for (uint i = len - 1; i >= 0 && len > i; i--) {
uint crateBlock = addressToPurchasedBlocks[msg.sender][i];
require(block.number > crateBlock);
var hash = block.blockhash(crateBlock);
if (uint(hash) != 0) {
uint rand = uint(keccak256(hash, msg.sender, i)) % (10 ** 20);
userToRobots[msg.sender].push(rand);
count++;
} else {
expiredCrates[msg.sender] += (i + 1);
break;
}
}
CratesOpened(msg.sender, count);
delete addressToPurchasedBlocks[msg.sender];
}
event CratesPurchased(address indexed _from, uint8 _quantity);
event CratesOpened(address indexed _from, uint8 _quantity);
function getPrice() view public returns (uint256) {
return currentPrice;
}
function getRobotCountForUser(address _user) external view returns(uint256) {
return userToRobots[_user].length;
}
function getRobotForUserByIndex(address _user, uint _index) external view returns(uint) {
return userToRobots[_user][_index];
}
function getRobotsForUser(address _user) view public returns (uint[]) {
return userToRobots[_user];
}
function getPendingCratesForUser(address _user) external view returns(uint[]) {
return addressToPurchasedBlocks[_user];
}
function getPendingCrateForUserByIndex(address _user, uint _index) external view returns(uint) {
return addressToPurchasedBlocks[_user][_index];
}
function getExpiredCratesForUser(address _user) external view returns(uint) {
return expiredCrates[_user];
}
function incrementPrice() private {
if ( currentPrice == 100000000000000000 ) {
appreciationRateWei = 200000000000000;
} else if ( currentPrice == 200000000000000000) {
appreciationRateWei = 100000000000000;
} else if (currentPrice == 300000000000000000) {
appreciationRateWei = 50000000000000;
}
currentPrice += appreciationRateWei;
}
function purchaseCrates(uint8 _cratesToBuy) public payable whenNotPaused {
require(now < PRESALE_END_TIMESTAMP);
require(_cratesToBuy <= 10);
require(_cratesToBuy >= 1);
require(cratesSold + _cratesToBuy <= MAX_CRATES_TO_SELL);
uint256 priceToPay = _calculatePayment(_cratesToBuy);
require(msg.value >= priceToPay);
if (msg.value > priceToPay) {
msg.sender.transfer(msg.value-priceToPay);
}
cratesSold += _cratesToBuy;
for (uint8 i = 0; i < _cratesToBuy; i++) {
incrementPrice();
addressToPurchasedBlocks[msg.sender].push(block.number);
}
CratesPurchased(msg.sender, _cratesToBuy);
}
function _calculatePayment (uint8 _cratesToBuy) private view returns (uint256) {
uint256 tempPrice = currentPrice;
for (uint8 i = 1; i < _cratesToBuy; i++) {
tempPrice += (currentPrice + (appreciationRateWei * i));
}
return tempPrice;
}
function withdraw() onlyOwner public {
owner.transfer(this.balance);
}
function addFunds() onlyOwner external payable {
}
event SetPaused(bool paused);
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() external onlyOwner whenNotPaused returns (bool) {
paused = true;
SetPaused(paused);
return true;
}
function unpause() external onlyOwner whenPaused returns (bool) {
paused = false;
SetPaused(paused);
return true;
}
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract EtherbotsMigrations is Mint {
event CratesOpened(address indexed _from, uint8 _quantity);
event OpenedOldCrates(address indexed _from);
event MigratedCrates(address indexed _from, uint16 _quantity, bool isMigrationComplete);
address presale = 0xc23F76aEa00B775AADC8504CcB22468F4fD2261A;
mapping(address => bool) public hasMigrated;
mapping(address => bool) public hasOpenedOldCrates;
mapping(address => uint[]) pendingCrates;
mapping(address => uint16) public cratesMigrated;
string constant private DEFENCE_ELEMENT_BY_ID = "12434133214";
string constant private MELEE_ELEMENT_BY_ID = "31323422111144";
string constant private BODY_ELEMENT_BY_ID = "212343114234111";
string constant private TURRET_ELEMENT_BY_ID = "43212113434";
function openOldCrates() external {
require(hasOpenedOldCrates[msg.sender] == false);
_migrateExpiredCrates();
hasOpenedOldCrates[msg.sender] = true;
OpenedOldCrates(msg.sender);
}
function migrate() external whenNotPaused {
require(hasMigrated[msg.sender] == false);
require(pendingCrates[msg.sender].length == 0);
if (NewCratePreSale(presale).getExpiredCratesForUser(msg.sender) > 0) {
require(hasOpenedOldCrates[msg.sender]);
}
uint16 length = uint16(NewCratePreSale(presale).getRobotCountForUser(msg.sender));
bool isMigrationComplete = false;
var max = length - cratesMigrated[msg.sender];
if (max > 9) {
max = 9;
} else {
isMigrationComplete = true;
hasMigrated[msg.sender] = true;
}
for (uint i = cratesMigrated[msg.sender]; i < cratesMigrated[msg.sender] + max; i++) {
var robot = NewCratePreSale(presale).getRobotForUserByIndex(msg.sender, i);
var robotString = uintToString(robot);
_migrateRobot(robotString);
}
cratesMigrated[msg.sender] += max;
MigratedCrates(msg.sender, cratesMigrated[msg.sender], isMigrationComplete);
}
function _migrateRobot(string robot) private {
var (melee, defence, body, turret) = _convertBlueprint(robot);
_createPart(melee, msg.sender);
_createPart(defence, msg.sender);
_createPart(turret, msg.sender);
_createPart(body, msg.sender);
}
function _getRarity(string original, uint8 low, uint8 high) pure private returns (uint8) {
uint32 rarity = stringToUint32(substring(original,low,high));
if (rarity >= 950) {
return GOLD;
} else if (rarity >= 850) {
return SHADOW;
} else {
return STANDARD;
}
}
function _getElement(string elementString, uint partId) pure private returns(uint8) {
return stringToUint8(substring(elementString, partId-1,partId));
}
function _getPartId(string original, uint8 start, uint8 end, uint8 partCount) pure private returns(uint8) {
return (stringToUint8(substring(original,start,end)) % partCount) + 1;
}
function userPendingCrateNumber(address _user) external view returns (uint) {
return pendingCrates[_user].length;
}
function _convertBlueprint(string original) pure private returns(uint8[4] body,uint8[4] melee, uint8[4] turret, uint8[4] defence ) {
body[0] = BODY;
body[1] = _getPartId(original, 3, 5, 15);
body[2] = _getRarity(original, 0, 3);
body[3] = _getElement(BODY_ELEMENT_BY_ID, body[1]);
turret[0] = TURRET;
turret[1] = _getPartId(original, 8, 10, 11);
turret[2] = _getRarity(original, 5, 8);
turret[3] = _getElement(TURRET_ELEMENT_BY_ID, turret[1]);
melee[0] = MELEE;
melee[1] = _getPartId(original, 13, 15, 14);
melee[2] = _getRarity(original, 10, 13);
melee[3] = _getElement(MELEE_ELEMENT_BY_ID, melee[1]);
defence[0] = DEFENCE;
var len = bytes(original).length;
if (len == 20) {
defence[1] = _getPartId(original, 18, 20, 11);
} else if (len == 19) {
defence[1] = _getPartId(original, 18, 19, 11);
} else {
defence[1] = uint8(1);
}
defence[2] = _getRarity(original, 15, 18);
defence[3] = _getElement(DEFENCE_ELEMENT_BY_ID, defence[1]);
}
function _migrateExpiredCrates() private {
uint expired = NewCratePreSale(presale).getExpiredCratesForUser(msg.sender);
for (uint i = 0; i < expired; i++) {
pendingCrates[msg.sender].push(block.number);
}
}
function openCrates() public whenNotPaused {
uint[] memory pc = pendingCrates[msg.sender];
require(pc.length > 0);
uint8 count = 0;
for (uint i = 0; i < pc.length; i++) {
uint crateBlock = pc[i];
require(block.number > crateBlock);
var hash = block.blockhash(crateBlock);
if (uint(hash) != 0) {
uint rand = uint(keccak256(hash, msg.sender, i)) % (10 ** 20);
_migrateRobot(uintToString(rand));
count++;
}
}
CratesOpened(msg.sender, count);
delete pendingCrates[msg.sender];
}
}
contract Battle {
function name() external view returns (string);
function playerCount() external view returns (uint count);
function createBattle(address _creator, uint[] _partIds, bytes32 _commit, uint _revealLength) external payable returns (uint);
function cancelBattle(uint battleID) external;
function winnerOf(uint battleId, uint index) external view returns (address);
function loserOf(uint battleId, uint index) external view returns (address);
event BattleCreated(uint indexed battleID, address indexed starter);
event BattleStage(uint indexed battleID, uint8 moveNumber, uint8[2] attackerMovesDefenderMoves, uint16[2] attackerDamageDefenderDamage);
event BattleEnded(uint indexed battleID, address indexed winner);
event BattleConcluded(uint indexed battleID);
event BattlePropertyChanged(string name, uint previous, uint value);
}
contract EtherbotsBattle is EtherbotsMigrations {
function addApprovedBattle(Battle _battle) external onlyOwner {
approvedBattles.push(_battle);
}
function _isApprovedBattle() internal view returns (bool) {
for (uint8 i = 0; i < approvedBattles.length; i++) {
if (msg.sender == address(approvedBattles[i])) {
return true;
}
}
return false;
}
modifier onlyApprovedBattles(){
require(_isApprovedBattle());
_;
}
function createBattle(uint _battleId, uint[] partIds, bytes32 commit, uint revealLength) external payable {
require(_battleId < approvedBattles.length);
if (partIds.length > 0) {
require(ownsAll(msg.sender, partIds));
}
Battle battle = Battle(approvedBattles[_battleId]);
for (uint i=0; i<partIds.length; i++) {
_approve(partIds[i], address(battle));
}
uint newDuelId = battle.createBattle.value(msg.value)(msg.sender, partIds, commit, revealLength);
NewDuel(_battleId, newDuelId);
}
event NewDuel(uint battleId, uint duelId);
mapping(address => Reward[]) public pendingRewards;
function getPendingBattleRewardsCount(address _user) external view returns (uint) {
return pendingRewards[_user].length;
}
struct Reward {
uint blocknumber;
int32 exp;
}
function addExperience(address _user, uint[] _partIds, int32[] _exps) external onlyApprovedBattles {
address user = _user;
require(_partIds.length == _exps.length);
int32 sum = 0;
for (uint i = 0; i < _exps.length; i++) {
sum += _addPartExperience(_partIds[i], _exps[i]);
}
_addUserExperience(user, sum);
_storeReward(user, sum);
}
function _storeReward(address _user, int32 _battleExp) internal {
pendingRewards[_user].push(Reward({
blocknumber: 0,
exp: _battleExp
}));
}
uint8 bestMultiple = 3;
uint8 mediumMultiple = 2;
uint8 worstMultiple = 1;
uint8 minShards = 1;
uint8 bestProbability = 97;
uint8 mediumProbability = 85;
function _getExpMultiple(int _exp) internal view returns (uint8, uint8) {
if (_exp > 500) {
return (bestMultiple,mediumMultiple);
} else if (_exp > 0) {
return (mediumMultiple,mediumMultiple);
} else {
return (worstMultiple,mediumMultiple);
}
}
function setBest(uint8 _newBestMultiple) external onlyOwner {
bestMultiple = _newBestMultiple;
}
function setMedium(uint8 _newMediumMultiple) external onlyOwner {
mediumMultiple = _newMediumMultiple;
}
function setWorst(uint8 _newWorstMultiple) external onlyOwner {
worstMultiple = _newWorstMultiple;
}
function setMinShards(uint8 _newMin) external onlyOwner {
minShards = _newMin;
}
function setBestProbability(uint8 _newBestProb) external onlyOwner {
bestProbability = _newBestProb;
}
function setMediumProbability(uint8 _newMinProb) external onlyOwner {
mediumProbability = _newMinProb;
}
function _calculateShards(int _exp, uint rand) internal view returns (uint16) {
var (a, b) = _getExpMultiple(_exp);
uint16 shards;
uint randPercent = rand % 100;
if (randPercent > bestProbability) {
shards = uint16(a * ((rand % 20) + 12) / b);
} else if (randPercent > mediumProbability) {
shards = uint16(a * ((rand % 10) + 6) / b);
} else {
shards = uint16((a * (rand % 5)) / b);
}
if (shards < minShards) {
shards = minShards;
}
return shards;
}
function convertReward() external {
Reward[] storage rewards = pendingRewards[msg.sender];
for (uint i = 0; i < rewards.length; i++) {
if (rewards[i].blocknumber == 0) {
rewards[i].blocknumber = block.number;
}
}
}
function redeemBattleCrates() external {
uint8 count = 0;
uint len = pendingRewards[msg.sender].length;
require(len > 0);
for (uint i = 0; i < len; i++) {
Reward memory rewardStruct = pendingRewards[msg.sender][i];
require(block.number > rewardStruct.blocknumber);
require(rewardStruct.blocknumber != 0);
var hash = block.blockhash(rewardStruct.blocknumber);
if (uint(hash) != 0) {
uint rand = uint(keccak256(hash, msg.sender, i));
_generateBattleReward(rand,rewardStruct.exp);
count++;
} else {
}
}
CratesOpened(msg.sender, count);
delete pendingRewards[msg.sender];
}
function _generateBattleReward(uint rand, int32 exp) internal {
if (((rand % 1000) > PART_REWARD_CHANCE) && (exp > 0)) {
_generateRandomPart(rand, msg.sender);
} else {
_addShardsToUser(addressToUser[msg.sender], _calculateShards(exp, rand));
}
}
function _addUserExperience(address user, int32 exp) internal {
User memory u = addressToUser[user];
if (exp < 0 && uint32(int32(u.experience) + exp) > u.experience) {
u.experience = 0;
return;
} else if (exp > 0) {
require(uint32(int32(u.experience) + exp) > u.experience);
}
addressToUser[user].experience = uint32(int32(u.experience) + exp);
}
function setMinScaled(int8 _min) external onlyOwner {
minScaled = _min;
}
int8 minScaled = 25;
function _scaleExp(uint32 _battleCount, int32 _exp) internal view returns (int32) {
if (_battleCount <= 10) {
return _exp;
}
int32 exp =  (_exp * 10)/int32(_battleCount);
if (exp < minScaled) {
return minScaled;
}
return exp;
}
function _addPartExperience(uint _id, int32 _baseExp) internal returns (int32) {
Part storage p = parts[_id];
if (now - p.battlesLastReset > 24 hours) {
p.battlesLastReset = uint32(now);
p.battlesLastDay = 0;
}
p.battlesLastDay++;
int32 exp = _baseExp;
if (exp > 0) {
exp = _scaleExp(p.battlesLastDay, _baseExp);
}
if (exp < 0 && uint32(int32(p.experience) + exp) > p.experience) {
p.experience = 0;
return;
} else if (exp > 0) {
require(uint32(int32(p.experience) + exp) > p.experience);
}
parts[_id].experience = uint32(int32(parts[_id].experience) + exp);
return exp;
}
function totalLevel(uint[] partIds) public view returns (uint32) {
uint32 total = 0;
for (uint i = 0; i < partIds.length; i++) {
total += getLevel(parts[partIds[i]].experience);
}
return total;
}
function hasOrderedRobotParts(uint[] partIds) external view returns(bool) {
uint len = partIds.length;
if (len != 4) {
return false;
}
for (uint i = 0; i < len; i++) {
if (parts[partIds[i]].partType != i+1) {
return false;
}
}
return true;
}
}
contract EtherbotsCore is EtherbotsBattle {
function EtherbotsCore() public {
paused = true;
owner = msg.sender;
}
function() external payable {
}
function withdrawBalance() external onlyOwner {
owner.transfer(this.balance);
}
}