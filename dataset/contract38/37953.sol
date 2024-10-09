pragma solidity ^0.4.13;
library Sets {
struct addressSet {
address[] members;
mapping(address => uint) memberIndices;
}
function insert(addressSet storage self, address other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(addressSet storage self, address other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
address lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(addressSet storage self, address other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(addressSet storage self) constant returns (uint) {
return self.members.length;
}
struct uintSet {
uint[] members;
mapping(uint => uint) memberIndices;
}
function insert(uintSet storage self, uint other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(uintSet storage self, uint other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
uint lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(uintSet storage self, uint other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(uintSet storage self) constant returns (uint) {
return self.members.length;
}
struct uint8Set {
uint8[] members;
mapping(uint8 => uint) memberIndices;
}
function insert(uint8Set storage self, uint8 other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(uint8Set storage self, uint8 other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
uint8 lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(uint8Set storage self, uint8 other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(uint8Set storage self) constant returns (uint) {
return self.members.length;
}
struct intSet {
int[] members;
mapping(int => uint) memberIndices;
}
function insert(intSet storage self, int other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(intSet storage self, int other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
int lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(intSet storage self, int other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(intSet storage self) constant returns (uint) {
return self.members.length;
}
struct int8Set {
int8[] members;
mapping(int8 => uint) memberIndices;
}
function insert(int8Set storage self, int8 other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(int8Set storage self, int8 other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
int8 lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(int8Set storage self, int8 other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(int8Set storage self) constant returns (uint) {
return self.members.length;
}
struct byteSet {
byte[] members;
mapping(byte => uint) memberIndices;
}
function insert(byteSet storage self, byte other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(byteSet storage self, byte other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
byte lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(byteSet storage self, byte other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(byteSet storage self) constant returns (uint) {
return self.members.length;
}
struct bytes32Set {
bytes32[] members;
mapping(bytes32 => uint) memberIndices;
}
function insert(bytes32Set storage self, bytes32 other) {
if (!contains(self, other)) {
self.members.push(other);
self.memberIndices[other] = length(self);
}
}
function remove(bytes32Set storage self, bytes32 other) {
if (contains(self, other)) {
uint replaceIndex = self.memberIndices[other];
bytes32 lastMember = self.members[length(self)-1];
self.members[replaceIndex-1] = lastMember;
self.members.length--;
self.memberIndices[lastMember] = replaceIndex;
delete self.memberIndices[other];
}
}
function contains(bytes32Set storage self, bytes32 other)
constant
returns (bool)
{
return self.memberIndices[other] > 0;
}
function length(bytes32Set storage self) constant returns (uint) {
return self.members.length;
}
}