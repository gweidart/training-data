contract MintInterface {
function mint(address recipient, uint amount) returns (bool success);
}
contract SafeMath {
function safeMul(uint a, uint b) internal constant returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint a, uint b) internal constant returns (uint) {
uint c = a / b;
return c;
}
function safeSub(uint a, uint b) internal constant returns (uint) {
require(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal constant returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
}
contract WithdrawTokensInput is SafeMath {
address public tokenContract;
address public receiver;
uint public numTokensLimit;
uint public numTokensIssued;
address public multisig;
bool public open;
uint public startDate;
modifier input() {
require(open);
_;
}
modifier onlyMultisig() {
require(msg.sender == multisig);
_;
}
modifier onlyReceiver() {
require(msg.sender == receiver);
_;
}
function WithdrawTokensInput(
address _tokenContract,
address _multisig,
address _receiver,
uint _numTokens
) {
tokenContract = _tokenContract;
multisig = _multisig;
receiver = _receiver;
numTokensLimit = _numTokens;
}
function withdraw() public input onlyReceiver {
uint tokensToIssue = safeSub(limit(safeDiv(safeSub(now, startDate), 24 hours)), numTokensIssued);
numTokensIssued += tokensToIssue;
if (!MintInterface(tokenContract).mint(receiver, tokensToIssue))
revert();
}
function limit(uint d) public constant returns (uint tokensToIssue) {
if(d > 3650)
tokensToIssue = numTokensLimit;
else
tokensToIssue = (   (  ( (560791145 * d) >> 10 ) - ( d * (d-1) ) * 75  ) >> 1   ) * 10**18;
}
function submitInput() public onlyMultisig {
require(!open);
open = true;
startDate = now;
}
}