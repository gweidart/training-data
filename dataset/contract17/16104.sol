pragma solidity 		^0.4.21	;
contract	TableDeRapprochement_322		{
address	owner	;
function	TableDeRapprochement_322		()	public	{
owner	= msg.sender;
}
modifier	onlyOwner	() {
require(msg.sender ==		owner	);
_;
}
uint256	Data_1	=	1000	;
function	setData_1	(	uint256	newData_1	)	public	onlyOwner	{
Data_1	=	newData_1	;
}
function	getData_1	()	public	constant	returns	(	uint256	)	{
return	Data_1	;
}
}