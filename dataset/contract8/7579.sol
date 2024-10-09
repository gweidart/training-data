contract ABLEBurned {
function () payable {
}
function burnMe () {
selfdestruct(address(this));
}
}