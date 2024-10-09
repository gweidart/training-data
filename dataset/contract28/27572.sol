pragma solidity ^0.4.17;
contract ApplicationEntityABI {
address public ProposalsEntity;
address public FundingEntity;
address public MilestonesEntity;
address public MeetingsEntity;
address public BountyManagerEntity;
address public TokenManagerEntity;
address public ListingContractEntity;
address public FundingManagerEntity;
address public NewsContractEntity;
bool public _initialized = false;
bool public _locked = false;
uint8 public CurrentEntityState;
uint8 public AssetCollectionNum;
address public GatewayInterfaceAddress;
address public deployerAddress;
address testAddressAllowUpgradeFrom;
mapping (bytes32 => uint8) public EntityStates;
mapping (bytes32 => address) public AssetCollection;
mapping (uint8 => bytes32) public AssetCollectionIdToName;
mapping (bytes32 => uint256) public BylawsUint256;
mapping (bytes32 => bytes32) public BylawsBytes32;
function ApplicationEntity() public;
function getEntityState(bytes32 name) public view returns (uint8);
function linkToGateway( address _GatewayInterfaceAddress, bytes32 _sourceCodeUrl ) external;
function setUpgradeState(uint8 state) public ;
function addAssetProposals(address _assetAddresses) external;
function addAssetFunding(address _assetAddresses) external;
function addAssetMilestones(address _assetAddresses) external;
function addAssetMeetings(address _assetAddresses) external;
function addAssetBountyManager(address _assetAddresses) external;
function addAssetTokenManager(address _assetAddresses) external;
function addAssetFundingManager(address _assetAddresses) external;
function addAssetListingContract(address _assetAddresses) external;
function addAssetNewsContract(address _assetAddresses) external;
function getAssetAddressByName(bytes32 _name) public view returns (address);
function setBylawUint256(bytes32 name, uint256 value) public;
function getBylawUint256(bytes32 name) public view returns (uint256);
function setBylawBytes32(bytes32 name, bytes32 value) public;
function getBylawBytes32(bytes32 name) public view returns (bytes32);
function initialize() external returns (bool);
function getParentAddress() external view returns(address);
function createCodeUpgradeProposal( address _newAddress, bytes32 _sourceCodeUrl ) external returns (uint256);
function acceptCodeUpgradeProposal(address _newAddress) external;
function initializeAssetsToThisApplication() external returns (bool);
function transferAssetsToNewApplication(address _newAddress) external returns (bool);
function lock() external returns (bool);
function canInitiateCodeUpgrade(address _sender) public view returns(bool);
function doStateChanges() public;
function hasRequiredStateChanges() public view returns (bool);
function anyAssetHasChanges() public view returns (bool);
function extendedAnyAssetHasChanges() internal view returns (bool);
function getRequiredStateChanges() public view returns (uint8, uint8);
function getTimestamp() view public returns (uint256);
}
contract ABIToken {
string public  symbol;
string public  name;
uint8 public   decimals;
uint256 public totalSupply;
string public  version;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) allowed;
address public manager;
address public deployer;
bool public mintingFinished = false;
bool public initialized = false;
function transfer(address _to, uint256 _value) public returns (bool);
function balanceOf(address _owner) public view returns (uint256 balance);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
function approve(address _spender, uint256 _value) public returns (bool);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
function increaseApproval(address _spender, uint _addedValue) public returns (bool success);
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success);
function mint(address _to, uint256 _amount) public returns (bool);
function finishMinting() public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 indexed value);
event Approval(address indexed owner, address indexed spender, uint256 indexed value);
event Mint(address indexed to, uint256 amount);
event MintFinished();
}
contract ABIApplicationAsset {
bytes32 public assetName;
uint8 public CurrentEntityState;
uint8 public RecordNum;
bool public _initialized;
bool public _settingsApplied;
address public owner;
address public deployerAddress;
mapping (bytes32 => uint8) public EntityStates;
mapping (bytes32 => uint8) public RecordStates;
function setInitialApplicationAddress(address _ownerAddress) public;
function setInitialOwnerAndName(bytes32 _name) external returns (bool);
function getRecordState(bytes32 name) public view returns (uint8);
function getEntityState(bytes32 name) public view returns (uint8);
function applyAndLockSettings() public returns(bool);
function transferToNewOwner(address _newOwner) public returns (bool);
function getApplicationAssetAddressByName(bytes32 _name) public returns(address);
function getApplicationState() public view returns (uint8);
function getApplicationEntityState(bytes32 name) public view returns (uint8);
function getAppBylawUint256(bytes32 name) public view returns (uint256);
function getAppBylawBytes32(bytes32 name) public view returns (bytes32);
function getTimestamp() view public returns (uint256);
}
contract ABIFunding is ABIApplicationAsset {
address public multiSigOutputAddress;
address public DirectInput;
address public MilestoneInput;
address public TokenManagerEntity;
address public FundingManagerEntity;
struct FundingStage {
bytes32 name;
uint8   state;
uint256 time_start;
uint256 time_end;
uint256 amount_cap_soft;
uint256 amount_cap_hard;
uint256 amount_raised;
uint256 minimum_entry;
uint8   methods;
uint256 fixed_tokens;
uint8   price_addition_percentage;
uint8   token_share_percentage;
uint8   index;
}
mapping (uint8 => FundingStage) public Collection;
uint8 public FundingStageNum;
uint8 public currentFundingStage;
uint256 public AmountRaised;
uint256 public MilestoneAmountRaised;
uint256 public GlobalAmountCapSoft;
uint256 public GlobalAmountCapHard;
uint8 public TokenSellPercentage;
uint256 public Funding_Setting_funding_time_start;
uint256 public Funding_Setting_funding_time_end;
uint256 public Funding_Setting_cashback_time_start;
uint256 public Funding_Setting_cashback_time_end;
uint256 public Funding_Setting_cashback_before_start_wait_duration;
uint256 public Funding_Setting_cashback_duration;
function addFundingStage(
bytes32 _name,
uint256 _time_start,
uint256 _time_end,
uint256 _amount_cap_soft,
uint256 _amount_cap_hard,
uint8   _methods,
uint256 _minimum_entry,
uint256 _fixed_tokens,
uint8   _price_addition_percentage,
uint8   _token_share_percentage
)
public;
function addSettings(address _outputAddress, uint256 soft_cap, uint256 hard_cap, uint8 sale_percentage, address _direct, address _milestone ) public;
function getStageAmount(uint8 StageId) public view returns ( uint256 );
function allowedPaymentMethod(uint8 _payment_method) public pure returns (bool);
function receivePayment(address _sender, uint8 _payment_method) payable public returns(bool);
function canAcceptPayment(uint256 _amount) public view returns (bool);
function getValueOverCurrentCap(uint256 _amount) public view returns (uint256);
function isFundingStageUpdateAllowed(uint8 _new_state ) public view returns (bool);
function getRecordStateRequiredChanges() public view returns (uint8);
function doStateChanges() public;
function hasRequiredStateChanges() public view returns (bool);
function getRequiredStateChanges() public view returns (uint8, uint8, uint8);
}
contract ABIMilestones is ABIApplicationAsset {
struct Record {
bytes32 name;
string description;
uint8 state;
uint256 duration;
uint256 time_start;
uint256 last_state_change_time;
uint256 time_end;
uint256 time_ended;
uint256 meeting_time;
uint8 funding_percentage;
uint8 index;
}
uint8 public currentRecord;
uint256 public MilestoneCashBackTime = 0;
mapping (uint8 => Record) public Collection;
mapping (bytes32 => bool) public MilestonePostponingHash;
mapping (bytes32 => uint256) public ProposalIdByHash;
function getBylawsProjectDevelopmentStart() public view returns (uint256);
function getBylawsMinTimeInTheFutureForMeetingCreation() public view returns (uint256);
function getBylawsCashBackVoteRejectedDuration() public view returns (uint256);
function addRecord( bytes32 _name, string _description, uint256 _duration, uint8 _perc ) public;
function getMilestoneFundingPercentage(uint8 recordId) public view returns (uint8);
function doStateChanges() public;
function getRecordStateRequiredChanges() public view returns (uint8);
function hasRequiredStateChanges() public view returns (bool);
function afterVoteNoCashBackTime() public view returns ( bool );
function getHash(uint8 actionType, bytes32 arg1, bytes32 arg2) public pure returns ( bytes32 );
function getCurrentHash() public view returns ( bytes32 );
function getCurrentProposalId() internal view returns ( uint256 );
function setCurrentMilestoneMeetingTime(uint256 _meeting_time) public;
function isRecordUpdateAllowed(uint8 _new_state ) public view returns (bool);
function getRequiredStateChanges() public view returns (uint8, uint8, uint8);
function ApplicationIsInDevelopment() public view returns(bool);
function MeetingTimeSetFailure() public view returns (bool);
}
contract ABIProposals is ABIApplicationAsset {
address public Application;
address public ListingContractEntity;
address public FundingEntity;
address public FundingManagerEntity;
address public TokenManagerEntity;
address public TokenEntity;
address public MilestonesEntity;
struct ProposalRecord {
address creator;
bytes32 name;
uint8 actionType;
uint8 state;
bytes32 hash;
address addr;
bytes32 sourceCodeUrl;
uint256 extra;
uint256 time_start;
uint256 time_end;
uint256 index;
}
struct VoteStruct {
address voter;
uint256 time;
bool    vote;
uint256 power;
bool    annulled;
uint256 index;
}
struct ResultRecord {
uint256 totalAvailable;
uint256 requiredForResult;
uint256 totalSoFar;
uint256 yes;
uint256 no;
bool    requiresCounting;
}
uint8 public ActiveProposalNum;
uint256 public VoteCountPerProcess;
bool public EmergencyFundingReleaseApproved;
mapping (bytes32 => uint8) public ActionTypes;
mapping (uint8 => uint256) public ActiveProposalIds;
mapping (uint256 => bool) public ExpiredProposalIds;
mapping (uint256 => ProposalRecord) public ProposalsById;
mapping (bytes32 => uint256) public ProposalIdByHash;
mapping (uint256 => mapping (uint256 => VoteStruct) ) public VotesByProposalId;
mapping (uint256 => mapping (address => VoteStruct) ) public VotesByCaster;
mapping (uint256 => uint256) public VotesNumByProposalId;
mapping (uint256 => ResultRecord ) public ResultsByProposalId;
mapping (uint256 => uint256) public lastProcessedVoteIdByProposal;
mapping (uint256 => uint256) public ProcessedVotesByProposal;
mapping (uint256 => uint256) public VoteCountAtProcessingStartByProposal;
function getRecordState(bytes32 name) public view returns (uint8);
function getActionType(bytes32 name) public view returns (uint8);
function getProposalState(uint256 _proposalId) public view returns (uint8);
function getBylawsProposalVotingDuration() public view returns (uint256);
function getBylawsMilestoneMinPostponing() public view returns (uint256);
function getBylawsMilestoneMaxPostponing() public view returns (uint256);
function getHash(uint8 actionType, bytes32 arg1, bytes32 arg2) public pure returns ( bytes32 );
function process() public;
function hasRequiredStateChanges() public view returns (bool);
function getRequiredStateChanges() public view returns (uint8);
function addCodeUpgradeProposal(address _addr, bytes32 _sourceCodeUrl) external returns (uint256);
function createMilestoneAcceptanceProposal() external returns (uint256);
function createMilestonePostponingProposal(uint256 _duration) external returns (uint256);
function getCurrentMilestonePostponingProposalDuration() public view returns (uint256);
function getCurrentMilestoneProposalStatusForType(uint8 _actionType ) public view returns (uint8);
function createEmergencyFundReleaseProposal() external returns (uint256);
function createDelistingProposal(uint256 _projectId) external returns (uint256);
function RegisterVote(uint256 _proposalId, bool _myVote) public;
function hasPreviousVote(uint256 _proposalId, address _voter) public view returns (bool);
function getTotalTokenVotingPower(address _voter) public view returns ( uint256 );
function getVotingPower(uint256 _proposalId, address _voter) public view returns ( uint256 );
function setVoteCountPerProcess(uint256 _perProcess) external;
function ProcessVoteTotals(uint256 _proposalId, uint256 length) public;
function canEndVoting(uint256 _proposalId) public view returns (bool);
function getProposalType(uint256 _proposalId) public view returns (uint8);
function expiryChangesState(uint256 _proposalId) public view returns (bool);
function needsProcessing(uint256 _proposalId) public view returns (bool);
function getMyVoteForCurrentMilestoneRelease(address _voter) public view returns (bool);
function getHasVoteForCurrentMilestoneRelease(address _voter) public view returns (bool);
function getMyVote(uint256 _proposalId, address _voter) public view returns (bool);
}
contract ABITokenManager is ABIApplicationAsset {
address public TokenSCADAEntity;
address public TokenEntity;
address public MarketingMethodAddress;
bool OwnerTokenBalancesReleased = false;
function addSettings(address _scadaAddress, address _tokenAddress, address _marketing ) public;
function getTokenSCADARequiresHardCap() public view returns (bool);
function mint(address _to, uint256 _amount) public returns (bool);
function finishMinting() public returns (bool);
function mintForMarketingPool(address _to, uint256 _amount) external returns (bool);
function ReleaseOwnersLockedTokens(address _multiSigOutputAddress) public returns (bool);
}
contract ABIFundingManager is ABIApplicationAsset {
bool public fundingProcessed;
bool FundingPoolBalancesAllocated;
uint8 public VaultCountPerProcess;
uint256 public lastProcessedVaultId;
uint256 public vaultNum;
uint256 public LockedVotingTokens;
bytes32 public currentTask;
mapping (bytes32 => bool) public taskByHash;
mapping  (address => address) public vaultList;
mapping  (uint256 => address) public vaultById;
function receivePayment(address _sender, uint8 _payment_method, uint8 _funding_stage) payable public returns(bool);
function getMyVaultAddress(address _sender) public view returns (address);
function setVaultCountPerProcess(uint8 _perProcess) external;
function getHash(bytes32 actionType, bytes32 arg1) public pure returns ( bytes32 );
function getCurrentMilestoneProcessed() public view returns (bool);
function processFundingFailedFinished() public view returns (bool);
function processFundingSuccessfulFinished() public view returns (bool);
function getCurrentMilestoneIdHash() internal view returns (bytes32);
function processMilestoneFinished() public view returns (bool);
function processEmergencyFundReleaseFinished() public view returns (bool);
function getAfterTransferLockedTokenBalances(address vaultAddress, bool excludeCurrent) public view returns (uint256);
function VaultRequestedUpdateForLockedVotingTokens(address owner) public;
function doStateChanges() public;
function hasRequiredStateChanges() public view returns (bool);
function getRequiredStateChanges() public view returns (uint8, uint8);
function ApplicationInFundingOrDevelopment() public view returns(bool);
}
contract ABITokenSCADAVariable {
bool public SCADA_requires_hard_cap = true;
bool public initialized;
address public deployerAddress;
function addSettings(address _fundingContract) public;
function requiresHardCap() public view returns (bool);
function getTokensForValueInCurrentStage(uint256 _value) public view returns (uint256);
function getTokensForValueInStage(uint8 _stage, uint256 _value) public view returns (uint256);
function getBoughtTokens( address _vaultAddress, bool _direct ) public view returns (uint256);
}
contract FundingVault {
bool public _initialized = false;
address public vaultOwner ;
address public outputAddress;
address public managerAddress;
bool public allFundingProcessed = false;
bool public DirectFundingProcessed = false;
ABIFunding FundingEntity;
ABIFundingManager FundingManagerEntity;
ABIMilestones MilestonesEntity;
ABIProposals ProposalsEntity;
ABITokenSCADAVariable TokenSCADAEntity;
ABIToken TokenEntity ;
uint256 public amount_direct = 0;
uint256 public amount_milestone = 0;
bool public emergencyFundReleased = false;
uint8 emergencyFundPercentage = 0;
uint256 BylawsCashBackOwnerMiaDuration;
uint256 BylawsCashBackVoteRejectedDuration;
uint256 BylawsProposalVotingDuration;
struct PurchaseStruct {
uint256 unix_time;
uint8 payment_method;
uint256 amount;
uint8 funding_stage;
uint16 index;
}
mapping(uint16 => PurchaseStruct) public purchaseRecords;
uint16 public purchaseRecordsNum;
event EventPaymentReceived(uint8 indexed _payment_method, uint256 indexed _amount, uint16 indexed _index );
event VaultInitialized(address indexed _owner);
function initialize(
address _owner,
address _output,
address _fundingAddress,
address _milestoneAddress,
address _proposalsAddress
)
public
requireNotInitialised
returns(bool)
{
VaultInitialized(_owner);
outputAddress = _output;
vaultOwner = _owner;
managerAddress = msg.sender;
FundingEntity = ABIFunding(_fundingAddress);
FundingManagerEntity = ABIFundingManager(managerAddress);
MilestonesEntity = ABIMilestones(_milestoneAddress);
ProposalsEntity = ABIProposals(_proposalsAddress);
address TokenManagerAddress = FundingEntity.getApplicationAssetAddressByName("TokenManager");
ABITokenManager TokenManagerEntity = ABITokenManager(TokenManagerAddress);
address TokenAddress = TokenManagerEntity.TokenEntity();
TokenEntity = ABIToken(TokenAddress);
address TokenSCADAAddress = TokenManagerEntity.TokenSCADAEntity();
TokenSCADAEntity = ABITokenSCADAVariable(TokenSCADAAddress);
address ApplicationEntityAddress = TokenManagerEntity.owner();
ApplicationEntityABI ApplicationEntity = ApplicationEntityABI(ApplicationEntityAddress);
emergencyFundPercentage             = uint8( ApplicationEntity.getBylawUint256("emergency_fund_percentage") );
BylawsCashBackOwnerMiaDuration      = ApplicationEntity.getBylawUint256("cashback_owner_mia_dur") ;
BylawsCashBackVoteRejectedDuration  = ApplicationEntity.getBylawUint256("cashback_investor_no") ;
BylawsProposalVotingDuration        = ApplicationEntity.getBylawUint256("proposal_voting_duration") ;
_initialized = true;
return true;
}
mapping (uint8 => uint256) public stageAmounts;
mapping (uint8 => uint256) public stageAmountsDirect;
function addPayment(
uint8 _payment_method,
uint8 _funding_stage
)
public
payable
requireInitialised
onlyManager
returns (bool)
{
if(msg.value > 0 && FundingEntity.allowedPaymentMethod(_payment_method)) {
PurchaseStruct storage purchase = purchaseRecords[++purchaseRecordsNum];
purchase.unix_time = now;
purchase.payment_method = _payment_method;
purchase.amount = msg.value;
purchase.funding_stage = _funding_stage;
purchase.index = purchaseRecordsNum;
if(_payment_method == 1) {
amount_direct+= purchase.amount;
stageAmountsDirect[_funding_stage]+=purchase.amount;
}
if(_payment_method == 2) {
amount_milestone+= purchase.amount;
}
stageAmounts[_funding_stage]+=purchase.amount;
EventPaymentReceived( purchase.payment_method, purchase.amount, purchase.index );
return true;
} else {
revert();
}
}
function getBoughtTokens() public view returns (uint256) {
return TokenSCADAEntity.getBoughtTokens( address(this), false );
}
function getDirectBoughtTokens() public view returns (uint256) {
return TokenSCADAEntity.getBoughtTokens( address(this), true );
}
mapping (uint8 => uint256) public etherBalances;
mapping (uint8 => uint256) public tokenBalances;
uint8 public BalanceNum = 0;
bool public BalancesInitialised = false;
function initMilestoneTokenAndEtherBalances() internal
{
if(BalancesInitialised == false) {
uint256 milestoneTokenBalance = TokenEntity.balanceOf(address(this));
uint256 milestoneEtherBalance = this.balance;
if(emergencyFundPercentage > 0) {
tokenBalances[0] = milestoneTokenBalance / 100 * emergencyFundPercentage;
etherBalances[0] = milestoneEtherBalance / 100 * emergencyFundPercentage;
milestoneTokenBalance-=tokenBalances[0];
milestoneEtherBalance-=etherBalances[0];
}
for(uint8 i = 1; i <= MilestonesEntity.RecordNum(); i++) {
uint8 perc = MilestonesEntity.getMilestoneFundingPercentage(i);
tokenBalances[i] = milestoneTokenBalance / 100 * perc;
etherBalances[i] = milestoneEtherBalance / 100 * perc;
}
BalanceNum = i;
BalancesInitialised = true;
}
}
function ReleaseFundsAndTokens()
public
requireInitialised
onlyManager
returns (bool)
{
if(!canCashBack() && allFundingProcessed == false) {
if(FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("FUNDING_SUCCESSFUL_PROGRESS")) {
if(amount_direct > 0 && amount_milestone == 0) {
TokenEntity.transfer(vaultOwner, TokenEntity.balanceOf( address(this) ) );
outputAddress.transfer(this.balance);
allFundingProcessed = true;
} else {
if(amount_direct > 0 && DirectFundingProcessed == false ) {
TokenEntity.transfer(vaultOwner, getDirectBoughtTokens() );
outputAddress.transfer(amount_direct);
DirectFundingProcessed = true;
}
initMilestoneTokenAndEtherBalances();
}
return true;
} else if(FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("MILESTONE_PROCESS_PROGRESS")) {
uint8 milestoneId = MilestonesEntity.currentRecord();
uint256 transferTokens = tokenBalances[milestoneId];
uint256 transferEther = etherBalances[milestoneId];
if(milestoneId == BalanceNum - 1) {
transferTokens = TokenEntity.balanceOf(address(this));
transferEther = this.balance;
}
TokenEntity.transfer(vaultOwner, transferTokens );
outputAddress.transfer(transferEther);
if(milestoneId == BalanceNum - 1) {
allFundingProcessed = true;
}
return true;
}
}
return false;
}
function releaseTokensAndEtherForEmergencyFund()
public
requireInitialised
onlyManager
returns (bool)
{
if( emergencyFundReleased == false && emergencyFundPercentage > 0) {
TokenEntity.transfer(vaultOwner, tokenBalances[0] );
outputAddress.transfer(etherBalances[0]);
emergencyFundReleased = true;
return true;
}
return false;
}
function ReleaseFundsToInvestor()
public
requireInitialised
isOwner
{
if(canCashBack()) {
uint256 myBalance = TokenEntity.balanceOf(address(this));
if(myBalance > 0) {
TokenEntity.transfer(outputAddress, myBalance );
}
vaultOwner.transfer(this.balance);
FundingManagerEntity.VaultRequestedUpdateForLockedVotingTokens( vaultOwner );
allFundingProcessed = true;
}
}
function canCashBack() public view requireInitialised returns (bool) {
if(checkFundingStateFailed()) {
return true;
}
if(checkMilestoneStateInvestorVotedNoVotingEndedNo()) {
return true;
}
if(checkOwnerFailedToSetTimeOnMeeting()) {
return true;
}
return false;
}
function checkFundingStateFailed() public view returns (bool) {
if(FundingEntity.CurrentEntityState() == FundingEntity.getEntityState("FAILED_FINAL") ) {
return true;
}
if( FundingEntity.getTimestamp() >= FundingEntity.Funding_Setting_cashback_time_start() ) {
if( FundingEntity.CurrentEntityState() != FundingEntity.getEntityState("SUCCESSFUL_FINAL") ) {
return true;
}
}
return false;
}
function checkMilestoneStateInvestorVotedNoVotingEndedNo() public view returns (bool) {
if(MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("VOTING_ENDED_NO") ) {
if( ProposalsEntity.getHasVoteForCurrentMilestoneRelease(vaultOwner) == true) {
if( ProposalsEntity.getMyVoteForCurrentMilestoneRelease( vaultOwner ) == false) {
return true;
}
}
}
return false;
}
function checkOwnerFailedToSetTimeOnMeeting() public view returns (bool) {
if( MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("DEADLINE_MEETING_TIME_FAILED") ) {
return true;
}
return false;
}
modifier isOwner() {
require(msg.sender == vaultOwner);
_;
}
modifier onlyManager() {
require(msg.sender == managerAddress);
_;
}
modifier requireInitialised() {
require(_initialized == true);
_;
}
modifier requireNotInitialised() {
require(_initialized == false);
_;
}
}