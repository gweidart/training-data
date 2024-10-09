pragma solidity 0.4.24;
contract Main0001_initFirstDeploy {
address constant DEPLOYER_ACCOUNT = 0x7b534c2D0F9Ee973e0b6FE8D4000cA711A20f22e;
address constant RATES_FEEDER_ACCOUNT = 0x8C58187a978979947b88824DCdA5Cb5fD4410387;
address constant preTokenProxyAddress = 0x1411b3B189B01f6e6d1eA883bFFcbD3a5224934C;
address constant stabilityBoardProxyAddress = 0x4686f017D456331ed2C1de66e134D8d05B24413D;
PreToken constant preToken = PreToken(0xeCb782B19Be6E657ae2D88831dD98145A00D32D5);
Rates constant rates = Rates(0x4babbe57453e2b6AF125B4e304256fCBDf744480);
FeeAccount constant feeAccount = FeeAccount(0xF6B541E1B5e001DCc11827C1A16232759aeA730a);
AugmintReserves constant augmintReserves = AugmintReserves(0x633cb544b2EF1bd9269B2111fD2B66fC05cd3477);
InterestEarnedAccount constant interestEarnedAccount = InterestEarnedAccount(0x5C1a44E07541203474D92BDD03f803ea74f6947c);
TokenAEur constant tokenAEur = TokenAEur(0x86A635EccEFFfA70Ff8A6DB29DA9C8DB288E40D0);
MonetarySupervisor constant monetarySupervisor = MonetarySupervisor(0x1Ca4F9d261707aF8A856020a4909B777da218868);
LoanManager constant loanManager = LoanManager(0xCBeFaF199b800DEeB9EAd61f358EE46E06c54070);
Locker constant locker = Locker(0x095c0F071Fd75875a6b5a1dEf3f3a993F591080c);
Exchange constant exchange = Exchange(0x8b52b019d237d0bbe8Baedf219132D5254e0690b);
require(address(this) == stabilityBoardProxyAddress, "only deploy via stabilityboardsigner");
bytes32[] memory preTokenPermissions = new bytes32[](2);
preTokenPermissions[0] = "PreTokenSigner";
preTokenPermissions[1] = "PermissionGranter";
preToken.grantMultiplePermissions(preTokenProxyAddress, preTokenPermissions);
rates.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
feeAccount.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
interestEarnedAccount.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
tokenAEur.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
augmintReserves.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
monetarySupervisor.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
loanManager.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
locker.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
exchange.grantPermission(stabilityBoardProxyAddress, "StabilityBoard");
rates.grantPermission(RATES_FEEDER_ACCOUNT, "RatesFeeder");
feeAccount.grantPermission(feeAccount, "NoTransferFee");
feeAccount.grantPermission(augmintReserves, "NoTransferFee");
feeAccount.grantPermission(interestEarnedAccount, "NoTransferFee");
feeAccount.grantPermission(monetarySupervisor, "NoTransferFee");
feeAccount.grantPermission(loanManager, "NoTransferFee");
feeAccount.grantPermission(locker, "NoTransferFee");
feeAccount.grantPermission(exchange, "NoTransferFee");
interestEarnedAccount.grantPermission(monetarySupervisor, "MonetarySupervisor");
tokenAEur.grantPermission(monetarySupervisor, "MonetarySupervisor");
augmintReserves.grantPermission(monetarySupervisor, "MonetarySupervisor");
monetarySupervisor.grantPermission(loanManager, "LoanManager");
monetarySupervisor.grantPermission(locker, "Locker");
loanManager.addLoanProduct(30 days, 990641, 600000, 1000, 50000, true);
loanManager.addLoanProduct(14 days, 996337, 600000, 1000, 50000, true);
loanManager.addLoanProduct(7 days, 998170, 600000, 1000, 50000, true);
locker.addLockProduct(4019, 30 days, 1000, true);
locker.addLockProduct(1506, 14 days, 1000, true);
locker.addLockProduct(568, 7 days, 1000, true);
preToken.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
rates.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
feeAccount.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
augmintReserves.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
interestEarnedAccount.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
tokenAEur.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
monetarySupervisor.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
loanManager.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
locker.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
exchange.revokePermission(DEPLOYER_ACCOUNT, "PermissionGranter");
preToken.revokePermission(stabilityBoardProxyAddress, "PermissionGranter");
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
require(a == 0 || c / a == b, "mul overflow");
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0, "div by 0");
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a, "sub underflow");
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a, "add overflow");
return c;
}
function roundedDiv(uint a, uint b) internal pure returns (uint256) {
require(b > 0, "div by 0");
uint256 z = a / b;
if (a % b >= b / 2) {
z++;
}
return z;
}
}
contract Restricted {
mapping (address => mapping (bytes32 => bool)) public permissions;
event PermissionGranted(address indexed agent, bytes32 grantedPermission);
event PermissionRevoked(address indexed agent, bytes32 revokedPermission);
modifier restrict(bytes32 requiredPermission) {
require(permissions[msg.sender][requiredPermission], "msg.sender must have permission");
_;
}
constructor(address permissionGranterContract) public {
require(permissionGranterContract != address(0), "permissionGranterContract must be set");
permissions[permissionGranterContract]["PermissionGranter"] = true;
emit PermissionGranted(permissionGranterContract, "PermissionGranter");
}
function grantPermission(address agent, bytes32 requiredPermission) public {
require(permissions[msg.sender]["PermissionGranter"],
"msg.sender must have PermissionGranter permission");
permissions[agent][requiredPermission] = true;
emit PermissionGranted(agent, requiredPermission);
}
function grantMultiplePermissions(address agent, bytes32[] requiredPermissions) public {
require(permissions[msg.sender]["PermissionGranter"],
"msg.sender must have PermissionGranter permission");
uint256 length = requiredPermissions.length;
for (uint256 i = 0; i < length; i++) {
grantPermission(agent, requiredPermissions[i]);
}
}
function revokePermission(address agent, bytes32 requiredPermission) public {
require(permissions[msg.sender]["PermissionGranter"],
"msg.sender must have PermissionGranter permission");
permissions[agent][requiredPermission] = false;
emit PermissionRevoked(agent, requiredPermission);
}
function revokeMultiplePermissions(address agent, bytes32[] requiredPermissions) public {
uint256 length = requiredPermissions.length;
for (uint256 i = 0; i < length; i++) {
revokePermission(agent, requiredPermissions[i]);
}
}
}
contract MultiSig {
using SafeMath for uint256;
uint public constant CHUNK_SIZE = 100;
mapping(address => bool) public isSigner;
address[] public allSigners;
uint public activeSignersCount;
enum ScriptState {New, Approved, Done, Cancelled, Failed}
struct Script {
ScriptState state;
uint signCount;
mapping(address => bool) signedBy;
address[] allSigners;
}
mapping(address => Script) public scripts;
address[] public scriptAddresses;
event SignerAdded(address signer);
event SignerRemoved(address signer);
event ScriptSigned(address scriptAddress, address signer);
event ScriptApproved(address scriptAddress);
event ScriptCancelled(address scriptAddress);
event ScriptExecuted(address scriptAddress, bool result);
constructor() public {
isSigner[msg.sender] = true;
allSigners.push(msg.sender);
activeSignersCount = 1;
emit SignerAdded(msg.sender);
}
function sign(address scriptAddress) public {
require(isSigner[msg.sender], "sender must be signer");
Script storage script = scripts[scriptAddress];
require(script.state == ScriptState.Approved || script.state == ScriptState.New,
"script state must be New or Approved");
require(!script.signedBy[msg.sender], "script must not be signed by signer yet");
if(script.allSigners.length == 0) {
scriptAddresses.push(scriptAddress);
}
script.allSigners.push(msg.sender);
script.signedBy[msg.sender] =  true;
script.signCount = script.signCount.add(1);
emit ScriptSigned(scriptAddress, msg.sender);
if(checkQuorum(script.signCount)){
script.state = ScriptState.Approved;
emit ScriptApproved(scriptAddress);
}
}
function execute(address scriptAddress) public returns (bool result) {
require(isSigner[msg.sender], "sender must be signer");
Script storage script = scripts[scriptAddress];
require(script.state == ScriptState.Approved, "script state must be Approved");
script.state = ScriptState.Failed;
if(scriptAddress.delegatecall(bytes4(keccak256("execute(address)")), scriptAddress)) {
script.state = ScriptState.Done;
result = true;
} else {
result = false;
}
emit ScriptExecuted(scriptAddress, result);
}
function cancelScript(address scriptAddress) public {
require(msg.sender == address(this), "only callable via MultiSig");
Script storage script = scripts[scriptAddress];
require(script.state == ScriptState.Approved || script.state == ScriptState.New,
"script state must be New or Approved");
script.state= ScriptState.Cancelled;
emit ScriptCancelled(scriptAddress);
}
function addSigners(address[] signers) public {
require(msg.sender == address(this), "only callable via MultiSig");
for (uint i= 0; i < signers.length; i++) {
if (!isSigner[signers[i]]) {
require(signers[i] != address(0), "new signer must not be 0x0");
activeSignersCount++;
allSigners.push(signers[i]);
isSigner[signers[i]] = true;
emit SignerAdded(signers[i]);
}
}
}
function removeSigners(address[] signers) public {
require(msg.sender == address(this), "only callable via MultiSig");
for (uint i= 0; i < signers.length; i++) {
if (isSigner[signers[i]]) {
require(activeSignersCount > 1, "must not remove last signer");
activeSignersCount--;
isSigner[signers[i]] = false;
emit SignerRemoved(signers[i]);
}
}
}
function checkQuorum(uint signersCount) internal view returns(bool isQuorum);
function getAllSignersCount() view external returns (uint allSignersCount) {
return allSigners.length;
}
function getAllSigners(uint offset) external view returns(uint[3][CHUNK_SIZE] signersResult) {
for (uint8 i = 0; i < CHUNK_SIZE && i + offset < allSigners.length; i++) {
address signerAddress = allSigners[i + offset];
signersResult[i] = [ i + offset, uint(signerAddress), isSigner[signerAddress] ? 1 : 0 ];
}
}
function getScriptsCount() view external returns (uint scriptsCount) {
return scriptAddresses.length;
}
function getAllScripts(uint offset) external view returns(uint[4][CHUNK_SIZE] scriptsResult) {
for (uint8 i = 0; i < CHUNK_SIZE && i + offset < scriptAddresses.length; i++) {
address scriptAddress = scriptAddresses[i + offset];
scriptsResult[i] = [ i + offset, uint(scriptAddress), uint(scripts[scriptAddress].state),
scripts[scriptAddress].signCount ];
}
}
}
contract PreToken is Restricted {
using SafeMath for uint256;
uint public constant CHUNK_SIZE = 100;
string constant public name = "Augmint pretokens";
string constant public symbol = "APRE";
uint8 constant public decimals = 0;
uint public totalSupply;
struct Agreement {
address owner;
uint balance;
uint32 discount;
uint32 valuationCap;
}
mapping(address => bytes32) public agreementOwners;
mapping(bytes32 => Agreement) public agreements;
bytes32[] public allAgreements;
event Transfer(address indexed from, address indexed to, uint amount);
event NewAgreement(address owner, bytes32 agreementHash, uint32 discount, uint32 valuationCap);
constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {}
function addAgreement(address owner, bytes32 agreementHash, uint32 discount, uint32 valuationCap)
external restrict("PreTokenSigner") {
require(owner != address(0), "owner must not be 0x0");
require(agreementOwners[owner] == 0x0, "owner must not have an aggrement yet");
require(agreementHash != 0x0, "agreementHash must not be 0x0");
require(discount > 0, "discount must be > 0");
require(agreements[agreementHash].discount == 0, "agreement must not exist yet");
agreements[agreementHash] = Agreement(owner, 0, discount, valuationCap);
agreementOwners[owner] = agreementHash;
allAgreements.push(agreementHash);
emit NewAgreement(owner, agreementHash, discount, valuationCap);
}
function issueTo(bytes32 agreementHash, uint amount) external restrict("PreTokenSigner") {
Agreement storage agreement = agreements[agreementHash];
require(agreement.discount > 0, "agreement must exist");
agreement.balance = agreement.balance.add(amount);
totalSupply = totalSupply.add(amount);
emit Transfer(0x0, agreement.owner, amount);
}
function burnFrom(bytes32 agreementHash, uint amount)
public restrict("PreTokenSigner") returns (bool) {
Agreement storage agreement = agreements[agreementHash];
require(agreement.discount > 0, "agreement must exist");
require(amount > 0, "burn amount must be > 0");
require(agreement.balance >= amount, "must not burn more than balance");
agreement.balance = agreement.balance.sub(amount);
totalSupply = totalSupply.sub(amount);
emit Transfer(agreement.owner, 0x0, amount);
return true;
}
function balanceOf(address owner) public view returns (uint) {
return agreements[agreementOwners[owner]].balance;
}
function transfer(address to, uint amount) public returns (bool) {
require(amount == agreements[agreementOwners[msg.sender]].balance, "must transfer full balance");
_transfer(msg.sender, to);
return true;
}
function transferAgreement(bytes32 agreementHash, address to)
public restrict("PreTokenSigner") returns (bool) {
_transfer(agreements[agreementHash].owner, to);
return true;
}
function _transfer(address from, address to) private {
Agreement storage agreement = agreements[agreementOwners[from]];
require(agreementOwners[from] != 0x0, "from agreement must exists");
require(agreementOwners[to] == 0, "to must not have an agreement");
require(to != 0x0, "must not transfer to 0x0");
agreement.owner = to;
agreementOwners[to] = agreementOwners[from];
agreementOwners[from] = 0x0;
emit Transfer(from, to, agreement.balance);
}
function getAgreementsCount() external view returns (uint agreementsCount) {
return allAgreements.length;
}
function getAllAgreements(uint offset) external view returns(uint[6][CHUNK_SIZE] agreementsResult) {
for (uint8 i = 0; i < CHUNK_SIZE && i + offset < allAgreements.length; i++) {
bytes32 agreementHash = allAgreements[i + offset];
Agreement storage agreement = agreements[agreementHash];
agreementsResult[i] = [ i + offset, uint(agreement.owner), agreement.balance,
uint(agreementHash), uint(agreement.discount), uint(agreement.valuationCap)];
}
}
}
contract Rates is Restricted {
using SafeMath for uint256;
struct RateInfo {
uint rate;
uint lastUpdated;
}
mapping(bytes32 => RateInfo) public rates;
event RateChanged(bytes32 symbol, uint newRate);
constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {}
function setRate(bytes32 symbol, uint newRate) external restrict("RatesFeeder") {
rates[symbol] = RateInfo(newRate, now);
emit RateChanged(symbol, newRate);
}
function setMultipleRates(bytes32[] symbols, uint[] newRates) external restrict("RatesFeeder") {
require(symbols.length == newRates.length, "symobls and newRates lengths must be equal");
for (uint256 i = 0; i < symbols.length; i++) {
rates[symbols[i]] = RateInfo(newRates[i], now);
emit RateChanged(symbols[i], newRates[i]);
}
}
function convertFromWei(bytes32 bSymbol, uint weiValue) external view returns(uint value) {
require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");
return weiValue.mul(rates[bSymbol].rate).roundedDiv(1000000000000000000);
}
function convertToWei(bytes32 bSymbol, uint value) external view returns(uint weiValue) {
require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");
return value.mul(1000000000000000000).roundedDiv(rates[bSymbol].rate);
}
}
contract SystemAccount is Restricted {
event WithdrawFromSystemAccount(address tokenAddress, address to, uint tokenAmount, uint weiAmount,
string narrative);
constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {}
function withdraw(AugmintToken tokenAddress, address to, uint tokenAmount, uint weiAmount, string narrative)
external restrict("StabilityBoard") {
tokenAddress.transferWithNarrative(to, tokenAmount, narrative);
if (weiAmount > 0) {
to.transfer(weiAmount);
}
emit WithdrawFromSystemAccount(tokenAddress, to, tokenAmount, weiAmount, narrative);
}
}
interface TokenReceiver {
function transferNotification(address from, uint256 amount, uint data) external;
}
interface TransferFeeInterface {
function calculateTransferFee(address from, address to, uint amount) external view returns (uint256 fee);
}
interface ExchangeFeeInterface {
function calculateExchangeFee(uint weiAmount) external view returns (uint256 weiFee);
}
interface ERC20Interface {
event Approval(address indexed _owner, address indexed _spender, uint _value);
event Transfer(address indexed from, address indexed to, uint amount);
function transfer(address to, uint value) external returns (bool);
function transferFrom(address from, address to, uint value) external returns (bool);
function approve(address spender, uint value) external returns (bool);
function balanceOf(address who) external view returns (uint);
function allowance(address _owner, address _spender) external view returns (uint remaining);
}
contract AugmintTokenInterface is Restricted, ERC20Interface {
using SafeMath for uint256;
string public name;
string public symbol;
bytes32 public peggedSymbol;
uint8 public decimals;
uint public totalSupply;
mapping(address => uint256) public balances;
mapping(address => mapping (address => uint256)) public allowed;
address public stabilityBoardProxy;
TransferFeeInterface public feeAccount;
mapping(bytes32 => bool) public delegatedTxHashesUsed;
event TransferFeesChanged(uint transferFeePt, uint transferFeeMin, uint transferFeeMax);
event Transfer(address indexed from, address indexed to, uint amount);
event AugmintTransfer(address indexed from, address indexed to, uint amount, string narrative, uint fee);
event TokenIssued(uint amount);
event TokenBurned(uint amount);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function transfer(address to, uint value) external returns (bool);
function transferFrom(address from, address to, uint value) external returns (bool);
function approve(address spender, uint value) external returns (bool);
function delegatedTransfer(address from, address to, uint amount, string narrative,
bytes signature,
) external;
function delegatedTransferAndNotify(address from, TokenReceiver target, uint amount, uint data,
bytes signature,
) external;
function increaseApproval(address spender, uint addedValue) external returns (bool);
function decreaseApproval(address spender, uint subtractedValue) external returns (bool);
function issueTo(address to, uint amount) external;
function burn(uint amount) external;
function transferAndNotify(TokenReceiver target, uint amount, uint data) external;
function transferWithNarrative(address to, uint256 amount, string narrative) external;
function transferFromWithNarrative(address from, address to, uint256 amount, string narrative) external;
function allowance(address owner, address spender) external view returns (uint256 remaining);
function balanceOf(address who) external view returns (uint);
}
library ECRecovery {
function recover(bytes32 hash, bytes sig)
internal
pure
returns (address)
{
bytes32 r;
bytes32 s;
uint8 v;
if (sig.length != 65) {
return (address(0));
}
assembly {
r := mload(add(sig, 32))
s := mload(add(sig, 64))
v := byte(0, mload(add(sig, 96)))
}
if (v < 27) {
v += 27;
}
if (v != 27 && v != 28) {
return (address(0));
} else {
return ecrecover(hash, v, r, s);
}
}
function toEthSignedMessageHash(bytes32 hash)
internal
pure
returns (bytes32)
{
return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
}
}
contract AugmintToken is AugmintTokenInterface {
event FeeAccountChanged(TransferFeeInterface newFeeAccount);
constructor(address permissionGranterContract, string _name, string _symbol, bytes32 _peggedSymbol, uint8 _decimals, TransferFeeInterface _feeAccount)
public Restricted(permissionGranterContract) {
require(_feeAccount != address(0), "feeAccount must be set");
require(bytes(_name).length > 0, "name must be set");
require(bytes(_symbol).length > 0, "symbol must be set");
name = _name;
symbol = _symbol;
peggedSymbol = _peggedSymbol;
decimals = _decimals;
feeAccount = _feeAccount;
}
function transfer(address to, uint256 amount) external returns (bool) {
_transfer(msg.sender, to, amount, "");
return true;
}
function delegatedTransfer(address from, address to, uint amount, string narrative,
bytes signature,
)
external {
bytes32 txHash = keccak256(abi.encodePacked(this, from, to, amount, narrative, maxExecutorFeeInToken, nonce));
_checkHashAndTransferExecutorFee(txHash, signature, from, maxExecutorFeeInToken, requestedExecutorFeeInToken);
_transfer(from, to, amount, narrative);
}
function approve(address _spender, uint256 amount) external returns (bool) {
require(_spender != 0x0, "spender must be set");
allowed[msg.sender][_spender] = amount;
emit Approval(msg.sender, _spender, amount);
return true;
}
function increaseApproval(address _spender, uint _addedValue) external returns (bool) {
return _increaseApproval(msg.sender, _spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function transferFrom(address from, address to, uint256 amount) external returns (bool) {
_transferFrom(from, to, amount, "");
return true;
}
function issueTo(address to, uint amount) external restrict("MonetarySupervisor") {
balances[to] = balances[to].add(amount);
totalSupply = totalSupply.add(amount);
emit Transfer(0x0, to, amount);
emit AugmintTransfer(0x0, to, amount, "", 0);
}
function burn(uint amount) external {
require(balances[msg.sender] >= amount, "balance must be >= amount");
balances[msg.sender] = balances[msg.sender].sub(amount);
totalSupply = totalSupply.sub(amount);
emit Transfer(msg.sender, 0x0, amount);
emit AugmintTransfer(msg.sender, 0x0, amount, "", 0);
}
function setFeeAccount(TransferFeeInterface newFeeAccount) external restrict("StabilityBoard") {
feeAccount = newFeeAccount;
emit FeeAccountChanged(newFeeAccount);
}
function transferAndNotify(TokenReceiver target, uint amount, uint data) external {
_transfer(msg.sender, target, amount, "");
target.transferNotification(msg.sender, amount, data);
}
function delegatedTransferAndNotify(address from, TokenReceiver target, uint amount, uint data,
bytes signature,
)
external {
bytes32 txHash = keccak256(abi.encodePacked(this, from, target, amount, data, maxExecutorFeeInToken, nonce));
_checkHashAndTransferExecutorFee(txHash, signature, from, maxExecutorFeeInToken, requestedExecutorFeeInToken);
_transfer(from, target, amount, "");
target.transferNotification(from, amount, data);
}
function transferWithNarrative(address to, uint256 amount, string narrative) external {
_transfer(msg.sender, to, amount, narrative);
}
function transferFromWithNarrative(address from, address to, uint256 amount, string narrative) external {
_transferFrom(from, to, amount, narrative);
}
function balanceOf(address _owner) external view returns (uint256 balance) {
return balances[_owner];
}
function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function _checkHashAndTransferExecutorFee(bytes32 txHash, bytes signature, address signer,
uint maxExecutorFeeInToken, uint requestedExecutorFeeInToken) private {
require(requestedExecutorFeeInToken <= maxExecutorFeeInToken, "requestedExecutorFee must be <= maxExecutorFee");
require(!delegatedTxHashesUsed[txHash], "txHash already used");
delegatedTxHashesUsed[txHash] = true;
address recovered = ECRecovery.recover(ECRecovery.toEthSignedMessageHash(txHash), signature);
require(recovered == signer, "invalid signature");
_transfer(signer, msg.sender, requestedExecutorFeeInToken, "Delegated transfer fee", 0);
}
function _increaseApproval(address _approver, address _spender, uint _addedValue) private returns (bool) {
allowed[_approver][_spender] = allowed[_approver][_spender].add(_addedValue);
emit Approval(_approver, _spender, allowed[_approver][_spender]);
}
function _transferFrom(address from, address to, uint256 amount, string narrative) private {
require(balances[from] >= amount, "balance must >= amount");
require(allowed[from][msg.sender] >= amount, "allowance must be >= amount");
require(allowed[from][msg.sender] > 0, "allowance must be >= 0 even with 0 amount");
_transfer(from, to, amount, narrative);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
}
function _transfer(address from, address to, uint transferAmount, string narrative) private {
uint fee = feeAccount.calculateTransferFee(from, to, transferAmount);
_transfer(from, to, transferAmount, narrative, fee);
}
function _transfer(address from, address to, uint transferAmount, string narrative, uint fee) private {
require(to != 0x0, "to must be set");
uint amountWithFee = transferAmount.add(fee);
require(balances[from] >= amountWithFee, "balance must be >= amount + transfer fee");
if (fee > 0) {
balances[feeAccount] = balances[feeAccount].add(fee);
emit Transfer(from, feeAccount, fee);
}
balances[from] = balances[from].sub(amountWithFee);
balances[to] = balances[to].add(transferAmount);
emit Transfer(from, to, transferAmount);
emit AugmintTransfer(from, to, transferAmount, narrative, fee);
}
}
contract FeeAccount is SystemAccount, TransferFeeInterface {
using SafeMath for uint256;
struct TransferFee {
uint pt;
uint min;
uint max;
}
TransferFee public transferFee;
event TransferFeesChanged(uint transferFeePt, uint transferFeeMin, uint transferFeeMax);
constructor(address permissionGranterContract, uint transferFeePt, uint transferFeeMin, uint transferFeeMax)
public SystemAccount(permissionGranterContract) {
transferFee = TransferFee(transferFeePt, transferFeeMin, transferFeeMax);
}
function () public payable {
}
function setTransferFees(uint transferFeePt, uint transferFeeMin, uint transferFeeMax)
external restrict("StabilityBoard") {
transferFee = TransferFee(transferFeePt, transferFeeMin, transferFeeMax);
emit TransferFeesChanged(transferFeePt, transferFeeMin, transferFeeMax);
}
function calculateTransferFee(address from, address to, uint amount) external view returns (uint256 fee) {
if (!permissions[from]["NoTransferFee"] && !permissions[to]["NoTransferFee"]) {
fee = amount.mul(transferFee.pt).div(1000000);
if (fee > transferFee.max) {
fee = transferFee.max;
} else if (fee < transferFee.min) {
fee = transferFee.min;
}
}
return fee;
}
function calculateExchangeFee(uint weiAmount) external view returns (uint256 weiFee) {
require(weiAmount != weiAmount, "not yet implemented");
weiFee = transferFee.max;
}
}
contract InterestEarnedAccount is SystemAccount {
constructor(address permissionGranterContract) public SystemAccount(permissionGranterContract) {}
function transferInterest(AugmintTokenInterface augmintToken, address locker, uint interestAmount)
external restrict("MonetarySupervisor") {
augmintToken.transfer(locker, interestAmount);
}
}
contract AugmintReserves is SystemAccount {
function () public payable {
}
constructor(address permissionGranterContract) public SystemAccount(permissionGranterContract) {}
function burn(AugmintTokenInterface augmintToken, uint amount) external restrict("MonetarySupervisor") {
augmintToken.burn(amount);
}
}
contract MonetarySupervisor is Restricted, TokenReceiver {
using SafeMath for uint256;
uint public constant PERCENT_100 = 1000000;
AugmintTokenInterface public augmintToken;
InterestEarnedAccount public interestEarnedAccount;
AugmintReserves public augmintReserves;
uint public issuedByStabilityBoard;
uint public totalLoanAmount;
uint public totalLockedAmount;
struct LtdParams {
uint  allowedDifferenceAmount;
}
LtdParams public ltdParams;
mapping(address => bool) public acceptedLegacyAugmintTokens;
event LtdParamsChanged(uint lockDifferenceLimit, uint loanDifferenceLimit, uint allowedDifferenceAmount);
event AcceptedLegacyAugmintTokenChanged(address augmintTokenAddress, bool newAcceptedState);
event LegacyTokenConverted(address oldTokenAddress, address account, uint amount);
event KPIsAdjusted(uint totalLoanAmountAdjustment, uint totalLockedAmountAdjustment);
event SystemContractsChanged(InterestEarnedAccount newInterestEarnedAccount, AugmintReserves newAugmintReserves);
constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken, AugmintReserves _augmintReserves,
InterestEarnedAccount _interestEarnedAccount,
uint lockDifferenceLimit, uint loanDifferenceLimit, uint allowedDifferenceAmount)
public Restricted(permissionGranterContract) {
augmintToken = _augmintToken;
augmintReserves = _augmintReserves;
interestEarnedAccount = _interestEarnedAccount;
ltdParams = LtdParams(lockDifferenceLimit, loanDifferenceLimit, allowedDifferenceAmount);
}
function issueToReserve(uint amount) external restrict("StabilityBoard") {
issuedByStabilityBoard = issuedByStabilityBoard.add(amount);
augmintToken.issueTo(augmintReserves, amount);
}
function burnFromReserve(uint amount) external restrict("StabilityBoard") {
issuedByStabilityBoard = issuedByStabilityBoard.sub(amount);
augmintReserves.burn(augmintToken, amount);
}
function requestInterest(uint amountToLock, uint interestAmount) external {
require(permissions[msg.sender]["Locker"], "msg.sender must have Locker permission");
require(amountToLock <= getMaxLockAmountAllowedByLtd(), "amountToLock must be <= maxLockAmountAllowedByLtd");
totalLockedAmount = totalLockedAmount.add(amountToLock);
require(augmintToken.balanceOf(address(interestEarnedAccount)) >= interestAmount,
"interestEarnedAccount balance must be >= interestAmount");
interestEarnedAccount.transferInterest(augmintToken, msg.sender, interestAmount);
}
function releaseFundsNotification(uint lockedAmount) external {
require(permissions[msg.sender]["Locker"], "msg.sender must have Locker permission");
totalLockedAmount = totalLockedAmount.sub(lockedAmount);
}
function issueLoan(address borrower, uint loanAmount) external {
require(permissions[msg.sender]["LoanManager"],
"msg.sender must have LoanManager permission");
require(loanAmount <= getMaxLoanAmountAllowedByLtd(), "loanAmount must be <= maxLoanAmountAllowedByLtd");
totalLoanAmount = totalLoanAmount.add(loanAmount);
augmintToken.issueTo(borrower, loanAmount);
}
function loanRepaymentNotification(uint loanAmount) external {
require(permissions[msg.sender]["LoanManager"],
"msg.sender must have LoanManager permission");
totalLoanAmount = totalLoanAmount.sub(loanAmount);
}
function loanCollectionNotification(uint totalLoanAmountCollected) external {
require(permissions[msg.sender]["LoanManager"],
"msg.sender must have LoanManager permission");
totalLoanAmount = totalLoanAmount.sub(totalLoanAmountCollected);
}
function setAcceptedLegacyAugmintToken(address legacyAugmintTokenAddress, bool newAcceptedState)
external restrict("StabilityBoard") {
acceptedLegacyAugmintTokens[legacyAugmintTokenAddress] = newAcceptedState;
emit AcceptedLegacyAugmintTokenChanged(legacyAugmintTokenAddress, newAcceptedState);
}
function setLtdParams(uint lockDifferenceLimit, uint loanDifferenceLimit, uint allowedDifferenceAmount)
external restrict("StabilityBoard") {
ltdParams = LtdParams(lockDifferenceLimit, loanDifferenceLimit, allowedDifferenceAmount);
emit LtdParamsChanged(lockDifferenceLimit, loanDifferenceLimit, allowedDifferenceAmount);
}
function adjustKPIs(uint totalLoanAmountAdjustment, uint totalLockedAmountAdjustment)
external restrict("StabilityBoard") {
totalLoanAmount = totalLoanAmount.add(totalLoanAmountAdjustment);
totalLockedAmount = totalLockedAmount.add(totalLockedAmountAdjustment);
emit KPIsAdjusted(totalLoanAmountAdjustment, totalLockedAmountAdjustment);
}
function setSystemContracts(InterestEarnedAccount newInterestEarnedAccount, AugmintReserves newAugmintReserves)
external restrict("StabilityBoard") {
interestEarnedAccount = newInterestEarnedAccount;
augmintReserves = newAugmintReserves;
emit SystemContractsChanged(newInterestEarnedAccount, newAugmintReserves);
}
AugmintTokenInterface legacyToken = AugmintTokenInterface(msg.sender);
require(acceptedLegacyAugmintTokens[legacyToken], "msg.sender must be allowed in acceptedLegacyAugmintTokens");
legacyToken.burn(amount);
augmintToken.issueTo(from, amount);
emit LegacyTokenConverted(msg.sender, from, amount);
}
function getLoanToDepositRatio() external view returns (uint loanToDepositRatio) {
loanToDepositRatio = totalLockedAmount == 0 ? 0 : totalLockedAmount.mul(PERCENT_100).div(totalLoanAmount);
}
function getMaxLockAmount(uint minLockAmount, uint interestPt) external view returns (uint maxLock) {
uint allowedByEarning = augmintToken.balanceOf(address(interestEarnedAccount)).mul(PERCENT_100).div(interestPt);
uint allowedByLtd = getMaxLockAmountAllowedByLtd();
maxLock = allowedByEarning < allowedByLtd ? allowedByEarning : allowedByLtd;
maxLock = maxLock < minLockAmount ? 0 : maxLock;
}
function getMaxLoanAmount(uint minLoanAmount) external view returns (uint maxLoan) {
uint allowedByLtd = getMaxLoanAmountAllowedByLtd();
maxLoan = allowedByLtd < minLoanAmount ? 0 : allowedByLtd;
}
function getMaxLockAmountAllowedByLtd() public view returns(uint maxLockByLtd) {
uint allowedByLtdDifferencePt = totalLoanAmount.mul(PERCENT_100).div(PERCENT_100
.sub(ltdParams.lockDifferenceLimit));
allowedByLtdDifferencePt = totalLockedAmount >= allowedByLtdDifferencePt ?
0 : allowedByLtdDifferencePt.sub(totalLockedAmount);
uint allowedByLtdDifferenceAmount =
totalLockedAmount >= totalLoanAmount.add(ltdParams.allowedDifferenceAmount) ?
0 : totalLoanAmount.add(ltdParams.allowedDifferenceAmount).sub(totalLockedAmount);
maxLockByLtd = allowedByLtdDifferencePt > allowedByLtdDifferenceAmount ?
allowedByLtdDifferencePt : allowedByLtdDifferenceAmount;
}
function getMaxLoanAmountAllowedByLtd() public view returns(uint maxLoanByLtd) {
uint allowedByLtdDifferencePt = totalLockedAmount.mul(ltdParams.loanDifferenceLimit.add(PERCENT_100))
.div(PERCENT_100);
allowedByLtdDifferencePt = totalLoanAmount >= allowedByLtdDifferencePt ?
0 : allowedByLtdDifferencePt.sub(totalLoanAmount);
uint allowedByLtdDifferenceAmount =
totalLoanAmount >= totalLockedAmount.add(ltdParams.allowedDifferenceAmount) ?
0 : totalLockedAmount.add(ltdParams.allowedDifferenceAmount).sub(totalLoanAmount);
maxLoanByLtd = allowedByLtdDifferencePt > allowedByLtdDifferenceAmount ?
allowedByLtdDifferencePt : allowedByLtdDifferenceAmount;
}
}
pragma solidity 0.4.24;
contract Exchange is Restricted {
using SafeMath for uint256;
AugmintTokenInterface public augmintToken;
Rates public rates;
uint public constant CHUNK_SIZE = 100;
struct Order {
uint64 index;
address maker;
uint32 price;
uint amount;
}
uint64 public orderCount;
mapping(uint64 => Order) public buyTokenOrders;
mapping(uint64 => Order) public sellTokenOrders;
uint64[] private activeBuyOrders;
uint64[] private activeSellOrders;
uint32 private constant ORDER_MATCH_WORST_GAS = 100000;
event NewOrder(uint64 indexed orderId, address indexed maker, uint32 price, uint tokenAmount, uint weiAmount);
event OrderFill(address indexed tokenBuyer, address indexed tokenSeller, uint64 buyTokenOrderId,
uint64 sellTokenOrderId, uint publishedRate, uint32 price, uint fillRate, uint weiAmount, uint tokenAmount);
event CancelledOrder(uint64 indexed orderId, address indexed maker, uint tokenAmount, uint weiAmount);
event RatesContractChanged(Rates newRatesContract);
constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken, Rates _rates)
public Restricted(permissionGranterContract) {
augmintToken = _augmintToken;
rates = _rates;
}
function setRatesContract(Rates newRatesContract)
external restrict("StabilityBoard") {
rates = newRatesContract;
emit RatesContractChanged(newRatesContract);
}
function placeBuyTokenOrder(uint32 price) external payable returns (uint64 orderId) {
require(price > 0, "price must be > 0");
require(msg.value > 0, "msg.value must be > 0");
orderId = ++orderCount;
buyTokenOrders[orderId] = Order(uint64(activeBuyOrders.length), msg.sender, price, msg.value);
activeBuyOrders.push(orderId);
emit NewOrder(orderId, msg.sender, price, 0, msg.value);
}
function placeSellTokenOrder(uint32 price, uint tokenAmount) external returns (uint orderId) {
augmintToken.transferFrom(msg.sender, this, tokenAmount);
return _placeSellTokenOrder(msg.sender, price, tokenAmount);
}
function transferNotification(address maker, uint tokenAmount, uint price) external {
require(msg.sender == address(augmintToken), "msg.sender must be augmintToken");
_placeSellTokenOrder(maker, uint32(price), tokenAmount);
}
function cancelBuyTokenOrder(uint64 buyTokenId) external {
Order storage order = buyTokenOrders[buyTokenId];
require(order.maker == msg.sender, "msg.sender must be order.maker");
require(order.amount > 0, "buy order already removed");
uint amount = order.amount;
order.amount = 0;
_removeBuyOrder(order);
msg.sender.transfer(amount);
emit CancelledOrder(buyTokenId, msg.sender, 0, amount);
}
function cancelSellTokenOrder(uint64 sellTokenId) external {
Order storage order = sellTokenOrders[sellTokenId];
require(order.maker == msg.sender, "msg.sender must be order.maker");
require(order.amount > 0, "sell order already removed");
uint amount = order.amount;
order.amount = 0;
_removeSellOrder(order);
augmintToken.transferWithNarrative(msg.sender, amount, "Sell token order cancelled");
emit CancelledOrder(sellTokenId, msg.sender, amount, 0);
}
function matchOrders(uint64 buyTokenId, uint64 sellTokenId) external {
require(_fillOrder(buyTokenId, sellTokenId), "fill order failed");
}
function matchMultipleOrders(uint64[] buyTokenIds, uint64[] sellTokenIds) external returns(uint matchCount) {
uint len = buyTokenIds.length;
require(len == sellTokenIds.length, "buyTokenIds and sellTokenIds lengths must be equal");
for (uint i = 0; i < len && gasleft() > ORDER_MATCH_WORST_GAS; i++) {
if(_fillOrder(buyTokenIds[i], sellTokenIds[i])) {
matchCount++;
}
}
}
function getActiveOrderCounts() external view returns(uint buyTokenOrderCount, uint sellTokenOrderCount) {
return(activeBuyOrders.length, activeSellOrders.length);
}
function getActiveBuyOrders(uint offset) external view returns (uint[4][CHUNK_SIZE] response) {
for (uint8 i = 0; i < CHUNK_SIZE && i + offset < activeBuyOrders.length; i++) {
uint64 orderId = activeBuyOrders[offset + i];
Order storage order = buyTokenOrders[orderId];
response[i] = [orderId, uint(order.maker), order.price, order.amount];
}
}
function getActiveSellOrders(uint offset) external view returns (uint[4][CHUNK_SIZE] response) {
for (uint8 i = 0; i < CHUNK_SIZE && i + offset < activeSellOrders.length; i++) {
uint64 orderId = activeSellOrders[offset + i];
Order storage order = sellTokenOrders[orderId];
response[i] = [orderId, uint(order.maker), order.price, order.amount];
}
}
function _fillOrder(uint64 buyTokenId, uint64 sellTokenId) private returns(bool success) {
Order storage buy = buyTokenOrders[buyTokenId];
Order storage sell = sellTokenOrders[sellTokenId];
if( buy.amount == 0 || sell.amount == 0 ) {
return false;
}
require(buy.price >= sell.price, "buy price must be >= sell price");
uint32 price = buyTokenId > sellTokenId ? sell.price : buy.price;
uint publishedRate;
(publishedRate, ) = rates.rates(augmintToken.peggedSymbol());
uint fillRate = publishedRate.mul(price).roundedDiv(1000000);
uint sellWei = sell.amount.mul(1 ether).roundedDiv(fillRate);
uint tradedWei;
uint tradedTokens;
if (sellWei <= buy.amount) {
tradedWei = sellWei;
tradedTokens = sell.amount;
} else {
tradedWei = buy.amount;
tradedTokens = buy.amount.mul(fillRate).roundedDiv(1 ether);
}
buy.amount = buy.amount.sub(tradedWei);
if (buy.amount == 0) {
_removeBuyOrder(buy);
}
sell.amount = sell.amount.sub(tradedTokens);
if (sell.amount == 0) {
_removeSellOrder(sell);
}
augmintToken.transferWithNarrative(buy.maker, tradedTokens, "Buy token order fill");
sell.maker.transfer(tradedWei);
emit OrderFill(buy.maker, sell.maker, buyTokenId,
sellTokenId, publishedRate, price, fillRate, tradedWei, tradedTokens);
return true;
}
function _placeSellTokenOrder(address maker, uint32 price, uint tokenAmount)
private returns (uint64 orderId) {
require(price > 0, "price must be > 0");
require(tokenAmount > 0, "tokenAmount must be > 0");
orderId = ++orderCount;
sellTokenOrders[orderId] = Order(uint64(activeSellOrders.length), maker, price, tokenAmount);
activeSellOrders.push(orderId);
emit NewOrder(orderId, maker, price, tokenAmount, 0);
}
function _removeBuyOrder(Order storage order) private {
_removeOrder(activeBuyOrders, order.index);
}
function _removeSellOrder(Order storage order) private {
_removeOrder(activeSellOrders, order.index);
}
function _removeOrder(uint64[] storage orders, uint64 index) private {
if (index < orders.length - 1) {
orders[index] = orders[orders.length - 1];
}
orders.length--;
}
}
contract TokenAEur is AugmintToken {
constructor(address _permissionGranterContract, TransferFeeInterface _feeAccount)
public AugmintToken(_permissionGranterContract, "Augmint Crypto Euro", "AEUR", "EUR", 2, _feeAccount)
{}
}
contract LoanManager is Restricted {
using SafeMath for uint256;
uint16 public constant CHUNK_SIZE = 100;
enum LoanState { Open, Repaid, Defaulted, Collected }
struct LoanProduct {
uint minDisbursedAmount;
uint32 term;
uint32 discountRate;
uint32 collateralRatio;
uint32 defaultingFeePt;
bool isActive;
}
struct LoanData {
uint collateralAmount;
uint repaymentAmount;
address borrower;
uint32 productId;
LoanState state;
uint40 maturity;
}
LoanProduct[] public products;
LoanData[] public loans;
mapping(address => uint[]) public accountLoans;
Rates public rates;
AugmintTokenInterface public augmintToken;
MonetarySupervisor public monetarySupervisor;
event NewLoan(uint32 productId, uint loanId, address indexed borrower, uint collateralAmount, uint loanAmount,
uint repaymentAmount, uint40 maturity);
event LoanProductActiveStateChanged(uint32 productId, bool newState);
event LoanProductAdded(uint32 productId);
event LoanRepayed(uint loanId, address borrower);
event LoanCollected(uint loanId, address indexed borrower, uint collectedCollateral,
uint releasedCollateral, uint defaultingFee);
event SystemContractsChanged(Rates newRatesContract, MonetarySupervisor newMonetarySupervisor);
constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken,
MonetarySupervisor _monetarySupervisor, Rates _rates)
public Restricted(permissionGranterContract) {
augmintToken = _augmintToken;
monetarySupervisor = _monetarySupervisor;
rates = _rates;
}
function addLoanProduct(uint32 term, uint32 discountRate, uint32 collateralRatio, uint minDisbursedAmount,
uint32 defaultingFeePt, bool isActive)
external restrict("StabilityBoard") {
uint _newProductId = products.push(
LoanProduct(minDisbursedAmount, term, discountRate, collateralRatio, defaultingFeePt, isActive)
) - 1;
uint32 newProductId = uint32(_newProductId);
require(newProductId == _newProductId, "productId overflow");
emit LoanProductAdded(newProductId);
}
function setLoanProductActiveState(uint32 productId, bool newState)
external restrict ("StabilityBoard") {
require(productId < products.length, "invalid productId");
products[productId].isActive = false;
emit LoanProductActiveStateChanged(productId, newState);
}
function newEthBackedLoan(uint32 productId) external payable {
require(productId < products.length, "invalid productId");
LoanProduct storage product = products[productId];
require(product.isActive, "product must be in active state");
uint tokenValue = rates.convertFromWei(augmintToken.peggedSymbol(), msg.value);
uint repaymentAmount = tokenValue.mul(product.collateralRatio).div(1000000);
uint loanAmount;
(loanAmount, ) = calculateLoanValues(product, repaymentAmount);
require(loanAmount >= product.minDisbursedAmount, "loanAmount must be >= minDisbursedAmount");
uint expiration = now.add(product.term);
uint40 maturity = uint40(expiration);
require(maturity == expiration, "maturity overflow");
uint loanId = loans.push(LoanData(msg.value, repaymentAmount, msg.sender,
productId, LoanState.Open, maturity)) - 1;
accountLoans[msg.sender].push(loanId);
monetarySupervisor.issueLoan(msg.sender, loanAmount);
emit NewLoan(productId, loanId, msg.sender, msg.value, loanAmount, repaymentAmount, maturity);
}
function transferNotification(address, uint repaymentAmount, uint loanId) external {
require(msg.sender == address(augmintToken), "msg.sender must be augmintToken");
_repayLoan(loanId, repaymentAmount);
}
function collect(uint[] loanIds) external {
uint totalLoanAmountCollected;
uint totalCollateralToCollect;
uint totalDefaultingFee;
for (uint i = 0; i < loanIds.length; i++) {
require(i < loans.length, "invalid loanId");
LoanData storage loan = loans[loanIds[i]];
require(loan.state == LoanState.Open, "loan state must be Open");
require(now >= loan.maturity, "current time must be later than maturity");
LoanProduct storage product = products[loan.productId];
uint loanAmount;
(loanAmount, ) = calculateLoanValues(product, loan.repaymentAmount);
totalLoanAmountCollected = totalLoanAmountCollected.add(loanAmount);
loan.state = LoanState.Collected;
uint defaultingFeeInToken = loan.repaymentAmount.mul(product.defaultingFeePt).div(1000000);
uint defaultingFee = rates.convertToWei(augmintToken.peggedSymbol(), defaultingFeeInToken);
uint targetCollection = rates.convertToWei(augmintToken.peggedSymbol(),
loan.repaymentAmount).add(defaultingFee);
uint releasedCollateral;
if (targetCollection < loan.collateralAmount) {
releasedCollateral = loan.collateralAmount.sub(targetCollection);
loan.borrower.transfer(releasedCollateral);
}
uint collateralToCollect = loan.collateralAmount.sub(releasedCollateral);
if (defaultingFee >= collateralToCollect) {
defaultingFee = collateralToCollect;
collateralToCollect = 0;
} else {
collateralToCollect = collateralToCollect.sub(defaultingFee);
}
totalDefaultingFee = totalDefaultingFee.add(defaultingFee);
totalCollateralToCollect = totalCollateralToCollect.add(collateralToCollect);
emit LoanCollected(loanIds[i], loan.borrower, collateralToCollect.add(defaultingFee), releasedCollateral, defaultingFee);
}
if (totalCollateralToCollect > 0) {
address(monetarySupervisor.augmintReserves()).transfer(totalCollateralToCollect);
}
if (totalDefaultingFee > 0){
address(augmintToken.feeAccount()).transfer(totalDefaultingFee);
}
monetarySupervisor.loanCollectionNotification(totalLoanAmountCollected);
}
function setSystemContracts(Rates newRatesContract, MonetarySupervisor newMonetarySupervisor)
external restrict("StabilityBoard") {
rates = newRatesContract;
monetarySupervisor = newMonetarySupervisor;
emit SystemContractsChanged(newRatesContract, newMonetarySupervisor);
}
function getProductCount() external view returns (uint ct) {
return products.length;
}
function getProducts(uint offset) external view returns (uint[8][CHUNK_SIZE] response) {
for (uint16 i = 0; i < CHUNK_SIZE; i++) {
if (offset + i >= products.length) { break; }
LoanProduct storage product = products[offset + i];
response[i] = [offset + i, product.minDisbursedAmount, product.term, product.discountRate,
product.collateralRatio, product.defaultingFeePt,
monetarySupervisor.getMaxLoanAmount(product.minDisbursedAmount), product.isActive ? 1 : 0 ];
}
}
function getLoanCount() external view returns (uint ct) {
return loans.length;
}
function getLoans(uint offset) external view returns (uint[10][CHUNK_SIZE] response) {
for (uint16 i = 0; i < CHUNK_SIZE; i++) {
if (offset + i >= loans.length) { break; }
response[i] = getLoanTuple(offset + i);
}
}
function getLoanCountForAddress(address borrower) external view returns (uint) {
return accountLoans[borrower].length;
}
function getLoansForAddress(address borrower, uint offset) external view returns (uint[10][CHUNK_SIZE] response) {
uint[] storage loansForAddress = accountLoans[borrower];
for (uint16 i = 0; i < CHUNK_SIZE; i++) {
if (offset + i >= loansForAddress.length) { break; }
response[i] = getLoanTuple(loansForAddress[offset + i]);
}
}
function getLoanTuple(uint loanId) public view returns (uint[10] result) {
require(loanId < loans.length, "invalid loanId");
LoanData storage loan = loans[loanId];
LoanProduct storage product = products[loan.productId];
uint loanAmount;
uint interestAmount;
(loanAmount, interestAmount) = calculateLoanValues(product, loan.repaymentAmount);
uint disbursementTime = loan.maturity - product.term;
LoanState loanState =
loan.state == LoanState.Open && now >= loan.maturity ? LoanState.Defaulted : loan.state;
result = [loanId, loan.collateralAmount, loan.repaymentAmount, uint(loan.borrower),
loan.productId, uint(loanState), loan.maturity, disbursementTime, loanAmount, interestAmount];
}
function calculateLoanValues(LoanProduct storage product, uint repaymentAmount)
internal view returns (uint loanAmount, uint interestAmount) {
loanAmount = repaymentAmount.mul(product.discountRate).div(1000000);
interestAmount = loanAmount > repaymentAmount ? 0 : repaymentAmount.sub(loanAmount);
}
function _repayLoan(uint loanId, uint repaymentAmount) internal {
require(loanId < loans.length, "invalid loanId");
LoanData storage loan = loans[loanId];
require(loan.state == LoanState.Open, "loan state must be Open");
require(repaymentAmount == loan.repaymentAmount, "repaymentAmount must be equal to tokens sent");
require(now <= loan.maturity, "current time must be earlier than maturity");
LoanProduct storage product = products[loan.productId];
uint loanAmount;
uint interestAmount;
(loanAmount, interestAmount) = calculateLoanValues(product, loan.repaymentAmount);
loans[loanId].state = LoanState.Repaid;
if (interestAmount > 0) {
augmintToken.transfer(monetarySupervisor.interestEarnedAccount(), interestAmount);
augmintToken.burn(loanAmount);
} else {
augmintToken.burn(repaymentAmount);
}
monetarySupervisor.loanRepaymentNotification(loanAmount);
loan.borrower.transfer(loan.collateralAmount);
emit LoanRepayed(loanId, loan.borrower);
}
}
contract Locker is Restricted, TokenReceiver {
using SafeMath for uint256;
uint public constant CHUNK_SIZE = 100;
event NewLockProduct(uint32 indexed lockProductId, uint32 perTermInterest, uint32 durationInSecs,
uint32 minimumLockAmount, bool isActive);
event LockProductActiveChange(uint32 indexed lockProductId, bool newActiveState);
event NewLock(address indexed lockOwner, uint lockId, uint amountLocked, uint interestEarned,
uint40 lockedUntil, uint32 perTermInterest, uint32 durationInSecs);
event LockReleased(address indexed lockOwner, uint lockId);
event MonetarySupervisorChanged(MonetarySupervisor newMonetarySupervisor);
struct LockProduct {
uint32 perTermInterest;
uint32 durationInSecs;
uint32 minimumLockAmount;
bool isActive;
}
struct Lock {
uint amountLocked;
address owner;
uint32 productId;
uint40 lockedUntil;
bool isActive;
}
AugmintTokenInterface public augmintToken;
MonetarySupervisor public monetarySupervisor;
LockProduct[] public lockProducts;
Lock[] public locks;
mapping(address => uint[]) public accountLocks;
constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken,
MonetarySupervisor _monetarySupervisor)
public Restricted(permissionGranterContract) {
augmintToken = _augmintToken;
monetarySupervisor = _monetarySupervisor;
}
function addLockProduct(uint32 perTermInterest, uint32 durationInSecs, uint32 minimumLockAmount, bool isActive)
external restrict("StabilityBoard") {
uint _newLockProductId = lockProducts.push(
LockProduct(perTermInterest, durationInSecs, minimumLockAmount, isActive)) - 1;
uint32 newLockProductId = uint32(_newLockProductId);
require(newLockProductId == _newLockProductId, "lockProduct overflow");
emit NewLockProduct(newLockProductId, perTermInterest, durationInSecs, minimumLockAmount, isActive);
}
function setLockProductActiveState(uint32 lockProductId, bool isActive) external restrict("StabilityBoard") {
require(lockProductId < lockProducts.length, "invalid lockProductId");
lockProducts[lockProductId].isActive = isActive;
emit LockProductActiveChange(lockProductId, isActive);
}
function transferNotification(address from, uint256 amountToLock, uint _lockProductId) external {
require(msg.sender == address(augmintToken), "msg.sender must be augmintToken");
require(lockProductId < lockProducts.length, "invalid lockProductId");
uint32 lockProductId = uint32(_lockProductId);
require(lockProductId == _lockProductId, "lockProductId overflow");
_createLock(lockProductId, from, amountToLock);
}
function releaseFunds(uint lockId) external {
require(lockId < locks.length, "invalid lockId");
Lock storage lock = locks[lockId];
LockProduct storage lockProduct = lockProducts[lock.productId];
require(lock.isActive, "lock must be in active state");
require(now >= lock.lockedUntil, "current time must be later than lockedUntil");
lock.isActive = false;
uint interestEarned = calculateInterest(lockProduct.perTermInterest, lock.amountLocked);
monetarySupervisor.releaseFundsNotification(lock.amountLocked);
augmintToken.transferWithNarrative(lock.owner, lock.amountLocked.add(interestEarned),
"Funds released from lock");
emit LockReleased(lock.owner, lockId);
}
function setMonetarySupervisor(MonetarySupervisor newMonetarySupervisor) external restrict("StabilityBoard") {
monetarySupervisor = newMonetarySupervisor;
emit MonetarySupervisorChanged(newMonetarySupervisor);
}
function getLockProductCount() external view returns (uint) {
return lockProducts.length;
}
function getLockProducts(uint offset) external view returns (uint[5][CHUNK_SIZE] response) {
for (uint8 i = 0; i < CHUNK_SIZE; i++) {
if (offset + i >= lockProducts.length) { break; }
LockProduct storage lockProduct = lockProducts[offset + i];
response[i] = [ lockProduct.perTermInterest, lockProduct.durationInSecs, lockProduct.minimumLockAmount,
monetarySupervisor.getMaxLockAmount(lockProduct.minimumLockAmount, lockProduct.perTermInterest),
lockProduct.isActive ? 1 : 0 ];
}
}
function getLockCount() external view returns (uint) {
return locks.length;
}
function getLockCountForAddress(address lockOwner) external view returns (uint) {
return accountLocks[lockOwner].length;
}
function getLocks(uint offset) external view returns (uint[8][CHUNK_SIZE] response) {
for (uint16 i = 0; i < CHUNK_SIZE; i++) {
if (offset + i >= locks.length) { break; }
Lock storage lock = locks[offset + i];
LockProduct storage lockProduct = lockProducts[lock.productId];
uint interestEarned = calculateInterest(lockProduct.perTermInterest, lock.amountLocked);
response[i] = [uint(offset + i), uint(lock.owner), lock.amountLocked, interestEarned, lock.lockedUntil,
lockProduct.perTermInterest, lockProduct.durationInSecs, lock.isActive ? 1 : 0];
}
}
function getLocksForAddress(address lockOwner, uint offset) external view returns (uint[7][CHUNK_SIZE] response) {
uint[] storage locksForAddress = accountLocks[lockOwner];
for (uint16 i = 0; i < CHUNK_SIZE; i++) {
if (offset + i >= locksForAddress.length) { break; }
Lock storage lock = locks[locksForAddress[offset + i]];
LockProduct storage lockProduct = lockProducts[lock.productId];
uint interestEarned = calculateInterest(lockProduct.perTermInterest, lock.amountLocked);
response[i] = [ locksForAddress[offset + i], lock.amountLocked, interestEarned, lock.lockedUntil,
lockProduct.perTermInterest, lockProduct.durationInSecs, lock.isActive ? 1 : 0 ];
}
}
function calculateInterest(uint32 perTermInterest, uint amountToLock) public pure returns (uint interestEarned) {
interestEarned = amountToLock.mul(perTermInterest).div(1000000);
}
function _createLock(uint32 lockProductId, address lockOwner, uint amountToLock) internal returns(uint lockId) {
LockProduct storage lockProduct = lockProducts[lockProductId];
require(lockProduct.isActive, "lockProduct must be in active state");
require(amountToLock >= lockProduct.minimumLockAmount, "amountToLock must be >= minimumLockAmount");
uint interestEarned = calculateInterest(lockProduct.perTermInterest, amountToLock);
uint expiration = now.add(lockProduct.durationInSecs);
uint40 lockedUntil = uint40(expiration);
require(lockedUntil == expiration, "lockedUntil overflow");
lockId = locks.push(Lock(amountToLock, lockOwner, lockProductId, lockedUntil, true)) - 1;
accountLocks[lockOwner].push(lockId);
monetarySupervisor.requestInterest(amountToLock, interestEarned);
emit NewLock(lockOwner, lockId, amountToLock, interestEarned, lockedUntil, lockProduct.perTermInterest,
lockProduct.durationInSecs);
}
}