pragma solidity ^0.4.13;
library BasicMathLib {
event Err(string typeErr);
function times(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
assembly{
res := mul(a,b)
switch or(iszero(b), eq(div(res,b), a))
case 0 {
err := 1
res := 0
}
}
if (err)
Err("times func overflow");
}
function dividedBy(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
assembly{
switch iszero(b)
case 0 {
res := div(a,b)
mstore(add(mload(0x40),0x20),res)
return(mload(0x40),0x40)
}
}
Err("tried to divide by zero");
return (true, 0);
}
function plus(uint256 a, uint256 b) constant returns (bool err, uint256 res) {
assembly{
res := add(a,b)
switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
case 0 {
err := 1
res := 0
}
}
if (err)
Err("plus func overflow");
}
function minus(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
assembly{
res := sub(a,b)
switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
case 0 {
err := 1
res := 0
}
}
if (err)
Err("minus func underflow");
}
}