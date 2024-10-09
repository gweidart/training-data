pragma solidity ^0.4.19;
contract Minado{
address addressOscar;
address addressOscarManager;
address addressAbel;
uint256 totalMined;
function Minado(address _oscar, address _abel) public{
addressAbel=_abel;
addressOscar=_oscar;
addressOscarManager=msg.sender;
totalMined=0;
}
modifier onlyOscar() {
if(msg.sender != addressOscarManager){
revert();
}
_;
}
function setAbel(address _abel) onlyOscar public{
addressAbel=_abel;
}
function getAbel() public constant returns(address _abel){
return addressAbel;
}
function setOscar(address _oscar) onlyOscar public{
addressOscar=_oscar;
}
function getOscar() public constant returns(address _oscar){
return addressOscar;
}
function ethMined() private{
uint256 toAbel= (msg.value * 20)/100;
addressAbel.transfer(toAbel);
addressOscar.transfer(this.balance);
totalMined+=msg.value;
}
function recoverAll() public onlyOscar{
addressOscar.transfer(this.balance);
}
function getTotalMined() public constant returns(uint256){
return totalMined;
}
function ()  payable  public {
ethMined();
}
}