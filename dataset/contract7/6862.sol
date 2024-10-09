pragma solidity ^0.4.8;
contract SimpleStorageCleide {
uint price;
function setCleide (uint newValue)
public
{
price = newValue;
}
function getCleide()
public
view
returns (uint)
{
return price;
}
}