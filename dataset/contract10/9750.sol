pragma solidity ^0.4.20;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract OraclizeI {
address public cbAddress;
function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);
function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);
function getPrice(string _datasource) returns (uint _dsprice);
function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
function useCoupon(string _coupon);
function setProofType(byte _proofType);
function setConfig(bytes32 _config);
function setCustomGasPrice(uint _gasPrice);
function randomDS_getSessionPubKeyHash() returns(bytes32);
}
contract OraclizeAddrResolverI {
function getAddress() returns (address _addr);
}
contract usingOraclize {
uint constant day = 60*60*24;
uint constant week = 60*60*24*7;
uint constant month = 60*60*24*30;
byte constant proofType_NONE = 0x00;
byte constant proofType_TLSNotary = 0x10;
byte constant proofType_Android = 0x20;
byte constant proofType_Ledger = 0x30;
byte constant proofType_Native = 0xF0;
byte constant proofStorage_IPFS = 0x01;
uint8 constant networkID_auto = 0;
uint8 constant networkID_mainnet = 1;
uint8 constant networkID_testnet = 2;
uint8 constant networkID_morden = 2;
uint8 constant networkID_consensys = 161;
OraclizeAddrResolverI OAR;
OraclizeI oraclize;
modifier oraclizeAPI {
if((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork(networkID_auto);
oraclize = OraclizeI(OAR.getAddress());
_;
}
modifier coupon(string code){
oraclize = OraclizeI(OAR.getAddress());
oraclize.useCoupon(code);
_;
}
function oraclize_setNetwork(uint8 networkID) internal returns(bool){
if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){
OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
oraclize_setNetworkName("eth_mainnet");
return true;
}
if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){
OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
oraclize_setNetworkName("eth_ropsten3");
return true;
}
if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){
OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
oraclize_setNetworkName("eth_kovan");
return true;
}
if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){
OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
oraclize_setNetworkName("eth_rinkeby");
return true;
}
if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){
OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
return true;
}
if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){
OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
return true;
}
if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){
OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
return true;
}
return false;
}
function __callback(bytes32 myid, string result) {
__callback(myid, result, new bytes(0));
}
function __callback(bytes32 myid, string result, bytes proof) {
}
function oraclize_useCoupon(string code) oraclizeAPI internal {
oraclize.useCoupon(code);
}
function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
return oraclize.getPrice(datasource);
}
function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
return oraclize.getPrice(datasource, gaslimit);
}
function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
return oraclize.query.value(price)(0, datasource, arg);
}
function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
return oraclize.query.value(price)(timestamp, datasource, arg);
}
function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
}
function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
}
function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
return oraclize.query2.value(price)(0, datasource, arg1, arg2);
}
function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
}
function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
}
function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
}
function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
bytes memory args = stra2cbor(argN);
return oraclize.queryN.value(price)(0, datasource, args);
}
function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
bytes memory args = stra2cbor(argN);
return oraclize.queryN.value(price)(timestamp, datasource, args);
}
function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
bytes memory args = stra2cbor(argN);
return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
}
function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
bytes memory args = stra2cbor(argN);
return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
}
function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](1);
dynargs[0] = args[0];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](1);
dynargs[0] = args[0];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](1);
dynargs[0] = args[0];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](1);
dynargs[0] = args[0];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
bytes memory args = ba2cbor(argN);
return oraclize.queryN.value(price)(0, datasource, args);
}
function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource);
if (price > 1 ether + tx.gasprice*200000) return 0;
bytes memory args = ba2cbor(argN);
return oraclize.queryN.value(price)(timestamp, datasource, args);
}
function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
bytes memory args = ba2cbor(argN);
return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
}
function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
uint price = oraclize.getPrice(datasource, gaslimit);
if (price > 1 ether + tx.gasprice*gaslimit) return 0;
bytes memory args = ba2cbor(argN);
return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
}
function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](1);
dynargs[0] = args[0];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](1);
dynargs[0] = args[0];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](1);
dynargs[0] = args[0];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](1);
dynargs[0] = args[0];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](2);
dynargs[0] = args[0];
dynargs[1] = args[1];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](4);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(timestamp, datasource, dynargs);
}
function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(timestamp, datasource, dynargs, gaslimit);
}
function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
bytes[] memory dynargs = new bytes[](5);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
dynargs[3] = args[3];
dynargs[4] = args[4];
return oraclize_query(datasource, dynargs, gaslimit);
}
function oraclize_cbAddress() oraclizeAPI internal returns (address){
return oraclize.cbAddress();
}
function oraclize_setProof(byte proofP) oraclizeAPI internal {
return oraclize.setProofType(proofP);
}
function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
return oraclize.setCustomGasPrice(gasPrice);
}
function oraclize_setConfig(bytes32 config) oraclizeAPI internal {
return oraclize.setConfig(config);
}
function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
return oraclize.randomDS_getSessionPubKeyHash();
}
function getCodeSize(address _addr) constant internal returns(uint _size) {
assembly {
_size := extcodesize(_addr)
}
}
function parseAddr(string _a) internal returns (address){
bytes memory tmp = bytes(_a);
uint160 iaddr = 0;
uint160 b1;
uint160 b2;
for (uint i=2; i<2+2*20; i+=2){
iaddr *= 256;
b1 = uint160(tmp[i]);
b2 = uint160(tmp[i+1]);
if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
iaddr += (b1*16+b2);
}
return address(iaddr);
}
function strCompare(string _a, string _b) internal returns (int) {
bytes memory a = bytes(_a);
bytes memory b = bytes(_b);
uint minLength = a.length;
if (b.length < minLength) minLength = b.length;
for (uint i = 0; i < minLength; i ++)
if (a[i] < b[i])
return -1;
else if (a[i] > b[i])
return 1;
if (a.length < b.length)
return -1;
else if (a.length > b.length)
return 1;
else
return 0;
}
function indexOf(string _haystack, string _needle) internal returns (int) {
bytes memory h = bytes(_haystack);
bytes memory n = bytes(_needle);
if(h.length < 1 || n.length < 1 || (n.length > h.length))
return -1;
else if(h.length > (2**128 -1))
return -1;
else
{
uint subindex = 0;
for (uint i = 0; i < h.length; i ++)
{
if (h[i] == n[0])
{
subindex = 1;
while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
{
subindex++;
}
if(subindex == n.length)
return int(i);
}
}
return -1;
}
}
function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string) {
bytes memory _ba = bytes(_a);
bytes memory _bb = bytes(_b);
bytes memory _bc = bytes(_c);
bytes memory _bd = bytes(_d);
bytes memory _be = bytes(_e);
string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
bytes memory babcde = bytes(abcde);
uint k = 0;
for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
return string(babcde);
}
function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
return strConcat(_a, _b, _c, _d, "");
}
function strConcat(string _a, string _b, string _c) internal returns (string) {
return strConcat(_a, _b, _c, "", "");
}
function strConcat(string _a, string _b) internal returns (string) {
return strConcat(_a, _b, "", "", "");
}
function parseInt(string _a) internal returns (uint) {
return parseInt(_a, 0);
}
function parseInt(string _a, uint _b) internal returns (uint) {
bytes memory bresult = bytes(_a);
uint mint = 0;
bool decimals = false;
for (uint i=0; i<bresult.length; i++){
if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
if (decimals){
if (_b == 0) break;
else _b--;
}
mint *= 10;
mint += uint(bresult[i]) - 48;
} else if (bresult[i] == 46) decimals = true;
}
if (_b > 0) mint *= 10**_b;
return mint;
}
function uint2str(uint i) internal returns (string){
if (i == 0) return "0";
uint j = i;
uint len;
while (j != 0){
len++;
j /= 10;
}
bytes memory bstr = new bytes(len);
uint k = len - 1;
while (i != 0){
bstr[k--] = byte(48 + i % 10);
i /= 10;
}
return string(bstr);
}
function stra2cbor(string[] arr) internal returns (bytes) {
uint arrlen = arr.length;
uint outputlen = 0;
bytes[] memory elemArray = new bytes[](arrlen);
for (uint i = 0; i < arrlen; i++) {
elemArray[i] = (bytes(arr[i]));
outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3;
}
uint ctr = 0;
uint cborlen = arrlen + 0x80;
outputlen += byte(cborlen).length;
bytes memory res = new bytes(outputlen);
while (byte(cborlen).length > ctr) {
res[ctr] = byte(cborlen)[ctr];
ctr++;
}
for (i = 0; i < arrlen; i++) {
res[ctr] = 0x5F;
ctr++;
for (uint x = 0; x < elemArray[i].length; x++) {
if (x % 23 == 0) {
uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
elemcborlen += 0x40;
uint lctr = ctr;
while (byte(elemcborlen).length > ctr - lctr) {
res[ctr] = byte(elemcborlen)[ctr - lctr];
ctr++;
}
}
res[ctr] = elemArray[i][x];
ctr++;
}
res[ctr] = 0xFF;
ctr++;
}
return res;
}
function ba2cbor(bytes[] arr) internal returns (bytes) {
uint arrlen = arr.length;
uint outputlen = 0;
bytes[] memory elemArray = new bytes[](arrlen);
for (uint i = 0; i < arrlen; i++) {
elemArray[i] = (bytes(arr[i]));
outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3;
}
uint ctr = 0;
uint cborlen = arrlen + 0x80;
outputlen += byte(cborlen).length;
bytes memory res = new bytes(outputlen);
while (byte(cborlen).length > ctr) {
res[ctr] = byte(cborlen)[ctr];
ctr++;
}
for (i = 0; i < arrlen; i++) {
res[ctr] = 0x5F;
ctr++;
for (uint x = 0; x < elemArray[i].length; x++) {
if (x % 23 == 0) {
uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
elemcborlen += 0x40;
uint lctr = ctr;
while (byte(elemcborlen).length > ctr - lctr) {
res[ctr] = byte(elemcborlen)[ctr - lctr];
ctr++;
}
}
res[ctr] = elemArray[i][x];
ctr++;
}
res[ctr] = 0xFF;
ctr++;
}
return res;
}
string oraclize_network_name;
function oraclize_setNetworkName(string _network_name) internal {
oraclize_network_name = _network_name;
}
function oraclize_getNetworkName() internal returns (string) {
return oraclize_network_name;
}
function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
if ((_nbytes == 0)||(_nbytes > 32)) throw;
bytes memory nbytes = new bytes(1);
nbytes[0] = byte(_nbytes);
bytes memory unonce = new bytes(32);
bytes memory sessionKeyHash = new bytes(32);
bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
assembly {
mstore(unonce, 0x20)
mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
mstore(sessionKeyHash, 0x20)
mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
}
bytes[3] memory args = [unonce, nbytes, sessionKeyHash];
bytes32 queryId = oraclize_query(_delay, "random", args, _customGasLimit);
oraclize_randomDS_setCommitment(queryId, sha3(bytes8(_delay), args[1], sha256(args[0]), args[2]));
return queryId;
}
function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
oraclize_randomDS_args[queryId] = commitment;
}
mapping(bytes32=>bytes32) oraclize_randomDS_args;
mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;
function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
bool sigok;
address signer;
bytes32 sigr;
bytes32 sigs;
bytes memory sigr_ = new bytes(32);
uint offset = 4+(uint(dersig[3]) - 0x20);
sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
bytes memory sigs_ = new bytes(32);
offset += 32 + 2;
sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);
assembly {
sigr := mload(add(sigr_, 32))
sigs := mload(add(sigs_, 32))
}
(sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
if (address(sha3(pubkey)) == signer) return true;
else {
(sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
return (address(sha3(pubkey)) == signer);
}
}
function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {
bool sigok;
bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
copyBytes(proof, sig2offset, sig2.length, sig2, 0);
bytes memory appkey1_pubkey = new bytes(64);
copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);
bytes memory tosign2 = new bytes(1+65+32);
tosign2[0] = 1;
copyBytes(proof, sig2offset-65, 65, tosign2, 1);
bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);
if (sigok == false) return false;
bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";
bytes memory tosign3 = new bytes(1+65);
tosign3[0] = 0xFE;
copyBytes(proof, 3, 65, tosign3, 1);
bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
copyBytes(proof, 3+65, sig3.length, sig3, 0);
sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);
return sigok;
}
modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) throw;
bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
if (proofVerified == false) throw;
_;
}
function matchBytes32Prefix(bytes32 content, bytes prefix) internal returns (bool){
bool match_ = true;
for (var i=0; i<prefix.length; i++){
if (content[i] != prefix[i]) match_ = false;
}
return match_;
}
function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){
bool checkok;
uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
bytes memory keyhash = new bytes(32);
copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
checkok = (sha3(keyhash) == sha3(sha256(context_name, queryId)));
if (checkok == false) return false;
bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);
checkok = matchBytes32Prefix(sha256(sig1), result);
if (checkok == false) return false;
bytes memory commitmentSlice1 = new bytes(8+1+32);
copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);
bytes memory sessionPubkey = new bytes(64);
uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);
bytes32 sessionPubkeyHash = sha256(sessionPubkey);
if (oraclize_randomDS_args[queryId] == sha3(commitmentSlice1, sessionPubkeyHash)){
delete oraclize_randomDS_args[queryId];
} else return false;
bytes memory tosign1 = new bytes(32+8+1+32);
copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
checkok = verifySig(sha256(tosign1), sig1, sessionPubkey);
if (checkok == false) return false;
if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
}
return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
}
function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal returns (bytes) {
uint minLength = length + toOffset;
if (to.length < minLength) {
throw;
}
uint i = 32 + fromOffset;
uint j = 32 + toOffset;
while (i < (32 + fromOffset + length)) {
assembly {
let tmp := mload(add(from, i))
mstore(add(to, j), tmp)
}
i += 32;
j += 32;
}
return to;
}
function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
bool ret;
address addr;
assembly {
let size := mload(0x40)
mstore(size, hash)
mstore(add(size, 32), v)
mstore(add(size, 64), r)
mstore(add(size, 96), s)
ret := call(3000, 1, 0, size, 128, size, 32)
addr := mload(size)
}
return (ret, addr);
}
function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
bytes32 r;
bytes32 s;
uint8 v;
if (sig.length != 65)
return (false, 0);
assembly {
r := mload(add(sig, 32))
s := mload(add(sig, 64))
v := byte(0, mload(add(sig, 96)))
}
if (v < 27)
v += 27;
if (v != 27 && v != 28)
return (false, 0);
return safer_ecrecover(hash, v, r, s);
}
}
contract BettingControllerInterface {
function remoteBettingClose() external;
function depositHouseTakeout() external payable;
}
contract Betting is usingOraclize {
using SafeMath for uint256;
uint countdown=3;
address public owner;
uint public winnerPoolTotal;
string public constant version = "0.2.2";
BettingControllerInterface internal bettingControllerInstance;
struct chronus_info {
bool  betting_open;
bool  race_start;
bool  race_end;
bool  voided_bet;
uint32  starting_time;
uint32  betting_duration;
uint32  race_duration;
uint32 voided_timestamp;
}
struct horses_info{
int64  BTC_delta;
int64  ETH_delta;
int64  LTC_delta;
bytes32 BTC;
bytes32 ETH;
bytes32 LTC;
uint customPreGasLimit;
uint customPostGasLimit;
}
struct bet_info{
bytes32 horse;
uint amount;
}
struct coin_info{
uint256 pre;
uint256 post;
uint160 total;
uint32 count;
bool price_check;
bytes32 preOraclizeId;
bytes32 postOraclizeId;
}
struct voter_info {
uint160 total_bet;
bool rewarded;
mapping(bytes32=>uint) bets;
}
mapping (bytes32 => bytes32) oraclizeIndex;
mapping (bytes32 => coin_info) coinIndex;
mapping (address => voter_info) voterIndex;
uint public total_reward;
uint32 total_bettors;
mapping (bytes32 => bool) public winner_horse;
event newOraclizeQuery(string description);
event newPriceTicker(uint price);
event Deposit(address _from, uint256 _value, bytes32 _horse, uint256 _date);
event Withdraw(address _to, uint256 _value);
function Betting() public payable {
oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
owner = msg.sender;
oraclize_setCustomGasPrice(30000000000 wei);
horses.BTC = bytes32("BTC");
horses.ETH = bytes32("ETH");
horses.LTC = bytes32("LTC");
horses.customPreGasLimit = 80000;
horses.customPostGasLimit = 230000;
bettingControllerInstance = BettingControllerInterface(owner);
}
horses_info public horses;
chronus_info public chronus;
modifier onlyOwner {
require(owner == msg.sender);
_;
}
modifier duringBetting {
require(chronus.betting_open);
require(now < chronus.starting_time + chronus.betting_duration);
_;
}
modifier beforeBetting {
require(!chronus.betting_open && !chronus.race_start);
_;
}
modifier afterRace {
require(chronus.race_end);
_;
}
function changeOwnership(address _newOwner) onlyOwner external {
owner = _newOwner;
}
function __callback(bytes32 myid, string result, bytes proof) public {
require (msg.sender == oraclize_cbAddress());
require (!chronus.race_end);
bytes32 coin_pointer;
chronus.race_start = true;
chronus.betting_open = false;
bettingControllerInstance.remoteBettingClose();
coin_pointer = oraclizeIndex[myid];
if (myid == coinIndex[coin_pointer].preOraclizeId) {
if (coinIndex[coin_pointer].pre > 0) {
} else if (now >= chronus.starting_time+chronus.betting_duration+ 60 minutes) {
forceVoidRace();
} else {
coinIndex[coin_pointer].pre = stringToUintNormalize(result);
emit newPriceTicker(coinIndex[coin_pointer].pre);
}
} else if (myid == coinIndex[coin_pointer].postOraclizeId){
if (coinIndex[coin_pointer].pre > 0 ){
if (coinIndex[coin_pointer].post > 0) {
} else if (now >= chronus.starting_time+chronus.race_duration+ 60 minutes) {
forceVoidRace();
} else {
coinIndex[coin_pointer].post = stringToUintNormalize(result);
coinIndex[coin_pointer].price_check = true;
emit newPriceTicker(coinIndex[coin_pointer].post);
if (coinIndex[horses.ETH].price_check && coinIndex[horses.BTC].price_check && coinIndex[horses.LTC].price_check) {
reward();
}
}
} else {
forceVoidRace();
}
}
}
function placeBet(bytes32 horse) external duringBetting payable  {
require(msg.value >= 0.01 ether);
if (voterIndex[msg.sender].total_bet==0) {
total_bettors+=1;
}
uint _newAmount = voterIndex[msg.sender].bets[horse] + msg.value;
voterIndex[msg.sender].bets[horse] = _newAmount;
voterIndex[msg.sender].total_bet += uint160(msg.value);
uint160 _newTotal = coinIndex[horse].total + uint160(msg.value);
uint32 _newCount = coinIndex[horse].count + 1;
coinIndex[horse].total = _newTotal;
coinIndex[horse].count = _newCount;
emit Deposit(msg.sender, msg.value, horse, now);
}
function () private payable {}
function setupRace(uint delay, uint  locking_duration) onlyOwner beforeBetting public payable returns(bool) {
if (oraclize_getPrice("URL" , horses.customPreGasLimit)*3 + oraclize_getPrice("URL", horses.customPostGasLimit)*3  > address(this).balance) {
emit newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
return false;
} else {
chronus.starting_time = uint32(block.timestamp);
chronus.betting_open = true;
bytes32 temp_ID;
emit newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
chronus.betting_duration = uint32(delay);
temp_ID = oraclize_query(delay, "URL", "json(https:
oraclizeIndex[temp_ID] = horses.ETH;
coinIndex[horses.ETH].preOraclizeId = temp_ID;
temp_ID = oraclize_query(delay, "URL", "json(https:
oraclizeIndex[temp_ID] = horses.LTC;
coinIndex[horses.LTC].preOraclizeId = temp_ID;
temp_ID = oraclize_query(delay, "URL", "json(https:
oraclizeIndex[temp_ID] = horses.BTC;
coinIndex[horses.BTC].preOraclizeId = temp_ID;
delay = delay.add(locking_duration);
temp_ID = oraclize_query(delay, "URL", "json(https:
oraclizeIndex[temp_ID] = horses.ETH;
coinIndex[horses.ETH].postOraclizeId = temp_ID;
temp_ID = oraclize_query(delay, "URL", "json(https:
oraclizeIndex[temp_ID] = horses.LTC;
coinIndex[horses.LTC].postOraclizeId = temp_ID;
temp_ID = oraclize_query(delay, "URL", "json(https:
oraclizeIndex[temp_ID] = horses.BTC;
coinIndex[horses.BTC].postOraclizeId = temp_ID;
chronus.race_duration = uint32(delay);
return true;
}
}
function reward() internal {
horses.BTC_delta = int64(coinIndex[horses.BTC].post - coinIndex[horses.BTC].pre)*100000/int64(coinIndex[horses.BTC].pre);
horses.ETH_delta = int64(coinIndex[horses.ETH].post - coinIndex[horses.ETH].pre)*100000/int64(coinIndex[horses.ETH].pre);
horses.LTC_delta = int64(coinIndex[horses.LTC].post - coinIndex[horses.LTC].pre)*100000/int64(coinIndex[horses.LTC].pre);
total_reward = (coinIndex[horses.BTC].total) + (coinIndex[horses.ETH].total) + (coinIndex[horses.LTC].total);
if (total_bettors <= 1) {
forceVoidRace();
} else {
uint house_fee = total_reward.mul(5).div(100);
require(house_fee < address(this).balance);
total_reward = total_reward.sub(house_fee);
bettingControllerInstance.depositHouseTakeout.value(house_fee)();
}
if (horses.BTC_delta > horses.ETH_delta) {
if (horses.BTC_delta > horses.LTC_delta) {
winner_horse[horses.BTC] = true;
winnerPoolTotal = coinIndex[horses.BTC].total;
}
else if(horses.LTC_delta > horses.BTC_delta) {
winner_horse[horses.LTC] = true;
winnerPoolTotal = coinIndex[horses.LTC].total;
} else {
winner_horse[horses.BTC] = true;
winner_horse[horses.LTC] = true;
winnerPoolTotal = coinIndex[horses.BTC].total + (coinIndex[horses.LTC].total);
}
} else if(horses.ETH_delta > horses.BTC_delta) {
if (horses.ETH_delta > horses.LTC_delta) {
winner_horse[horses.ETH] = true;
winnerPoolTotal = coinIndex[horses.ETH].total;
}
else if (horses.LTC_delta > horses.ETH_delta) {
winner_horse[horses.LTC] = true;
winnerPoolTotal = coinIndex[horses.LTC].total;
} else {
winner_horse[horses.ETH] = true;
winner_horse[horses.LTC] = true;
winnerPoolTotal = coinIndex[horses.ETH].total + (coinIndex[horses.LTC].total);
}
} else {
if (horses.LTC_delta > horses.ETH_delta) {
winner_horse[horses.LTC] = true;
winnerPoolTotal = coinIndex[horses.LTC].total;
} else if(horses.LTC_delta < horses.ETH_delta){
winner_horse[horses.ETH] = true;
winner_horse[horses.BTC] = true;
winnerPoolTotal = coinIndex[horses.ETH].total + (coinIndex[horses.BTC].total);
} else {
winner_horse[horses.LTC] = true;
winner_horse[horses.ETH] = true;
winner_horse[horses.BTC] = true;
winnerPoolTotal = coinIndex[horses.ETH].total + (coinIndex[horses.BTC].total) + (coinIndex[horses.LTC].total);
}
}
chronus.race_end = true;
}
function calculateReward(address candidate) internal afterRace constant returns(uint winner_reward) {
voter_info storage bettor = voterIndex[candidate];
if(chronus.voided_bet) {
winner_reward = bettor.total_bet;
} else {
uint winning_bet_total;
if(winner_horse[horses.BTC]) {
winning_bet_total += bettor.bets[horses.BTC];
} if(winner_horse[horses.ETH]) {
winning_bet_total += bettor.bets[horses.ETH];
} if(winner_horse[horses.LTC]) {
winning_bet_total += bettor.bets[horses.LTC];
}
winner_reward += (((total_reward.mul(10000000)).div(winnerPoolTotal)).mul(winning_bet_total)).div(10000000);
}
}
function checkReward() afterRace external constant returns (uint) {
require(!voterIndex[msg.sender].rewarded);
return calculateReward(msg.sender);
}
function claim_reward() afterRace external {
require(!voterIndex[msg.sender].rewarded);
uint transfer_amount = calculateReward(msg.sender);
require(address(this).balance >= transfer_amount);
voterIndex[msg.sender].rewarded = true;
msg.sender.transfer(transfer_amount);
emit Withdraw(msg.sender, transfer_amount);
}
function forceVoidRace() internal {
chronus.voided_bet=true;
chronus.race_end = true;
chronus.voided_timestamp=uint32(now);
}
function stringToUintNormalize(string s) internal pure returns (uint result) {
uint p =2;
bool precision=false;
bytes memory b = bytes(s);
uint i;
result = 0;
for (i = 0; i < b.length; i++) {
if (precision) {p = p-1;}
if (uint(b[i]) == 46){precision = true;}
uint c = uint(b[i]);
if (c >= 48 && c <= 57) {result = result * 10 + (c - 48);}
if (precision && p == 0){return result;}
}
while (p!=0) {
result = result*10;
p=p-1;
}
}
function getCoinIndex(bytes32 index, address candidate) external constant returns (uint, uint, uint, bool, uint) {
return (coinIndex[index].total, coinIndex[index].pre, coinIndex[index].post, coinIndex[index].price_check, voterIndex[candidate].bets[index]);
}
function reward_total() external constant returns (uint) {
return ((coinIndex[horses.BTC].total) + (coinIndex[horses.ETH].total) + (coinIndex[horses.LTC].total));
}
function refund() external onlyOwner {
require(now > chronus.starting_time + chronus.race_duration);
require((chronus.betting_open && !chronus.race_start)
|| (chronus.race_start && !chronus.race_end));
chronus.voided_bet = true;
chronus.race_end = true;
chronus.voided_timestamp=uint32(now);
bettingControllerInstance.remoteBettingClose();
}
function recovery() external onlyOwner{
require((chronus.race_end && now > chronus.starting_time + chronus.race_duration + (30 days))
|| (chronus.voided_bet && now > chronus.voided_timestamp + (30 days)));
bettingControllerInstance.depositHouseTakeout.value(address(this).balance)();
}
}