library Uint8Lib {
function xorReduce(
uint8[] arr,
uint    len
)
public
constant
returns (uint8 res) {
res = arr[0];
for (uint i = 1; i < len; i++) {
res ^= arr[i];
}
}
}