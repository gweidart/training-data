contract IOU {
address owner;
string public name;
string public symbol;
uint8 public decimals;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function IOU(string tokenName, string tokenSymbol, uint8 decimalUnits) {
owner = msg.sender;
name = tokenName;
symbol = tokenSymbol;
decimals = decimalUnits;
}
function transfer(address _from, address _to, uint256 _value) {
if(msg.sender != owner) throw;
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
}
contract RipplePayMain {
mapping(string => address) currencies;
function newCurrency(string currencyName, string currencySymbol, uint8 decimalUnits){
currencies[currencySymbol] = new IOU(currencyName, currencySymbol, decimalUnits);
}
function issueIOU(string _currency, uint256 _amount, address _to){
IOU(currencies[_currency]).transfer(msg.sender, _to, _amount);
}
}