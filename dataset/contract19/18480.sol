pragma solidity ^0.4.21;
library StringUtils {
function allLower(string memory _string) internal pure returns (bool) {
bytes memory bytesString = bytes(_string);
for (uint i = 0; i < bytesString.length; i++) {
if ((bytesString[i] >= 65) && (bytesString[i] <= 90)) {
return false;
}
}
return true;
}
}