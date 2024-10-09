pragma solidity ^0.4.11;
contract DoNotBloodyDeployThisGetTheRightOne {
uint256 nothing;
function DoNotBloodyDeployThisGetTheRightOne() {
nothing = 27;
}
}
modifier whenNotPaused() {
require (!paused);
_;
}
modifier whenPaused {
require (paused) ;
_;
}
function pause() onlyOwner whenNotPaused returns (bool) {
paused = true;
Pause();
return true;
}
function unpause() onlyOwner whenPaused returns (bool) {
paused = false;
Unpause();
return true;
}
}
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4);
_;
}
mapping(address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  returns (bool success){
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from], _value);
allowed[_from][msg.sender] = safeSub(_allowance, _value);
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint balance) {
return balances[_owner];
}
function approve(address _spender, uint _value) returns (bool success) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
}
contract GBT {
function parentChange(address,uint);
function parentFees(address);
function setHGT(address _hgt);
}
mapping (address => Balance) public balances;
mapping (address => mapping (address => uint)) allowed;
function update(address where) internal {
uint256 pos;
uint256 fees;
uint256 val;
(val,fees,pos) = updatedBalance(where);
balances[where].nextAllocationIndex = pos;
balances[where].amount = val;
balances[where].lastUpdated = now;
}
function updatedBalance(address where) constant public returns (uint val, uint fees, uint pos) {
uint256 c_val;
uint256 c_fees;
uint256 c_amount;
(val, fees) = calcFees(balances[where].lastUpdated,now,balances[where].amount);
pos = balances[where].nextAllocationIndex;
if ((pos < currentAllocations.length) &&  (balances[where].allocationShare != 0)) {
c_amount = currentAllocations[balances[where].nextAllocationIndex].amount * balances[where].allocationShare / allocationPool;
(c_val,c_fees)   = calcFees(currentAllocations[balances[where].nextAllocationIndex].date,now,c_amount);
}
val  += c_val;
fees += c_fees;
pos   = currentAllocations.length;
}
function balanceOf(address where) constant returns (uint256 val) {
uint256 fees;
uint256 pos;
(val,fees,pos) = updatedBalance(where);
return ;
}
event Allocation(uint256 amount, uint256 date);
event FeeOnAllocation(uint256 fees, uint256 date);
event PartComplete();
event StillToGo(uint numLeft);
uint256 public partPos;
uint256 public partFees;
uint256 partL;
allocation[]   public partAllocations;
function partAllocationLength() constant returns (uint) {
return partAllocations.length;
}
function addAllocationPartOne(uint newAllocation,uint numSteps) onlyOwner{
uint256 thisAllocation = newAllocation;
require(totAllocation < maxAllocation);
if (currentAllocations.length > partAllocations.length) {
partAllocations = currentAllocations;
}
if (totAllocation + thisAllocation > maxAllocation) {
thisAllocation = maxAllocation - totAllocation;
log0("max alloc reached");
}
totAllocation += thisAllocation;
Allocation(thisAllocation,now);
allocation memory newDiv;
newDiv.amount = thisAllocation;
newDiv.date = now;
allocationsOverTime.push(newDiv);
partL = partAllocations.push(newDiv);
if (partAllocations.length < 2) {
PartComplete();
currentAllocations = partAllocations;
FeeOnAllocation(0,now);
return;
}
for (partPos = partAllocations.length - 2; partPos >= 0; partPos-- ){
(partAllocations[partPos].amount,partFees) = calcFees(partAllocations[partPos].date,now,partAllocations[partPos].amount);
partAllocations[partPos].amount += partAllocations[partL - 1].amount;
partAllocations[partPos].date    = now;
if ((partPos == 0) || (partPos == partAllocations.length-numSteps)){
break;
}
}
if (partPos != 0) {
StillToGo(partPos);
return;
}
PartComplete();
FeeOnAllocation(partFees,now);
currentAllocations = partAllocations;
}
function addAllocationPartTwo(uint numSteps) onlyOwner {
require(numSteps > 0);
require(partPos > 0);
for (uint i = 0; i < numSteps; i++ ){
partPos--;
(partAllocations[partPos].amount,partFees) = calcFees(partAllocations[partPos].date,now,partAllocations[partPos].amount);
partAllocations[partPos].amount += partAllocations[partL - 1].amount;
partAllocations[partPos].date    = now;
if (partPos == 0) {
break;
}
}
if (partPos != 0) {
StillToGo(partPos);
return;
}
PartComplete();
FeeOnAllocation(partFees,now);
currentAllocations = partAllocations;
}
function setHGT(address _hgt) onlyOwner {
HGT = _hgt;
}
function parentFees(address where) whenNotPaused {
require(msg.sender == HGT);
update(where);
}
function parentChange(address where, uint newValue) whenNotPaused {
require(msg.sender == HGT);
balances[where].allocationShare = newValue;
}
function transfer(address _to, uint256 _value) whenNotPaused returns (bool ok) {
update(msg.sender);
update(_to);
balances[msg.sender].amount = safeSub(balances[msg.sender].amount, _value);
balances[_to].amount = safeAdd(balances[_to].amount, _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) whenNotPaused returns (bool success) {
var _allowance = allowed[_from][msg.sender];
update(_from);
update(_to);
balances[_to].amount = safeAdd(balances[_to].amount, _value);
balances[_from].amount = safeSub(balances[_from].amount, _value);
allowed[_from][msg.sender] = safeSub(_allowance, _value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint _value) whenNotPaused returns (bool success) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
address public authorisedMinter;
function setMinter(address minter) onlyOwner {
authorisedMinter = minter;
}
function mintTokens(address destination, uint256 amount) {
require(msg.sender == authorisedMinter);
update(destination);
balances[destination].amount = safeAdd(balances[destination].amount, amount);
balances[destination].lastUpdated = now;
balances[destination].nextAllocationIndex = currentAllocations.length;
TokenMinted(destination,amount);
}
function burnTokens(address source, uint256 amount) {
require(msg.sender == authorisedMinter);
update(source);
balances[source].amount = safeSub(balances[source].amount,amount);
balances[source].lastUpdated = now;
balances[source].nextAllocationIndex = currentAllocations.length;
TokenBurned(source,amount);
}
}
mapping (address => csAction) public permissions;
mapping (address => uint256)  public deposits;
modifier MustBeEnabled(address x) {
require (!permissions[x].blocked) ;
require (permissions[x].passedKYC) ;
_;
}
function HelloGoldSale(address _cs, address _hgt, address _multiSig, address _reserve) {
cs          = _cs;
token       = HelloGoldToken(_hgt);
multiSig    = _multiSig;
HGT_Reserve = _reserve;
}
function setStart(uint256 when_) onlyOwner {
startDate = when_;
endDate = when_ + tranchePeriod;
}
modifier MustBeCs() {
require (msg.sender == cs) ;
_;
}
uint256[5] public hgtRates = [1248900000000,1196900000000,1144800000000,1092800000000,1040700000000];
function approve(address user) MustBeCs {
permissions[user].passedKYC = true;
}
function block(address user) MustBeCs {
permissions[user].blocked = true;
}
function unblock(address user) MustBeCs {
permissions[user].blocked = false;
}
function newCs(address newCs) onlyOwner {
cs = newCs;
}
function setPeriod(uint256 period_) onlyOwner {
require (!funding()) ;
tranchePeriod = period_;
endDate = startDate + tranchePeriod;
if (endDate < now + tranchePeriod) {
endDate = now + tranchePeriod;
}
}
function when()  constant returns (uint256) {
return now;
}
function funding() constant returns (bool) {
if (paused) return false;
if (now < startDate) return false;
if (now > endDate) return false;
if (coinsRemaining == 0) return false;
if (tierNo >= numTiers ) return false;
return true;
}
function success() constant returns (bool succeeded) {
if (coinsRemaining == 0) return true;
bool complete = (now > endDate) ;
bool didOK = (coinsRemaining <= (MaxCoinsR1 - minimumCap));
succeeded = (complete && didOK)  ;
return ;
}
function failed() constant returns (bool didNotSucceed) {
bool complete = (now > endDate  );
bool didBad = (coinsRemaining > (MaxCoinsR1 - minimumCap));
didNotSucceed = (complete && didBad);
return;
}
function () payable MustBeEnabled(msg.sender) whenNotPaused {
createTokens(msg.sender,msg.value);
}
function linkCoin(address coin) onlyOwner {
token = HelloGoldToken(coin);
}
function coinAddress() constant returns (address) {
return address(token);
}
function setHgtRates(uint256 p0,uint256 p1,uint256 p2,uint256 p3,uint256 p4, uint256 _max ) onlyOwner {
require (now < startDate) ;
hgtRates[0]   = p0 * 10**8;
hgtRates[1]   = p1 * 10**8;
hgtRates[2]   = p2 * 10**8;
hgtRates[3]   = p3 * 10**8;
hgtRates[4]   = p4 * 10**8;
personalMax = _max * 1 ether;
}
event Purchase(address indexed buyer, uint256 level,uint256 value, uint256 tokens);
event Reduction(string msg, address indexed buyer, uint256 wanted, uint256 allocated);
function createTokens(address recipient, uint256 value) private {
uint256 totalTokens;
uint256 hgtRate;
require (funding()) ;
require (value > 1 finney) ;
require (deposits[recipient] < personalMax);
uint256 maxRefund = 0;
if ((deposits[msg.sender] + value) > personalMax) {
maxRefund = deposits[msg.sender] + value - personalMax;
value -= maxRefund;
log0("maximum funds exceeded");
}
uint256 val = value;
ethRaised = safeAdd(ethRaised,value);
if (deposits[recipient] == 0) contributors++;
do {
hgtRate = hgtRates[tierNo];
uint tokens = safeMul(val, hgtRate);
tokens = safeDiv(tokens, 1 ether);
if (tokens <= coinsLeftInTier) {
uint256 actualTokens = tokens;
uint refund = 0;
if (tokens > coinsRemaining) {
Reduction("in tier",recipient,tokens,coinsRemaining);
actualTokens = coinsRemaining;
refund = safeSub(tokens, coinsRemaining );
refund = safeDiv(refund*1 ether,hgtRate );
coinsRemaining = 0;
val = safeSub( val,refund);
} else {
coinsRemaining  = safeSub(coinsRemaining,  actualTokens);
}
purchasedCoins  = safeAdd(purchasedCoins, actualTokens);
totalTokens = safeAdd(totalTokens,actualTokens);
require (token.transferFrom(HGT_Reserve, recipient,totalTokens)) ;
Purchase(recipient,tierNo,val,actualTokens);
deposits[recipient] = safeAdd(deposits[recipient],val);
refund += maxRefund;
if (refund > 0) {
ethRaised = safeSub(ethRaised,refund);
recipient.transfer(refund);
}
if (coinsRemaining <= (MaxCoinsR1 - minimumCap)){
if (!multiSig.send(this.balance)) {
log0("cannot forward funds to owner");
}
}
coinsLeftInTier = safeSub(coinsLeftInTier,actualTokens);
if ((coinsLeftInTier == 0) && (coinsRemaining != 0)) {
coinsLeftInTier = coinsPerTier;
tierNo++;
endDate = now + tranchePeriod;
}
return;
}
uint256 coins2buy = min256(coinsLeftInTier , coinsRemaining);
endDate = safeAdd( now, tranchePeriod);
purchasedCoins = safeAdd(purchasedCoins, coins2buy);
totalTokens    = safeAdd(totalTokens,coins2buy);
coinsRemaining = safeSub(coinsRemaining,coins2buy);
uint weiCoinsLeftInThisTier = safeMul(coins2buy,1 ether);
uint costOfTheseCoins = safeDiv(weiCoinsLeftInThisTier, hgtRate);
Purchase(recipient, tierNo,costOfTheseCoins,coins2buy);
deposits[recipient] = safeAdd(deposits[recipient],costOfTheseCoins);
val    = safeSub(val,costOfTheseCoins);
tierNo = tierNo + 1;
coinsLeftInTier = coinsPerTier;
} while ((val > 0) && funding());
require (token.transferFrom(HGT_Reserve, recipient,totalTokens)) ;
if ((val > 0) || (maxRefund > 0)){
Reduction("finished crowdsale, returning ",recipient,value,totalTokens);
recipient.transfer(val+maxRefund);
}
if (!multiSig.send(this.balance)) {
ethRaised = safeSub(ethRaised,this.balance);
log0("cannot send at tier jump");
}
}
function allocatedTokens(address grantee, uint256 numTokens) onlyOwner {
require (now < startDate) ;
if (numTokens < coinsRemaining) {
coinsRemaining = safeSub(coinsRemaining, numTokens);
} else {
numTokens = coinsRemaining;
coinsRemaining = 0;
}
preallocCoins = safeAdd(preallocCoins,numTokens);
require (token.transferFrom(HGT_Reserve,grantee,numTokens));
}
function withdraw() {
if (failed()) {
if (deposits[msg.sender] > 0) {
uint256 val = deposits[msg.sender];
deposits[msg.sender] = 0;
msg.sender.transfer(val);
}
}
}
function complete() onlyOwner {
if (success()) {
uint256 val = this.balance;
if (val > 0) {
if (!multiSig.send(val)) {
log0("cannot withdraw");
} else {
log0("funds withdrawn");
}
} else {
log0("nothing to withdraw");
}
}
}
}