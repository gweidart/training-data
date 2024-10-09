pragma solidity ^0.4.4;
contract TeamContract {
address   contractOwner;
struct Team {
uint      index;
address   owner;
uint      lastUpdated;
bool initialized;
string team;
string lead;
string size;
string description;
string github;
}
mapping(bytes32 => Team) public teamMap;
bytes32[] public teamArray;
function TeamContract() public {
contractOwner = msg.sender;
}
function createTeam(bytes32 id,
string team, string lead, string size, string description, string github)
public returns (bool) {
require (teamMap[id].owner == address(0));
teamMap[id].index = teamArray.length;
teamArray.push(id);
teamMap[id].owner = msg.sender;
teamMap[id].lastUpdated = now;
teamMap[id].team=team;
teamMap[id].lead=lead;
teamMap[id].size=size;
teamMap[id].description=description;
teamMap[id].github=github;
TeamCreated(id,
team, lead, size, description, github);
return true;
}
function  readTeam(bytes32 id) constant public returns (address,uint,
string, string, string, string, string) {
return (teamMap[id].owner, teamMap[id].lastUpdated,
teamMap[id].team, teamMap[id].lead, teamMap[id].size, teamMap[id].description, teamMap[id].github);
}
function  readTeamByIndex(uint index) constant public returns (address,uint,
string, string, string, string, string) {
require(index < teamArray.length);
bytes32 id = teamArray[index];
return (teamMap[id].owner, teamMap[id].lastUpdated,
teamMap[id].team, teamMap[id].lead, teamMap[id].size, teamMap[id].description, teamMap[id].github);
}
function updateTeam(bytes32 id,
string team, string lead, string size, string description, string github)
public  returns (bool) {
require (teamMap[id].owner != address(0));
require (teamMap[id].owner == msg.sender || contractOwner == msg.sender);
teamMap[id].lastUpdated = now;
teamMap[id].team=team;
teamMap[id].lead=lead;
teamMap[id].size=size;
teamMap[id].description=description;
teamMap[id].github=github;
TeamUpdated(id,
team, lead, size, description, github);
return true;
}
function deleteTeam  (bytes32 id) public  returns (bool) {
require (teamMap[id].owner != address(0));
require (teamMap[id].owner == msg.sender || contractOwner == msg.sender);
var i = teamMap[id].index;
var lastTeam = teamArray[teamArray.length-1];
teamMap[lastTeam].index = i;
teamArray[i] = lastTeam;
teamArray.length--;
TeamDeleted(id,
teamMap[id].team, teamMap[id].lead, teamMap[id].size, teamMap[id].description, teamMap[id].github );
delete(teamMap[id]);
return true;
}
function  countTeam() constant public returns (uint) {
return teamArray.length;
}
event TeamCreated(bytes32 indexed _id,
string team, string lead, string size, string description, string github);
event TeamUpdated(bytes32 indexed _id,
string team, string lead, string size, string description, string github);
event TeamDeleted(bytes32 indexed _id,
string team, string lead, string size, string description, string github);
}