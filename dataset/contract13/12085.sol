pragma solidity ^0.4.23;
contract DSAuthority {
function canCall(
address src, address dst, bytes4 sig
) public view returns (bool);
}
contract DSAuthEvents {
event LogSetAuthority (address indexed authority);
event LogSetOwner     (address indexed owner);
}
contract DSAuth is DSAuthEvents {
DSAuthority  public  authority;
address      public  owner;
constructor() public {
owner = msg.sender;
emit LogSetOwner(msg.sender);
}
function setOwner(address owner_)
public
auth
{
owner = owner_;
emit LogSetOwner(owner);
}
function setAuthority(DSAuthority authority_)
public
auth
{
authority = authority_;
emit LogSetAuthority(authority);
}
modifier auth {
require(isAuthorized(msg.sender, msg.sig));
_;
}
function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
if (src == address(this)) {
return true;
} else if (src == owner) {
return true;
} else if (authority == DSAuthority(0)) {
return false;
} else {
return authority.canCall(src, this, sig);
}
}
}
contract TokenAuthority is DSAuthority {
address public token;
mapping(address => mapping(bytes4 => bool)) authorizations;
constructor(address _token, address _vesting) public {
token = _token;
bytes4 transferSig = bytes4(keccak256("transfer(address,uint256)"));
bytes4 transferFromSig = bytes4(keccak256("transferFrom(address,address,uint256)"));
authorizations[_vesting][transferSig] = true;
authorizations[_vesting][transferFromSig] = true;
}
function canCall(address src, address dst, bytes4 sig) public view returns (bool) {
if (dst != token) {
return false;
}
return authorizations[src][sig];
}
}