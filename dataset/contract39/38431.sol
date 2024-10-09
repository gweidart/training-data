pragma solidity ^0.4.8;
contract ERC20Interface {
function totalSupply() constant returns (uint256 totalSupply);
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract AgoraToken is ERC20Interface {
address contractOwner;
string public constant name = "Agora";
string public constant symbol = "AGO";
uint8 public constant decimals = 0;
struct BalanceSnapshot {
bool initialized;
uint256 value;
}
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
mapping(uint256 => mapping (address => BalanceSnapshot)) balancesAtBlock;
uint256 public constant creatorSupply = 30000000;
uint256 public constant seriesASupply = 10000000;
uint256 public constant seriesBSupply = 30000000;
uint256 public constant seriesCSupply = 60000000;
uint256 public currentlyReleased = 0;
uint256 public valueRaised = 0;
function AgoraToken() {
contractOwner = msg.sender;
balances[contractOwner] = creatorSupply;
currentlyReleased += creatorSupply;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
registerBalanceForReference(msg.sender);
registerBalanceForReference(_to);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if(balances[_from] >= _value && _value > 0 && allowed[_from][msg.sender] >= _value) {
registerBalanceForReference(_from);
registerBalanceForReference(_to);
balances[_from] -= _value;
balances[_to] += _value;
allowed[_from][msg.sender] -= _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function totalSupply() constant returns (uint256 totalSupply) {
return creatorSupply + seriesASupply + seriesBSupply + seriesCSupply;
}
function() payable {
require(block.number > 4116800);
require(msg.value >= 0);
var(pricePerThousands, supplyRemaining) = currentRoundInformation();
require(pricePerThousands > 0);
uint256 tokenToReceive = (msg.value * 1000 / pricePerThousands);
require(tokenToReceive <= supplyRemaining);
balances[msg.sender] += tokenToReceive;
currentlyReleased += tokenToReceive;
valueRaised += msg.value;
}
function currentRoundInformation() constant returns (uint256 pricePerThousands, uint256 supplyRemaining) {
if(currentlyReleased >= 30000000 && currentlyReleased < 40000000) {
return(0.75 ether, 40000000-currentlyReleased);
} else if(currentlyReleased >= 40000000 && currentlyReleased < 70000000) {
return(1.25 ether, 70000000-currentlyReleased);
} else if(currentlyReleased >= 70000000 && currentlyReleased < 130000000) {
return(1.5 ether, 130000000-currentlyReleased);
} else {
return(0,0);
}
}
function withdrawICO(uint256 amount) {
require(msg.sender == contractOwner);
contractOwner.transfer(amount);
}
function registerBalanceForReference(address _owner) private {
uint256 referenceBlockNumber = latestReferenceBlockNumber();
if (balancesAtBlock[referenceBlockNumber][_owner].initialized) { return; }
balancesAtBlock[referenceBlockNumber][_owner].initialized = true;
balancesAtBlock[referenceBlockNumber][_owner].value = balances[_owner];
}
function latestReferenceBlockNumber() constant returns (uint256 blockNumber) {
return (block.number - block.number % 157553);
}
function balanceAtBlock(address _owner, uint256 blockNumber) constant returns (uint256 balance) {
if(balancesAtBlock[blockNumber][_owner].initialized) {
return balancesAtBlock[blockNumber][_owner].value;
}
return balances[_owner];
}
}