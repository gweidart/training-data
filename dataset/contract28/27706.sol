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
contract GatewayInterface {
event EventGatewayNewLinkRequest ( address indexed newAddress );
event EventGatewayNewAddress ( address indexed newAddress );
address public currentApplicationEntityAddress;
ApplicationEntityABI private currentApp;
address public deployerAddress;
function GatewayInterface() public {
deployerAddress = msg.sender;
}
function getApplicationAddress() external view returns (address) {
return currentApplicationEntityAddress;
}
function requestCodeUpgrade( address _newAddress, bytes32 _sourceCodeUrl )
external
validCodeUpgradeInitiator
returns (bool)
{
require(_newAddress != address(0x0));
EventGatewayNewLinkRequest ( _newAddress );
if(currentApplicationEntityAddress == address(0x0)) {
if(!ApplicationEntityABI(_newAddress).initializeAssetsToThisApplication()) {
revert();
}
link(_newAddress);
return true;
} else {
currentApp.createCodeUpgradeProposal(_newAddress, _sourceCodeUrl);
}
}
function approveCodeUpgrade( address _newAddress ) external returns (bool) {
require(msg.sender == currentApplicationEntityAddress);
uint8 atState = currentApp.CurrentEntityState();
lockCurrentApp();
if(!currentApp.transferAssetsToNewApplication(_newAddress)) {
revert();
}
link(_newAddress);
currentApp.setUpgradeState( atState );
return true;
}
function lockCurrentApp() internal {
if(!currentApp.lock()) {
revert();
}
}
function link( address _newAddress ) internal returns (bool) {
currentApplicationEntityAddress = _newAddress;
currentApp = ApplicationEntityABI(currentApplicationEntityAddress);
if( !currentApp.initialize() ) {
revert();
}
EventGatewayNewAddress(currentApplicationEntityAddress);
return true;
}
function getNewsContractAddress() external view returns (address) {
return currentApp.NewsContractEntity();
}
function getListingContractAddress() external view returns (address) {
return currentApp.ListingContractEntity();
}
modifier validCodeUpgradeInitiator() {
bool valid = false;
ApplicationEntityABI newDeployedApp = ApplicationEntityABI(msg.sender);
address newDeployer = newDeployedApp.deployerAddress();
if(newDeployer == deployerAddress) {
valid = true;
} else {
if(currentApplicationEntityAddress != address(0x0)) {
currentApp = ApplicationEntityABI(currentApplicationEntityAddress);
if(currentApp.canInitiateCodeUpgrade(newDeployer)) {
valid = true;
}
}
}
require( valid == true );
_;
}
}