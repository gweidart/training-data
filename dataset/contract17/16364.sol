pragma solidity 0.4.18;
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
library MathUtils {
using SafeMath for uint256;
uint256 public constant PERC_DIVISOR = 1000000;
function validPerc(uint256 _amount) internal pure returns (bool) {
return _amount <= PERC_DIVISOR;
}
function percOf(uint256 _amount, uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {
return _amount.mul(percPoints(_fracNum, _fracDenom)).div(PERC_DIVISOR);
}
function percOf(uint256 _amount, uint256 _fracNum) internal pure returns (uint256) {
return _amount.mul(_fracNum).div(PERC_DIVISOR);
}
function percPoints(uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {
return _fracNum.mul(PERC_DIVISOR).div(_fracDenom);
}
}
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
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract IController is Pausable {
event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);
function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
function updateController(bytes32 _id, address _controller) external;
function getContract(bytes32 _id) public view returns (address);
}
contract IManager {
event SetController(address controller);
event ParameterUpdate(string param);
function setController(address _controller) external;
}
contract Manager is IManager {
IController public controller;
modifier onlyController() {
require(msg.sender == address(controller));
_;
}
modifier onlyControllerOwner() {
require(msg.sender == controller.owner());
_;
}
modifier whenSystemNotPaused() {
require(!controller.paused());
_;
}
modifier whenSystemPaused() {
require(controller.paused());
_;
}
function Manager(address _controller) public {
controller = IController(_controller);
}
function setController(address _controller) external onlyController {
controller = IController(_controller);
SetController(_controller);
}
}
contract ManagerProxyTarget is Manager {
bytes32 public targetContractId;
}
contract IMinter {
event SetCurrentRewardTokens(uint256 currentMintableTokens, uint256 currentInflation);
function createReward(uint256 _fracNum, uint256 _fracDenom) external returns (uint256);
function trustedTransferTokens(address _to, uint256 _amount) external;
function trustedBurnTokens(uint256 _amount) external;
function trustedWithdrawETH(address _to, uint256 _amount) external;
function depositETH() external payable returns (bool);
function setCurrentRewardTokens() external;
function getController() public view returns (IController);
}
contract IBondingManager {
event TranscoderUpdate(address indexed transcoder, uint256 pendingRewardCut, uint256 pendingFeeShare, uint256 pendingPricePerSegment, bool registered);
event TranscoderEvicted(address indexed transcoder);
event TranscoderResigned(address indexed transcoder);
event TranscoderSlashed(address indexed transcoder, address finder, uint256 penalty, uint256 finderReward);
event Reward(address indexed transcoder, uint256 amount);
event Bond(address indexed delegate, address indexed delegator);
event Unbond(address indexed delegate, address indexed delegator);
event WithdrawStake(address indexed delegator);
event WithdrawFees(address indexed delegator);
function setActiveTranscoders() external;
function updateTranscoderWithFees(address _transcoder, uint256 _fees, uint256 _round) external;
function slashTranscoder(address _transcoder, address _finder, uint256 _slashAmount, uint256 _finderFee) external;
function electActiveTranscoder(uint256 _maxPricePerSegment, bytes32 _blockHash, uint256 _round) external view returns (address);
function transcoderTotalStake(address _transcoder) public view returns (uint256);
function activeTranscoderTotalStake(address _transcoder, uint256 _round) public view returns (uint256);
function isRegisteredTranscoder(address _transcoder) public view returns (bool);
function getTotalBonded() public view returns (uint256);
}
contract IRoundsManager {
event NewRound(uint256 round);
function initializeRound() external;
function blockNum() public view returns (uint256);
function blockHash(uint256 _block) public view returns (bytes32);
function currentRound() public view returns (uint256);
function currentRoundStartBlock() public view returns (uint256);
function currentRoundInitialized() public view returns (bool);
function currentRoundLocked() public view returns (bool);
}
contract RoundsManager is ManagerProxyTarget, IRoundsManager {
using SafeMath for uint256;
uint256 public roundLength;
uint256 public roundLockAmount;
uint256 public lastInitializedRound;
uint256 public lastRoundLengthUpdateRound;
uint256 public lastRoundLengthUpdateStartBlock;
function RoundsManager(address _controller) public Manager(_controller) {}
function setRoundLength(uint256 _roundLength) external onlyControllerOwner {
require(_roundLength > 0);
if (roundLength == 0) {
roundLength = _roundLength;
lastRoundLengthUpdateRound = currentRound();
lastRoundLengthUpdateStartBlock = currentRoundStartBlock();
} else {
lastRoundLengthUpdateRound = currentRound();
lastRoundLengthUpdateStartBlock = currentRoundStartBlock();
roundLength = _roundLength;
}
ParameterUpdate("roundLength");
}
function setRoundLockAmount(uint256 _roundLockAmount) external onlyControllerOwner {
require(MathUtils.validPerc(_roundLockAmount));
roundLockAmount = _roundLockAmount;
ParameterUpdate("roundLockAmount");
}
function initializeRound() external whenSystemNotPaused {
uint256 currRound = currentRound();
require(lastInitializedRound < currRound);
lastInitializedRound = currRound;
bondingManager().setActiveTranscoders();
minter().setCurrentRewardTokens();
NewRound(currRound);
}
function blockNum() public view returns (uint256) {
return block.number;
}
function blockHash(uint256 _block) public view returns (bytes32) {
uint256 currentBlock = blockNum();
require(_block < currentBlock);
require(currentBlock < 256 || _block >= currentBlock - 256);
return block.blockhash(_block);
}
function currentRound() public view returns (uint256) {
uint256 roundsSinceUpdate = blockNum().sub(lastRoundLengthUpdateStartBlock).div(roundLength);
return lastRoundLengthUpdateRound.add(roundsSinceUpdate);
}
function currentRoundStartBlock() public view returns (uint256) {
uint256 roundsSinceUpdate = blockNum().sub(lastRoundLengthUpdateStartBlock).div(roundLength);
return lastRoundLengthUpdateStartBlock.add(roundsSinceUpdate.mul(roundLength));
}
function currentRoundInitialized() public view returns (bool) {
return lastInitializedRound == currentRound();
}
function currentRoundLocked() public view returns (bool) {
uint256 lockedBlocks = MathUtils.percOf(roundLength, roundLockAmount);
return blockNum().sub(currentRoundStartBlock()) >= roundLength.sub(lockedBlocks);
}
function bondingManager() internal view returns (IBondingManager) {
return IBondingManager(controller.getContract(keccak256("BondingManager")));
}
function minter() internal view returns (IMinter) {
return IMinter(controller.getContract(keccak256("Minter")));
}
}