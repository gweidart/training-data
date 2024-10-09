contract LootboxInterface {
event LootboxPurchased(address indexed owner, address indexed storeAddress, uint16 displayValue);
function buy(address _buyer) external;
}
contract ExternalInterface {
function giveItem(address _recipient, uint256 _traits) external;
function giveMultipleItems(address _recipient, uint256[] _traits) external;
function giveMultipleItemsToMultipleRecipients(address[] _recipients, uint256[] _traits) external;
function giveMultipleItemsAndDestroyMultipleItems(address _recipient, uint256[] _traits, uint256[] _tokenIds) external;
function destroyItem(uint256 _tokenId) external;
function destroyMultipleItems(uint256[] _tokenIds) external;
function updateItemTraits(uint256 _tokenId, uint256 _traits) external;
}
contract StarterLootBox is LootboxInterface {
uint16 constant _displayValue = 2;
mapping(address => uint) previousPurchasers;
function buy(address _buyer) external {
require(previousPurchasers[_buyer] == 0);
previousPurchasers[_buyer] = 1;
emit LootboxPurchased(_buyer, msg.sender, _displayValue);
ExternalInterface store = ExternalInterface(msg.sender);
store.giveItem(_buyer, 1238317834368705331822870561);
store.giveItem(_buyer, 1238317834368705331822870577);
}
}