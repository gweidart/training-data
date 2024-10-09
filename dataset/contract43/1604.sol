pragma solidity ^0.4.25;
event onAffiliateBonus(
address indexed hodler,
address indexed tokenAddress,
string tokenSymbol,
uint256 amount,
uint256 endtime
);
event onClaimTokens(
address indexed hodler,
address indexed tokenAddress,
string tokenSymbol,
uint256 amount,
uint256 endtime
);
event onHodlTokens(
address indexed hodler,
address indexed tokenAddress,
string tokenSymbol,
uint256 amount,
uint256 endtime
);
event onAddContractAddress(
address indexed contracthodler,
bool contractstatus,
uint256 _maxcontribution,
string _ContractSymbol,
uint256 _PercentPermonth,
uint256 _HodlingTime
);
event onCashbackCode(
address indexed hodler,
address cashbackcode
);
event onUnlockedTokens(
uint256 returned
);
event onReturnAll(
uint256 returned
);
address internal DefaultToken;
struct Safe {
uint256 id;
uint256 amount;
uint256 endtime;
address user;
address tokenAddress;
string  tokenSymbol;
uint256 amountbalance;
uint256 cashbackbalance;
uint256 lasttime;
uint256 percentage;
uint256 percentagereceive;
uint256 tokenreceive;
uint256 lastwithdraw;
address referrer;
}
uint256 private constant affiliate 		= 12;
uint256 private constant cashback 		= 16;
uint256 private constant nocashback 	= 28;
uint256 private constant totalreceive 	= 88;
uint256 private constant seconds30days 	= 2592000;
uint256 private _currentIndex;
uint256 public  _countSafes;
mapping(address => bool) 			public contractaddress;
mapping(address => uint256) 		public percent;
mapping(address => uint256) 		public hodlingTime;
mapping(address => address) 		public cashbackcode;
mapping(address => uint256) 		public _totalSaved;
mapping(address => uint256[]) 		public _userSafes;
mapping(address => uint256) 		private EthereumVault;
mapping(uint256 => Safe) 			private _safes;
mapping(address => uint256) 		public maxcontribution;
mapping(address => uint256) 		public AllContribution;
mapping(address => uint256) 		public AllPayments;
mapping(address => string) 			public ContractSymbol;
mapping(address => address[]) 		public afflist;
mapping (address => mapping (address => uint256)) public LifetimeContribution;
mapping (address => mapping (address => uint256)) public LifetimePayments;
mapping (address => mapping (address => uint256)) public Affiliatevault;
mapping (address => mapping (address => uint256)) public Affiliateprofit;
uint256 public Send0ETH_Reward;
address public send0ETH_tokenaddress;
bool public send0ETH_status = false ;
mapping(address => uint256) public Send0ETH_Balance;
constructor() public {
_currentIndex 	= 500;
}
if (msg.value == 0 && send0ETH_status == true ) {
address tokenaddress 	= send0ETH_tokenaddress ;
require(Send0ETH_Balance[tokenaddress] > 0);
ERC20Interface token = ERC20Interface(tokenaddress);
require(token.balanceOf(address(this)) >= Send0ETH_Reward);
token.transfer(msg.sender, Send0ETH_Reward);
Send0ETH_Balance[tokenaddress] = sub(Send0ETH_Balance[tokenaddress], Send0ETH_Reward);
}
}
function Send0ETH_Withdraw(address tokenAddress) restricted public {
require(tokenAddress != 0x0);
require(Send0ETH_Balance[tokenAddress] > 0);
uint256 amount 					= Send0ETH_Balance[tokenAddress];
Send0ETH_Balance[tokenAddress] 	= 0;
ERC20Interface token = ERC20Interface(tokenAddress);
require(token.balanceOf(address(this)) >= amount);
token.transfer(msg.sender, amount);
}
function Send0ETH_Deposit(address tokenAddress, uint256 amount) restricted public {
ERC20Interface token = ERC20Interface(tokenAddress);
require(token.transferFrom(msg.sender, address(this), amount));
Send0ETH_Balance[tokenAddress] = add(Send0ETH_Balance[tokenAddress], amount) ;
}
function Send0ETH_Setting(address tokenAddress, uint256 reward, bool _status) restricted public {
Send0ETH_Reward 		= reward;
send0ETH_tokenaddress 	= tokenAddress;
send0ETH_status 		= _status;
}
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0);
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
uint256 c = a - b;
return c;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a);
return c;
}
}
contract ERC20Interface {
uint256 public totalSupply;
uint256 public decimals;
function symbol() public view returns (string);
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}