pragma solidity ^0.4.21;
contract IContractFeatures {
function isSupported(address _contract, uint256 _features) public view returns (bool);
function enableFeatures(uint256 _features, bool _enable) public;
}
contract ContractFeatures is IContractFeatures {
mapping (address => uint256) private featureFlags;
event FeaturesAddition(address indexed _address, uint256 _features);
event FeaturesRemoval(address indexed _address, uint256 _features);
function ContractFeatures() public {
}
function isSupported(address _contract, uint256 _features) public view returns (bool) {
return (featureFlags[_contract] & _features) == _features;
}
function enableFeatures(uint256 _features, bool _enable) public {
if (_enable) {
if (isSupported(msg.sender, _features))
return;
featureFlags[msg.sender] |= _features;
emit FeaturesAddition(msg.sender, _features);
} else {
if (!isSupported(msg.sender, _features))
return;
featureFlags[msg.sender] &= ~_features;
emit FeaturesRemoval(msg.sender, _features);
}
}
}