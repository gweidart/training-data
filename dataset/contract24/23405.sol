contract ChronoBankAssetInterface {
function __transferWithReference(address _to, uint _value, string _reference, address _sender) returns(bool);
function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) returns(bool);
function __approve(address _spender, uint _value, address _sender) returns(bool);
function __process(bytes _data, address _sender) payable {
throw;
}
}
contract ChronoBankAssetProxy {
function __transferWithReference(address _to, uint _value, string _reference, address _sender) returns(bool);
function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) returns(bool);
function __approve(address _spender, uint _value, address _sender) returns(bool);
}
contract ChronoBankAsset is ChronoBankAssetInterface {
ChronoBankAssetProxy public proxy;
modifier onlyProxy() {
if (proxy == msg.sender) {
_;
}
}
function init(ChronoBankAssetProxy _proxy) returns(bool) {
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