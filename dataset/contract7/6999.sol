pragma solidity ^0.4.24;
library UintCompressor {
using SafeMath for *;
function insert(uint256 _var, uint256 _include, uint256 _start, uint256 _end)
internal
pure
returns(uint256)
{
require(_end < 77 && _start < 77, "start/end must be less than 77");
require(_end >= _start, "end must be >= start");
_end = exponent(_end).mul(10);
_start = exponent(_start);
require(_include < (_end / _start));
if (_include > 0)
_include = _include.mul(_start);
return((_var.sub((_var / _start).mul(_start))).add(_include).add((_var / _end).mul(_end)));
}
function extract(uint256 _input, uint256 _start, uint256 _end)
internal
pure
returns(uint256)
{
require(_end < 77 && _start < 77, "start/end must be less than 77");
require(_end >= _start, "end must be >= start");
_end = exponent(_end).mul(10);
_start = exponent(_start);
return((((_input / _start).mul(_start)).sub((_input / _end).mul(_end))) / _start);
}
function exponent(uint256 _position)
private
pure
returns(uint256)
{
return((10).pwr(_position));
}
}
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