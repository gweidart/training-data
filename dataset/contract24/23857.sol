pragma solidity ^0.4.20;
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
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
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
contract FunCoin is Ownable, Pausable {
using SafeMath for uint256;
modifier onlyBagholders() {
require(myTokens() > 0);
_;
}
modifier onlyStronghands() {
require(myDividends(true) > 0);
_;
}
event onTokenPurchase(
address indexed customerAddress,
uint256 incomingEthereum,
uint256 tokensMinted,
address indexed referredBy
);
event onTokenSell(
address indexed customerAddress,
uint256 tokensBurned,
uint256 ethereumEarned
);
event onReinvestment(
address indexed customerAddress,
uint256 ethereumReinvested,
uint256 tokensMinted
);
event onWithdraw(
address indexed customerAddress,
uint256 ethereumWithdrawn
);
event Transfer(
address indexed from,
address indexed to,
uint256 tokens
);
string public name = "FunCoin";
string public symbol = "FUN";
uint8 constant public decimals = 18;
uint8 constant internal dividendFee_ = 15;
uint8 constant internal devFee_ = 5;
uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
uint256 constant internal magnitude = 2**64;
uint256 public stakingRequirement = 100e18;
mapping(address => uint256) internal tokenBalanceLedger_;
mapping(address => uint256) internal referralBalance_;
mapping(address => int256) internal payoutsTo_;
uint256 internal tokenSupply_ = 0;
uint256 internal profitPerShare_;
function buy(address _referredBy) whenNotPaused() public payable returns(uint256)
{
purchaseTokens(msg.value, _referredBy);
}
function() whenNotPaused() payable public
{
purchaseTokens(msg.value, 0x0);
}
function reinvest() whenNotPaused() onlyStronghands() public
{
uint256 _dividends = myDividends(false);
address _customerAddress = msg.sender;
payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
_dividends += referralBalance_[_customerAddress];
referralBalance_[_customerAddress] = 0;
uint256 _tokens = purchaseTokens(_dividends, 0x0);
onReinvestment(_customerAddress, _dividends, _tokens);
}
function exit() public
{
address _customerAddress = msg.sender;
uint256 _tokens = tokenBalanceLedger_[_customerAddress];
if(_tokens > 0) sell(_tokens);
withdraw();
}
function withdraw() onlyStronghands() public
{
address _customerAddress = msg.sender;
uint256 _dividends = myDividends(false);
payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
_dividends += referralBalance_[_customerAddress];
referralBalance_[_customerAddress] = 0;
_customerAddress.transfer(_dividends);
onWithdraw(_customerAddress, _dividends);
}
function sell(uint256 _amountOfTokens) onlyBagholders() public
{
address _customerAddress = msg.sender;
require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
uint256 _tokens = _amountOfTokens;
uint256 _ethereum = tokensToEthereum_(_tokens);
uint256 _dividends = calculateDividends_(_ethereum);
uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
payoutsTo_[_customerAddress] -= _updatedPayouts;
if (tokenSupply_ > 0) {
profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
}
onTokenSell(_customerAddress, _tokens, _taxedEthereum);
}
function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders() public returns(bool)
{
address _customerAddress = msg.sender;
require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
if(myDividends(true) > 0) withdraw();
uint256 _tokenFee = calculateDividends_(_amountOfTokens);
uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
uint256 _dividends = tokensToEthereum_(_tokenFee);
tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);
tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);
profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
Transfer(_customerAddress, _toAddress, _taxedTokens);
return true;
}
function setStakingRequirement(uint256 _amountOfTokens) onlyOwner() public
{
stakingRequirement = _amountOfTokens;
}
function setName(string _name) onlyOwner() public
{
name = _name;
}
function setSymbol(string _symbol) onlyOwner() public
{
symbol = _symbol;
}
function totalEthereumBalance() public view returns(uint)
{
return this.balance;
}
function totalSupply() public view returns(uint256)
{
return tokenSupply_;
}
function myTokens() public view returns(uint256)
{
address _customerAddress = msg.sender;
return balanceOf(_customerAddress);
}
function myDividends(bool _includeReferralBonus) public view returns(uint256)
{
address _customerAddress = msg.sender;
return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
}
function balanceOf(address _customerAddress) view public returns(uint256)
{
return tokenBalanceLedger_[_customerAddress];
}
function dividendsOf(address _customerAddress) view public returns(uint256)
{
return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
}
function sellPrice() public view returns(uint256)
{
if(tokenSupply_ == 0){
return tokenPriceInitial_ - tokenPriceIncremental_;
} else {
uint256 _ethereum = tokensToEthereum_(1e18);
uint256 _dividends = calculateDividends_(_ethereum);
uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
return _taxedEthereum;
}
}
function buyPrice() public view returns(uint256)
{
if(tokenSupply_ == 0){
return tokenPriceInitial_ + tokenPriceIncremental_;
} else {
uint256 _ethereum = tokensToEthereum_(1e18);
uint256 _dividends = calculateDividends_(_ethereum);
uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
return _taxedEthereum;
}
}
function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256)
{
uint256 _dividends = calculateDividends_(_ethereumToSpend);
uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
return _amountOfTokens;
}
function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256)
{
require(_tokensToSell <= tokenSupply_);
uint256 _ethereum = tokensToEthereum_(_tokensToSell);
uint256 _dividends = calculateDividends_(_ethereum);
uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
return _taxedEthereum;
}
function purchaseTokens(uint256 _incomingEthereum, address _referredBy) internal returns(uint256)
{
address _customerAddress = msg.sender;
uint256 _undividedDividends = calculateDividends_(_incomingEthereum);
uint256 _devCut = calculateDevCut_(_incomingEthereum);
uint256 _dividends = SafeMath.sub(_undividedDividends, _devCut);
uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
uint256 _fee = _dividends * magnitude;
require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
referralBalance_[owner] = SafeMath.add(referralBalance_[owner], _devCut);
if(tokenSupply_ > 0){
tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
_fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
} else {
tokenSupply_ = _amountOfTokens;
}
tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
payoutsTo_[_customerAddress] += _updatedPayouts;
onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);
return _amountOfTokens;
}
function ethereumToTokens_(uint256 _ethereum) internal view returns(uint256)
{
uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
uint256 _tokensReceived =
(
(
SafeMath.sub(
(sqrt
(
(_tokenPriceInitial**2)
+
(2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
+
(((tokenPriceIncremental_)**2)*(tokenSupply_**2))
+
(2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
)
), _tokenPriceInitial
)
)/(tokenPriceIncremental_)
)-(tokenSupply_)
;
return _tokensReceived;
}
function tokensToEthereum_(uint256 _tokens) internal view returns(uint256)
{
uint256 tokens_ = (_tokens + 1e18);
uint256 _tokenSupply = (tokenSupply_ + 1e18);
uint256 _etherReceived =
(
SafeMath.sub(
(
(
(
tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
)-tokenPriceIncremental_
)*(tokens_ - 1e18)
),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
)
/1e18);
return _etherReceived;
}
function calculateDividends_(uint256 _incomingEthereum) internal view returns(uint256) {
uint256 _dividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
return _dividends;
}
function calculateDevCut_(uint256 _incomingEthereum) internal view returns(uint256) {
uint256 _devCut = SafeMath.div(SafeMath.mul(_incomingEthereum, devFee_), 100);
return _devCut;
}
function sqrt(uint x) internal pure returns (uint y) {
uint z = (x + 1) / 2;
y = x;
while (z < y) {
y = z;
z = (x / z + z) / 2;
}
}
}