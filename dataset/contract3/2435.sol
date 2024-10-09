pragma solidity ^0.4.24;
contract FamilienSpardose {
string public spardosenName;
mapping (address => uint) public guthaben;
uint public gesamtGuthaben = address(this).balance;
constructor(string _name, address _sparer) payable {
spardosenName = _name;
uint startGuthaben = msg.value;
if (_sparer != 0x0) guthaben[_sparer] = startGuthaben;
else guthaben[msg.sender] = startGuthaben;
}
function einzahlen() public payable{
guthaben[msg.sender] = msg.value;
}
function abbuchen(uint _betrag) public {
require(guthaben[msg.sender] >= _betrag);
guthaben [msg.sender] = guthaben [msg.sender] - _betrag;
msg.sender.transfer(_betrag);
}
function guthabenAnzeigen(address _sparer) view returns (uint) {
return guthaben[_sparer];
}
function addieren(uint _menge1, uint _menge2) pure returns (uint) {
return _menge1 + _menge2;
}
}