pragma solidity 0.4.18;
contract ERC20Basic {
uint256 public totalSupply;
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
contract ILivepeerToken is ERC20, Ownable {
function mint(address _to, uint256 _amount) public returns (bool);
function burn(uint256 _amount) public;
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
contract Minter is Manager, IMinter {
using SafeMath for uint256;
uint256 public inflation;
uint256 public inflationChange;
uint256 public targetBondingRate;
uint256 public currentMintableTokens;
uint256 public currentMintedTokens;
modifier onlyBondingManager() {
require(msg.sender == controller.getContract(keccak256("BondingManager")));
_;
}
modifier onlyRoundsManager() {
require(msg.sender == controller.getContract(keccak256("RoundsManager")));
_;
}
modifier onlyBondingManagerOrJobsManager() {
require(msg.sender == controller.getContract(keccak256("BondingManager")) || msg.sender == controller.getContract(keccak256("JobsManager")));
_;
}
modifier onlyMinterOrJobsManager() {
require(msg.sender == controller.getContract(keccak256("Minter")) || msg.sender == controller.getContract(keccak256("JobsManager")));
_;
}
function Minter(address _controller, uint256 _inflation, uint256 _inflationChange, uint256 _targetBondingRate) public Manager(_controller) {
require(MathUtils.validPerc(_inflation));
require(MathUtils.validPerc(_inflationChange));
require(MathUtils.validPerc(_targetBondingRate));
inflation = _inflation;
inflationChange = _inflationChange;
targetBondingRate = _targetBondingRate;
}
function setTargetBondingRate(uint256 _targetBondingRate) external onlyControllerOwner {
require(MathUtils.validPerc(_targetBondingRate));
targetBondingRate = _targetBondingRate;
ParameterUpdate("targetBondingRate");
}
function setInflationChange(uint256 _inflationChange) external onlyControllerOwner {
require(MathUtils.validPerc(_inflationChange));
inflationChange = _inflationChange;
ParameterUpdate("inflationChange");
}
function migrateToNewMinter(IMinter _newMinter) external onlyControllerOwner whenSystemPaused {
require(_newMinter != this);
require(address(_newMinter) != address(0));
IController newMinterController = _newMinter.getController();
require(newMinterController == controller);
require(newMinterController.getContract(keccak256("Minter")) == address(this));
livepeerToken().transferOwnership(_newMinter);
livepeerToken().transfer(_newMinter, livepeerToken().balanceOf(this));
_newMinter.depositETH.value(this.balance)();
}
function createReward(uint256 _fracNum, uint256 _fracDenom) external onlyBondingManager whenSystemNotPaused returns (uint256) {
uint256 mintAmount = MathUtils.percOf(currentMintableTokens, _fracNum, _fracDenom);
currentMintedTokens = currentMintedTokens.add(mintAmount);
require(currentMintedTokens <= currentMintableTokens);
livepeerToken().mint(this, mintAmount);
return mintAmount;
}
function trustedTransferTokens(address _to, uint256 _amount) external onlyBondingManager whenSystemNotPaused {
livepeerToken().transfer(_to, _amount);
}
function trustedBurnTokens(uint256 _amount) external onlyBondingManager whenSystemNotPaused {
livepeerToken().burn(_amount);
}
function trustedWithdrawETH(address _to, uint256 _amount) external onlyBondingManagerOrJobsManager whenSystemNotPaused {
_to.transfer(_amount);
}
function depositETH() external payable onlyMinterOrJobsManager whenSystemNotPaused returns (bool) {
return true;
}
function setCurrentRewardTokens() external onlyRoundsManager whenSystemNotPaused {
setInflation();
currentMintableTokens = MathUtils.percOf(livepeerToken().totalSupply(), inflation);
currentMintedTokens = 0;
SetCurrentRewardTokens(currentMintableTokens, inflation);
}
function getController() public view returns (IController) {
return controller;
}
function setInflation() internal {
uint256 currentBondingRate = 0;
uint256 totalSupply = livepeerToken().totalSupply();
if (totalSupply > 0) {
uint256 totalBonded = bondingManager().getTotalBonded();
currentBondingRate = MathUtils.percPoints(totalBonded, totalSupply);
}
if (currentBondingRate < targetBondingRate) {
inflation = inflation.add(inflationChange);
} else if (currentBondingRate > targetBondingRate) {
if (inflationChange > inflation) {
inflation = 0;
} else {
inflation = inflation.sub(inflationChange);
}
}
}
function livepeerToken() internal view returns (ILivepeerToken) {
return ILivepeerToken(controller.getContract(keccak256("LivepeerToken")));
}
function bondingManager() internal view returns (IBondingManager) {
return IBondingManager(controller.getContract(keccak256("BondingManager")));
}
}