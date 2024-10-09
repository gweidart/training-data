contract Destructible {
address _owner;
event receipt(address indexed investor, uint value);
modifier onlyOwner() {
require(msg.sender == _owner);
_;
}
constructor() public {
_owner = msg.sender;
}
function() payable public {
emit receipt(msg.sender, msg.value);
}
function destroyAndSend(address _recipient) onlyOwner() public {
selfdestruct(_recipient);
}
}