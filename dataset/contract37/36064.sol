library ErrorLib {
event Error(string message);
function orThrow(bool condition, string message) public constant {
if (!condition) {
error(message);
}
}
function error(string message) public constant {
Error(message);
revert();
}
}