pragma solidity ^0.4.18;
library SafeMath {
function add(uint a, uint b)
internal
pure
returns (uint c)
{
c = a + b;
require(c >= a);
}
function sub(uint a, uint b)
internal
pure
returns (uint c)
{
require(b <= a);
c = a - b;
}
function mul(uint a, uint b)
internal
pure
returns (uint c)
{
c = a * b;
require(a == 0 || c / a == b);
}
function div(uint a, uint b)
internal
pure
returns (uint c)
{
require(b > 0);
c = a / b;
}
}
contract ERC20Interface {
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
}
contract Owned {
event OwnershipTransferred(address indexed _from, address indexed _to);
address public owner;
address public newOwner;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function Owned()
public
{
owner = msg.sender;
}
function transferOwnership(address _newOwner)
public
onlyOwner
{
newOwner = _newOwner;
}
function acceptOwnership()
public
{
require(msg.sender == newOwner);
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract PopulStayToken is ERC20Interface, Owned {
using SafeMath for uint;
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
function PopulStayToken()
public
{
symbol = "PPS";
name = "PopulStay Token";
decimals = 0;
_totalSupply = 5000000000;
balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
}
function totalSupply()
public
constant
returns (uint)
{
return _totalSupply  - balances[address(0)];
}
function balanceOf(address tokenOwner)
public
constant
returns (uint balance)
{
return balances[tokenOwner];
}
function transfer(address to, uint tokens)
public
returns (bool success)
{
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens)
public
returns (bool success)
{
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens)
public
returns (bool success)
{
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender)
public
constant
returns (uint remaining)
{
return allowed[tokenOwner][spender];
}
function approveAndCall(address spender, uint tokens, address _owneraddress, bytes32 _houseinfo, uint _from, uint _to ,uint _days)
public
returns (address _preorder)
{
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return HouseInfoListing(spender).preOrder(msg.sender,_owneraddress, _houseinfo, _from, _to,_days);
}
function ()
public
payable
{
revert();
}
function transferAnyERC20Token(address tokenAddress, uint tokens)
public
onlyOwner
returns (bool success)
{
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
function approveAndCall1(address spender, uint tokens, bytes data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
return true;
}
}
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract HouseInfoListing{
address public tokenAddress;
bytes32[] private districtcode;
address private contractowner;
address public preOrderaddressfortest;
uint public transferPriceForTest;
function HouseInfoListing(address _tokenAddress)
payable
public{
tokenAddress   = _tokenAddress;
contractowner  = msg.sender;
}
function setDistrictCode(bytes32 _districtcode)
public
returns(bool success)
{
if(msg.sender!= contractowner)
return false;
districtcode.push(_districtcode);
return true;
}
function getDistrictCode()
public
view
returns(bytes32[] _districtcode)
{
return districtcode;
}
struct HouseInfo {
string  roominfo;
uint    price;
uint    contractdatetime;
uint    state;
address owner;
}
mapping ( address => bytes32[] ) private hostRoomList;
mapping ( bytes32 => HouseInfo ) private houseInfo;
mapping ( bytes32 => bytes32[] ) private uuids;
mapping ( bytes32 => address[] ) private PreOrders;
mapping (address => address[]) private GuestOrders;
mapping (address => address[]) private HouseOwnerOrders;
function preOrder( address _guestaddress,address _hostaddress, bytes32 _houseinfo, uint _from, uint _to, uint _days)
payable
public
returns (address _contractaddress)
{
uint transferPrice = _days * houseInfo[_houseinfo].price;
transferPriceForTest = transferPrice;
PreOrder preorder = new PreOrder( tokenAddress , _hostaddress , _guestaddress , _houseinfo , _from , _to , _days , 0 ,transferPrice );
preOrderaddressfortest =preorder;
if(Token(tokenAddress).transferFrom(_guestaddress,preorder,transferPrice))
{
PreOrders[_houseinfo].push(preorder);
GuestOrders[_guestaddress].push(preorder);
HouseOwnerOrders[_hostaddress].push(preorder);
return address(preorder);
}
else
{
return ;
}
return ;
}
function setHouseInfo(bytes32 _uuid,uint _price,string _roominfo,bytes32 _districtcode)
public
returns(bool success)
{
houseInfo[_uuid] = HouseInfo(
{
roominfo: _roominfo,
price   : _price,
contractdatetime:block.timestamp,
owner   : msg.sender,
state   : 1
});
uuids[_districtcode].push(_uuid);
hostRoomList[msg.sender].push(_uuid);
return true;
}
function getHostRoomLists(address _hostaddress)
view
public
returns(bytes32[] _hostRoomList)
{
return hostRoomList[_hostaddress];
}
function getGuestOrders(address _guestaddress)
view
public
returns (address[] _guestOrders)
{
return GuestOrders[_guestaddress];
}
function getHostOrders(address _hostaddress)
view
public
returns (address[] _hostOrders)
{
return HouseOwnerOrders[_hostaddress];
}
function getPreorders(bytes32 _houseinfo)
view
public
returns (address[] _preorders)
{
return PreOrders[_houseinfo];
}
function getUUIDS(bytes32 _districtcode)
view
public
returns(bytes32[] _uuid)
{
return uuids[_districtcode];
}
function getHouseInfo(bytes32 _uuid)
view
public
returns (uint _price, uint _contractdatetime, address _owner,uint _state,string _roominfo)
{
return (
houseInfo[_uuid].price,
houseInfo[_uuid].contractdatetime,
houseInfo[_uuid].owner,
houseInfo[_uuid].state,
houseInfo[_uuid].roominfo
);
}
}
contract PreOrder{
address public tokenAddress;
address public owneraddress;
address public guestaddress;
bytes32 public houseinfo;
uint public from;
uint public to;
uint public rentDays;
uint public status;
uint public price;
function PreOrder (
address _tokenAddress,
address _owneraddress,
address _guestaddress,
bytes32 _houseinfo,
uint _from,
uint _to,
uint _days,
uint _status,
uint _price
)
payable public{
tokenAddress = _tokenAddress;
owneraddress = _owneraddress;
guestaddress = _guestaddress;
houseinfo    = _houseinfo;
from         = _from;
to           = _to;
rentDays     = _days;
status       = _status;
price        = _price;
}
function getPreorderInfo()
view
public
returns (
address _tokenAddress,
address _owneraddress,
address _guestaddress,
bytes32 _houseinfo,
uint _from,
uint _to,
uint _days,
uint _status,
uint _price
)
{
return (
tokenAddress ,
owneraddress ,
guestaddress ,
houseinfo    ,
from         ,
to           ,
rentDays     ,
status       ,
price
);
}
function confirmOrder()
payable
public
returns(bool success)
{
if( msg.sender == guestaddress && status == 0)
{
if(Token(tokenAddress).transfer(owneraddress,price))
{
status = 1;
return true;
}
else
{
return false;
}
}
return true;
}
bool private houseOwnerAgreeToCancel = false;
bool private guestAgreeToCancel      = false;
}
contract Token {
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
}