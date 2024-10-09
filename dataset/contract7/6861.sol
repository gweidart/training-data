pragma solidity ^0.4.8;
contract SimpleStorageKevin {
uint x = 316;
function setKevin(uint newValue)
public
{
x = newValue;
}
function getKevin()
public
view
returns (uint)
{
return x;
}
}