pragma solidity ^ 0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns(uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
}
function sub(uint256 a, uint256 b) internal pure returns(uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns(uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20 {
function balanceOf(address _owner) public constant returns(uint256);
function transfer(address _to, uint256 _value) public returns(bool);
function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
function approve(address _spender, uint256 _value) public returns(bool);
function allowance(address _owner, address _spender) public constant returns(uint256);
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract TESTTESTToken is ERC20 {
using SafeMath for uint256;
string public name = "TESTTEST TOKEN";
string public symbol = "TTT";
uint256 public decimals = 18;
uint256 public totalSupply = 0;
uint256 public constant MAX_TOKENS = 166000000 * 1e18;
address public owner;
event Burn(address indexed from, uint256 value);
bool public tokensAreFrozen = true;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function TESTTESTToken(address _owner) public {
owner = _owner;
}
function mintTokens(address _investor, uint256 _value) external onlyOwner {
require(_value > 0);
require(totalSupply.add(_value) <= MAX_TOKENS);
balances[_investor] = balances[_investor].add(_value);
totalSupply = totalSupply.add(_value);
emit Transfer(0x0, _investor, _value);
}
function defrostTokens() external onlyOwner {
tokensAreFrozen = false;
}
function frostTokens() external onlyOwner {
tokensAreFrozen = true;
}
function burnTokens(address _investor, uint256 _value) external onlyOwner {
require(balances[_investor] > 0);
totalSupply = totalSupply.sub(_value);
balances[_investor] = balances[_investor].sub(_value);
emit Burn(_investor, _value);
}
function balanceOf(address _owner) public constant returns(uint256) {
return balances[_owner];
}
function transfer(address _to, uint256 _amount) public returns(bool) {
require(!tokensAreFrozen);
balances[msg.sender] = balances[msg.sender].sub(_amount);
balances[_to] = balances[_to].add(_amount);
emit Transfer(msg.sender, _to, _amount);
return true;
}
function transferFrom(address _from, address _to, uint256 _amount) public returns(bool) {
require(!tokensAreFrozen);
balances[_from] = balances[_from].sub(_amount);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
balances[_to] = balances[_to].add(_amount);
emit Transfer(_from, _to, _amount);
return true;
}
function approve(address _spender, uint256 _amount) public returns(bool) {
require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _amount;
emit Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) public constant returns(uint256) {
return allowed[_owner][_spender];
}
}
contract TESTTESTICO {
TESTTESTToken public LTO = new TESTTESTToken(this);
using SafeMath for uint256;
uint256 public Rate_Eth = 700;
uint256 public Tokens_Per_Dollar = 50;
uint256 public Token_Price = Tokens_Per_Dollar.mul(Rate_Eth);
uint256 constant bountyPart = 20;
uint256 constant teamPart = 30;
uint256 constant companyPart = 120;
uint256 constant MAX_PREICO_TOKENS = 27556000 * 1e18;
uint256 constant TOKENS_FOR_SALE = 137780000 * 1e18;
uint256 constant SOFT_CAP = 36300000 * 1e18;
uint256 constant HARD_CAP = 93690400 * 1e18;
uint256 public soldTotal;
bool public isItIco = false;
bool public canIBuy = false;
bool public canIWithdraw = false;
address public BountyFund;
address public TeamFund;
address public Company;
address public Manager;
StatusICO statusICO;
enum StatusICO {
Created,
PreIcoStage1,
PreIcoStage2,
PreIcoStage3,
PreIcoFinished,
IcoStage1,
IcoStage2,
IcoStage3,
IcoStage4,
IcoStage5,
IcoFinished
}
mapping(address => uint256) public preInvestments;
mapping(address => uint256) public icoInvestments;
mapping(address => bool) public returnStatusPre;
mapping(address => bool) public returnStatusIco;
mapping(address => uint256) public tokensPreIco;
mapping(address => uint256) public tokensIco;
mapping(address => uint256) public tokensPreIcoInOtherCrypto;
mapping(address => uint256) public tokensIcoInOtherCrypto;
mapping(address => uint256) public tokensNoBonusSold;
event LogStartPreIcoStage(uint stageNum);
event LogFinishPreICO();
event LogStartIcoStage(uint stageNum);
event LogFinishICO(address bountyFund, address Company, address teamFund);
event LogBuyForInvestor(address investor, uint256 value);
event LogReturnEth(address investor, uint256 eth);
event LogReturnOtherCrypto(address investor);
modifier managerOnly {
require(msg.sender == Manager);
_;
}
function TESTTESTICO(
address _BountyFund,
address _TeamFund,
address _Company,
address _Manager
)
public {
BountyFund = _BountyFund;
TeamFund = _TeamFund;
Company = _Company;
Manager = _Manager;
statusICO = StatusICO.Created;
}
function currentStage() public view returns (string) {
if(statusICO == StatusICO.Created){return "Created";}
else if(statusICO == StatusICO.PreIcoStage1){return  "PreIcoStage1";}
else if(statusICO == StatusICO.PreIcoStage2){return "PreIcoStage2";}
else if(statusICO == StatusICO.PreIcoStage3){return "PreIcoStage3";}
else if(statusICO == StatusICO.PreIcoFinished){return "PreIcoFinished";}
else if(statusICO == StatusICO.IcoStage1){return "IcoStage1";}
else if(statusICO == StatusICO.IcoStage2){return "IcoStage2";}
else if(statusICO == StatusICO.IcoStage1){return "IcoStage3";}
else if(statusICO == StatusICO.IcoStage1){return "IcoStage4";}
else if(statusICO == StatusICO.IcoStage1){return "IcoStage5";}
else if(statusICO == StatusICO.IcoStage1){return "IcoFinished";}
}
function setRate(uint256 _RateEth) external managerOnly {
Rate_Eth = _RateEth;
Token_Price = Tokens_Per_Dollar.mul(Rate_Eth);
}
function setPreIcoStatus(uint _numb) external managerOnly {
require(statusICO == StatusICO.Created
|| statusICO == StatusICO.PreIcoStage1
|| statusICO == StatusICO.PreIcoStage2);
require(_numb == 1 ||  _numb == 2 || _numb == 3);
StatusICO stat = StatusICO.PreIcoStage1;
if(_numb == 2){stat = StatusICO.PreIcoStage2;}
else if(_numb == 3){stat = StatusICO.PreIcoStage3;}
statusICO = stat;
canIBuy = true;
canIWithdraw = true;
emit LogStartPreIcoStage(_numb);
}
function finishPreIco() external managerOnly {
require(statusICO == StatusICO.PreIcoStage3);
statusICO = StatusICO.PreIcoFinished;
isItIco = true;
canIBuy = false;
canIWithdraw = false;
emit LogFinishPreICO();
}
function setIcoStatus(uint _numb) external managerOnly {
require(statusICO == StatusICO.PreIcoFinished
|| statusICO == StatusICO.IcoStage1
|| statusICO == StatusICO.IcoStage2
|| statusICO == StatusICO.IcoStage3
|| statusICO == StatusICO.IcoStage4);
require(_numb == 1 ||  _numb == 2 || _numb == 3 || _numb == 4 || _numb == 5);
StatusICO stat = StatusICO.IcoStage1;
if(_numb == 2){stat = StatusICO.IcoStage2;}
else if(_numb == 3){stat = StatusICO.IcoStage3;}
else if(_numb == 4){stat = StatusICO.IcoStage4;}
else if(_numb == 5){stat = StatusICO.IcoStage5;}
statusICO = stat;
canIBuy = true;
canIWithdraw = true;
emit LogStartIcoStage(_numb);
}
function finishIco() external managerOnly {
require(statusICO == StatusICO.IcoStage5);
uint256 totalAmount = LTO.totalSupply();
LTO.mintTokens(BountyFund, bountyPart.mul(totalAmount).div(1000));
LTO.mintTokens(TeamFund, teamPart.mul(totalAmount).div(1000));
LTO.mintTokens(Company, companyPart.mul(totalAmount).div(1000));
statusICO = StatusICO.IcoFinished;
canIBuy = false;
if(soldTotal >= SOFT_CAP){canIWithdraw = false;}
emit LogFinishICO(BountyFund, Company, TeamFund);
}
function enableTokensTransfer() external managerOnly {
LTO.defrostTokens();
}
function disableTokensTransfer() external managerOnly {
require(statusICO != StatusICO.IcoFinished);
LTO.frostTokens();
}
function() external payable {
require(canIBuy);
require(msg.value > 0);
createTokens(msg.sender, msg.value.mul(Token_Price), msg.value);
}
function buyToken() external payable {
require(canIBuy);
require(msg.value > 0);
createTokens(msg.sender, msg.value.mul(Token_Price), msg.value);
}
function buyForInvestor(address _investor, uint256 _value) external managerOnly {
require(_value > 0);
require(canIBuy);
uint256 decvalue = _value.mul(1 ether);
uint256 bonus = getBonus(decvalue);
uint256 total = decvalue.add(bonus);
if(!isItIco){
require(LTO.totalSupply().add(total) <= MAX_PREICO_TOKENS);
tokensPreIcoInOtherCrypto[_investor] = tokensPreIcoInOtherCrypto[_investor].add(total);}
else {
require(LTO.totalSupply().add(total) <= TOKENS_FOR_SALE);
require(soldTotal.add(decvalue) <= HARD_CAP);
tokensIcoInOtherCrypto[_investor] = tokensIcoInOtherCrypto[_investor].add(total);
soldTotal = soldTotal.add(decvalue);}
LTO.mintTokens(_investor, total);
tokensNoBonusSold[_investor] = tokensNoBonusSold[_investor].add(decvalue);
emit LogBuyForInvestor(_investor, _value);
}
function createTokens(address _investor, uint256 _value, uint256 _ethValue) internal {
require(_value > 0);
uint256 bonus = getBonus(_value);
uint256 total = _value.add(bonus);
if(!isItIco){
require(LTO.totalSupply().add(total) <= MAX_PREICO_TOKENS);
tokensPreIco[_investor] = tokensPreIco[_investor].add(total);
preInvestments[_investor] = preInvestments[_investor].add(_ethValue);}
else {
require(LTO.totalSupply().add(total) <= TOKENS_FOR_SALE);
require(soldTotal.add(_value) <= HARD_CAP);
tokensIco[_investor] = tokensIco[_investor].add(total);
icoInvestments[_investor] = icoInvestments[_investor].add(_ethValue);
soldTotal = soldTotal.add(_value);}
LTO.mintTokens(_investor, total);
tokensNoBonusSold[_investor] = tokensNoBonusSold[_investor].add(_value);
}
function getBonus(uint256 _value) public view returns(uint256) {
uint256 bonus = 0;
if (statusICO == StatusICO.PreIcoStage1) {
bonus = _value.mul(300).div(1000);
} else if (statusICO == StatusICO.PreIcoStage2) {
bonus = _value.mul(250).div(1000);
} else if (statusICO == StatusICO.PreIcoStage3) {
bonus = _value.mul(200).div(1000);
} else if (statusICO == StatusICO.IcoStage1) {
bonus = _value.mul(150).div(1000);
} else if (statusICO == StatusICO.IcoStage2) {
bonus = _value.mul(100).div(1000);
} else if (statusICO == StatusICO.IcoStage3) {
bonus = _value.mul(60).div(1000);
} else if (statusICO == StatusICO.IcoStage4) {
bonus = _value.mul(30).div(1000);
}
return bonus;
}
function returnEther() public {
uint256 eth = 0;
uint256 tokens = 0;
require(canIWithdraw);
if (!isItIco) {
require(!returnStatusPre[msg.sender]);
require(preInvestments[msg.sender] > 0);
eth = preInvestments[msg.sender];
tokens = tokensPreIco[msg.sender];
preInvestments[msg.sender] = 0;
tokensPreIco[msg.sender] = 0;
returnStatusPre[msg.sender] = true;
}
else {
require(!returnStatusIco[msg.sender]);
require(icoInvestments[msg.sender] > 0);
eth = icoInvestments[msg.sender];
tokens = tokensIco[msg.sender];
icoInvestments[msg.sender] = 0;
tokensIco[msg.sender] = 0;
returnStatusIco[msg.sender] = true;
soldTotal = soldTotal.sub(tokensNoBonusSold[msg.sender]);}
LTO.burnTokens(msg.sender, tokens);
msg.sender.transfer(eth);
emit LogReturnEth(msg.sender, eth);
}
function returnOtherCrypto(address _investor)external managerOnly {
uint256 tokens = 0;
require(canIWithdraw);
if (!isItIco) {
require(!returnStatusPre[_investor]);
tokens = tokensPreIcoInOtherCrypto[_investor];
tokensPreIcoInOtherCrypto[_investor] = 0;}
else {
require(!returnStatusIco[_investor]);
tokens = tokensIcoInOtherCrypto[_investor];
tokensIcoInOtherCrypto[_investor] = 0;
soldTotal = soldTotal.sub(tokensNoBonusSold[_investor]);}
LTO.burnTokens(_investor, tokens);
emit LogReturnOtherCrypto(_investor);
}
function takeInvestments() external managerOnly {
require(statusICO == StatusICO.PreIcoFinished || statusICO == StatusICO.IcoFinished);
if(statusICO == StatusICO.PreIcoFinished){
uint256 totalb = address(this).balance;
uint256 fivePercent = (totalb.mul(50)).div(1000);
TeamFund.transfer(fivePercent);
Company.transfer(totalb.sub(fivePercent));
} else {
Company.transfer(address(this).balance);
LTO.defrostTokens();
}
}
}