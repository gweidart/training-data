pragma solidity 0.4.24;
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function burnToken(uint256 _burnedAmount) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract admined {
mapping(address => uint8) level;
constructor() internal {
level[0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B] = 2;
emit AdminshipUpdated(0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B,2);
}
modifier onlyAdmin(uint8 _level) {
require(level[msg.sender] >= _level );
_;
}
function adminshipLevel(address _newAdmin, uint8 _level) onlyAdmin(2) public {
require(_newAdmin != address(0));
level[_newAdmin] = _level;
emit AdminshipUpdated(_newAdmin,_level);
}
event AdminshipUpdated(address _newAdmin, uint8 _level);
}
contract CircaICO is admined {
using SafeMath for uint256;
enum State {
PreSale,
MainSale,
Successful
}
State public state = State.PreSale;
uint256 constant public PreSaleStart = 1532908800;
uint256 constant public PreSaleDeadline = 1534118399;
uint256 constant public MainSaleStart = 1535155200;
uint256 constant public MainSaleDeadline = 1536105599;
uint256 public completedAt;
uint256 public totalRaised;
uint256 public PreSaleDistributed;
uint256 public MainSaleDistributed;
uint256 public PreSaleLimit = 260000000 * (10 ** 18);
uint256 public mainSale1Limit = 190000000 * (10 ** 18);
uint256 public totalDistributed;
ERC20Basic public tokenReward;
uint256 public hardCap = 640000000 * (10 ** 18);
address public creator;
string public version = '1';
bool ended = false;
uint256[3] rates = [45000,35000,28000];
event LogFundrisingInitialized(address _creator);
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogContributorsPayout(address _addr, uint _amount);
event LogFundingSuccessful(uint _totalRaised);
modifier notFinished() {
require(state != State.Successful);
_;
}
constructor(ERC20Basic _addressOfTokenUsedAsReward) public {
creator = 0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B;
tokenReward = _addressOfTokenUsedAsReward;
emit LogFundrisingInitialized(creator);
}
function contribute() public notFinished payable {
require(msg.value <= 500 ether);
uint256 tokenBought = 0;
totalRaised = totalRaised.add(msg.value);
if (state == State.PreSale){
require(now >= PreSaleStart);
tokenBought = msg.value.mul(rates[0]);
if(PreSaleDistributed <= 30000000 * (10**18)){
tokenBought = tokenBought.mul(12);
tokenBought = tokenBought.div(10);
} else if (PreSaleDistributed <= 50000000 * (10**18)){
tokenBought = tokenBought.mul(11);
tokenBought = tokenBought.div(10);
}
PreSaleDistributed = PreSaleDistributed.add(tokenBought);
} else if (state == State.MainSale){
require(now >= MainSaleStart);
if(MainSaleDistributed < mainSale1Limit){
tokenBought = msg.value.mul(rates[1]);
if(MainSaleDistributed <= 80000000 * (10**18)){
tokenBought = tokenBought.mul(12);
tokenBought = tokenBought.div(10);
}
} else tokenBought = msg.value.mul(rates[2]);
MainSaleDistributed = MainSaleDistributed.add(tokenBought);
}
totalDistributed = totalDistributed.add(tokenBought);
require(totalDistributed <= hardCap);
require(tokenReward.transfer(msg.sender, tokenBought));
emit LogContributorsPayout(msg.sender, tokenBought);
emit LogFundingReceived(msg.sender, msg.value, totalRaised);
checkIfFundingCompleteOrExpired();
}
function checkIfFundingCompleteOrExpired() public {
if (totalDistributed == hardCap && state != State.Successful){
state = State.Successful;
completedAt = now;
emit LogFundingSuccessful(totalRaised);
successful();
} else if(state == State.PreSale && PreSaleDistributed >= PreSaleLimit){
state = State.MainSale;
}
}
function forceNextStage() onlyAdmin(2) public {
if(state == State.PreSale && now > PreSaleDeadline){
state = State.MainSale;
} else if (state == State.MainSale && now > MainSaleDeadline ){
state = State.Successful;
completedAt = now;
emit LogFundingSuccessful(totalRaised);
successful();
} else revert();
}
function successful() public {
require(state == State.Successful);
if(ended == false){
ended = true;
uint256 remanent = hardCap.sub(totalDistributed);
require(tokenReward.burnToken(remanent));
}
creator.transfer(address(this).balance);
emit LogBeneficiaryPaid(creator);
}
function ethRetrieve() onlyAdmin(2) public {
creator.transfer(address(this).balance);
emit LogBeneficiaryPaid(creator);
}
function externalTokensRecovery(ERC20Basic _address) onlyAdmin(2) public{
require(state == State.Successful);
uint256 remainder = _address.balanceOf(this);
_address.transfer(msg.sender,remainder);
}
function () public payable {
contribute();
}
}