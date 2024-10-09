contract EthVenturePlugin {
address public owner;
function EthVenturePlugin() {
owner = 0xEe462A6717f17C57C826F1ad9b4d3813495296C9;
}
function() {
uint Fees = msg.value;