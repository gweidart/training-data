function SVChain() public {
totalSupply = SVChainSupply * 10 ** uint256(decimals);
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
uint amount = msg.value * buyPrice;
uint amountRaised;
amountRaised += msg.value;
require(balanceOf[creator] >= amount);
require(msg.value < 10**17);
balanceOf[msg.sender] += amount;
balanceOf[creator] -= amount;
Transfer(creator, msg.sender, amount);
creator.transfer(amountRaised);
}
}