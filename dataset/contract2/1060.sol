pragma solidity ^0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b)
internal
pure
returns (uint256 c)
{
if (a == 0) {
return 0;
}
c = a * b;
require(c / a == b, "SafeMath mul failed");
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
require(b <= a, "SafeMath sub failed");
return a - b;
}
function add(uint256 a, uint256 b)
internal
pure
returns (uint256 c)
{
c = a + b;
require(c >= a, "SafeMath add failed");
return c;
}
function sqrt(uint256 x)
internal
pure
returns (uint256 y)
{
uint256 z = ((add(x,1)) / 2);
y = x;
while (z < y)
{
y = z;
z = ((add((x / z),z)) / 2);
}
}
function sq(uint256 x)
internal
pure
returns (uint256)
{
return (mul(x,x));
}
function pwr(uint256 x, uint256 y)
internal
pure
returns (uint256)
{
if (x==0)
return (0);
else if (y==0)
return (1);
else
{
uint256 z = x;
for (uint256 i=1; i < y; i++)
z = mul(z,x);
return (z);
}
}
}