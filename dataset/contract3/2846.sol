pragma solidity 0.4.24;
contract TokenBurn {
address public thisContractAddress;
address public admin;
address public newOwner = 0x0000000000000000000000000000000000000000;
modifier onlyAdmin {
require(msg.sender == admin
);
_;
}
constructor() public {
thisContractAddress = address(this);
admin = newOwner;
}
function () private payable {}
}