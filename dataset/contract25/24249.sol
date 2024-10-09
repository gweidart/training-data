pragma solidity ^0.4.18;
contract CoinLib {
address public constant btc = address(0xe98e2830be1a7e4156d656a7505e65d08c67660dc618072422e9c78053c261e9);
address public constant bch = address(0xc157673705e9a7d6253fb36c51e0b2c9193b9b560fd6d145bd19ecdf6b3a873b);
address public constant btg = address(0x4e5f418e667aa2b937135735d3deb218f913284dd429fa56a60a2a8c2d913f6c);
address public constant eth = address(0xaaaebeba3810b1e6b70781f14b2d72c1cb89c0b2b320c43bb67ff79f562f5ff4);
address public constant etc = address(0x49b019f3320b92b2244c14d064de7e7b09dbc4c649e8650e7aa17e5ce7253294);
address public constant ltc = address(0xfdd18b7aa4e2107a72f3310e2403b9bd7ace4a9f01431002607b3b01430ce75d);
address public constant doge = address(0x9a3f52b1b31ae58da40209f38379e78c3a0756495a0f585d0b3c84a9e9718f9d);
address public constant dash = address(0x279c8d120dfdb1ac051dfcfe9d373ee1d16624187fd2ed07d8817b7f9da2f07b);
address public constant xmr = address(0x8f7631e03f6499d6370dbfd69bc9be2ac2a84e20aa74818087413a5c8e085688);
address public constant zec = address(0x85118a02446a6ea7372cee71b5fc8420a3f90277281c88f5c237f3edb46419a6);
address public constant bcn = address(0x333433c3d35b6491924a29fbd93a9852a3c64d3d5b9229c073a047045d57cbe4);
address public constant pivx = address(0xa8b003381bf1e14049ab83186dd79e07408b0884618bc260f4e76ccd730638c7);
address public constant ada = address(0x4e1e6d8aa1ff8f43f933718e113229b0ec6b091b699f7a8671bcbd606da36eea);
address public constant xem = address(0x5f83a7d8f46444571fbbd0ea2d2613ab294391cb1873401ac6090df731d949e5);
address public constant neo = address(0x6dc5790d7c4bfaaa2e4f8e2cd517bacd4a3831f85c0964e56f2743cbb847bc46);
address public constant eos = 0x86Fa049857E0209aa7D9e616F7eb3b3B78ECfdb0;
address[] internal oldSchool = [btc, ltc, eth, dash];
address[] internal btcForks = [btc, bch, btg];
address[] internal smart = [eth, ada, eos, xem];
address[] internal anons = [dash, xmr, zec, bcn];
function getBtcForkCoins() public view returns (address[]) {
return btcForks;
}
function getOldSchoolCoins() public view returns (address[]) {
return oldSchool;
}
function getPrivacyCoins() public view returns (address[]) {
return anons;
}
function getSmartCoins() public view returns (address[]) {
return smart;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract SuperOwners {
address public owner1;
address public pendingOwner1;
address public owner2;
address public pendingOwner2;
function SuperOwners(address _owner1, address _owner2) internal {
require(_owner1 != address(0));
owner1 = _owner1;
require(_owner2 != address(0));
owner2 = _owner2;
}
modifier onlySuperOwner1() {
require(msg.sender == owner1);
_;
}
modifier onlySuperOwner2() {
require(msg.sender == owner2);
_;
}
modifier onlySuperOwner() {
require(isSuperOwner(msg.sender));
_;
}
function isSuperOwner(address _addr) public view returns (bool) {
return _addr == owner1 || _addr == owner2;
}
function transferOwnership1(address _newOwner1) onlySuperOwner1 public {
pendingOwner1 = _newOwner1;
}
function transferOwnership2(address _newOwner2) onlySuperOwner2 public {
pendingOwner2 = _newOwner2;
}
function claimOwnership1() public {
require(msg.sender == pendingOwner1);
owner1 = pendingOwner1;
pendingOwner1 = address(0);
}
function claimOwnership2() public {
require(msg.sender == pendingOwner2);
owner2 = pendingOwner2;
pendingOwner2 = address(0);
}
}
contract MultiOwnable is SuperOwners {
mapping (address => bool) public ownerMap;
address[] public ownerHistory;
event OwnerAddedEvent(address indexed _newOwner);
event OwnerRemovedEvent(address indexed _oldOwner);
function MultiOwnable(address _owner1, address _owner2)
SuperOwners(_owner1, _owner2) internal {}
modifier onlyOwner() {
require(isOwner(msg.sender));
_;
}
function isOwner(address owner) public view returns (bool) {
return isSuperOwner(owner) || ownerMap[owner];
}
function ownerHistoryCount() public view returns (uint) {
return ownerHistory.length;
}
function addOwner(address owner) onlySuperOwner public {
require(owner != address(0));
require(!ownerMap[owner]);
ownerMap[owner] = true;
ownerHistory.push(owner);
OwnerAddedEvent(owner);
}
function removeOwner(address owner) onlySuperOwner public {
require(ownerMap[owner]);
ownerMap[owner] = false;
OwnerRemovedEvent(owner);
}
}
contract Pausable is MultiOwnable {
bool public paused;
modifier ifNotPaused {
require(!paused);
_;
}
modifier ifPaused {
require(paused);
_;
}
function pause() external onlySuperOwner {
paused = true;
}
function resume() external onlySuperOwner ifPaused {
paused = false;
}
}
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is ERC20 {
using SafeMath for uint;
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value > 0);
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value > 0);
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract CommonToken is StandardToken, MultiOwnable {
string public name;
string public symbol;
uint256 public totalSupply;
uint8 public decimals = 18;
string public version = 'v0.1';
address public seller;
uint256 public saleLimit;
uint256 public tokensSold;
uint256 public totalSales;
bool public locked = true;
event SellEvent(address indexed _seller, address indexed _buyer, uint256 _value);
event ChangeSellerEvent(address indexed _oldSeller, address indexed _newSeller);
event Burn(address indexed _burner, uint256 _value);
event Unlock();
function CommonToken(
address _owner1,
address _owner2,
address _seller,
string _name,
string _symbol,
uint256 _totalSupplyNoDecimals,
uint256 _saleLimitNoDecimals
) MultiOwnable(_owner1, _owner2) public {
require(_seller != address(0));
require(_totalSupplyNoDecimals > 0);
require(_saleLimitNoDecimals > 0);
seller = _seller;
name = _name;
symbol = _symbol;
totalSupply = _totalSupplyNoDecimals * 1e18;
saleLimit = _saleLimitNoDecimals * 1e18;
balances[seller] = totalSupply;
Transfer(0x0, seller, totalSupply);
}
modifier ifUnlocked(address _from, address _to) {
require(!locked || isOwner(_from) || isOwner(_to));
_;
}
function unlock() onlySuperOwner public {
require(locked);
locked = false;
Unlock();
}
function changeSeller(address newSeller) onlySuperOwner public returns (bool) {
require(newSeller != address(0));
require(seller != newSeller);
address oldSeller = seller;
uint256 unsoldTokens = balances[oldSeller];
balances[oldSeller] = 0;
balances[newSeller] = balances[newSeller].add(unsoldTokens);
Transfer(oldSeller, newSeller, unsoldTokens);
seller = newSeller;
ChangeSellerEvent(oldSeller, newSeller);
return true;
}
function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
return sell(_to, _value * 1e18);
}
function sell(address _to, uint256 _value) onlyOwner public returns (bool) {
require(tokensSold.add(_value) <= saleLimit);
require(_to != address(0));
require(_value > 0);
require(_value <= balances[seller]);
balances[seller] = balances[seller].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(seller, _to, _value);
totalSales++;
tokensSold = tokensSold.add(_value);
SellEvent(seller, _to, _value);
return true;
}
function transfer(address _to, uint256 _value) ifUnlocked(msg.sender, _to) public returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) ifUnlocked(_from, _to) public returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function burn(uint256 _value) public returns (bool) {
require(_value > 0);
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value) ;
totalSupply = totalSupply.sub(_value);
Transfer(msg.sender, 0x0, _value);
Burn(msg.sender, _value);
return true;
}
}
contract RaceToken is CommonToken {
function RaceToken() CommonToken(
0x229B9Ef80D25A7e7648b17e2c598805d042f9e56,
0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7,
0x2821e1486D604566842FF27F626aF133FddD5f89,
'Coin Race',
'RACE',
100 * 1e6,
70 * 1e6
) public {}
}
library RaceCalc {
using SafeMath for uint;
function calcStake(
uint _currentTime,
uint _finishTime
) public pure returns (uint) {
require(_currentTime > 0);
require(_currentTime < _finishTime);
return _finishTime.sub(_currentTime);
}
function calcGainE8(
uint _startRateToUsdE8,
uint _finishRateToUsdE8
) public pure returns (int) {
require(_startRateToUsdE8 > 0);
require(_finishRateToUsdE8 > 0);
int diff = int(_finishRateToUsdE8) - int(_startRateToUsdE8);
return (diff * 1e8) / int(_startRateToUsdE8);
}
function calcPrizeTokensE18(
uint totalTokens,
uint winningStake,
uint driverStake
) public pure returns (uint) {
if (totalTokens == 0) return 0;
if (winningStake == 0) return 0;
if (driverStake == 0) return 0;
if (winningStake == driverStake) return totalTokens;
require(winningStake > driverStake);
uint share = driverStake.mul(1e8).div(winningStake);
return totalTokens.mul(share).div(1e8);
}
}
contract CommonWallet is MultiOwnable {
RaceToken public token;
event ChangeTokenEvent(address indexed _oldAddress, address indexed _newAddress);
function CommonWallet(address _owner1, address _owner2)
MultiOwnable(_owner1, _owner2) public {}
function setToken(address _token) public onlySuperOwner {
require(_token != 0);
require(_token != address(token));
ChangeTokenEvent(token, _token);
token = RaceToken(_token);
}
function transfer(address _to, uint256 _value) onlyOwner public returns (bool) {
return token.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
return token.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) onlyOwner public returns (bool) {
return token.approve(_spender, _value);
}
function burn(uint256 _value) onlySuperOwner public returns (bool) {
return token.burn(_value);
}
function balance() public view returns (uint256) {
return token.balanceOf(this);
}
function balanceOf(address _owner) public view returns (uint256) {
return token.balanceOf(_owner);
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return token.allowance(_owner, _spender);
}
}
contract GameWallet is CommonWallet {
function GameWallet() CommonWallet(
0x229B9Ef80D25A7e7648b17e2c598805d042f9e56,
0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7
) public {}
}
library RaceLib {
using SafeMath for uint;
function makeBet(
Race storage _race,
address _driver,
address _car,
uint _tokensE18
) public {
require(!isFinished(_race));
var bet = Bet({
driver: _driver,
car: _car,
tokens: _tokensE18,
time: now
});
_race.betsByDriver[_driver].push(bet);
_race.betsByCar[_car].push(bet);
if (_race.tokensByCarAndDriver[_car][_driver] == 0) {
_race.driverCountByCar[_car] = _race.driverCountByCar[_car] + 1;
}
_race.tokensByCar[_car] = _race.tokensByCar[_car].add(_tokensE18);
_race.tokensByCarAndDriver[_car][_driver] =
_race.tokensByCarAndDriver[_car][_driver].add(_tokensE18);
uint stakeTime = bet.time;
if (bet.time < _race.leftGraceTime && _race.leftGraceTime > 0) stakeTime = _race.leftGraceTime;
if (bet.time > _race.rightGraceTime && _race.rightGraceTime > 0) stakeTime = _race.rightGraceTime;
uint stake = RaceCalc.calcStake(stakeTime, _race.finishTime);
_race.stakeByCar[_car] = _race.stakeByCar[_car].add(stake);
_race.stakeByCarAndDriver[_car][_driver] =
_race.stakeByCarAndDriver[_car][_driver].add(stake);
_race.totalTokens = _race.totalTokens.add(_tokensE18);
}
function hasDriverJoined(
Race storage _race,
address _driver
) public view returns (bool) {
return betCountByDriver(_race, _driver) > 0;
}
function betCountByDriver(
Race storage _race,
address _driver
) public view returns (uint) {
return _race.betsByDriver[_driver].length;
}
function betCountByCar(
Race storage _race,
address _car
) public view returns (uint) {
return _race.betsByCar[_car].length;
}
function startCar(
Race storage _race,
address _car,
uint _rateToUsdE8
) public {
require(_rateToUsdE8 > 0);
require(_race.carRates[_car].startRateToUsdE8 == 0);
_race.carRates[_car].startRateToUsdE8 = _rateToUsdE8;
}
function finish(
Race storage _race
) public {
require(!_race.finished);
require(now >= _race.finishTime);
_race.finished = true;
}
function isFinished(
Race storage _race
) public view returns (bool) {
return _race.finished;
}
struct Race {
uint id;
uint leftGraceTime;
uint rightGraceTime;
uint startTime;
uint finishTime;
bool finished;
uint finishedCarCount;
address firstCar;
uint totalTokens;
uint driverCount;
mapping (uint => address) drivers;
mapping (address => uint) driverCountByCar;
mapping (address => Bet[]) betsByDriver;
mapping (address => Bet[]) betsByCar;
mapping (address => uint) tokensByCar;
mapping (address => mapping (address => uint)) tokensByCarAndDriver;
mapping (address => uint) stakeByCar;
mapping (address => mapping (address => uint)) stakeByCarAndDriver;
mapping (address => CarRates) carRates;
mapping (address => int) gainByCar;
mapping (address => bool) isFinishedCar;
mapping (address => uint) tokensClaimedByDriver;
}
struct Bet {
address driver;
address car;
uint tokens;
uint time;
}
struct CarRates {
uint startRateToUsdE8;
uint finishRateToUsdE8;
}
}
contract CommonRace is MultiOwnable {
using SafeMath for uint;
using RaceLib for RaceLib.Race;
GameWallet public wallet;
string public name;
address[] public cars;
mapping (address => bool) public isKnownCar;
RaceLib.Race[] public races;
address[] public drivers;
mapping (address => bool) public isKnownDriver;
modifier ifWalletDefined() {
require(address(wallet) != address(0));
_;
}
function CommonRace(
address _owner1,
address _owner2,
address[] _cars,
string _name
) MultiOwnable(_owner1, _owner2) public {
require(_cars.length > 0);
name = _name;
cars = _cars;
for (uint16 i = 0; i < _cars.length; i++) {
isKnownCar[_cars[i]] = true;
}
}
function getNow() public view returns (uint) {
return now;
}
function raceCount() public view returns (uint) {
return races.length;
}
function carCount() public view returns (uint) {
return cars.length;
}
function driverCount() public view returns (uint) {
return drivers.length;
}
function setWallet(address _newWallet) onlySuperOwner public {
require(wallet != _newWallet);
require(_newWallet != 0);
GameWallet newWallet = GameWallet(_newWallet);
wallet = newWallet;
}
function lastLapId() public view returns (uint) {
require(races.length > 0);
return races.length - 1;
}
function nextLapId() public view returns (uint) {
return races.length;
}
function getRace(uint _lapId) internal view returns (RaceLib.Race storage race) {
race = races[_lapId];
require(race.startTime > 0);
}
function startNewRace(
uint _newLapId,
uint[] _carsAndRates,
uint _durationSecs,
uint _leftGraceSecs,
uint _rightGraceSecs
) onlyOwner public {
require(_newLapId == nextLapId());
require(_carsAndRates.length == (cars.length * 2));
require(_durationSecs > 0);
if (_leftGraceSecs > 0) require(_leftGraceSecs <= _durationSecs);
if (_rightGraceSecs > 0) require(_rightGraceSecs <= _durationSecs);
uint finishTime = now.add(_durationSecs);
races.push(RaceLib.Race({
id: _newLapId,
leftGraceTime: now + _leftGraceSecs,
rightGraceTime: finishTime - _rightGraceSecs,
startTime: now,
finishTime: finishTime,
finished: false,
finishedCarCount: 0,
firstCar: 0,
totalTokens: 0,
driverCount: 0
}));
RaceLib.Race storage race = races[_newLapId];
uint8 j = 0;
for (uint8 i = 0; i < _carsAndRates.length; i += 2) {
address car = address(_carsAndRates[j++]);
uint startRateToUsdE8 = _carsAndRates[j++];
require(isKnownCar[car]);
race.startCar(car, startRateToUsdE8);
}
}
function finishRace(
uint _lapId,
uint[] _carsAndRates
) onlyOwner public {
require(_carsAndRates.length == (cars.length * 2));
RaceLib.Race storage race = getRace(_lapId);
race.finish();
int maxGain = 0;
address firstCar;
uint8 j = 0;
for (uint8 i = 0; i < _carsAndRates.length; i += 2) {
address car = address(_carsAndRates[j++]);
uint finishRateToUsdE8 = _carsAndRates[j++];
require(!isCarFinished(_lapId, car));
RaceLib.CarRates storage rates = race.carRates[car];
rates.finishRateToUsdE8 = finishRateToUsdE8;
race.isFinishedCar[car] = true;
race.finishedCarCount++;
int gain = RaceCalc.calcGainE8(rates.startRateToUsdE8, finishRateToUsdE8);
race.gainByCar[car] = gain;
if (i == 0 || gain > maxGain) {
maxGain = gain;
firstCar = car;
}
}
require(firstCar != 0);
race.firstCar = firstCar;
}
function finishRaceThenStartNext(
uint _lapId,
uint[] _carsAndRates,
uint _durationSecs,
uint _leftGraceSecs,
uint _rightGraceSecs
) onlyOwner public {
finishRace(_lapId, _carsAndRates);
startNewRace(_lapId + 1, _carsAndRates, _durationSecs, _leftGraceSecs, _rightGraceSecs);
}
function isLastRaceFinsihed() public view returns (bool) {
return isLapFinished(lastLapId());
}
function isLapFinished(
uint _lapId
) public view returns (bool) {
return getRace(_lapId).isFinished();
}
function lapStartTime(
uint _lapId
) public view returns (uint) {
return getRace(_lapId).startTime;
}
function lapFinishTime(
uint _lapId
) public view returns (uint) {
return getRace(_lapId).finishTime;
}
function isCarFinished(
uint _lapId,
address _car
) public view returns (bool) {
require(isKnownCar[_car]);
return getRace(_lapId).isFinishedCar[_car];
}
function allCarsFinished(
uint _lapId
) public view returns (bool) {
return finishedCarCount(_lapId) == cars.length;
}
function finishedCarCount(
uint _lapId
) public view returns (uint) {
return getRace(_lapId).finishedCarCount;
}
function firstCar(
uint _lapId
) public view returns (address) {
return getRace(_lapId).firstCar;
}
function isWinningDriver(
uint _lapId,
address _driver
) public view returns (bool) {
RaceLib.Race storage race = getRace(_lapId);
return race.tokensByCarAndDriver[race.firstCar][_driver] > 0;
}
function myUnclaimedTokens(
uint _lapId
) public view returns (uint) {
return unclaimedTokens(_lapId, msg.sender);
}
function unclaimedTokens(
uint _lapId,
address _driver
) public view returns (uint) {
RaceLib.Race storage race = getRace(_lapId);
if (race.tokensClaimedByDriver[_driver] > 0) return 0;
if (!race.isFinished()) return 0;
if (race.firstCar == 0) return 0;
if (race.totalTokens == 0) return 0;
if (race.stakeByCar[race.firstCar] == 0) return 0;
uint driverStake = race.stakeByCarAndDriver[race.firstCar][_driver];
if (driverStake == 0) return 0;
return RaceCalc.calcPrizeTokensE18(
race.totalTokens,
race.stakeByCar[race.firstCar],
driverStake
);
}
function claimTokens(
uint _lapId
) public ifWalletDefined {
address driver = msg.sender;
uint tokens = unclaimedTokens(_lapId, driver);
require(tokens > 0);
require(wallet.transfer(driver, tokens));
getRace(_lapId).tokensClaimedByDriver[driver] = tokens;
}
function makeBet(
uint _lapId,
address _car,
uint _tokensE18
) public ifWalletDefined {
address driver = msg.sender;
require(isKnownCar[_car]);
require(wallet.transferFrom(msg.sender, wallet, _tokensE18));
getRace(_lapId).makeBet(driver, _car, _tokensE18);
if (!isKnownDriver[driver]) {
isKnownDriver[driver] = true;
drivers.push(driver);
}
}
function myBetsInLap(
uint _lapId
) public view returns (uint[] memory totals) {
RaceLib.Race storage race = getRace(_lapId);
totals = new uint[](cars.length * 2);
uint8 j = 0;
address car;
for (uint8 i = 0; i < cars.length; i++) {
car = cars[i];
totals[j++] = uint(car);
totals[j++] = race.tokensByCarAndDriver[car][msg.sender];
}
}
function lapTotals(
uint _lapId
) public view returns (int[] memory totals) {
RaceLib.Race storage race = getRace(_lapId);
totals = new int[](5 + cars.length * 7);
uint _myUnclaimedTokens = 0;
if (isLapFinished(_lapId)) {
_myUnclaimedTokens = unclaimedTokens(_lapId, msg.sender);
}
address car;
uint8 j = 0;
totals[j++] = int(now);
totals[j++] = int(race.startTime);
totals[j++] = int(race.finishTime - race.startTime);
totals[j++] = int(race.firstCar);
totals[j++] = int(_myUnclaimedTokens);
for (uint8 i = 0; i < cars.length; i++) {
car = cars[i];
totals[j++] = int(car);
totals[j++] = int(race.carRates[car].startRateToUsdE8);
totals[j++] = int(race.carRates[car].finishRateToUsdE8);
totals[j++] = int(race.driverCountByCar[car]);
totals[j++] = int(race.tokensByCar[car]);
totals[j++] = int(race.tokensByCarAndDriver[car][msg.sender]);
totals[j++] = race.gainByCar[car];
}
}
}
contract RaceOldSchool4h is CommonRace, CoinLib {
function RaceOldSchool4h() CommonRace(
0x229B9Ef80D25A7e7648b17e2c598805d042f9e56,
0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7,
oldSchool,
'Old School'
) public {}
}
contract RaceBtcForks4h is CommonRace, CoinLib {
function RaceBtcForks4h() CommonRace(
0x229B9Ef80D25A7e7648b17e2c598805d042f9e56,
0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7,
btcForks,
'Bitcoin Forks'
) public {}
}
contract RaceSmart4h is CommonRace, CoinLib {
function RaceSmart4h() CommonRace(
0x229B9Ef80D25A7e7648b17e2c598805d042f9e56,
0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7,
smart,
'Smart Coins'
) public {}
}
contract RaceAnons4h is CommonRace, CoinLib {
function RaceAnons4h() CommonRace(
0x229B9Ef80D25A7e7648b17e2c598805d042f9e56,
0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7,
anons,
'Anonymouses'
) public {}
}