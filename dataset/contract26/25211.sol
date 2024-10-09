pragma solidity ^0.4.18;
interface ERC20 {
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
}
interface TokenConfigInterface {
function admin() public returns(address);
function claimAdmin() public;
function transferAdminQuickly(address newAdmin) public;
function addOperator(address newOperator) public;
function removeOperator (address operator) public;
function setQtyStepFunction(
ERC20 token,
int[] xBuy,
int[] yBuy,
int[] xSell,
int[] ySell
) public;
function setImbalanceStepFunction(
ERC20 token,
int[] xBuy,
int[] yBuy,
int[] xSell,
int[] ySell
) public;
}
contract TokenAdder {
TokenConfigInterface public network;
TokenConfigInterface public reserve;
TokenConfigInterface public conversionRate;
address public multisigAddress;
address public withdrawAddress;
address public ETH = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
ERC20 public ENG = ERC20(0xf0ee6b27b759c9893ce4f094b49ad28fd15a23e4);
ERC20 public SALT = ERC20(0x4156D3342D5c385a87D264F90653733592000581);
ERC20 public APPC = ERC20(0x1a7a8bd9106f2b8d977e08582dc7d24c723ab0db);
ERC20 public RDN = ERC20(0x255aa6df07540cb5d3d297f0d0d4d84cb52bc8e6);
address[] public newTokens = [
ENG,
SALT,
APPC,
RDN];
int[] zeroArray;
function TokenAdder(
TokenConfigInterface _conversionRate
)
public {
conversionRate = _conversionRate;
}
function setStepFunctions() public {
address orgAdmin = conversionRate.admin();
conversionRate.claimAdmin();
conversionRate.addOperator(address(this));
zeroArray.length = 0;
zeroArray.push(int(0));
for( uint i = 0 ; i < newTokens.length ; i++ ) {
conversionRate.setQtyStepFunction(ERC20(newTokens[i]),
zeroArray,
zeroArray,
zeroArray,
zeroArray);
conversionRate.setImbalanceStepFunction(ERC20(newTokens[i]),
zeroArray,
zeroArray,
zeroArray,
zeroArray);
}
conversionRate.removeOperator(address(this));
conversionRate.transferAdminQuickly(orgAdmin);
require(orgAdmin == conversionRate.admin());
}
}