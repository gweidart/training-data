pragma solidity ^0.4.0;
contract TestHello {
event logite(string name);
function TestHello() public {
logite("HELLO_TestHello");
}
function logit() public {
logite("LOGIT_TestHello");
}
}