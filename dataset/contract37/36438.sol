pragma solidity ^0.4.11;
contract BMCAssetInterface {
function __transferWithReference(address _to, uint _value, string _reference, address _sender) returns(bool);
function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) returns(bool);
function __approve(address _spender, uint _value, address _sender) returns(bool);
function __process(bytes _data, address _sender) payable {
throw;
}
}
contract BMCAssetProxy {
address public bmcPlatform;
function __transferWithReference(address _to, uint _value, string _reference, address _sender) returns(bool);
function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) returns(bool);
function __approve(address _spender, uint _value, address _sender) returns(bool);
function getLatestVersion() returns(address);
function init(address _bmcPlatform, string _symbol, string _name);
function proposeUpgrade(address _newVersion);
}
contract BMCAsset is BMCAssetInterface {
BMCAssetProxy public proxy;
modifier onlyProxy() {
if (proxy == msg.sender) {
_;
}
}
function init(BMCAssetProxy _proxy) returns(bool) {
if (address(proxy) != 0x0) {
return false;
}
proxy = _proxy;
return true;
}
function __transferWithReference(address _to, uint _value, string _reference, address _sender) onlyProxy() returns(bool) {
return _transferWithReference(_to, _value, _reference, _sender);
}
function _transferWithReference(address _to, uint _value, string _reference, address _sender) internal returns(bool) {
return proxy.__transferWithReference(_to, _value, _reference, _sender);
}
function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) onlyProxy() returns(bool) {
return _transferFromWithReference(_from, _to, _value, _reference, _sender);
}
function _transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) internal returns(bool) {
return proxy.__transferFromWithReference(_from, _to, _value, _reference, _sender);
}
function __approve(address _spender, uint _value, address _sender) onlyProxy() returns(bool) {
return _approve(_spender, _value, _sender);
}
function _approve(address _spender, uint _value, address _sender) internal returns(bool) {
return proxy.__approve(_spender, _value, _sender);
}
}
contract BMC is BMCAsset {
uint public icoUsd;
uint public icoEth;
uint public icoBtc;
uint public icoLtc;
function initBMC(BMCAssetProxy _proxy, uint _icoUsd, uint _icoEth, uint _icoBtc, uint _icoLtc) returns(bool) {
if(icoUsd != 0 || icoEth != 0 || icoBtc != 0 || icoLtc != 0) {
return false;
}
icoUsd = _icoUsd;
icoEth = _icoEth;
icoBtc = _icoBtc;
icoLtc = _icoLtc;
super.init(_proxy);
return true;
}
}