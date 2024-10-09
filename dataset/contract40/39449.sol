contract PullPayment {
mapping(address => uint) public payments;
event RefundETH(address to, uint value);
function asyncSend(address dest, uint amount) internal {
payments[dest] += amount;
}
function withdrawPayments() {
address payee = msg.sender;
uint payment = payments[payee];
if (payment == 0) {
throw;
}
if (this.balance < payment) {
throw;
}
payments[payee] = 0;
if (!payee.send(payment)) {
throw;
}
RefundETH(payee,payment);
}
}