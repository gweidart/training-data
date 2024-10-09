pragma solidity 		^0.4.21	;
contract	Annexe_CPS_6		{
address	owner	;
function	Annexe_CPS_6		()	public	{
owner	= msg.sender;
}
modifier	onlyOwner	() {
require(msg.sender ==		owner	);
_;
}
string	Compte_1	=	"	une première phrase			"	;
function	setCompte_1	(	string	newCompte_1	)	public	onlyOwner	{
Compte_1	=	newCompte_1	;
}
function	getCompte_1	()	public	constant	returns	(	string	)	{
return	Compte_1	;
}
string	Compte_2	=	"	une première phrase			"	;
function	setCompte_2	(	string	newCompte_2	)	public	onlyOwner	{
Compte_2	=	newCompte_2	;
}
function	getCompte_2	()	public	constant	returns	(	string	)	{
return	Compte_2	;
}
string	Compte_3	=	"	une première phrase			"	;
function	setCompte_3	(	string	newCompte_3	)	public	onlyOwner	{
Compte_3	=	newCompte_3	;
}
function	getCompte_3	()	public	constant	returns	(	string	)	{
return	Compte_3	;
}
string	Compte_4	=	"	une première phrase			"	;
function	setCompte_4	(	string	newCompte_4	)	public	onlyOwner	{
Compte_4	=	newCompte_4	;
}
function	getCompte_4	()	public	constant	returns	(	string	)	{
return	Compte_4	;
}
}