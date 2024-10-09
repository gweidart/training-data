pragma solidity ^0.4.18;
interface IERC20 {
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
interface ICustomers {
function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);
function changeFee(uint256 _newFee) public returns (bool success);
function verifyCustomer(
address _customer,
bytes32 _countryJurisdiction,
bytes32 _divisionJurisdiction,
uint8 _role,
bool _accredited,
uint256 _expires
) public returns (bool success);
function getCustomer(address _provider, address _customer) public constant returns (
bytes32,
bytes32,
bool,
uint8,
bool,
uint256
);
function getProvider(address _providerAddress) public constant returns (
string name,
uint256 joined,
bytes32 details,
uint256 fee
);
}
contract Customers is ICustomers {
string public VERSION = "1";
IERC20 POLY;
struct Customer {
bytes32 countryJurisdiction;
bytes32 divisionJurisdiction;
uint256 joined;
uint8 role;
bool verified;
bool accredited;
bytes32 proof;
uint256 expires;
}
mapping(address => mapping(address => Customer)) public customers;
struct Provider {
string name;
uint256 joined;
bytes32 details;
uint256 fee;
}
mapping(address => Provider) public providers;
event LogNewProvider(address providerAddress, string name, bytes32 details);
event LogCustomerVerified(address customer, address provider, uint8 role);
modifier onlyProvider() {
require(providers[msg.sender].details != 0x0);
_;
}
function Customers(address _polyTokenAddress) public {
POLY = IERC20(_polyTokenAddress);
}
function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
require(_providerAddress != address(0));
require(_details != 0x0);
require(providers[_providerAddress].details == 0x0);
providers[_providerAddress] = Provider(_name, now, _details, _fee);
LogNewProvider(_providerAddress, _name, _details);
return true;
}
function changeFee(uint256 _newFee) public returns (bool success) {
require(providers[msg.sender].details != 0x0);
providers[msg.sender].fee = _newFee;
return true;
}
function verifyCustomer(
address _customer,
bytes32 _countryJurisdiction,
bytes32 _divisionJurisdiction,
uint8 _role,
bool _accredited,
uint256 _expires
) public onlyProvider returns (bool success)
{
require(_expires > now);
require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
customers[msg.sender][_customer].countryJurisdiction = _countryJurisdiction;
customers[msg.sender][_customer].divisionJurisdiction = _divisionJurisdiction;
customers[msg.sender][_customer].role = _role;
customers[msg.sender][_customer].accredited = _accredited;
customers[msg.sender][_customer].expires = _expires;
customers[msg.sender][_customer].verified = true;
LogCustomerVerified(_customer, msg.sender, _role);
return true;
}
function getCustomer(address _provider, address _customer) public constant returns (
bytes32,
bytes32,
bool,
uint8,
bool,
uint256
) {
return (
customers[_provider][_customer].countryJurisdiction,
customers[_provider][_customer].divisionJurisdiction,
customers[_provider][_customer].accredited,
customers[_provider][_customer].role,
customers[_provider][_customer].verified,
customers[_provider][_customer].expires
);
}
function getProvider(address _providerAddress) public constant returns (
string name,
uint256 joined,
bytes32 details,
uint256 fee
) {
return (
providers[_providerAddress].name,
providers[_providerAddress].joined,
providers[_providerAddress].details,
providers[_providerAddress].fee
);
}
}