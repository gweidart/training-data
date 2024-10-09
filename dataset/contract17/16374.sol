pragma solidity 0.4.18;
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
contract IVerifier {
function verify(
uint256 _jobId,
uint256 _claimId,
uint256 _segmentNumber,
string _transcodingOptions,
string _dataStorageHash,
bytes32[2] _dataHashes
)
external
payable;
function getPrice() public view returns (uint256);
}
contract IVerifiable {
function receiveVerification(uint256 _jobId, uint256 _claimId, uint256 _segmentNumber, bool _result) external;
}
contract LivepeerVerifier is Manager, IVerifier {
string public verificationCodeHash;
address[] public solvers;
mapping (address => bool) public isSolver;
struct Request {
uint256 jobId;
uint256 claimId;
uint256 segmentNumber;
bytes32 commitHash;
}
mapping (uint256 => Request) public requests;
uint256 public requestCount;
event VerifyRequest(uint256 indexed requestId, uint256 indexed jobId, uint256 indexed claimId, uint256 segmentNumber, string transcodingOptions, string dataStorageHash, bytes32 dataHash, bytes32 transcodedDataHash);
event Callback(uint256 indexed requestId, uint256 indexed jobId, uint256 indexed claimId, uint256 segmentNumber, bool result);
modifier onlyJobsManager() {
require(msg.sender == controller.getContract(keccak256("JobsManager")));
_;
}
modifier onlySolvers() {
require(isSolver[msg.sender]);
_;
}
function LivepeerVerifier(address _controller, address[] _solvers, string _verificationCodeHash) public Manager(_controller) {
for (uint256 i = 0; i < _solvers.length; i++) {
require(!isSolver[_solvers[i]] && _solvers[i] != address(0));
isSolver[_solvers[i]] = true;
}
solvers = _solvers;
verificationCodeHash = _verificationCodeHash;
}
function setVerificationCodeHash(string _verificationCodeHash) external onlyControllerOwner {
verificationCodeHash = _verificationCodeHash;
}
function addSolver(address _solver) external onlyControllerOwner {
require(_solver != address(0));
require(!isSolver[_solver]);
solvers.push(_solver);
isSolver[_solver] = true;
}
function verify(
uint256 _jobId,
uint256 _claimId,
uint256 _segmentNumber,
string _transcodingOptions,
string _dataStorageHash,
bytes32[2] _dataHashes
)
external
payable
onlyJobsManager
whenSystemNotPaused
{
requests[requestCount].jobId = _jobId;
requests[requestCount].claimId = _claimId;
requests[requestCount].segmentNumber = _segmentNumber;
requests[requestCount].commitHash = keccak256(_dataHashes[0], _dataHashes[1]);
VerifyRequest(
requestCount,
_jobId,
_claimId,
_segmentNumber,
_transcodingOptions,
_dataStorageHash,
_dataHashes[0],
_dataHashes[1]
);
requestCount++;
}
function __callback(uint256 _requestId, bytes32 _result) external onlySolvers whenSystemNotPaused {
Request memory q = requests[_requestId];
if (q.commitHash == _result) {
IVerifiable(controller.getContract(keccak256("JobsManager"))).receiveVerification(q.jobId, q.claimId, q.segmentNumber, true);
Callback(_requestId, q.jobId, q.claimId, q.segmentNumber, true);
} else {
IVerifiable(controller.getContract(keccak256("JobsManager"))).receiveVerification(q.jobId, q.claimId, q.segmentNumber, false);
Callback(_requestId, q.jobId, q.claimId, q.segmentNumber, false);
}
delete requests[_requestId];
}
function getPrice() public view returns (uint256) {
return 0;
}
}