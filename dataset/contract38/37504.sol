contract F2UPay {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public initialSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function F2UPay() {
initialSupply = 90000000000000000000;
name ="F2UPay";
decimals = 9;
symbol = "F2UPay";
balanceOf[msg.sender] = initialSupply;
uint256 totalSupply = initialSupply;
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