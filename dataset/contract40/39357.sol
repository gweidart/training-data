pragma solidity ^0.4.8;
contract JingzhiContract{
address public jingZhiManager;
mapping(uint=>mapping(bytes1=>uint)) jingZhiMap;
modifier onlyBy(address _account){
if(msg.sender!=_account){
throw;
}
_;
}
function JingzhiContract(){
jingZhiManager=msg.sender;
}
function updatejingzhi(uint date,string fundid,uint value)
onlyBy(jingZhiManager)
{
jingZhiMap[date][bytes1(sha3(fundid))]=value;
}
function queryjingzhi(uint date,string fundid) constant returns(uint value){
return jingZhiMap[date][bytes1(sha3(fundid))];
}
}