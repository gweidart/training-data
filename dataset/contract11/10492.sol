pragma solidity ^0.4.18;
library SafeMath
{
function mul(uint256 a, uint256 b) internal pure returns (uint256)
{
if (a == 0)     return 0;
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256)
{
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256)
{
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256)
{
uint256 c = a + b;
assert(c >= a);
return c;
}
}
library StringLib
{
function concat(string strA, string strB) internal pure returns (string)
{
uint            i;
uint            g;
uint            finalLen;
bytes memory    dataStrA;
bytes memory    dataStrB;
bytes memory    buffer;
dataStrA  = bytes(strA);
dataStrB  = bytes(strB);
finalLen  = dataStrA.length + dataStrB.length;
buffer    = new bytes(finalLen);
for (g=i=0; i<dataStrA.length; i++)   buffer[g++] = dataStrA[i];
for (i=0;   i<dataStrB.length; i++)   buffer[g++] = dataStrB[i];
return string(buffer);
}
function same(string strA, string strB) internal pure returns(bool)
{
return keccak256(strA)==keccak256(strB);
}
function uintToAscii(uint number) internal pure returns(byte)
{
if (number < 10)         return byte(48 + number);
else if (number < 16)         return byte(87 + number);
revert();
}
function asciiToUint(byte char) internal pure returns (uint)
{
uint asciiNum = uint(char);
if (asciiNum > 47 && asciiNum < 58)    return asciiNum - 48;
else if (asciiNum > 96 && asciiNum < 103)   return asciiNum - 87;
revert();
}
function bytes32ToString (bytes32 data) internal pure returns (string)
{
bytes memory bytesString = new bytes(64);
for (uint j=0; j < 32; j++)
{
byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
bytesString[j*2+0] = uintToAscii(uint(char) / 16);
bytesString[j*2+1] = uintToAscii(uint(char) % 16);
}
return string(bytesString);
}
function stringToBytes32(string str) internal pure returns (bytes32)
{
bytes memory bString = bytes(str);
uint uintString;
if (bString.length != 64) { revert(); }
for (uint i = 0; i < 64; i++)
{
uintString = uintString*16 + uint(asciiToUint(bString[i]));
}
return bytes32(uintString);
}
}
contract ERC20
{
function balanceOf(   address _owner)                               public constant returns (uint256 balance);
function transfer(    address toAddr,  uint256 amount)              public returns (bool success);
function allowance(   address owner,   address spender)             public constant returns (uint256);
function transferFrom(address fromAddr,address toAddr, uint256 value)   public returns (bool);
function approve(     address spender, uint256 value)               public returns (bool);
event Transfer(address indexed fromAddr, address indexed toAddr,   uint256 amount);
event Approval(address indexed _owner,   address indexed _spender, uint256 amount);
uint256 public totalSupply;
}
contract Ownable
{
address public owner;
function Ownable() public
{
owner = msg.sender;
}
modifier onlyOwner()
{
require(msg.sender == owner);
_;
}
}
contract Lockable is Ownable
{
uint256 internal constant lockedUntil = 1527811200;
address internal allowedSender;
modifier unlocked()
{
require((now > lockedUntil) || (allowedSender == msg.sender));
_;
}
function transferOwnership(address newOwner) public onlyOwner
{
require(newOwner != address(0));
owner = newOwner;
allowedSender = newOwner;
}
}
contract Token is ERC20, Lockable
{
using SafeMath for uint256;
address public                                      owner;
mapping(address => uint256)                         balances;
mapping(address => mapping (address => uint256))    allowances;
string public constant      name     = "Yield Coin";
string public constant      symbol   = "YLD";
uint256 public constant     decimals = 2;
uint256 public constant     initSupply = 1100000000 * 10**decimals;
modifier onlyOwner()
{
if (msg.sender != owner)
{
assert(true==false);
}
_;
}
function Token() public
{
owner           = msg.sender;
totalSupply     = initSupply;
balances[owner] = initSupply;
allowedSender = owner;
}
function transfer(address toAddr, uint256 amount)  public   unlocked returns (bool success)
{
require(toAddr!=0x0 && toAddr!=msg.sender && amount>0);
balances[msg.sender] = balances[msg.sender].sub(amount);
balances[toAddr]     = balances[toAddr].add(amount);
Transfer(msg.sender, toAddr, amount);
return true;
}
function transferFrom(address fromAddr, address toAddr, uint256 amount)  public   unlocked returns (bool)
{
if (amount <= 0)                                return false;
if (fromAddr==toAddr)                           return false;
if(allowances[fromAddr][msg.sender] < amount)   return false;
if(balances[fromAddr] < amount)                 return false;
balances[fromAddr] = balances[fromAddr].sub(amount);
balances[toAddr]   = balances[toAddr].add(  amount);
allowances[fromAddr][msg.sender] = allowances[fromAddr][msg.sender].sub(amount);
Transfer(fromAddr, toAddr, amount);
return true;
}
function balanceOf(address _owner)  public   constant returns (uint256 balance)
{
return balances[_owner];
}
function approve(address _spender, uint256 amount)  public   returns (bool)
{
require((amount == 0) || (allowances[msg.sender][_spender] == 0));
allowances[msg.sender][_spender] = amount;
Approval(msg.sender, _spender, amount);
return true;
}
function allowance(address _owner, address _spender)  public   constant returns (uint remaining)
{
return allowances[_owner][_spender];
}
function() public
{
assert(true == false);
}
}