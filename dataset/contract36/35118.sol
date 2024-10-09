pragma solidity ^0.4.17;
contract GetEbola {
address private creator = msg.sender;
function getInfo() constant returns (string, string)
{
string memory developer = "Saluton, mia nomo estas Zach!";
string memory genomeInfo = "Ebola virus - Zaire, cat.1976";
return (developer, genomeInfo);
}
function getEbola() constant returns (string)
{
string memory genomeURL = "URL: http:
return (genomeURL);
}
function tipCreator() constant returns (string, address)
{
string memory tipMsg = "If you like you can tip me at this address :)";
address tipJar = creator;
return (tipMsg, tipJar);
}
function kill() public returns (string)
{
if (msg.sender == creator)
{
suicide(creator);
}
else {
string memory nope = "Vi ne havas povon ĉi tie!";
return (nope);
}
}
}