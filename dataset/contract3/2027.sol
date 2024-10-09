pragma solidity 0.4.8;
contract EventsHistory {
function versions(address) constant returns(uint);
}
library EToken2Emitter {
event Transfer(address indexed from, address indexed to, bytes32 indexed symbol, uint value, string reference, uint version);
event TransferToICAP(address indexed from, address indexed to, bytes32 indexed icap, uint value, string reference, uint version);
event Issue(bytes32 indexed symbol, uint value, address by, uint version);
event Revoke(bytes32 indexed symbol, uint value, address by, uint version);
event OwnershipChange(address indexed from, address indexed to, bytes32 indexed symbol, uint version);
event Approve(address indexed from, address indexed spender, bytes32 indexed symbol, uint value, uint version);
event Recovery(address indexed from, address indexed to, address by, uint version);
event Error(bytes32 message, uint version);
event Change(bytes32 indexed symbol, uint version);
function emitTransfer(address _from, address _to, bytes32 _symbol, uint _value, string _reference) {
Transfer(_from, _to, _symbol, _value, _reference, _getVersion());
}
function emitTransferToICAP(address _from, address _to, bytes32 _icap, uint _value, string _reference) {
TransferToICAP(_from, _to, _icap, _value, _reference, _getVersion());
}
function emitIssue(bytes32 _symbol, uint _value, address _by) {
Issue(_symbol, _value, _by, _getVersion());
}
function emitRevoke(bytes32 _symbol, uint _value, address _by) {
Revoke(_symbol, _value, _by, _getVersion());
}
function emitOwnershipChange(address _from, address _to, bytes32 _symbol) {
OwnershipChange(_from, _to, _symbol, _getVersion());
}
function emitApprove(address _from, address _spender, bytes32 _symbol, uint _value) {
Approve(_from, _spender, _symbol, _value, _getVersion());
}
function emitRecovery(address _from, address _to, address _by) {
Recovery(_from, _to, _by, _getVersion());
}
function emitError(bytes32 _message) {
Error(_message, _getVersion());
}
function emitChange(bytes32 _symbol) {
Change(_symbol, _getVersion());
}
function _getVersion() constant internal returns(uint) {
return EventsHistory(address(this)).versions(msg.sender);
}
}