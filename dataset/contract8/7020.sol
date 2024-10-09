pragma solidity ^0.4.24;
contract Authorized {
mapping (address => bool) public AuthorizedUser;
event AuthorizedUserChanged(address indexed addr, bool state );
constructor() public{
AuthorizedUser[msg.sender] = true;
}
modifier onlyAuthorized() {
require(AuthorizedUser[msg.sender]);
_;
}
function setAuthorizedUser(address addr, bool state) onlyAuthorized public {
AuthorizedUser[addr] = state;
emit AuthorizedUserChanged(addr, state);
}
}
pragma solidity ^0.4.24;
contract HBRIdentification is Authorized {
mapping (address => bool)  IdentificationDb;
event proven(address addr,bool isConfirm);
function verify(address _addr) public view returns(bool) {
return IdentificationDb[_addr];
}
function provenAddress(address _addr, bool _isConfirm) public onlyAuthorized {
IdentificationDb[_addr] = _isConfirm;
emit proven(_addr,_isConfirm);
}
function provenAddresseList(address[] _addrs, bool _isConfirm) public onlyAuthorized{
for (uint256 i = 0; i < _addrs.length; i++) {
provenAddress(_addrs[i],_isConfirm);
}
}
}