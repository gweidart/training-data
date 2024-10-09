pragma solidity ^0.4.11;
library BTC {
function parseVarInt(bytes txBytes, uint pos) returns (uint, uint) {
var ibit = uint8(txBytes[pos]);
pos += 1;
if (ibit < 0xfd) {
return (ibit, pos);
} else if (ibit == 0xfd) {
return (getBytesLE(txBytes, pos, 16), pos + 2);
} else if (ibit == 0xfe) {
return (getBytesLE(txBytes, pos, 32), pos + 4);
} else if (ibit == 0xff) {
return (getBytesLE(txBytes, pos, 64), pos + 8);
}
}
function getBytesLE(bytes data, uint pos, uint bits) returns (uint) {
if (bits == 8) {
return uint8(data[pos]);
} else if (bits == 16) {
return uint16(data[pos])
+ uint16(data[pos + 1]) * 2 ** 8;
} else if (bits == 32) {
return uint32(data[pos])
+ uint32(data[pos + 1]) * 2 ** 8
+ uint32(data[pos + 2]) * 2 ** 16
+ uint32(data[pos + 3]) * 2 ** 24;
} else if (bits == 64) {
return uint64(data[pos])
+ uint64(data[pos + 1]) * 2 ** 8
+ uint64(data[pos + 2]) * 2 ** 16
+ uint64(data[pos + 3]) * 2 ** 24
+ uint64(data[pos + 4]) * 2 ** 32
+ uint64(data[pos + 5]) * 2 ** 40
+ uint64(data[pos + 6]) * 2 ** 48
+ uint64(data[pos + 7]) * 2 ** 56;
}
}
function getFirstTwoOutputs(bytes txBytes)
returns (uint, bytes20, uint, bytes20)
{
uint pos;
uint[] memory input_script_lens = new uint[](2);
uint[] memory output_script_lens = new uint[](2);
uint[] memory script_starts = new uint[](2);
uint[] memory output_values = new uint[](2);
bytes20[] memory output_addresses = new bytes20[](2);
pos = 4;
(input_script_lens, pos) = scanInputs(txBytes, pos, 0);
(output_values, script_starts, output_script_lens, pos) = scanOutputs(txBytes, pos, 2);
for (uint i = 0; i < 2; i++) {
var pkhash = parseOutputScript(txBytes, script_starts[i], output_script_lens[i]);
output_addresses[i] = pkhash;
}
return (output_values[0], output_addresses[0],
output_values[1], output_addresses[1]);
}
function checkValueSent(bytes txBytes, bytes20 btcAddress, uint value)
returns (bool,uint)
{
uint pos = 4;
(, pos) = scanInputs(txBytes, pos, 0);
var (output_values, script_starts, output_script_lens,) = scanOutputs(txBytes, pos, 0);
for (uint i = 0; i < output_values.length; i++) {
var pkhash = parseOutputScript(txBytes, script_starts[i], output_script_lens[i]);
if (pkhash == btcAddress && output_values[i] >= value) {
return (true,output_values[i]);
}
}
}
function scanInputs(bytes txBytes, uint pos, uint stop)
returns (uint[], uint)
{
uint n_inputs;
uint halt;
uint script_len;
(n_inputs, pos) = parseVarInt(txBytes, pos);
if (stop == 0 || stop > n_inputs) {
halt = n_inputs;
} else {
halt = stop;
}
uint[] memory script_lens = new uint[](halt);
for (var i = 0; i < halt; i++) {
pos += 36;
(script_len, pos) = parseVarInt(txBytes, pos);
script_lens[i] = script_len;
pos += script_len + 4;
}
return (script_lens, pos);
}
function scanOutputs(bytes txBytes, uint pos, uint stop)
returns (uint[], uint[], uint[], uint)
{
uint n_outputs;
uint halt;
uint script_len;
(n_outputs, pos) = parseVarInt(txBytes, pos);
if (stop == 0 || stop > n_outputs) {
halt = n_outputs;
} else {
halt = stop;
}
uint[] memory script_starts = new uint[](halt);
uint[] memory script_lens = new uint[](halt);
uint[] memory output_values = new uint[](halt);
for (var i = 0; i < halt; i++) {
output_values[i] = getBytesLE(txBytes, pos, 64);
pos += 8;
(script_len, pos) = parseVarInt(txBytes, pos);
script_starts[i] = pos;
script_lens[i] = script_len;
pos += script_len;
}
return (output_values, script_starts, script_lens, pos);
}
function sliceBytes20(bytes data, uint start) returns (bytes20) {
uint160 slice = 0;
for (uint160 i = 0; i < 20; i++) {
slice += uint160(data[i + start]) << (8 * (19 - i));
}
return bytes20(slice);
}
function isP2PKH(bytes txBytes, uint pos, uint script_len) returns (bool) {
return (script_len == 25)
&& (txBytes[pos] == 0x76)
&& (txBytes[pos + 1] == 0xa9)
&& (txBytes[pos + 2] == 0x14)
&& (txBytes[pos + 23] == 0x88)
&& (txBytes[pos + 24] == 0xac);
}
function isP2SH(bytes txBytes, uint pos, uint script_len) returns (bool) {
return (script_len == 23)
&& (txBytes[pos + 0] == 0xa9)
&& (txBytes[pos + 1] == 0x14)
&& (txBytes[pos + 22] == 0x87);
}
function parseOutputScript(bytes txBytes, uint pos, uint script_len)
returns (bytes20)
{
if (isP2PKH(txBytes, pos, script_len)) {
return sliceBytes20(txBytes, pos + 3);
} else if (isP2SH(txBytes, pos, script_len)) {
return sliceBytes20(txBytes, pos + 2);
} else {
return;
}
}
}