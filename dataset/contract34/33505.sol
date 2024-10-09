contract Osler_SmartContracts_Demo_Certificate_of_Attendance {
address public owner = msg.sender;
string certificate;
bool certIssued = false;
function publishLawyersInAttendance(string cert) {
if (msg.sender !=owner || certIssued){
revert();
}
certIssued = true;
certificate = cert;
}
function showCertificate() constant returns (string) {
return certificate;
}
}