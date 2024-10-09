pragma solidity ^0.4.18;
contract Certification  {
address public certifierAddress;
string public CompanyName;
string public Norm;
string public CertID;
string public issued;
string public expires;
string public Scope;
string public issuingBody;
function Certification(string _CompanyName,
string _Norm,
string _CertID,
string _issued,
string _expires,
string _Scope,
string _issuingBody) public {
certifierAddress = msg.sender;
CompanyName = _CompanyName;
Norm =_Norm;
CertID = _CertID;
issued = _issued;
expires = _expires;
Scope = _Scope;
issuingBody = _issuingBody;
}
function deleteCertificate() public {
require(msg.sender == certifierAddress);
selfdestruct(tx.origin);
}
}