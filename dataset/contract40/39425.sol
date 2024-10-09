pragma solidity ^0.4.2;
contract DateTime {
struct DateTime {
uint16 year;
uint8 month;
uint8 day;
uint8 hour;
uint8 minute;
uint8 second;
uint8 weekday;
}
uint constant DAY_IN_SECONDS = 86400;
uint constant YEAR_IN_SECONDS = 31536000;
uint constant LEAP_YEAR_IN_SECONDS = 31622400;
uint constant HOUR_IN_SECONDS = 3600;
uint constant MINUTE_IN_SECONDS = 60;
uint16 constant ORIGIN_YEAR = 1970;
function isLeapYear(uint16 year) constant returns (bool) {
if (year % 4 != 0) {
return false;
}
if (year % 100 != 0) {
return true;
}
if (year % 400 != 0) {
return false;
}
return true;
}
function leapYearsBefore(uint year) constant returns (uint) {
year -= 1;
return year / 4 - year / 100 + year / 400;
}
function getDaysInMonth(uint8 month, uint16 year) constant returns (uint8) {
if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
return 31;
}
else if (month == 4 || month == 6 || month == 9 || month == 11) {
return 30;
}
else if (isLeapYear(year)) {
return 29;
}
else {
return 28;
}
}
function parseTimestamp(uint timestamp) internal  returns (DateTime dt) {
uint secondsAccountedFor = 0;
uint buf;
uint8 i;
dt.year = getYear(timestamp);
buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);
secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);
uint secondsInMonth;
for (i = 1; i <= 12; i++) {
secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
if (secondsInMonth + secondsAccountedFor > timestamp) {
dt.month = i;
break;
}
secondsAccountedFor += secondsInMonth;
}
for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
dt.day = i;
break;
}
secondsAccountedFor += DAY_IN_SECONDS;
}
dt.hour = getHour(timestamp);
dt.minute = getMinute(timestamp);
dt.second = getSecond(timestamp);
dt.weekday = getWeekday(timestamp);
}
function getYear(uint timestamp) constant returns (uint16) {
uint secondsAccountedFor = 0;
uint16 year;
uint numLeapYears;
year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);
while (secondsAccountedFor > timestamp) {
if (isLeapYear(uint16(year - 1))) {
secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
}
else {
secondsAccountedFor -= YEAR_IN_SECONDS;
}
year -= 1;
}
return year;
}
function getMonth(uint timestamp) constant returns (uint8) {
return parseTimestamp(timestamp).month;
}
function getDay(uint timestamp) constant returns (uint8) {
return parseTimestamp(timestamp).day;
}
function getHour(uint timestamp) constant returns (uint8) {
return uint8((timestamp / 60 / 60) % 24);
}
function getMinute(uint timestamp) constant returns (uint8) {
return uint8((timestamp / 60) % 60);
}
function getSecond(uint timestamp) constant returns (uint8) {
return uint8(timestamp % 60);
}
function getWeekday(uint timestamp) constant returns (uint8) {
return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
}
function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp) {
return toTimestamp(year, month, day, 0, 0, 0);
}
function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp) {
return toTimestamp(year, month, day, hour, 0, 0);
}
function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) constant returns (uint timestamp) {
return toTimestamp(year, month, day, hour, minute, 0);
}
function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp) {
uint16 i;
for (i = ORIGIN_YEAR; i < year; i++) {
if (isLeapYear(i)) {
timestamp += LEAP_YEAR_IN_SECONDS;
}
else {
timestamp += YEAR_IN_SECONDS;
}
}
uint8[12] memory monthDayCounts;
monthDayCounts[0] = 31;
if (isLeapYear(year)) {
monthDayCounts[1] = 29;
}
else {
monthDayCounts[1] = 28;
}
monthDayCounts[2] = 31;
monthDayCounts[3] = 30;
monthDayCounts[4] = 31;
monthDayCounts[5] = 30;
monthDayCounts[6] = 31;
monthDayCounts[7] = 31;
monthDayCounts[8] = 30;
monthDayCounts[9] = 31;
monthDayCounts[10] = 30;
monthDayCounts[11] = 31;
for (i = 1; i < month; i++) {
timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
}
timestamp += DAY_IN_SECONDS * (day - 1);
timestamp += HOUR_IN_SECONDS * (hour);
timestamp += MINUTE_IN_SECONDS * (minute);
timestamp += second;
return timestamp;
}
}
contract ProofOfExistence {
string public result;
function uintToString(uint v) constant returns (string str) {
uint maxlength = 100;
bytes memory reversed = new bytes(maxlength);
uint i = 0;
while (v != 0) {
uint remainder = v % 10;
v = v / 10;
reversed[i++] = byte(48 + remainder);
}
bytes memory s = new bytes(i + 1);
for (uint j = 0; j <= i; j++) {
s[j] = reversed[i - j];
}
str = string(s);
}
function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
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
mapping (string => uint) private proofs;
function notarize(string sha256) {
if ( bytes(sha256).length == 64 ){
if ( proofs[sha256] == 0 ){
proofs[sha256] = block.timestamp;
}
}
}
function verify(string sha256) constant returns (string) {
var timestamp =  proofs[sha256];
if ( timestamp == 0 ){
return "No data found";
}else{
DateTime dt = DateTime(msg.sender);
uint year = dt.getYear(timestamp);
uint month = dt.getMonth(timestamp);
uint day = dt.getDay(timestamp);
uint hour = dt.getHour(timestamp);
uint minute = dt.getMinute(timestamp);
uint second = dt.getSecond(timestamp);
result = strConcat(uintToString(year) , "-" , uintToString(month),"-",uintToString(day));
result = strConcat(result," ");
result = strConcat( uintToString(hour) , ":" , uintToString(minute),":",uintToString(second));
result = strConcat(result," UTC");
return result;
}
}
}