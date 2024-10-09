pragma solidity ^0.4.19;
contract theCyberClubhouse {
event GrantAdmission(string passphrase);
address private constant THECYBERADDRESS_ = 0x97A99C819544AD0617F48379840941eFbe1bfAE1;
modifier membersOnly() {
require(msg.sender == THECYBERADDRESS_);
_;
}
function theCyberMessage(string _passphrase) public membersOnly {
GrantAdmission(_passphrase);
}
}