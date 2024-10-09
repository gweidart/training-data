contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract ExchangeRate is Ownable {
event RateUpdated(uint timestamp, bytes32 symbol, uint rate);
mapping(bytes32 => uint) public rates;
function updateRate(string _symbol, uint _rate) public onlyOwner {
rates[sha3(_symbol)] = _rate;
RateUpdated(now, sha3(_symbol), _rate);
}
function updateRates(uint[] data) public onlyOwner {
require(data.length % 2 == 0);
uint i = 0;
while (i < data.length / 2) {
bytes32 symbol = bytes32(data[i * 2]);
uint rate = data[i * 2 + 1];
rates[symbol] = rate;
RateUpdated(now, symbol, rate);
i++;
}
}
function getRate(string _symbol) public constant returns(uint) {
return rates[sha3(_symbol)];
}
}