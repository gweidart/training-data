contract Medbaby {
string public standard;
string public name = "Medbaby";
string public symbol = "MDBY";
uint8 public decimals = 3;
uint256 public initialSupply = 300000000000;
uint256 public totalSupply = 200000000000;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function Medbaby() {
initialSupply = 300000000000;
name ="Medbaby";
decimals = 2;
symbol = "MDBY";
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
}
function transfer(address _to, uint256 _value) {
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
function () {
throw;
}
}