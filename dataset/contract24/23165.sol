pragma solidity ^0.4.18;
library U256 {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
interface INewPrice {
function getNewPrice(uint initial, uint origin) view public returns(uint);
function isNewPrice() view public returns(bool);
}
contract NewPricePlanet is INewPrice {
using U256 for uint256;
function getNewPrice(uint origin, uint current) view public returns(uint) {
if (current < 0.02 ether) {
return current.mul(150).div(100);
} else if (current < 0.5 ether) {
return current.mul(135).div(100);
} else if (current < 2 ether) {
return current.mul(125).div(100);
} else if (current < 50 ether) {
return current.mul(117).div(100);
} else if (current < 200 ether) {
return current.mul(113).div(100);
} else {
return current.mul(110).div(100);
}
}
function isNewPrice() view public returns(bool) {
return true;
}
}