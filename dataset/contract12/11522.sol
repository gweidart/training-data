pragma solidity ^0.4.21;
contract Endorsements {
struct Endorsement {
bool positive;
string title;
string description;
address endorser;
}
mapping (address => Endorsement[]) public userEndorsements;
mapping (bytes32 => Endorsement[]) public vineyardEndorsements;
mapping (bytes32 => Endorsement[]) public harvestOperationEndorsements;
mapping (bytes32 => Endorsement[]) public wineryOperationEndorsements;
mapping (bytes32 => Endorsement[]) public productOperationEndorsements;
function Endorsements() public { }
function addUserEndorsement(
address user,
bool positive,
string title,
string description
)
external
returns (bool success)
{
userEndorsements[user].push(Endorsement(positive, title, description, msg.sender));
return true;
}
function addVineyardEndorsement(
string _mappingID,
uint _index,
bool positive,
string title,
string description
)
external
returns (bool success)
{
vineyardEndorsements[keccak256(_mappingID, _index)].push(
Endorsement(positive, title, description, msg.sender)
);
return true;
}
function addHarvestOperationEndorsement(
string _mappingID,
bool positive,
string title,
string description
)
external
returns (bool success)
{
harvestOperationEndorsements[keccak256(_mappingID)].push(
Endorsement(positive, title, description, msg.sender)
);
return true;
}
function addWineryOperationEndorsement(
string _mappingID,
uint _index,
bool positive,
string title,
string description
)
external
returns (bool success)
{
wineryOperationEndorsements[keccak256(_mappingID, _index)].push(
Endorsement(positive, title, description, msg.sender)
);
return true;
}
function addProductEndorsement(
string _mappingID,
uint _operationIndex,
int _productIndex,
bool positive,
string title,
string description
)
external
returns (bool success)
{
require(_productIndex > 0);
productOperationEndorsements[keccak256(_mappingID, _operationIndex, _productIndex)].push(
Endorsement(positive, title, description, msg.sender)
);
return true;
}
}