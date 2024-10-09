pragma solidity 0.4.24;
contract ERC677Receiver {
function onTokenTransfer(address _from, uint _value, bytes _data) external returns(bool);
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
contract ERC677 is ERC20 {
event Transfer(address indexed from, address indexed to, uint value, bytes data);
function transferAndCall(address, uint, bytes) external returns (bool);
}
contract IBurnableMintableERC677Token is ERC677 {
function mint(address, uint256) public returns (bool);
function burn(uint256 _value) public;
function claimTokens(address _token, address _to) public;
}
interface IBridgeValidators {
function isValidator(address _validator) public view returns(bool);
function requiredSignatures() public view returns(uint256);
function owner() public view returns(address);
}
library Message {
function addressArrayContains(address[] array, address value) internal pure returns (bool) {
for (uint256 i = 0; i < array.length; i++) {
if (array[i] == value) {
return true;
}
}
return false;
}
function parseMessage(bytes message)
internal
pure
returns(address recipient, uint256 amount, bytes32 txHash, address contractAddress)
{
require(isMessageValid(message));
assembly {
recipient := and(mload(add(message, 20)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
amount := mload(add(message, 52))
txHash := mload(add(message, 84))
contractAddress := mload(add(message, 104))
}
}
function isMessageValid(bytes _msg) internal pure returns(bool) {
return _msg.length == requiredMessageLength();
}
function requiredMessageLength() internal pure returns(uint256) {
return 104;
}
function recoverAddressFromSignedMessage(bytes signature, bytes message) internal pure returns (address) {
require(signature.length == 65);
bytes32 r;
bytes32 s;
bytes1 v;
assembly {
r := mload(add(signature, 0x20))
s := mload(add(signature, 0x40))
v := mload(add(signature, 0x60))
}
return ecrecover(hashMessage(message), uint8(v), r, s);
}
function hashMessage(bytes message) internal pure returns (bytes32) {
bytes memory prefix = "\x19Ethereum Signed Message:\n";
string memory msgLength = "104";
return keccak256(abi.encodePacked(prefix, msgLength, message));
}
function hasEnoughValidSignatures(
bytes _message,
uint8[] _vs,
bytes32[] _rs,
bytes32[] _ss,
IBridgeValidators _validatorContract) internal view {
require(isMessageValid(_message));
uint256 requiredSignatures = _validatorContract.requiredSignatures();
require(_vs.length >= requiredSignatures);
bytes32 hash = hashMessage(_message);
address[] memory encounteredAddresses = new address[](requiredSignatures);
for (uint256 i = 0; i < requiredSignatures; i++) {
address recoveredAddress = ecrecover(hash, _vs[i], _rs[i], _ss[i]);
require(_validatorContract.isValidator(recoveredAddress));
if (addressArrayContains(encounteredAddresses, recoveredAddress)) {
revert();
}
encounteredAddresses[i] = recoveredAddress;
}
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
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
contract EternalStorage {
mapping(bytes32 => uint256) internal uintStorage;
mapping(bytes32 => string) internal stringStorage;
mapping(bytes32 => address) internal addressStorage;
mapping(bytes32 => bytes) internal bytesStorage;
mapping(bytes32 => bool) internal boolStorage;
mapping(bytes32 => int256) internal intStorage;
}
contract Validatable is EternalStorage {
function validatorContract() public view returns(IBridgeValidators) {
return IBridgeValidators(addressStorage[keccak256(abi.encodePacked("validatorContract"))]);
}
modifier onlyValidator() {
require(validatorContract().isValidator(msg.sender));
_;
}
modifier onlyOwner() {
require(validatorContract().owner() == msg.sender);
_;
}
function requiredSignatures() public view returns(uint256) {
return validatorContract().requiredSignatures();
}
}
contract BasicBridge is EternalStorage, Validatable {
using SafeMath for uint256;
event GasPriceChanged(uint256 gasPrice);
event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);
event DailyLimitChanged(uint256 newLimit);
function setGasPrice(uint256 _gasPrice) public onlyOwner {
require(_gasPrice > 0);
uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;
emit GasPriceChanged(_gasPrice);
}
function gasPrice() public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("gasPrice"))];
}
function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {
require(_blockConfirmations > 0);
uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _blockConfirmations;
emit RequiredBlockConfirmationChanged(_blockConfirmations);
}
function requiredBlockConfirmations() public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))];
}
function deployedAtBlock() public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))];
}
function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {
uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = _value;
}
function totalSpentPerDay(uint256 _day) public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))];
}
function minPerTx() public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("minPerTx"))];
}
function maxPerTx() public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("maxPerTx"))];
}
function setInitialize(bool _status) internal {
boolStorage[keccak256(abi.encodePacked("isInitialized"))] = _status;
}
function isInitialized() public view returns(bool) {
return boolStorage[keccak256(abi.encodePacked("isInitialized"))];
}
function getCurrentDay() public view returns(uint256) {
return now / 1 days;
}
function setDailyLimit(uint256 _dailyLimit) public onlyOwner {
uintStorage[keccak256(abi.encodePacked("dailyLimit"))] = _dailyLimit;
emit DailyLimitChanged(_dailyLimit);
}
function dailyLimit() public view returns(uint256) {
return uintStorage[keccak256(abi.encodePacked("dailyLimit"))];
}
function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {
require(_maxPerTx < dailyLimit());
uintStorage[keccak256(abi.encodePacked("maxPerTx"))] = _maxPerTx;
}
function setMinPerTx(uint256 _minPerTx) external onlyOwner {
require(_minPerTx < dailyLimit() && _minPerTx < maxPerTx());
uintStorage[keccak256(abi.encodePacked("minPerTx"))] = _minPerTx;
}
function withinLimit(uint256 _amount) public view returns(bool) {
uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
}
function claimTokens(address _token, address _to) public onlyOwner {
require(_to != address(0));
if (_token == address(0)) {
_to.transfer(address(this).balance);
return;
}
ERC20Basic token = ERC20Basic(_token);
uint256 balance = token.balanceOf(this);
require(token.transfer(_to, balance));
}
}
contract BasicForeignBridge is EternalStorage, Validatable {
using SafeMath for uint256;
event RelayedMessage(address recipient, uint value, bytes32 transactionHash);
function executeSignatures(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {
Message.hasEnoughValidSignatures(message, vs, rs, ss, validatorContract());
address recipient;
uint256 amount;
bytes32 txHash;
address contractAddress;
(recipient, amount, txHash, contractAddress) = Message.parseMessage(message);
require(contractAddress == address(this));
require(!relayedMessages(txHash));
setRelayedMessages(txHash, true);
require(onExecuteMessage(recipient, amount));
emit RelayedMessage(recipient, amount, txHash);
}
function onExecuteMessage(address, uint256) internal returns(bool){
}
function setRelayedMessages(bytes32 _txHash, bool _status) internal {
boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))] = _status;
}
function relayedMessages(bytes32 _txHash) public view returns(bool) {
return boolStorage[keccak256(abi.encodePacked("relayedMessages", _txHash))];
}
}
contract ForeignBridgeErcToErc is BasicBridge, BasicForeignBridge {
event RelayedMessage(address recipient, uint value, bytes32 transactionHash);
function initialize(
address _validatorContract,
address _erc20token
) public returns(bool) {
require(!isInitialized());
require(_validatorContract != address(0));
addressStorage[keccak256(abi.encodePacked("validatorContract"))] = _validatorContract;
setErc20token(_erc20token);
uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))] = block.number;
setInitialize(true);
return isInitialized();
}
function claimTokens(address _token, address _to) public onlyOwner {
require(_token != address(erc20token()));
super.claimTokens(_token, _to);
}
function erc20token() public view returns(ERC20Basic) {
return ERC20Basic(addressStorage[keccak256(abi.encodePacked("erc20token"))]);
}
function onExecuteMessage(address _recipient, uint256 _amount) internal returns(bool){
return erc20token().transfer(_recipient, _amount);
}
function setErc20token(address _token) private {
require(_token != address(0));
addressStorage[keccak256(abi.encodePacked("erc20token"))] = _token;
}
}