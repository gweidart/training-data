contract RipplePayExample {
mapping(address => mapping(address => uint)) TrustSettings;
function updateTrustSettings(address _peer, uint newTrustLimit) {
TrustSettings[msg.sender][_peer] = newTrustLimit;
}
function getTrustSetting(address _peer) returns(uint) {
return TrustSettings[msg.sender][_peer];
}
}