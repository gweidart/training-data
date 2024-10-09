contract MintInterface {
function mint(address recipient, uint amount) returns (bool success);
}
contract WithdrawTokensFlixxo {
address public tokenContract;
uint public vesting;
address public receiver;
uint public amount;
modifier afterDate() {
require(now >= vesting);
_;
}
modifier onlyReceiver() {
require(msg.sender == receiver);
_;
}
function WithdrawTokensFlixxo(
address _tokenContract,
uint _vesting,
address _receiver,
uint _amount
) {
tokenContract = _tokenContract;
vesting = now + _vesting * 1 days;
receiver = _receiver;
amount = _amount;
}
function withdraw() public afterDate onlyReceiver {
require(amount > 0);
uint tokens = amount;
amount = 0;
if (!MintInterface(tokenContract).mint(receiver, tokens))
revert();
}
}