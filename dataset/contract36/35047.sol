contract PriceModel {
function getPrice(uint block) constant returns (uint);
}
contract Phased is PriceModel {
uint[] prices;
uint[] blocks;
function Phased(uint[] _prices, uint[] _blocks) {
require(_prices.length == _blocks.length && _prices.length <= 10);
require(isSorted(_blocks));
prices = _prices;
blocks = _blocks;
}
function getPrice(uint _block) public constant returns (uint price) {
uint min = 0;
uint max = blocks.length-1;
while (max > min) {
uint mid = (max + min + 1)/ 2;
if (blocks[mid] <= _block) {
min = mid;
} else {
max = mid-1;
}
}
return prices[min];
}
function isSorted(uint[] list) internal constant returns (bool sorted) {
sorted = true;
for(uint i = 1; i < list.length; i++) {
if(list[i-1] > list[i])
sorted = false;
}
}
}