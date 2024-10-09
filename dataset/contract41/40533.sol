contract Token {
event Transfer(address indexed from, address indexed to, uint256 value);
function transfer(address _to, uint256 _value);
function balanceOf(address) returns (uint256);
}
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
if (msg.sender != owner) throw;
_
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract TokenSale is owned {
address public asset;
uint256 public price;
function TokenSale(address _asset, uint256 _price)
{
asset = _asset;
price = _price;
}
function transfer_token(address _token, address _to, uint256 _value)
onlyOwner()
{
Token(_token).transfer(_to,_value);
}
function transfer_asset(address _to, uint256 _value)
onlyOwner()
{
Token(asset).transfer(_to,_value);
}
function transfer_eth(address _to, uint256 _value)
onlyOwner()
{
_to.send(_value);
}
function () {
uint order   = msg.value / price;
if(order == 0) throw;
uint256 balance = Token(asset).balanceOf(address(this));
if(balance == 0) throw;
if(order > balance )
{
order = balance;
uint256 change = msg.value - order * price;
msg.sender.send(change);
}
Token(asset).transfer(msg.sender,order);
}
}
contract TokenSaleFactory {
event TokenSaleCreation(uint256 index, address saleAddress);
address[] public tokenSalesAll;
mapping (address => uint256[]) public tokenSalesByOwner;
mapping (address => uint256[]) public tokenSalesByAsset;
function createSale (address _asset, uint256 _price) returns (address) {
address c = new TokenSale(_asset,_price);
TokenSale(c).transferOwnership(msg.sender);
uint256 index = tokenSalesAll.push(c) -1;
tokenSalesByOwner[msg.sender].push(index);
tokenSalesByAsset[msg.sender].push(index);
TokenSaleCreation(index,c);
}
function () {
throw;
}
}