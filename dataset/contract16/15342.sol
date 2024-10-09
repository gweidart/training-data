pragma solidity 0.4.23;
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
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
returns(address recipient, uint256 amount, bytes32 txHash)
{
require(isMessageValid(message));
assembly {
recipient := and(mload(add(message, 20)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
amount := mload(add(message, 52))
txHash := mload(add(message, 84))
}
}
function isMessageValid(bytes _msg) internal pure returns(bool) {
return _msg.length == 116;
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
string memory msgLength = "116";
return keccak256(prefix, msgLength, message);
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
contract BasicBridge is EternalStorage {
event GasPriceChanged(uint256 gasPrice);
event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);
function validatorContract() public view returns(IBridgeValidators) {
return IBridgeValidators(addressStorage[keccak256("validatorContract")]);
}
modifier onlyValidator() {
require(validatorContract().isValidator(msg.sender));
_;
}
modifier onlyOwner() {
require(validatorContract().owner() == msg.sender);
_;
}
function setGasPrice(uint256 _gasPrice) public onlyOwner {
require(_gasPrice > 0);
uintStorage[keccak256("gasPrice")] = _gasPrice;
emit GasPriceChanged(_gasPrice);
}
function gasPrice() public view returns(uint256) {
return uintStorage[keccak256("gasPrice")];
}
function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {
require(_blockConfirmations > 0);
uintStorage[keccak256("requiredBlockConfirmations")] = _blockConfirmations;
emit RequiredBlockConfirmationChanged(_blockConfirmations);
}
function requiredBlockConfirmations() public view returns(uint256) {
return uintStorage[keccak256("requiredBlockConfirmations")];
}
}
contract ForeignBridge is ERC677Receiver, BasicBridge {
using SafeMath for uint256;
event Deposit(address recipient, uint value, bytes32 transactionHash);
event Withdraw(address recipient, uint256 value, uint256 homeGasPrice);
event CollectedSignatures(address authorityResponsibleForRelay, bytes32 messageHash);
event GasConsumptionLimitsUpdated(uint256 gasLimitDepositRelay, uint256 gasLimitWithdrawConfirm);
event SignedForDeposit(address indexed signer, bytes32 transactionHash);
event SignedForWithdraw(address indexed signer, bytes32 messageHash);
event DailyLimit(uint256 newLimit);
function initialize(
address _validatorContract,
address _erc677token,
uint256 _foreignDailyLimit,
uint256 _maxPerTx,
uint256 _minPerTx,
uint256 _foreignGasPrice,
uint256 _requiredBlockConfirmations
) public returns(bool) {
require(!isInitialized());
require(_validatorContract != address(0));
require(_minPerTx > 0 && _maxPerTx > _minPerTx && _foreignDailyLimit > _maxPerTx);
require(_foreignGasPrice > 0);
addressStorage[keccak256("validatorContract")] = _validatorContract;
setErc677token(_erc677token);
uintStorage[keccak256("foreignDailyLimit")] = _foreignDailyLimit;
uintStorage[keccak256("deployedAtBlock")] = block.number;
uintStorage[keccak256("maxPerTx")] = _maxPerTx;
uintStorage[keccak256("minPerTx")] = _minPerTx;
uintStorage[keccak256("gasPrice")] = _foreignGasPrice;
uintStorage[keccak256("requiredBlockConfirmations")] = _requiredBlockConfirmations;
setInitialize(true);
return isInitialized();
}
require(msg.sender == address(erc677token()));
require(withinLimit(_value));
setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_value));
erc677token().burn(_value);
emit Withdraw(_from, _value, gasPriceForCompensationAtHomeSide());
return true;
}
function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {
require(_maxPerTx < foreignDailyLimit());
uintStorage[keccak256("maxPerTx")] = _maxPerTx;
}
function setMinPerTx(uint256 _minPerTx) external onlyOwner {
require(_minPerTx < foreignDailyLimit() && _minPerTx < maxPerTx());
uintStorage[keccak256("minPerTx")] = _minPerTx;
}
function claimTokens(address _token, address _to) external onlyOwner {
require(_to != address(0));
if (_token == address(0)) {
_to.transfer(address(this).balance);
return;
}
ERC20Basic token = ERC20Basic(_token);
uint256 balance = token.balanceOf(this);
require(token.transfer(_to, balance));
}
function claimTokensFromErc677(address _token, address _to) external onlyOwner {
erc677token().claimTokens(_token, _to);
}
function minPerTx() public view returns(uint256) {
return uintStorage[keccak256("minPerTx")];
}
function maxPerTx() public view returns(uint256) {
return uintStorage[keccak256("maxPerTx")];
}
function totalSpentPerDay(uint256 _day) public view returns(uint256) {
return uintStorage[keccak256("totalSpentPerDay", _day)];
}
function deployedAtBlock() public view returns(uint256) {
return uintStorage[keccak256("deployedAtBlock")];
}
function gasLimitDepositRelay() public view returns(uint256) {
return uintStorage[keccak256("gasLimitDepositRelay")];
}
function gasLimitWithdrawConfirm() public view returns(uint256) {
return uintStorage[keccak256("gasLimitWithdrawConfirm")];
}
function foreignDailyLimit() public view returns(uint256) {
return uintStorage[keccak256("foreignDailyLimit")];
}
function erc677token() public view returns(IBurnableMintableERC677Token) {
return IBurnableMintableERC677Token(addressStorage[keccak256("erc677token")]);
}
function setGasLimits(uint256 _gasLimitDepositRelay, uint256 _gasLimitWithdrawConfirm) external onlyOwner {
uintStorage[keccak256("gasLimitDepositRelay")] = _gasLimitDepositRelay;
uintStorage[keccak256("gasLimitWithdrawConfirm")] = _gasLimitWithdrawConfirm;
emit GasConsumptionLimitsUpdated(gasLimitDepositRelay(), gasLimitWithdrawConfirm());
}
function deposit(address recipient, uint256 value, bytes32 transactionHash) external onlyValidator {
bytes32 hashMsg = keccak256(recipient, value, transactionHash);
bytes32 hashSender = keccak256(msg.sender, hashMsg);
require(!depositsSigned(hashSender));
setDepositsSigned(hashSender, true);
uint256 signed = numDepositsSigned(hashMsg);
require(!isAlreadyProcessed(signed));
signed = signed + 1;
setNumDepositsSigned(hashMsg, signed);
emit SignedForDeposit(msg.sender, transactionHash);
if (signed >= validatorContract().requiredSignatures()) {
setNumDepositsSigned(hashMsg, markAsProcessed(signed));
erc677token().mint(recipient, value);
emit Deposit(recipient, value, transactionHash);
}
}
function submitSignature(bytes signature, bytes message) external onlyValidator {
require(Message.isMessageValid(message));
require(msg.sender == Message.recoverAddressFromSignedMessage(signature, message));
bytes32 hashMsg = keccak256(message);
bytes32 hashSender = keccak256(msg.sender, hashMsg);
uint256 signed = numMessagesSigned(hashMsg);
require(!isAlreadyProcessed(signed));
signed = signed + 1;
if (signed > 1) {
require(!messagesSigned(hashSender));
} else {
setMessages(hashMsg, message);
}
setMessagesSigned(hashSender, true);
bytes32 signIdx = keccak256(hashMsg, (signed-1));
setSignatures(signIdx, signature);
setNumMessagesSigned(hashMsg, signed);
emit SignedForWithdraw(msg.sender, hashMsg);
if (signed >= validatorContract().requiredSignatures()) {
setNumMessagesSigned(hashMsg, markAsProcessed(signed));
emit CollectedSignatures(msg.sender, hashMsg);
}
}
function gasPriceForCompensationAtHomeSide() public pure returns(uint256) {
return 1000000000 wei;
}
function isAlreadyProcessed(uint256 _number) public pure returns(bool) {
return _number & 2**255 == 2**255;
}
function signature(bytes32 _hash, uint256 _index) public view returns (bytes) {
bytes32 signIdx = keccak256(_hash, _index);
return signatures(signIdx);
}
function message(bytes32 _hash) public view returns (bytes) {
return messages(_hash);
}
function getCurrentDay() public view returns(uint256) {
return now / 1 days;
}
function setForeignDailyLimit(uint256 _foreignDailyLimit) public onlyOwner {
uintStorage[keccak256("foreignDailyLimit")] = _foreignDailyLimit;
emit DailyLimit(_foreignDailyLimit);
}
function withinLimit(uint256 _amount) public view returns(bool) {
uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
return foreignDailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
}
function isInitialized() public view returns(bool) {
return boolStorage[keccak256("isInitialized")];
}
function messages(bytes32 _hash) private view returns(bytes) {
return bytesStorage[keccak256("messages", _hash)];
}
function setMessages(bytes32 _hash, bytes _message) private {
bytesStorage[keccak256("messages", _hash)] = _message;
}
function signatures(bytes32 _hash) private view returns(bytes) {
return bytesStorage[keccak256("signatures", _hash)];
}
function setSignatures(bytes32 _hash, bytes _signature) private {
bytesStorage[keccak256("signatures", _hash)] = _signature;
}
function messagesSigned(bytes32 _message) public view returns(bool) {
return boolStorage[keccak256("messagesSigned", _message)];
}
function depositsSigned(bytes32 _deposit) public view returns(bool) {
return boolStorage[keccak256("depositsSigned", _deposit)];
}
function markAsProcessed(uint256 _v) private pure returns(uint256) {
return _v | 2 ** 255;
}
function numMessagesSigned(bytes32 _message) private view returns(uint256) {
return uintStorage[keccak256("numMessagesSigned", _message)];
}
function numDepositsSigned(bytes32 _deposit) private view returns(uint256) {
return uintStorage[keccak256("numDepositsSigned", _deposit)];
}
function setMessagesSigned(bytes32 _hash, bool _status) private {
boolStorage[keccak256("messagesSigned", _hash)] = _status;
}
function setDepositsSigned(bytes32 _deposit, bool _status) private {
boolStorage[keccak256("depositsSigned", _deposit)] = _status;
}
function setNumMessagesSigned(bytes32 _message, uint256 _number) private {
uintStorage[keccak256("numMessagesSigned", _message)] = _number;
}
function setNumDepositsSigned(bytes32 _deposit, uint256 _number) private {
uintStorage[keccak256("numDepositsSigned", _deposit)] = _number;
}
function setTotalSpentPerDay(uint256 _day, uint256 _value) private {
uintStorage[keccak256("totalSpentPerDay", _day)] = _value;
}
function setErc677token(address _token) private {
require(_token != address(0));
addressStorage[keccak256("erc677token")] = _token;
}
function setInitialize(bool _status) private {
boolStorage[keccak256("isInitialized")] = _status;
}
}