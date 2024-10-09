pragma solidity ^0.4.19;
contract DigixConstants {
uint256 constant SECONDS_IN_A_DAY = 24 * 60 * 60;
uint256 constant ASSET_EVENT_CREATED_VENDOR_ORDER = 1;
uint256 constant ASSET_EVENT_CREATED_TRANSFER_ORDER = 2;
uint256 constant ASSET_EVENT_CREATED_REPLACEMENT_ORDER = 3;
uint256 constant ASSET_EVENT_FULFILLED_VENDOR_ORDER = 4;
uint256 constant ASSET_EVENT_FULFILLED_TRANSFER_ORDER = 5;
uint256 constant ASSET_EVENT_FULFILLED_REPLACEMENT_ORDER = 6;
uint256 constant ASSET_EVENT_MINTED = 7;
uint256 constant ASSET_EVENT_MINTED_REPLACEMENT = 8;
uint256 constant ASSET_EVENT_RECASTED = 9;
uint256 constant ASSET_EVENT_REDEEMED = 10;
uint256 constant ASSET_EVENT_FAILED_AUDIT = 11;
uint256 constant ASSET_EVENT_ADMIN_FAILED = 12;
uint256 constant ASSET_EVENT_REMINTED = 13;
uint256 constant ROLE_ZERO_ANYONE = 0;
uint256 constant ROLE_ROOT = 1;
uint256 constant ROLE_VENDOR = 2;
uint256 constant ROLE_XFERAUTH = 3;
uint256 constant ROLE_POPADMIN = 4;
uint256 constant ROLE_CUSTODIAN = 5;
uint256 constant ROLE_AUDITOR = 6;
uint256 constant ROLE_MARKETPLACE_ADMIN = 7;
uint256 constant ROLE_KYC_ADMIN = 8;
uint256 constant ROLE_FEES_ADMIN = 9;
uint256 constant ROLE_DOCS_UPLOADER = 10;
uint256 constant ROLE_KYC_RECASTER = 11;
uint256 constant ROLE_FEES_DISTRIBUTION_ADMIN = 12;
uint256 constant STATE_ZERO_UNDEFINED = 0;
uint256 constant STATE_CREATED = 1;
uint256 constant STATE_VENDOR_ORDER = 2;
uint256 constant STATE_TRANSFER = 3;
uint256 constant STATE_CUSTODIAN_DELIVERY = 4;
uint256 constant STATE_MINTED = 5;
uint256 constant STATE_AUDIT_FAILURE = 6;
uint256 constant STATE_REPLACEMENT_ORDER = 7;
uint256 constant STATE_REPLACEMENT_DELIVERY = 8;
uint256 constant STATE_RECASTED = 9;
uint256 constant STATE_REDEEMED = 10;
uint256 constant STATE_ADMIN_FAILURE = 11;
bytes32 constant CONTRACT_INTERACTIVE_ASSETS_EXPLORER = "i:asset:explorer";
bytes32 constant CONTRACT_INTERACTIVE_DIGIX_DIRECTORY = "i:directory";
bytes32 constant CONTRACT_INTERACTIVE_MARKETPLACE = "i:mp";
bytes32 constant CONTRACT_INTERACTIVE_MARKETPLACE_ADMIN = "i:mpadmin";
bytes32 constant CONTRACT_INTERACTIVE_POPADMIN = "i:popadmin";
bytes32 constant CONTRACT_INTERACTIVE_PRODUCTS_LIST = "i:products";
bytes32 constant CONTRACT_INTERACTIVE_TOKEN = "i:token";
bytes32 constant CONTRACT_INTERACTIVE_BULK_WRAPPER = "i:bulk-wrapper";
bytes32 constant CONTRACT_INTERACTIVE_TOKEN_CONFIG = "i:token:config";
bytes32 constant CONTRACT_INTERACTIVE_TOKEN_INFORMATION = "i:token:information";
bytes32 constant CONTRACT_INTERACTIVE_MARKETPLACE_INFORMATION = "i:mp:information";
bytes32 constant CONTRACT_INTERACTIVE_IDENTITY = "i:identity";
bytes32 constant CONTRACT_CONTROLLER_ASSETS = "c:asset";
bytes32 constant CONTRACT_CONTROLLER_ASSETS_RECAST = "c:asset:recast";
bytes32 constant CONTRACT_CONTROLLER_ASSETS_EXPLORER = "c:explorer";
bytes32 constant CONTRACT_CONTROLLER_DIGIX_DIRECTORY = "c:directory";
bytes32 constant CONTRACT_CONTROLLER_MARKETPLACE = "c:mp";
bytes32 constant CONTRACT_CONTROLLER_MARKETPLACE_ADMIN = "c:mpadmin";
bytes32 constant CONTRACT_CONTROLLER_PRODUCTS_LIST = "c:products";
bytes32 constant CONTRACT_CONTROLLER_TOKEN_APPROVAL = "c:token:approval";
bytes32 constant CONTRACT_CONTROLLER_TOKEN_CONFIG = "c:token:config";
bytes32 constant CONTRACT_CONTROLLER_TOKEN_INFO = "c:token:info";
bytes32 constant CONTRACT_CONTROLLER_TOKEN_TRANSFER = "c:token:transfer";
bytes32 constant CONTRACT_CONTROLLER_JOB_ID = "c:jobid";
bytes32 constant CONTRACT_CONTROLLER_IDENTITY = "c:identity";
bytes32 constant CONTRACT_STORAGE_ASSETS = "s:asset";
bytes32 constant CONTRACT_STORAGE_ASSET_EVENTS = "s:asset:events";
bytes32 constant CONTRACT_STORAGE_DIGIX_DIRECTORY = "s:directory";
bytes32 constant CONTRACT_STORAGE_MARKETPLACE = "s:mp";
bytes32 constant CONTRACT_STORAGE_PRODUCTS_LIST = "s:products";
bytes32 constant CONTRACT_STORAGE_GOLD_TOKEN = "s:goldtoken";
bytes32 constant CONTRACT_STORAGE_JOB_ID = "s:jobid";
bytes32 constant CONTRACT_STORAGE_IDENTITY = "s:identity";
bytes32 constant CONTRACT_SERVICE_TOKEN_DEMURRAGE = "sv:tdemurrage";
bytes32 constant CONTRACT_SERVICE_MARKETPLACE = "sv:mp";
bytes32 constant CONTRACT_SERVICE_DIRECTORY = "sv:directory";
bytes32 constant CONTRACT_DEMURRAGE_FEES_DISTRIBUTOR = "fees:distributor:demurrage";
bytes32 constant CONTRACT_RECAST_FEES_DISTRIBUTOR = "fees:distributor:recast";
bytes32 constant CONTRACT_TRANSFER_FEES_DISTRIBUTOR = "fees:distributor:transfer";
}
contract ContractResolver {
address public owner;
bool public locked;
function init_register_contract(bytes32 _key, address _contract_address) public returns (bool _success);
function unregister_contract(bytes32 _key) public returns (bool _success);
function get_contract(bytes32 _key) public constant returns (address _contract);
}
contract ResolverClient {
address public resolver;
bytes32 public key;
address public CONTRACT_ADDRESS;
modifier if_sender_is(bytes32 _contract) {
require(msg.sender == ContractResolver(resolver).get_contract(_contract));
_;
}
modifier unless_resolver_is_locked() {
require(is_locked() == false);
_;
}
function init(bytes32 _key, address _resolver)
internal
returns (bool _success)
{
bool _is_locked = ContractResolver(_resolver).locked();
if (_is_locked == false) {
CONTRACT_ADDRESS = address(this);
resolver = _resolver;
key = _key;
require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));
_success = true;
}  else {
_success = false;
}
}
function destroy()
public
returns (bool _success)
{
bool _is_locked = ContractResolver(resolver).locked();
require(!_is_locked);
address _owner_of_contract_resolver = ContractResolver(resolver).owner();
require(msg.sender == _owner_of_contract_resolver);
_success = ContractResolver(resolver).unregister_contract(key);
require(_success);
selfdestruct(_owner_of_contract_resolver);
}
function is_locked()
private
constant
returns (bool _locked)
{
_locked = ContractResolver(resolver).locked();
}
function get_contract(bytes32 _key)
public
constant
returns (address _contract)
{
_contract = ContractResolver(resolver).get_contract(_key);
}
}
contract IndexedBytesIteratorInteractive {
function list_indexed_bytesarray(bytes32 _collection_index, uint256 _count,
function (bytes32) external constant returns (bytes32) _function_first,
function (bytes32) external constant returns (bytes32) _function_last,
function (bytes32, bytes32) external constant returns (bytes32) _function_next,
function (bytes32, bytes32) external constant returns (bytes32) _function_previous,
bool _from_start)
internal
constant
returns (bytes32[] _indexed_bytes_items)
{
if (_from_start) {
_indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _function_first(_collection_index), _count, true, _function_last, _function_next);
} else {
_indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _function_last(_collection_index), _count, true, _function_first, _function_previous);
}
}
function list_indexed_bytesarray_from(bytes32 _collection_index, bytes32 _current_item, uint256 _count,
function (bytes32) external constant returns (bytes32) _function_first,
function (bytes32) external constant returns (bytes32) _function_last,
function (bytes32, bytes32) external constant returns (bytes32) _function_next,
function (bytes32, bytes32) external constant returns (bytes32) _function_previous,
bool _from_start)
internal
constant
returns (bytes32[] _indexed_bytes_items)
{
if (_from_start) {
_indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _current_item, _count, false, _function_last, _function_next);
} else {
_indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _current_item, _count, false, _function_first, _function_previous);
}
}
function private_list_indexed_bytes_from_bytes(bytes32 _collection_index, bytes32 _current_item, uint256 _count, bool _including_current,
function (bytes32) external constant returns (bytes32) _function_last,
function (bytes32, bytes32) external constant returns (bytes32) _function_next)
private
constant
returns (bytes32[] _indexed_bytes_items)
{
uint256 _i;
uint256 _real_count = 0;
bytes32 _last_item;
_last_item = _function_last(_collection_index);
if (_count == 0 || _last_item == bytes32(0x0)) {
_indexed_bytes_items = new bytes32[](0);
} else {
bytes32[] memory _items_temp = new bytes32[](_count);
bytes32 _this_item;
if (_including_current) {
_items_temp[0] = _current_item;
_real_count = 1;
}
_this_item = _current_item;
for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {
_this_item = _function_next(_collection_index, _this_item);
if (_this_item != bytes32(0x0)) {
_real_count++;
_items_temp[_i] = _this_item;
}
}
_indexed_bytes_items = new bytes32[](_real_count);
for(_i = 0;_i < _real_count;_i++) {
_indexed_bytes_items[_i] = _items_temp[_i];
}
}
}
}
contract BytesIteratorInteractive {
function list_bytesarray(uint256 _count,
function () external constant returns (bytes32) _function_first,
function () external constant returns (bytes32) _function_last,
function (bytes32) external constant returns (bytes32) _function_next,
function (bytes32) external constant returns (bytes32) _function_previous,
bool _from_start)
internal
constant
returns (bytes32[] _bytes_items)
{
if (_from_start) {
_bytes_items = private_list_bytes_from_bytes(_function_first(), _count, true, _function_last, _function_next);
} else {
_bytes_items = private_list_bytes_from_bytes(_function_last(), _count, true, _function_first, _function_previous);
}
}
function list_bytesarray_from(bytes32 _current_item, uint256 _count,
function () external constant returns (bytes32) _function_first,
function () external constant returns (bytes32) _function_last,
function (bytes32) external constant returns (bytes32) _function_next,
function (bytes32) external constant returns (bytes32) _function_previous,
bool _from_start)
internal
constant
returns (bytes32[] _bytes_items)
{
if (_from_start) {
_bytes_items = private_list_bytes_from_bytes(_current_item, _count, false, _function_last, _function_next);
} else {
_bytes_items = private_list_bytes_from_bytes(_current_item, _count, false, _function_first, _function_previous);
}
}
function private_list_bytes_from_bytes(bytes32 _current_item, uint256 _count, bool _including_current,
function () external constant returns (bytes32) _function_last,
function (bytes32) external constant returns (bytes32) _function_next)
private
constant
returns (bytes32[] _bytes32_items)
{
uint256 _i;
uint256 _real_count = 0;
bytes32 _last_item;
_last_item = _function_last();
if (_count == 0 || _last_item == bytes32(0x0)) {
_bytes32_items = new bytes32[](0);
} else {
bytes32[] memory _items_temp = new bytes32[](_count);
bytes32 _this_item;
if (_including_current == true) {
_items_temp[0] = _current_item;
_real_count = 1;
}
_this_item = _current_item;
for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {
_this_item = _function_next(_this_item);
if (_this_item != bytes32(0x0)) {
_real_count++;
_items_temp[_i] = _this_item;
}
}
_bytes32_items = new bytes32[](_real_count);
for(_i = 0;_i < _real_count;_i++) {
_bytes32_items[_i] = _items_temp[_i];
}
}
}
}
contract AssetsStorage {
}
contract GoldTokenStorage {
function read_supply() constant public returns (uint256 _total_supply, uint256 _effective_total_supply);
}
contract MarketplaceStorage {
}
contract AssetsController {
}
contract AssetsExplorerController {
function get_first_item_in_state(bytes32 _state_id) public constant returns (bytes32 _item);
function get_last_item_in_state(bytes32 _state_id) public constant returns (bytes32 _item);
function get_next_item_in_state_from_item(bytes32 _state_id, bytes32 _current_item) public constant returns (bytes32 _item);
function get_previous_item_in_state_from_item(bytes32 _state_id, bytes32 _current_item) public constant returns (bytes32 _item);
function get_first_global_audit_document() public constant returns (bytes32 _document);
function get_last_global_audit_document() public constant returns (bytes32 _document);
function get_next_global_audit_document(bytes32 _current_document) public constant returns (bytes32 _document);
function get_previous_global_audit_document(bytes32 _current_document) public constant returns (bytes32 _document);
function get_first_asset_document(bytes32 _item) public constant returns (bytes32 _document);
function get_last_asset_document(bytes32 _item) public constant returns (bytes32 _document);
function get_next_asset_document_from_document(bytes32 _item, bytes32 _current_document) public constant returns (bytes32 _document);
function get_previous_asset_document_from_document(bytes32 _item, bytes32 _current_document) public constant returns (bytes32 _document);
function get_first_user_recast(bytes32 _user_key) public constant returns (bytes32 _item);
function get_last_user_recast(bytes32 _user_key) public constant returns (bytes32 _item);
function get_next_user_recast_from_item(bytes32 _user_key, bytes32 _current_item) public constant returns (bytes32 _item);
function get_previous_user_recast_from_item(bytes32 _user_key, bytes32 _current_item) public constant returns (bytes32 _item);
function get_asset_info(bytes32 _item) public constant returns (uint256 _product_id, uint256 _ng_weight, uint256 _effective_ng_weight, bytes32 _serial, uint256 _state_id, uint256 _documents_count, uint256 _time_minted, uint256 _redeem_deadline);
function get_asset_details(bytes32 _item) public constant returns (address _mint_target, address _redeem_for, bytes32 _replaced_by, bytes32 _replaces);
function get_total_items_in_state(bytes32 _state_id) public constant returns (uint256 _total_items);
function get_asset_events_count(bytes32 _item) public constant returns (uint256 _count);
function get_asset_event_details(bytes32 _item, uint256 _event_index) public constant returns (uint256 _event_type, uint256 _timestamp);
function get_last_global_audit_time() public constant returns (uint256 _last_global_audit_time);
}
contract AssetsExplorer is ResolverClient, IndexedBytesIteratorInteractive, BytesIteratorInteractive, DigixConstants {
function AssetsExplorer(address _resolver) public
{
require(init(CONTRACT_INTERACTIVE_ASSETS_EXPLORER, _resolver));
}
function assets_controller()
internal
constant
returns (AssetsController _contract)
{
_contract = AssetsController(get_contract(CONTRACT_CONTROLLER_ASSETS));
}
function gold_token_storage()
internal
constant
returns (GoldTokenStorage _contract)
{
_contract = GoldTokenStorage(get_contract(CONTRACT_STORAGE_GOLD_TOKEN));
}
function marketplace_storage()
internal
constant
returns (MarketplaceStorage _contract)
{
_contract = MarketplaceStorage(get_contract(CONTRACT_STORAGE_MARKETPLACE));
}
function assets_explorer_controller()
internal
constant
returns (AssetsExplorerController _contract)
{
_contract = AssetsExplorerController(get_contract(CONTRACT_CONTROLLER_ASSETS_EXPLORER));
}
function listAssets(uint256 _state_id, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _assets)
{
bytes32 _collection = bytes32(_state_id);
_assets = list_indexed_bytesarray(_collection, _count,
assets_explorer_controller().get_first_item_in_state,
assets_explorer_controller().get_last_item_in_state,
assets_explorer_controller().get_next_item_in_state_from_item,
assets_explorer_controller().get_previous_item_in_state_from_item,
_from_start);
}
function listAssetsFrom(uint256 _state_id, bytes32 _current_item, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _assets)
{
bytes32 _collection = bytes32(_state_id);
_assets = list_indexed_bytesarray_from(_collection, _current_item, _count,
assets_explorer_controller().get_first_item_in_state,
assets_explorer_controller().get_last_item_in_state,
assets_explorer_controller().get_next_item_in_state_from_item,
assets_explorer_controller().get_previous_item_in_state_from_item,
_from_start);
}
function listGlobalAuditDocuments(uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _documents)
{
_documents =  list_bytesarray(_count,
assets_explorer_controller().get_first_global_audit_document,
assets_explorer_controller().get_last_global_audit_document,
assets_explorer_controller().get_next_global_audit_document,
assets_explorer_controller().get_previous_global_audit_document,
_from_start);
}
function listGlobalAuditDocumentsFrom(bytes32 _current_document, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _documents)
{
_documents = list_bytesarray_from(_current_document, _count,
assets_explorer_controller().get_first_global_audit_document,
assets_explorer_controller().get_last_global_audit_document,
assets_explorer_controller().get_next_global_audit_document,
assets_explorer_controller().get_previous_global_audit_document,
_from_start);
}
function listAssetDocuments(bytes32 _item, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _documents)
{
_documents = list_indexed_bytesarray(_item, _count,
assets_explorer_controller().get_first_asset_document,
assets_explorer_controller().get_last_asset_document,
assets_explorer_controller().get_next_asset_document_from_document,
assets_explorer_controller().get_previous_asset_document_from_document,
_from_start);
}
function listAssetDocumentsFrom(bytes32 _item, bytes32 _current_document, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _documents)
{
_documents = list_indexed_bytesarray_from(_item, _current_document, _count,
assets_explorer_controller().get_first_asset_document,
assets_explorer_controller().get_last_asset_document,
assets_explorer_controller().get_next_asset_document_from_document,
assets_explorer_controller().get_previous_asset_document_from_document,
_from_start);
}
function listUserRecasts(address _user, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _items)
{
bytes32 _user_key = bytes32(_user);
_items = list_indexed_bytesarray(_user_key, _count,
assets_explorer_controller().get_first_user_recast,
assets_explorer_controller().get_last_user_recast,
assets_explorer_controller().get_next_user_recast_from_item,
assets_explorer_controller().get_previous_user_recast_from_item,
_from_start);
}
function listUserRecastsFrom(address _user, bytes32 _current_item, uint256 _count, bool _from_start)
public
constant
returns (bytes32[] _items)
{
bytes32 _user_key = bytes32(_user);
_items = list_indexed_bytesarray_from(_user_key, _current_item, _count,
assets_explorer_controller().get_first_user_recast,
assets_explorer_controller().get_last_user_recast,
assets_explorer_controller().get_next_user_recast_from_item,
assets_explorer_controller().get_previous_user_recast_from_item,
_from_start);
}
function showAssetInfo(bytes32 _item)
public
constant
returns (uint256 _product_id, uint256 _ng_weight, uint256 _effective_ng_weight,
bytes32 _serial, uint256 _state_id, uint256 _documents_count, uint256 _time_minted, bytes32 _replaced_by)
{
(_product_id, _ng_weight, _effective_ng_weight,
_serial, _state_id, _documents_count, _time_minted,) = assets_explorer_controller().get_asset_info(_item);
(,,_replaced_by,) = assets_explorer_controller().get_asset_details(_item);
}
function showAssetDetails(bytes32 _item)
public
constant
returns (address _mint_target, address _redeem_for, bytes32 _replaced_by, bytes32 _replaces, uint256 _redeem_deadline)
{
(_mint_target, _redeem_for, _replaced_by, _replaces) = assets_explorer_controller().get_asset_details(_item);
(,,,,,,,_redeem_deadline) = assets_explorer_controller().get_asset_info(_item);
}
function countAssets(uint256 _state_id)
public
constant
returns (uint256 _count)
{
_count = assets_explorer_controller().get_total_items_in_state(bytes32(_state_id));
}
function showSupply()
public
constant
returns (uint256 _total_supply, uint256 _effective_total_supply)
{
(_total_supply, _effective_total_supply) = gold_token_storage().read_supply();
}
function countAssetEvents(bytes32 _item)
public
constant
returns (uint256 _count)
{
_count = assets_explorer_controller().get_asset_events_count(_item);
}
function showAssetEvent(bytes32 _item, uint256 _event_index)
public
constant
returns (uint256 _event_type, uint256 _timestamp)
{
(_event_type, _timestamp) = assets_explorer_controller().get_asset_event_details(_item, _event_index);
}
function showLastGlobalAuditTime()
public
constant
returns (uint256 _last_global_audit_time)
{
_last_global_audit_time = assets_explorer_controller().get_last_global_audit_time();
}
}