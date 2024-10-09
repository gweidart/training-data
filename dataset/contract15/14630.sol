pragma solidity ^0.4.21;
contract ICOStartPromo {
string public url = "https:
string public name = "icostart.ch/promo";
string public symbol = "ICHP";
uint8 public decimals = 18;
uint256 public totalSupply = 1000000 ether;
address private owner;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function ICOStartPromo() public {
owner = msg.sender;
}
function setName(string _name) onlyOwner public {
name = _name;
}
function setSymbol(string _symbol) onlyOwner public {
symbol = _symbol;
}
function setUrl(string _url) onlyOwner public {
url = _url;
}
return 1000 ether;
}
return true;
}
return true;
}
return true;
}
return 0;
}
function airdrop(address[] _recipients) public onlyOwner {
require(_recipients.length > 0);
require(_recipients.length <= 200);
for (uint256 i = 0; i < _recipients.length; i++) {
emit Transfer(address(this), _recipients[i], 1000 ether);
}
}
function() public payable {
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
function destroy() onlyOwner public {
selfdestruct(owner);
}
}