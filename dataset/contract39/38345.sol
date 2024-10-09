contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) constant returns (uint);
function transfer(address to, uint value);
event Transfer(address indexed from, address indexed to, uint value);
}
contract HasNoTokens is Ownable {
function tokenFallback(address from_, uint value_, bytes data_) external {
throw;
}
function reclaimToken(address tokenAddr) external onlyOwner {
ERC20Basic tokenInst = ERC20Basic(tokenAddr);
uint256 balance = tokenInst.balanceOf(this);
tokenInst.transfer(owner, balance);
}
}
contract AbstractSale {
function saleFinalized() constant returns (bool);
}
contract Escrow is HasNoTokens {
address public beneficiary;
uint public finalBlock;
AbstractSale public tokenSale;
function Escrow(address _beneficiary, uint _finalBlock, address _tokenSale) {
beneficiary = _beneficiary;
finalBlock = _finalBlock;
tokenSale = AbstractSale(_tokenSale);
}
function() public payable {}
function withdraw() public {
if (msg.sender != beneficiary) throw;
if (block.number > finalBlock) return doWithdraw();
if (tokenSale.saleFinalized()) return doWithdraw();
}
function doWithdraw() internal {
if (!beneficiary.send(this.balance)) throw;
}
}