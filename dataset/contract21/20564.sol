pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract BicycleToken {
string public name = "Bicycle Token";
string public symbol = "BIC";
uint8 public decimals = 0;
uint256 public totalSupply;
uint256 public BicycleSupply = 15000000;
uint256 public price ;
address public creator;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event FundTransfer(address backer, uint amount, bool isContribution);
function BicycleToken() public {
totalSupply = BicycleSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
creator = msg.sender;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function () payable internal {
if (price == 0 ether){
uint ammount = 500;
uint ammountRaised;
ammountRaised += msg.value;
require(balanceOf[creator] >= 6000000);
require(msg.value < 0.5 ether);
require(balanceOf[msg.sender] == 0);
balanceOf[msg.sender] += ammount;
balanceOf[creator] -= ammount;
Transfer(creator, msg.sender, ammount);
creator.transfer(ammountRaised);
}
}
}