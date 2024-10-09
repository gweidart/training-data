pragma solidity 0.4.16;
contract MultiSigTokenWallet {
address constant public TOKEN = 0xeD247980396B10169BB1d36f6e278eD16700a60f;
event Confirmation(address source, uint actionId);
event Revocation(address source, uint actionId);
event NewAction(uint actionId);
event Execution(uint actionId);
event ExecutionFailure(uint actionId);
event OwnerAddition(address owner);
event OwnerWithdraw(address owner);
event QuorumChange(uint quorum);
enum ActionChoices { AddOwner, ChangeQuorum, DeleteAction, TransferToken, WithdrawOwner}
mapping (uint => Action) public actions;
mapping (uint => mapping (address => bool)) public confirmations;
mapping (address => bool) public isOwner;
address[] public owners;
uint public quorum;
uint public actionCount;
struct Action {
address addressField;
uint value;
ActionChoices actionType;
bool executed;
bool deleted;
}
modifier ownerDeclared(address owner) {
require (isOwner[owner]);
_;
}
modifier actionSubmitted(uint actionId) {
require (   actions[actionId].addressField != 0
|| actions[actionId].value != 0);
_;
}
modifier confirmed(uint actionId, address owner) {
require (confirmations[actionId][owner]);
_;
}
modifier notConfirmed(uint actionId, address owner) {
require (!confirmations[actionId][owner]);
_;
}
modifier notExecuted(uint actionId) {
require (!actions[actionId].executed);
_;
}
modifier notDeleted(uint actionId) {
require (!actions[actionId].deleted);
_;
}
modifier validQuorum(uint ownerCount, uint _quorum) {
require (_quorum <= ownerCount && _quorum > 0);
_;
}
modifier validAction(address  addressField, uint value, ActionChoices actionType) {
require ((actionType == ActionChoices.AddOwner && addressField != 0 && value == 0)
|| (actionType == ActionChoices.ChangeQuorum && addressField == 0 && value > 0)
|| (actionType == ActionChoices.DeleteAction && addressField == 0 && value > 0)
|| (actionType == ActionChoices.TransferToken && addressField != 0 && value > 0)
|| (actionType == ActionChoices.WithdrawOwner && addressField != 0 && value == 0));
_;
}
function MultiSigTokenWallet(address[] _owners, uint _quorum)
public
validQuorum(_owners.length, _quorum)
{
for (uint i=0; i<_owners.length; i++) {
require (!isOwner[_owners[i]] && _owners[i] != 0);
isOwner[_owners[i]] = true;
}
owners = _owners;
quorum = _quorum;
}
function addOwner(address owner)
private
{
require(!isOwner[owner]);
isOwner[owner] = true;
owners.push(owner);
OwnerAddition(owner);
}
function withdrawOwner(address owner)
private
{
require (isOwner[owner]);
require (owners.length - 1 >= quorum);
isOwner[owner] = false;
for (uint i=0; i<owners.length - 1; i++)
if (owners[i] == owner) {
owners[i] = owners[owners.length - 1];
break;
}
owners.length -= 1;
OwnerWithdraw(owner);
}
function changeQuorum(uint _quorum)
private
{
require (_quorum > 0 && _quorum <= owners.length);
quorum = _quorum;
QuorumChange(_quorum);
}
function deleteAction(uint _actionId)
private
notExecuted(_actionId)
{
actions[_actionId].deleted = true;
}
function transferToken(address _destination, uint _value)
private
returns (bool)
{
ERC20Basic ERC20Contract = ERC20Basic(TOKEN);
return ERC20Contract.transfer(_destination, _value);
}
function submitAction(address addressField, uint value, ActionChoices actionType)
public
ownerDeclared(msg.sender)
validAction(addressField, value, actionType)
returns (uint actionId)
{
actionId = addAction(addressField, value, actionType);
confirmAction(actionId);
}
function confirmAction(uint actionId)
public
ownerDeclared(msg.sender)
actionSubmitted(actionId)
notConfirmed(actionId, msg.sender)
{
confirmations[actionId][msg.sender] = true;
Confirmation(msg.sender, actionId);
}
function revokeConfirmation(uint actionId)
public
ownerDeclared(msg.sender)
confirmed(actionId, msg.sender)
notExecuted(actionId)
{
confirmations[actionId][msg.sender] = false;
Revocation(msg.sender, actionId);
}
function executeAction(uint actionId)
public
ownerDeclared(msg.sender)
actionSubmitted(actionId)
notExecuted(actionId)
notDeleted(actionId)
{
if (isConfirmed(actionId)) {
Action memory action = actions[actionId];
action.executed = true;
if (action.actionType == ActionChoices.AddOwner)
addOwner(action.addressField);
else if (action.actionType == ActionChoices.ChangeQuorum)
changeQuorum(action.value);
else if (action.actionType == ActionChoices.DeleteAction)
deleteAction(action.value);
else if (action.actionType == ActionChoices.TransferToken)
if (transferToken(action.addressField, action.value))
Execution(actionId);
else {
ExecutionFailure(actionId);
action.executed = false;
}
else if (action.actionType == ActionChoices.WithdrawOwner)
withdrawOwner(action.addressField);
else
revert();
}
}
function isConfirmed(uint actionId)
public
constant
returns (bool)
{
uint count = 0;
for (uint i=0; i<owners.length; i++) {
if (confirmations[actionId][owners[i]])
count += 1;
if (count == quorum)
return true;
}
return false;
}
function addAction(address addressField, uint value, ActionChoices actionType)
private
returns (uint)
{
actionCount += 1;
uint actionId = actionCount;
actions[actionId] = Action({
addressField: addressField,
value: value,
actionType: actionType,
executed: false,
deleted: false
});
NewAction(actionId);
return actionId;
}
function getConfirmationCount(uint actionId)
public
constant
returns (uint count)
{
for (uint i=0; i<owners.length; i++)
if (confirmations[actionId][owners[i]])
count += 1;
}
function getActionCount(bool pending, bool executed, bool exceptDeleted)
public
constant
returns (uint count)
{
for (uint i=0; i<actionCount; i++)
if (   ((pending && !actions[i].executed)
|| (executed && actions[i].executed))
&& (!exceptDeleted || !actions[i].deleted))
count += 1;
}
function getOwners()
public
constant
returns (address[])
{
return owners;
}
function getConfirmations(uint actionId)
public
constant
returns (address[] _confirmations)
{
address[] memory confirmationsTemp = new address[](owners.length);
uint count = 0;
uint i;
for (i=0; i<owners.length; i++)
if (confirmations[actionId][owners[i]]) {
confirmationsTemp[count] = owners[i];
count += 1;
}
_confirmations = new address[](count);
for (i=0; i<count; i++)
_confirmations[i] = confirmationsTemp[i];
}
function getActionIds(bool pending, bool executed, bool exceptDeleted)
public
constant
returns (uint[] memory)
{
uint[] memory actionIds;
uint count = 0;
uint i;
for (i=0; i<actionCount; i++)
if (((pending && !actions[i].executed)
|| (executed && actions[i].executed))
&& (!exceptDeleted || !actions[i].deleted))
{
actionIds[count] = i;
count += 1;
}
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}