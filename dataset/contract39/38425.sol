pragma solidity ^0.4.11;
library BasicMathLib {
event Err(string typeErr);
function times(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
assembly{
res := mul(a,b)
jumpi(allGood, or(iszero(b), eq(div(res,b), a)))
err := 1
res := 0
allGood:
}
if (err)
Err("times func overflow");
}
function dividedBy(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
assembly{
jumpi(e, iszero(b))
res := div(a,b)
mstore(add(mload(0x40),0x20),res)
return(mload(0x40),0x40)
e:
}
Err("tried to divide by zero");
return (true, 0);
}
function plus(uint256 a, uint256 b) constant returns (bool err, uint256 res) {
assembly{
res := add(a,b)
jumpi(allGood, and(eq(sub(res,b), a), gt(res,b)))
err := 1
res := 0
allGood:
}
if (err)
Err("plus func overflow");
}
function minus(uint256 a, uint256 b) constant returns (bool err,uint256 res) {
assembly{
res := sub(a,b)
jumpi(allGood, eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1))
err := 1
res := 0
allGood:
}
if (err)
Err("minus func underflow");
}
}