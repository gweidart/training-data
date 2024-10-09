pragma solidity ^0.4.18;
interface UidCheckerInterface {
function isUid(
string _uid
)
public
pure returns (bool);
}
contract UidCheckerForReddit
is UidCheckerInterface
{
string public fromVersion = "1.0.0";
function isUid(
string _uid
)
public
pure
returns (bool)
{
bytes memory uid = bytes(_uid);
if (uid.length < 3 || uid.length > 20) {
return false;
} else {
for (uint i = 0; i < uid.length; i++) {
if (!(
uid[i] == 45 || uid[i] == 95
|| (uid[i] >= 48 && uid[i] <= 57)
|| (uid[i] >= 97 && uid[i] <= 122)
)) {
return false;
}
}
}
return true;
}
}