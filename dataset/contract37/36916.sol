pragma solidity ^0.4.13;
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract SafeMath {
function safeMul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
safeAssert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
safeAssert(b > 0);
uint256 c = a / b;
safeAssert(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal returns (uint256) {
safeAssert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
safeAssert(c>=a && c>=b);
return c;
}
function safeAssert(bool assertion) internal {
if (!assertion) revert();
}
}
contract ERC20Interface is owned, SafeMath {
function totalSupply() constant returns (uint256 tokenTotalSupply);
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Buy(address indexed _sender, uint256 _eth, uint256 _ARX);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Burn(address _from, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Refund(address indexed _refunder, uint256 _value);
}
contract ARXCrowdsale is ERC20Interface {
string  public constant standard              = "ARX";
string  public constant name                  = "ARX";
string  public constant symbol                = "ARX";
uint8   public constant decimals              = 18;
uint256 _totalSupply                          = 0;
address public admin = owner;
address public beneficiaryMultiSig;
address public foundationFundMultisig;
uint256 public tokensPerEthPrice;
uint256 public amountRaisedInWei;
uint256 public fundingMaxInWei;
uint256 public fundingMinInWei;
uint256 public fundingMaxInEth;
uint256 public fundingMinInEth;
uint256 public remainingCapInWei;
uint256 public remainingCapInEth;
uint256 public foundationFundTokenCountInWei;
string  public CurrentStatus                  = "";
uint256 public fundingStartBlock;
uint256 public fundingEndBlock;
bool    public isCrowdSaleFinished            = false;
bool    public isCrowdSaleSetup               = false;
bool    public halted                         = false;
bool    public founderTokensAvailable         = false;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
event Buy(address indexed _sender, uint256 _eth, uint256 _ARX);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Burn(address _from, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Refund(address indexed _refunder, uint256 _value);
function ARXCrowdsale() onlyOwner {
admin = msg.sender;
CurrentStatus = "Crowdsale deployed to chain";
}
function totalSupply() constant returns (uint256 tokenTotalSupply) {
tokenTotalSupply = safeDiv(_totalSupply,1 ether);
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function fundingMaxInEth() constant returns (uint256 fundingMaximumInEth) {
fundingMaximumInEth = safeDiv(fundingMaxInWei,1 ether);
}
function fundingMinInEth() constant returns (uint256 fundingMinimumInEth) {
fundingMinimumInEth = safeDiv(fundingMinInWei,1 ether);
}
function amountRaisedInEth() constant returns (uint256 amountRaisedSoFarInEth) {
amountRaisedSoFarInEth = safeDiv(amountRaisedInWei,1 ether);
}
function remainingCapInEth() constant returns (uint256 remainingHardCapInEth) {
remainingHardCapInEth = safeDiv(remainingCapInWei,1 ether);
}
function transfer(address _to, uint256 _amount) returns (bool success) {
require(!(_to == 0x0));
if ((balances[msg.sender] >= _amount)
&& (_amount > 0)
&& ((safeAdd(balances[_to],_amount) > balances[_to]))) {
balances[msg.sender] = safeSub(balances[msg.sender], _amount);
balances[_to] = safeAdd(balances[_to], _amount);
Transfer(msg.sender, _to, _amount);
return true;
} else {
return false;
}
}
function transferFrom(
address _from,
address _to,
uint256 _amount) returns (bool success) {
require(!(_to == 0x0));
if ((balances[_from] >= _amount)
&& (allowed[_from][msg.sender] >= _amount)
&& (_amount > 0)
&& (safeAdd(balances[_to],_amount) > balances[_to])) {
balances[_from] = safeSub(balances[_from], _amount);
allowed[_from][msg.sender] = safeSub((allowed[_from][msg.sender]),_amount);
balances[_to] = safeAdd(balances[_to], _amount);
Transfer(_from, _to, _amount);
return true;
} else {
return false;
}
}
function approve(address _spender, uint256 _amount) returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function SetupCrowdsale(uint256 _fundingStartBlock, uint256 _fundingEndBlock) onlyOwner returns (bytes32 response) {
if ((msg.sender == admin)
&& (!(isCrowdSaleSetup))
&& (!(beneficiaryMultiSig > 0))
&& (!(fundingMaxInWei > 0))) {
beneficiaryMultiSig = 0xd93333f8cb765397A5D0d0e0ba53A2899B48511f;
foundationFundMultisig = 0x70A0bE1a5d8A9F39afED536Ec7b55d87067371aA;
fundingMaxInWei = 70000000000000000000000;
fundingMinInWei = 7000000000000000000000;
tokensPerEthPrice = 4000;
fundingMaxInEth = safeDiv(fundingMaxInWei,1 ether);
fundingMinInEth = safeDiv(fundingMinInWei,1 ether);
remainingCapInWei = fundingMaxInWei;
remainingCapInEth = safeDiv(remainingCapInWei,1 ether);
fundingStartBlock = _fundingStartBlock;
fundingEndBlock = _fundingEndBlock;
isCrowdSaleSetup = true;
CurrentStatus = "Crowdsale is setup";
return "Crowdsale is setup";
} else if (msg.sender != admin) {
return "not authorized";
} else  {
return "campaign cannot be changed";
}
}
function () payable {
require(msg.data.length == 0);
BuyTokens();
}
function BuyTokens() payable {
require((!(msg.value == 0))
&& (!(halted))
&& (isCrowdSaleSetup)
&& (!((safeAdd(amountRaisedInWei,msg.value)) > fundingMaxInWei))
&& (block.number >= fundingStartBlock)
&& (block.number <= fundingEndBlock)
&& (!(isCrowdSaleFinished)));
address recipient = msg.sender;
uint256 amount = msg.value;
uint256 rewardTransferAmount = 0;
amountRaisedInWei = safeAdd(amountRaisedInWei,amount);
remainingCapInWei = safeSub(fundingMaxInWei,amountRaisedInWei);
rewardTransferAmount = safeMul(amount,tokensPerEthPrice);
balances[recipient] = safeAdd(balances[recipient], rewardTransferAmount);
_totalSupply = safeAdd(_totalSupply, rewardTransferAmount);
Transfer(this, recipient, rewardTransferAmount);
Buy(recipient, amount, rewardTransferAmount);
}
function AllocateFounderTokens() onlyOwner {
require(isCrowdSaleFinished && founderTokensAvailable && (foundationFundTokenCountInWei == 0));
foundationFundTokenCountInWei = safeMul((safeDiv(amountRaisedInWei,10)), tokensPerEthPrice);
balances[foundationFundMultisig] = safeAdd(balances[foundationFundMultisig], foundationFundTokenCountInWei);
_totalSupply = safeAdd(_totalSupply, foundationFundTokenCountInWei);
Transfer(this, foundationFundMultisig, foundationFundTokenCountInWei);
Buy(foundationFundMultisig, 0, foundationFundTokenCountInWei);
founderTokensAvailable = false;
}
function beneficiaryMultiSigWithdraw(uint256 _amount) onlyOwner {
require(isCrowdSaleFinished && (amountRaisedInWei >= fundingMinInWei));
beneficiaryMultiSig.transfer(_amount);
}
function checkGoalReached() onlyOwner returns (bytes32 response) {
require (!(halted) && isCrowdSaleSetup);
if ((amountRaisedInWei < fundingMinInWei) && (block.number <= fundingEndBlock && block.number >= fundingStartBlock)) {
founderTokensAvailable = false;
isCrowdSaleFinished = false;
CurrentStatus = "In progress (Eth < Softcap)";
return "In progress (Eth < Softcap)";
} else if ((amountRaisedInWei < fundingMinInWei) && (block.number < fundingStartBlock)) {
founderTokensAvailable = false;
isCrowdSaleFinished = false;
CurrentStatus = "Crowdsale is setup";
return "Crowdsale is setup";
} else if ((amountRaisedInWei < fundingMinInWei) && (block.number > fundingEndBlock)) {
founderTokensAvailable = false;
isCrowdSaleFinished = true;
CurrentStatus = "Unsuccessful (Eth < Softcap)";
return "Unsuccessful (Eth < Softcap)";
} else if ((amountRaisedInWei >= fundingMinInWei) && (amountRaisedInWei >= fundingMaxInWei)) {
if (foundationFundTokenCountInWei == 0) {
founderTokensAvailable = true;
isCrowdSaleFinished = true;
CurrentStatus = "Successful (Eth >= Hardcap)!";
return "Successful (Eth >= Hardcap)!";
} else if (foundationFundTokenCountInWei > 0) {
founderTokensAvailable = false;
isCrowdSaleFinished = true;
CurrentStatus = "Successful (Eth >= Hardcap)!";
return "Successful (Eth >= Hardcap)!";
}
} else if ((amountRaisedInWei >= fundingMinInWei) && (amountRaisedInWei < fundingMaxInWei) && (block.number > fundingEndBlock)) {
if (foundationFundTokenCountInWei == 0) {
founderTokensAvailable = true;
isCrowdSaleFinished = true;
CurrentStatus = "Successful (Eth >= Softcap)!";
return "Successful (Eth >= Softcap)!";
} else if (foundationFundTokenCountInWei > 0) {
founderTokensAvailable = false;
isCrowdSaleFinished = true;
CurrentStatus = "Successful (Eth >= Softcap)!";
return "Successful (Eth >= Softcap)!";
}
} else if ((amountRaisedInWei >= fundingMinInWei) && (amountRaisedInWei < fundingMaxInWei) && (block.number <= fundingEndBlock)) {
founderTokensAvailable = false;
isCrowdSaleFinished = false;
CurrentStatus = "In progress (Eth >= Softcap)!";
return "In progress (Eth >= Softcap)!";
}
}
function refund() {
require (!(halted)
&& (amountRaisedInWei < fundingMinInWei)
&& (block.number > fundingEndBlock)
&& (balances[msg.sender] > 0));
uint256 ARXbalance = balances[msg.sender];
balances[msg.sender] = 0;
_totalSupply = safeSub(_totalSupply, ARXbalance);
uint256 ethValue = safeDiv(ARXbalance, tokensPerEthPrice);
amountRaisedInWei = safeSub(amountRaisedInWei, ethValue);
msg.sender.transfer(ethValue);
Burn(msg.sender, ARXbalance);
Refund(msg.sender, ethValue);
}
function halt() onlyOwner {
halted = true;
CurrentStatus = "Halted";
}
function unhalt() onlyOwner {
halted = false;
CurrentStatus = "Unhalted";
checkGoalReached();
}
}