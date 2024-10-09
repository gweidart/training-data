pragma solidity ^0.4.24;
library SafeMath {
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
interface ERC20Interface {
function totalSupply() external constant returns (uint256);
function balanceOf(address _owner) external constant returns (uint256 balance);
function transfer(address _to, uint256 _value) external returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
function approve(address _spender, uint256 _value) external returns (bool success);
function allowance(address _owner, address _spender) external constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract STTInterface is ERC20Interface {
function BuyTokens () external payable returns (uint256 AtokenBought);
event Mint(address indexed _to, uint256 amount);
function SellTokens (uint256 SellAmount) external payable returns (uint256 EtherPaid);
function split() external returns (bool success);
event Split(uint256 factor);
function getReserve() external constant returns (uint256);
function burn(uint256 _value) external returns (bool success);
event Burn(address indexed _burner, uint256 value);
}
contract AToken is STTInterface {
using SafeMath for uint256;
uint256 public _totalSupply = 10000000000000000000000;
string public name = "A-Token";
string public symbol = "A";
uint8 public constant decimals = 18;
mapping(address => uint256) public balances;
mapping(address => mapping (address => uint256)) public allowed;
address[] private tokenHolders;
mapping(address => bool) private tokenHoldersMap;
constructor() public {
balances[msg.sender] = _totalSupply;
tokenHolders.push(msg.sender);
tokenHoldersMap[msg.sender] = true;
}