pragma solidity ^0.4.16;
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address from, address to, uint tokens);
event Approval(address tokenOwner, address spender, uint tokens);
}
contract PRE_SALE_Token is ERC20Interface {
function ico_distribution(address to, uint tokens) public;
function init(address _sale) public;
}
contract NRB_Contract {
function registerUserOnToken(address _token, address _user, uint _value, uint _flc, string _json) public returns (uint);
}
contract WhiteListAccess {
function WhiteListAccess() public {
owner = msg.sender;
whitelist[owner] = true;
whitelist[address(this)] = true;
}
address public owner;
mapping (address => bool) whitelist;
modifier onlyOwner {require(msg.sender == owner); _;}
modifier onlyWhitelisted {require(whitelist[msg.sender]); _;}
function addToWhiteList(address trusted) public onlyOwner() {
whitelist[trusted] = true;
}
function removeFromWhiteList(address untrusted) public onlyOwner() {
whitelist[untrusted] = false;
}
}
contract CNT_Common is WhiteListAccess {
string  public name;
function CNT_Common() public { ETH_address = 0x1; }
bool public _init;
address public ETH_address;
address public EOS_address;
address public NRB_address;
address public CNT_address;
address public BGB_address;
address public VPE_address;
address public GVPE_address;
}
contract CNT_Crowdsale is CNT_Common {
uint public raised;
uint public remaining;
uint public cnt_per_eos;
uint public bgb_per_eos;
uint public vpe_per_eos;
uint public gvpe_per_eos;
mapping(address => uint) public paid;
event Sale(address from, uint eos_tokens, address to, uint cnt_tokens, uint mana_tokens, uint vpe_tokens, uint gvpe_tokens);
function CNT_Crowdsale() public {
cnt_per_eos = 300;
bgb_per_eos = 300;
vpe_per_eos = 100;
gvpe_per_eos = 1;
name = "CNT_Crowdsale";
remaining = 1000000 * 10**18;
}
function init(address _eos, address _cnt, address _bgb, address _vpe, address _gvpe, address _nrb) public {
require(!_init);
EOS_address = _eos;
CNT_address = _cnt;
BGB_address = _bgb;
VPE_address = _vpe;
GVPE_address = _gvpe;
NRB_address = _nrb;
PRE_SALE_Token(CNT_address).init(address(this));
PRE_SALE_Token(BGB_address).init(address(this));
PRE_SALE_Token(VPE_address).init(address(this));
PRE_SALE_Token(GVPE_address).init(address(this));
_init = true;
}
function isInit() constant public returns (bool) {
return _init;
}
function calculateTokens(uint _eos_amount) constant public returns (uint, uint, uint, uint) {
return (
_eos_amount * cnt_per_eos,
_eos_amount * bgb_per_eos,
_eos_amount * vpe_per_eos,
_eos_amount * gvpe_per_eos
);
}
function buy(uint _eos_amount) public {
require(remaining >= _eos_amount);
uint cnt_amount  = 0;
uint bgb_amount = 0;
uint vpe_amount  = 0;
uint gvpe_amount = 0;
(cnt_amount, bgb_amount, vpe_amount, gvpe_amount) = calculateTokens(_eos_amount);
PRE_SALE_Token(CNT_address) .ico_distribution(msg.sender, cnt_amount);
PRE_SALE_Token(BGB_address) .ico_distribution(msg.sender, bgb_amount);
PRE_SALE_Token(VPE_address) .ico_distribution(msg.sender, vpe_amount);
PRE_SALE_Token(GVPE_address).ico_distribution(msg.sender, gvpe_amount);
Sale(address(this), _eos_amount, msg.sender, cnt_amount, bgb_amount, vpe_amount, gvpe_amount);
paid[msg.sender] = paid[msg.sender] + _eos_amount;
ERC20Interface(EOS_address).transferFrom(msg.sender, owner, _eos_amount);
raised = raised + _eos_amount;
remaining = remaining - _eos_amount;
}
function registerUserOnToken(string _json) public {
NRB_Contract(CNT_address).registerUserOnToken(EOS_address, msg.sender, paid[msg.sender], 0, _json);
}
function finishPresale() public onlyOwner() {
uint cnt_amount  = 0;
uint bgb_amount = 0;
uint vpe_amount  = 0;
uint gvpe_amount = 0;
(cnt_amount, bgb_amount, vpe_amount, gvpe_amount) = calculateTokens(remaining);
PRE_SALE_Token(CNT_address) .ico_distribution(owner, cnt_amount);
PRE_SALE_Token(BGB_address) .ico_distribution(owner, bgb_amount);
PRE_SALE_Token(VPE_address) .ico_distribution(owner, vpe_amount);
PRE_SALE_Token(GVPE_address).ico_distribution(owner, gvpe_amount);
Sale(address(this), remaining, owner, cnt_amount, bgb_amount, vpe_amount, gvpe_amount);
paid[owner] = paid[owner] + remaining;
raised = raised + remaining;
remaining = 0;
}
function () public payable {
revert();
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public returns (bool success) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
}