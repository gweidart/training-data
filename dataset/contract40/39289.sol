contract ANT {
function changeController(address network);
}
contract Controller {
function proxyPayment(address _owner) payable returns(bool);
function onTransfer(address _from, address _to, uint _amount) returns(bool);
function onApprove(address _owner, address _spender, uint _amount)
returns(bool);
}
contract ANPlaceholder is Controller {
address public sale;
ANT public token;
function ANPlaceholder(address _sale, address _ant) {
sale = _sale;
token = ANT(_ant);
}
function changeController(address network) public {
if (msg.sender != sale) throw;
token.changeController(network);
suicide(network);
}
function proxyPayment(address _owner) payable public returns (bool) {
throw;
return false;
}
function onTransfer(address _from, address _to, uint _amount) public returns (bool) {
return true;
}
function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {
return true;
}
}