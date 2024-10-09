library GroveLib {
struct Index {
bytes32 root;
mapping (bytes32 => Node) nodes;
}
struct Node {
bytes32 id;
int value;
bytes32 parent;
bytes32 left;
bytes32 right;
uint height;
}
function max(uint a, uint b) internal returns (uint) {
if (a >= b) {
return a;
}
return b;
}
function getNodeId(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].id;
}
function getNodeValue(Index storage index, bytes32 id) constant returns (int) {
return index.nodes[id].value;
}
function getNodeHeight(Index storage index, bytes32 id) constant returns (uint) {
return index.nodes[id].height;
}
function getNodeParent(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].parent;
}
function getNodeLeftChild(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].left;
}
function getNodeRightChild(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].right;
}
function getPreviousNode(Index storage index, bytes32 id) constant returns (bytes32) {
Node storage currentNode = index.nodes[id];
if (currentNode.id == 0x0) {
return 0x0;
}
Node memory child;
if (currentNode.left != 0x0) {
child = index.nodes[currentNode.left];
while (child.right != 0) {
child = index.nodes[child.right];
}
return child.id;
}
if (currentNode.parent != 0x0) {
Node storage parent = index.nodes[currentNode.parent];
child = currentNode;
while (true) {
if (parent.right == child.id) {
return parent.id;
}
if (parent.parent == 0x0) {
break;
}
child = parent;
parent = index.nodes[parent.parent];
}
}
return 0x0;
}
function getNextNode(Index storage index, bytes32 id) constant returns (bytes32) {
Node storage currentNode = index.nodes[id];
if (currentNode.id == 0x0) {
return 0x0;
}
Node memory child;
if (currentNode.right != 0x0) {
child = index.nodes[currentNode.right];
while (child.left != 0) {
child = index.nodes[child.left];
}
return child.id;
}
if (currentNode.parent != 0x0) {
Node storage parent = index.nodes[currentNode.parent];
child = currentNode;
while (true) {
if (parent.left == child.id) {
return parent.id;
}
if (parent.parent == 0x0) {
break;
}
child = parent;
parent = index.nodes[parent.parent];
}
}
return 0x0;
}
function insert(Index storage index, bytes32 id, int value) public {
if (index.nodes[id].id == id) {
if (index.nodes[id].value == value) {
return;
}
remove(index, id);
}
uint leftHeight;
uint rightHeight;
bytes32 previousNodeId = 0x0;
if (index.root == 0x0) {
index.root = id;
}
Node storage currentNode = index.nodes[index.root];
while (true) {
if (currentNode.id == 0x0) {
currentNode.id = id;
currentNode.parent = previousNodeId;
currentNode.value = value;
break;
}
previousNodeId = currentNode.id;
if (value >= currentNode.value) {
if (currentNode.right == 0x0) {
currentNode.right = id;
}
currentNode = index.nodes[currentNode.right];
continue;
}
if (currentNode.left == 0x0) {
currentNode.left = id;
}
currentNode = index.nodes[currentNode.left];
}
_rebalanceTree(index, currentNode.id);
}
function exists(Index storage index, bytes32 id) constant returns (bool) {
return (index.nodes[id].height > 0);
}
function remove(Index storage index, bytes32 id) public {
Node storage replacementNode;
Node storage parent;
Node storage child;
bytes32 rebalanceOrigin;
Node storage nodeToDelete = index.nodes[id];
if (nodeToDelete.id != id) {
return;
}
if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
if (nodeToDelete.left != 0x0) {
replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.id)];
}
else {
replacementNode = index.nodes[getNextNode(index, nodeToDelete.id)];
}
parent = index.nodes[replacementNode.parent];
rebalanceOrigin = replacementNode.id;
if (parent.left == replacementNode.id) {
parent.left = replacementNode.right;
if (replacementNode.right != 0x0) {
child = index.nodes[replacementNode.right];
child.parent = parent.id;
}
}
if (parent.right == replacementNode.id) {
parent.right = replacementNode.left;
if (replacementNode.left != 0x0) {
child = index.nodes[replacementNode.left];
child.parent = parent.id;
}
}
replacementNode.parent = nodeToDelete.parent;
if (nodeToDelete.parent != 0x0) {
parent = index.nodes[nodeToDelete.parent];
if (parent.left == nodeToDelete.id) {
parent.left = replacementNode.id;
}
if (parent.right == nodeToDelete.id) {
parent.right = replacementNode.id;
}
}
else {
index.root = replacementNode.id;
}
replacementNode.left = nodeToDelete.left;
if (nodeToDelete.left != 0x0) {
child = index.nodes[nodeToDelete.left];
child.parent = replacementNode.id;
}
replacementNode.right = nodeToDelete.right;
if (nodeToDelete.right != 0x0) {
child = index.nodes[nodeToDelete.right];
child.parent = replacementNode.id;
}
}
else if (nodeToDelete.parent != 0x0) {
parent = index.nodes[nodeToDelete.parent];
if (parent.left == nodeToDelete.id) {
parent.left = 0x0;
}
if (parent.right == nodeToDelete.id) {
parent.right = 0x0;
}
rebalanceOrigin = parent.id;
}
else {
index.root = 0x0;
}
nodeToDelete.id = 0x0;
nodeToDelete.value = 0;
nodeToDelete.parent = 0x0;
nodeToDelete.left = 0x0;
nodeToDelete.right = 0x0;
nodeToDelete.height = 0;
if (rebalanceOrigin != 0x0) {
_rebalanceTree(index, rebalanceOrigin);
}
}
bytes2 constant GT = ">";
bytes2 constant LT = "<";
bytes2 constant GTE = ">=";
bytes2 constant LTE = "<=";
bytes2 constant EQ = "==";
function _compare(int left, bytes2 operator, int right) internal returns (bool) {
if (operator == GT) {
return (left > right);
}
if (operator == LT) {
return (left < right);
}
if (operator == GTE) {
return (left >= right);
}
if (operator == LTE) {
return (left <= right);
}
if (operator == EQ) {
return (left == right);
}
throw;
}
function _getMaximum(Index storage index, bytes32 id) internal returns (int) {
Node storage currentNode = index.nodes[id];
while (true) {
if (currentNode.right == 0x0) {
return currentNode.value;
}
currentNode = index.nodes[currentNode.right];
}
}
function _getMinimum(Index storage index, bytes32 id) internal returns (int) {
Node storage currentNode = index.nodes[id];
while (true) {
if (currentNode.left == 0x0) {
return currentNode.value;
}
currentNode = index.nodes[currentNode.left];
}
}
function query(Index storage index, bytes2 operator, int value) public returns (bytes32) {
bytes32 rootNodeId = index.root;
if (rootNodeId == 0x0) {
return 0x0;
}
Node storage currentNode = index.nodes[rootNodeId];
while (true) {
if (_compare(currentNode.value, operator, value)) {
if ((operator == LT) || (operator == LTE)) {
if (currentNode.right == 0x0) {
return currentNode.id;
}
if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
currentNode = index.nodes[currentNode.right];
continue;
}
return currentNode.id;
}
if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
if (currentNode.left == 0x0) {
return currentNode.id;
}
if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
currentNode = index.nodes[currentNode.left];
continue;
}
return currentNode.id;
}
}
if ((operator == LT) || (operator == LTE)) {
if (currentNode.left == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.left];
continue;
}
if ((operator == GT) || (operator == GTE)) {
if (currentNode.right == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.right];
continue;
}
if (operator == EQ) {
if (currentNode.value < value) {
if (currentNode.right == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.right];
continue;
}
if (currentNode.value > value) {
if (currentNode.left == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.left];
continue;
}
}
}
}
function _rebalanceTree(Index storage index, bytes32 id) internal {
Node storage currentNode = index.nodes[id];
while (true) {
int balanceFactor = _getBalanceFactor(index, currentNode.id);
if (balanceFactor == 2) {
if (_getBalanceFactor(index, currentNode.left) == -1) {
_rotateLeft(index, currentNode.left);
}
_rotateRight(index, currentNode.id);
}
if (balanceFactor == -2) {
if (_getBalanceFactor(index, currentNode.right) == 1) {
_rotateRight(index, currentNode.right);
}
_rotateLeft(index, currentNode.id);
}
if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
_updateNodeHeight(index, currentNode.id);
}
if (currentNode.parent == 0x0) {
break;
}
currentNode = index.nodes[currentNode.parent];
}
}
function _getBalanceFactor(Index storage index, bytes32 id) internal returns (int) {
Node storage node = index.nodes[id];
return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
}
function _updateNodeHeight(Index storage index, bytes32 id) internal {
Node storage node = index.nodes[id];
node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
}
function _rotateLeft(Index storage index, bytes32 id) internal {
Node storage originalRoot = index.nodes[id];
if (originalRoot.right == 0x0) {
throw;
}
Node storage newRoot = index.nodes[originalRoot.right];
newRoot.parent = originalRoot.parent;
originalRoot.right = 0x0;
if (originalRoot.parent != 0x0) {
Node storage parent = index.nodes[originalRoot.parent];
if (parent.left == originalRoot.id) {
parent.left = newRoot.id;
}
if (parent.right == originalRoot.id) {
parent.right = newRoot.id;
}
}
if (newRoot.left != 0) {
Node storage leftChild = index.nodes[newRoot.left];
originalRoot.right = leftChild.id;
leftChild.parent = originalRoot.id;
}
originalRoot.parent = newRoot.id;
newRoot.left = originalRoot.id;
if (newRoot.parent == 0x0) {
index.root = newRoot.id;
}
_updateNodeHeight(index, originalRoot.id);
_updateNodeHeight(index, newRoot.id);
}
function _rotateRight(Index storage index, bytes32 id) internal {
Node storage originalRoot = index.nodes[id];
if (originalRoot.left == 0x0) {
throw;
}
Node storage newRoot = index.nodes[originalRoot.left];
newRoot.parent = originalRoot.parent;
originalRoot.left = 0x0;
if (originalRoot.parent != 0x0) {
Node storage parent = index.nodes[originalRoot.parent];
if (parent.left == originalRoot.id) {
parent.left = newRoot.id;
}
if (parent.right == originalRoot.id) {
parent.right = newRoot.id;
}
}
if (newRoot.right != 0x0) {
Node storage rightChild = index.nodes[newRoot.right];
originalRoot.left = newRoot.right;
rightChild.parent = originalRoot.id;
}
originalRoot.parent = newRoot.id;
newRoot.right = originalRoot.id;
if (newRoot.parent == 0x0) {
index.root = newRoot.id;
}
_updateNodeHeight(index, originalRoot.id);
_updateNodeHeight(index, newRoot.id);
}
}