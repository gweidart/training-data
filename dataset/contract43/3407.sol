pragma solidity ^0.4.24;
contract Ownable {}
contract AddressesFilterFeature is Ownable {}
contract ERC20Basic {}
contract BasicToken is ERC20Basic {}
contract ERC20 {}
contract StandardToken is ERC20, BasicToken {}
contract MintableToken is AddressesFilterFeature, StandardToken {}
contract Token is MintableToken {
function mint(address, uint256) public returns (bool);
}
contract FirstBountyWPTpayout {
address public owner;
Token public company_token;
address[] public addressOfBountyMembers;
mapping(address => uint256) bountyMembersAmounts;
uint currentBatch;
uint addrPerStep;
modifier onlyOwner
{
require(owner == msg.sender);
_;
}
event Transfer(address indexed to, uint indexed value);
event OwnerChanged(address indexed owner);
constructor (Token _company_token) public {
owner = msg.sender;
company_token = _company_token;
currentBatch = 0;
addrPerStep = 10;
setBountyAddresses();
setBountyAmounts();
}
function()
public
payable
{
revert();
}
function setOwner(address _owner)
public
onlyOwner
{
require(_owner != 0);
owner = _owner;
emit OwnerChanged(owner);
}
function makePayout() public onlyOwner {
uint startIndex = currentBatch * addrPerStep;
uint endIndex = (currentBatch + 1 ) * addrPerStep;
for (uint i = startIndex; (i < endIndex && i < addressOfBountyMembers.length); i++)
{
company_token.mint(addressOfBountyMembers[i], bountyMembersAmounts[addressOfBountyMembers[i]]);
}
currentBatch++;
}
function setBountyAddresses() internal {
addressOfBountyMembers.push(0xA18897f5eBE15fea6A1F4e305f494aAb999237a1);
addressOfBountyMembers.push(0x0062ac6d0906FAC009752a6c802B88D20dcaB4e5);
addressOfBountyMembers.push(0x548EEc899D859105164F4f04d709bAA21509765d);
addressOfBountyMembers.push(0xE062B1ba461BC58782CeD8a653F147798165D0f6);
addressOfBountyMembers.push(0xC26bc33DC0769D7Fe812282eAE9e78a72d06FC03);
addressOfBountyMembers.push(0x8e4cbDeC134C9050DE3d9D8Cfd6821Bd477c778A);
addressOfBountyMembers.push(0xA5F66EaFB02Db5ccAcc4af8AdB536090C362f9B6);
addressOfBountyMembers.push(0xe53723C804eFDa69632aEB53EC6c41Ce7dBc8D2b);
addressOfBountyMembers.push(0x8dcdc06c2aCC184a2DEbF0Fc41deEae966e3ee43);
addressOfBountyMembers.push(0xe37947155614f6146E4455d887CcA823B658Bf08);
addressOfBountyMembers.push(0xa8D9B735a876d4F9fb28f5C25F8e3Cd52c2f791C);
addressOfBountyMembers.push(0x727c9080069dFF36A93f66d59B234c9865EB3450);
addressOfBountyMembers.push(0x17714CDe9FE2889e279A7e9939557c8e4aCcC249);
addressOfBountyMembers.push(0xD748a3fE50368D47163b3b1fDa780798970d99C1);
addressOfBountyMembers.push(0x02CFa0abc6c05de03B2E03b2Ce9d4B4554cE8366);
addressOfBountyMembers.push(0x0701cCBa1c7a6991c6b40Fde81f7cda65199273c);
addressOfBountyMembers.push(0xbf57fdea968d3ea1638fb2324b1ca83da6445f1c);
addressOfBountyMembers.push(0x775AFd2f9bABD405D087D7bc32eBFFA477de3B9F);
addressOfBountyMembers.push(0x4a53687df3fDf2a992f420a9604d775caaC5d0A8);
addressOfBountyMembers.push(0x0a221cD57bAC3E4283f29D80caC20916eFce018B);
addressOfBountyMembers.push(0x54A9A28Bb5886Fe42B713BF106BB106EB19DE8b8);
addressOfBountyMembers.push(0x82C591A9282b91378C1f00310dc71C43548aA505);
addressOfBountyMembers.push(0x6101f09c1f7dBD5571455D9F2341317C905bB078);
addressOfBountyMembers.push(0xF54fAb200604ddDf868f3e397034F8c6d85BfA15);
addressOfBountyMembers.push(0x60C0C55f1De5bc4bc1D1Df41bd30968e89C80Ad7);
addressOfBountyMembers.push(0x33c760AE3A9d2397c07269E6DFFdCe855fB8B92b);
addressOfBountyMembers.push(0x08d5850e4C5A7B51F8950B14112A684F63B362c0);
addressOfBountyMembers.push(0xF1d66A7fa0331784325a9B1F8f8d4a9b02a55308);
addressOfBountyMembers.push(0x3477aC8EA3BAdAe9b29E2486620B71E817f044b5);
addressOfBountyMembers.push(0x35Ef1AB02e620C52129F17A9fc94c77a4cc77d51);
addressOfBountyMembers.push(0x0F825233eec816512031c26da35d97d9138FBCFD);
addressOfBountyMembers.push(0xAce5A8b05C4984E9Ad4D4fD02e1B6e1C47588c0f);
addressOfBountyMembers.push(0x2CAF79C60fbB93eABbDc965222406bc2AAfa8B11);
addressOfBountyMembers.push(0xec9a6bF47fa6A5dD2bE77380C33Bd954BC25A236);
addressOfBountyMembers.push(0x25914D13bb4b63073625502Ac6F176FE1FE35211);
addressOfBountyMembers.push(0xDaA2eeEa18206c095eDeE910bfCF7a2a488d3eC2);
addressOfBountyMembers.push(0x16fa371DdB604bE1706cF61E3B3053D9d7C25Bfc);
addressOfBountyMembers.push(0x614E7141AD154Eae92A5264B990df944694b5D1b);
addressOfBountyMembers.push(0xb8e3B0948009e77Df382499f94a255Dc8dF22336);
addressOfBountyMembers.push(0xcf581c3f91665214fc63675e698a57a55c207e46);
addressOfBountyMembers.push(0x7fE33AFe1109a52D7f6311Cc0B8b8388d547eA5C);
addressOfBountyMembers.push(0x36D91414E36246063f353bA71B4f9403F104e32A);
addressOfBountyMembers.push(0x4a460EC5bA610B3982A39a401EB72A37bA5dc43A);
addressOfBountyMembers.push(0x0C45d153177F64733dC0c691C229427F56d2d154);
addressOfBountyMembers.push(0x86628f5c3D6321176199Cd5dF9506F126fe9fE5A);
addressOfBountyMembers.push(0x1b31b34Dd5C5A91C3E61B68e35ea2a008F24327A);
addressOfBountyMembers.push(0x3F61156cB2D12F88B4B32D799D3ba47D3f2a2f90);
addressOfBountyMembers.push(0xA7240876D7d7D2b65C92e4460728c626BE7ab91B);
addressOfBountyMembers.push(0x6F98763ff5F6Ca0aFF91acdDF8b85032FE62F704);
addressOfBountyMembers.push(0x8D57020414261E8A4C619F78951Bec41d65Ee02A);
addressOfBountyMembers.push(0x5B2434b286FFE76E58d18c39fB5B188DB580E169);
addressOfBountyMembers.push(0x17984B778E34538950B62ee12E49f4ded8C0765D);
addressOfBountyMembers.push(0x64A38FAb91944aA4A300c65461185B2DeD5a718D);
addressOfBountyMembers.push(0xC27520f3d9eef2658Bc94933A6B8350257E52255);
addressOfBountyMembers.push(0xD73C41B5eA96786EAafa590183FaB71249B7B147);
addressOfBountyMembers.push(0x0649c8c75aea1148b3e51b5f7189ff49ff4b3fd5);
addressOfBountyMembers.push(0x98EA6b4E05Af3181001E6eD3A87bcA27C8A7ddFe);
addressOfBountyMembers.push(0x3cAb02429D5c33864f45887e53Df506EaC05bEC1);
addressOfBountyMembers.push(0x68B4683475747E28a83596e94b58187d452099Cf);
addressOfBountyMembers.push(0x52E1Da12ee737a70f10f8DD0B996b49aB448F0E4);
addressOfBountyMembers.push(0xe6863861818c31bad6fc3e38d0a236f73bc1c6c0);
addressOfBountyMembers.push(0xe7DF67F33b74CEbB0fD3a05b15FABFca756D4abB);
addressOfBountyMembers.push(0xfdd831e295a94d63BDF7dd912833bfAe229dbe6d);
addressOfBountyMembers.push(0x8a4B11DFf9A535Bd3931db9d438c02C284F43Bb4);
addressOfBountyMembers.push(0x7Bf3EeEF640DEC6069F451426e9D8CDb4bEb2956);
addressOfBountyMembers.push(0x63B56909257c89953E888c9a4FA83816d3d24Dc2);
addressOfBountyMembers.push(0xaB60bCC2d56910d12654692b74E9f44Dc5A7faaF);
addressOfBountyMembers.push(0x7D0c737248Aa04754a58ca66630b39f1B81534b8);
addressOfBountyMembers.push(0xa9D5fC61D27569195f77E25ef9C816B3cc9b3c4B);
addressOfBountyMembers.push(0x7526AEd3F7Ee8DCe9Cd7083F80f2E6B931Cb3A41);
addressOfBountyMembers.push(0x592782a5adcB83f8D13646b316514314EE3e72f4);
addressOfBountyMembers.push(0x7cd156863e8e7473426f566626e0d94d29d023a9);
addressOfBountyMembers.push(0x63e73058e65Ba0FE3f925d2948988782d2617ab2);
addressOfBountyMembers.push(0x8D57020414261E8A4C619F78951Bec41d65Ee02A);
addressOfBountyMembers.push(0x656118F75fc3C0D17a25eDc12d58FC9a9d4a64fF);
addressOfBountyMembers.push(0x63D87F83E307493517e46e3BDA4704Bcf8838b87);
addressOfBountyMembers.push(0xA65306BF7b9FBB4483dc3610A2f4BD2743cdBBA1);
addressOfBountyMembers.push(0xD71d50bf40A8eF3A29504671c45b24507D7a2bE9);
addressOfBountyMembers.push(0xd7c63d3c978acc3518cb61f2f6f1a86ad3c4bc9b);
addressOfBountyMembers.push(0x5cB42C674c1971DB7701A845e9A0c6AAe156d597);
addressOfBountyMembers.push(0x6567CD78Fb8f75308A43ec6a936313b19Ff4cCEa);
addressOfBountyMembers.push(0x1dc522072850Bc59bb2945a950E8647be72D9dF3);
addressOfBountyMembers.push(0x764A8Db8ec617A8415992a4E87bd5543CDC20890);
addressOfBountyMembers.push(0x22dC6dB1e1FD097d35E3957806859442C02B79ff);
addressOfBountyMembers.push(0xC006B26d5A4f718063772c323184CaE52929d4ac);
addressOfBountyMembers.push(0xD110a0298FBdB68B9f3B937B3a04cc65b65559b2);
addressOfBountyMembers.push(0xdd8E3B1FC8acEeF62c2aaE07ab6B39118fD38bC4);
addressOfBountyMembers.push(0xDac17FDFdD48C8e17539abb9074fa40a103259b3);
addressOfBountyMembers.push(0x96ea5C1f31872d655c7f302E895Ff56C8e39a403);
addressOfBountyMembers.push(0xd5AF150E79Ab52859f28Ce2cE3D47D2fa3721cC8);
addressOfBountyMembers.push(0xeaBFadf9724a8A8dd81732925F409d659B837eff);
addressOfBountyMembers.push(0xCe6754a176B23ACcbaf4197Fd739e146811fe4c3);
addressOfBountyMembers.push(0xfc2Ee8b8C9301968eb5cc5Ba896E20DF35aB0152);
addressOfBountyMembers.push(0x25cC08B2E4a5Ce990d6f9b09E108C0E7753ED78f);
addressOfBountyMembers.push(0x5Ce01b55Ac1750A8BEA447c70d2c5c4B2745a078);
addressOfBountyMembers.push(0x5Cc2e30e3af89363c437342a3AbB5762C09d0A58);
addressOfBountyMembers.push(0x740a5c3677a7018f367c38d8655f00b458eed9ab);
addressOfBountyMembers.push(0x1B7376e2a05f187dF562Fc91eeb3B78998849C6d);
addressOfBountyMembers.push(0x539B9B4b5b8f6494f0aD62851d8765Cb350aCe62);
addressOfBountyMembers.push(0x470234E7E3e386f519BaCEBfe6ebfd239d0d6133);
addressOfBountyMembers.push(0x726356cF0ED11183a093d5c454deb6F9543831f7);
addressOfBountyMembers.push(0x43dbc504A778db4bE3e43911BB793EA459203284);
addressOfBountyMembers.push(0x1C1c278C75ab20EfD30cd418907A669B83e23A4B);
addressOfBountyMembers.push(0x522aB87522A15A7004DFaa4b358d4f2c8b9f2fAE);
addressOfBountyMembers.push(0x96fC8Ae2d1404e9978485491cdbB2760dC013128);
addressOfBountyMembers.push(0x655D8C74e55E8b2bf58B68ff714392F7A126a578);
addressOfBountyMembers.push(0x561032144b0535fef28C1764e504dB2EB523C082);
addressOfBountyMembers.push(0x41e27C9a3EDE803a1D3548935E233a3A5e7A500b);
addressOfBountyMembers.push(0x2C0073a2Da29b6511cBB37bda40449c515567D31);
addressOfBountyMembers.push(0xb33d01dD954888Ae2FdA24403e64b2e1daD84DFF);
addressOfBountyMembers.push(0x8778Ec54b00c6240A75794Fd658b7E6178396831);
addressOfBountyMembers.push(0x507d933F8763Ba40dfFa8F1602ffd0Ed6A88BFbF);
addressOfBountyMembers.push(0xec0a22287657C85a317a8919b679Ce8eDD8411F9);
addressOfBountyMembers.push(0x09FA7F2fbb1F08FC325d39317d5548bA868559F3);
addressOfBountyMembers.push(0xc80e94b74b577ECC134AD5eAB05477aBA09afC93);
addressOfBountyMembers.push(0x80D840E635C6B6C86207a6F898E6Ed94053bEd1E);
addressOfBountyMembers.push(0x7E2a9b9e8576F4377E2079d3CB361aF872a0B68e);
addressOfBountyMembers.push(0xF9650CDC299b94c244102d20b872FE3614Fea171);
addressOfBountyMembers.push(0x10c9D209898e8926157faa9aAE0398F6B81D483F);
addressOfBountyMembers.push(0x04194AD8E4b82cb65c43E4860Ccb8397A6e10c20);
addressOfBountyMembers.push(0x0b653d2e8347b61c0064972684B5700686D73902);
addressOfBountyMembers.push(0xE6618fEe9B5f3aEf3e6aEd4f050cA7343f081994);
addressOfBountyMembers.push(0x93711F2B2291574D170bCaD2fD2b688F642E255A);
addressOfBountyMembers.push(0x22abD036efE57F0d70Cc9d246a645f0e53109bE8);
addressOfBountyMembers.push(0xD0B1bc752d6bF1029c92264D1e0ab42f7f26C25D);
addressOfBountyMembers.push(0xf3232ADc8e87ead9F29E1fec347B293b65BC07BF);
addressOfBountyMembers.push(0x9a48dE73c9BaB5644CeF0F9d82BcDd50F006A63D);
addressOfBountyMembers.push(0x5D155d0dC0b13ddf0a27230f53360a230C55337d);
addressOfBountyMembers.push(0xf3d66152EbA7F5D29d8beE4159F161Eb93372c9B);
addressOfBountyMembers.push(0x656dbA82000b71A9DF73ACA17F941C53e5673b8d);
addressOfBountyMembers.push(0x2Fb2f81b31C0124aE9180E5cE33FC384b18ffE49);
}
function setBountyAmounts() internal {
bountyMembersAmounts[0xA18897f5eBE15fea6A1F4e305f494aAb999237a1] = 3061200000000000000000;
bountyMembersAmounts[0x0062ac6d0906FAC009752a6c802B88D20dcaB4e5] = 29926150000000000000000;
bountyMembersAmounts[0x548EEc899D859105164F4f04d709bAA21509765d] = 698250000000000000000;
bountyMembersAmounts[0xE062B1ba461BC58782CeD8a653F147798165D0f6] = 7470000000000000000000;
bountyMembersAmounts[0xC26bc33DC0769D7Fe812282eAE9e78a72d06FC03] = 676360000000000000000;
bountyMembersAmounts[0x8e4cbDeC134C9050DE3d9D8Cfd6821Bd477c778A] = 308230000000000000000;
bountyMembersAmounts[0xA5F66EaFB02Db5ccAcc4af8AdB536090C362f9B6] = 768750000000000000000;
bountyMembersAmounts[0xe53723C804eFDa69632aEB53EC6c41Ce7dBc8D2b] = 282880000000000000000;
bountyMembersAmounts[0x8dcdc06c2aCC184a2DEbF0Fc41deEae966e3ee43] = 110000000000000000000;
bountyMembersAmounts[0xe37947155614f6146E4455d887CcA823B658Bf08] = 456470000000000000000;
bountyMembersAmounts[0xa8D9B735a876d4F9fb28f5C25F8e3Cd52c2f791C] = 191550000000000000000;
bountyMembersAmounts[0x727c9080069dFF36A93f66d59B234c9865EB3450] = 100000000000000000000;
bountyMembersAmounts[0x17714CDe9FE2889e279A7e9939557c8e4aCcC249] = 421120000000000000000;
bountyMembersAmounts[0xD748a3fE50368D47163b3b1fDa780798970d99C1] = 26020000000000000000000;
bountyMembersAmounts[0x02CFa0abc6c05de03B2E03b2Ce9d4B4554cE8366] = 372320000000000000000;
bountyMembersAmounts[0x0701cCBa1c7a6991c6b40Fde81f7cda65199273c] = 2981550000000000000000;
bountyMembersAmounts[0xbf57fdea968d3ea1638fb2324b1ca83da6445f1c] = 485710000000000000000;
bountyMembersAmounts[0x775AFd2f9bABD405D087D7bc32eBFFA477de3B9F] = 3343740000000000000000;
bountyMembersAmounts[0x4a53687df3fDf2a992f420a9604d775caaC5d0A8] = 339510000000000000000;
bountyMembersAmounts[0x0a221cD57bAC3E4283f29D80caC20916eFce018B] = 434720000000000000000;
bountyMembersAmounts[0x54A9A28Bb5886Fe42B713BF106BB106EB19DE8b8] = 726390000000000000000;
bountyMembersAmounts[0x82C591A9282b91378C1f00310dc71C43548aA505] = 727520000000000000000;
bountyMembersAmounts[0x6101f09c1f7dBD5571455D9F2341317C905bB078] = 469000000000000000000;
bountyMembersAmounts[0xF54fAb200604ddDf868f3e397034F8c6d85BfA15] = 100000000000000000000;
bountyMembersAmounts[0x60C0C55f1De5bc4bc1D1Df41bd30968e89C80Ad7] = 4791120000000000000000;
bountyMembersAmounts[0x33c760AE3A9d2397c07269E6DFFdCe855fB8B92b] = 8689000000000000000000;
bountyMembersAmounts[0x08d5850e4C5A7B51F8950B14112A684F63B362c0] = 8355000000000000000000;
bountyMembersAmounts[0xF1d66A7fa0331784325a9B1F8f8d4a9b02a55308] = 15373200000000000000000;
bountyMembersAmounts[0x3477aC8EA3BAdAe9b29E2486620B71E817f044b5] = 947680000000000000000;
bountyMembersAmounts[0x35Ef1AB02e620C52129F17A9fc94c77a4cc77d51] = 382720000000000000000;
bountyMembersAmounts[0x0F825233eec816512031c26da35d97d9138FBCFD] = 970660000000000000000;
bountyMembersAmounts[0xAce5A8b05C4984E9Ad4D4fD02e1B6e1C47588c0f] = 10026000000000000000000;
bountyMembersAmounts[0x2CAF79C60fbB93eABbDc965222406bc2AAfa8B11] = 422920000000000000000;
bountyMembersAmounts[0xec9a6bF47fa6A5dD2bE77380C33Bd954BC25A236] = 1555300000000000000000;
bountyMembersAmounts[0x25914D13bb4b63073625502Ac6F176FE1FE35211] = 669000000000000000000;
bountyMembersAmounts[0xDaA2eeEa18206c095eDeE910bfCF7a2a488d3eC2] = 656750000000000000000;
bountyMembersAmounts[0x16fa371DdB604bE1706cF61E3B3053D9d7C25Bfc] = 1365350000000000000000;
bountyMembersAmounts[0x614E7141AD154Eae92A5264B990df944694b5D1b] = 470000000000000000000;
bountyMembersAmounts[0xb8e3B0948009e77Df382499f94a255Dc8dF22336] = 5681000000000000000000;
bountyMembersAmounts[0xcf581c3f91665214fc63675e698a57a55c207e46] = 7352000000000000000000;
bountyMembersAmounts[0x7fE33AFe1109a52D7f6311Cc0B8b8388d547eA5C] = 3342000000000000000000;
bountyMembersAmounts[0x36D91414E36246063f353bA71B4f9403F104e32A] = 694600000000000000000;
bountyMembersAmounts[0x4a460EC5bA610B3982A39a401EB72A37bA5dc43A] = 678440000000000000000;
bountyMembersAmounts[0x0C45d153177F64733dC0c691C229427F56d2d154] = 712520000000000000000;
bountyMembersAmounts[0x86628f5c3D6321176199Cd5dF9506F126fe9fE5A] = 6684000000000000000000;
bountyMembersAmounts[0x1b31b34Dd5C5A91C3E61B68e35ea2a008F24327A] = 3676200000000000000000;
bountyMembersAmounts[0x3F61156cB2D12F88B4B32D799D3ba47D3f2a2f90] = 100000000000000000000;
bountyMembersAmounts[0xA7240876D7d7D2b65C92e4460728c626BE7ab91B] = 1882000000000000000000;
bountyMembersAmounts[0x6F98763ff5F6Ca0aFF91acdDF8b85032FE62F704] = 1000000000000000000000;
bountyMembersAmounts[0x8D57020414261E8A4C619F78951Bec41d65Ee02A] = 4411700000000000000000;
bountyMembersAmounts[0x5B2434b286FFE76E58d18c39fB5B188DB580E169] = 475000000000000000000;
bountyMembersAmounts[0x17984B778E34538950B62ee12E49f4ded8C0765D] = 1230600000000000000000;
bountyMembersAmounts[0x64A38FAb91944aA4A300c65461185B2DeD5a718D] = 1834000000000000000000;
bountyMembersAmounts[0xC27520f3d9eef2658Bc94933A6B8350257E52255] = 25508000000000000000000;
bountyMembersAmounts[0xD73C41B5eA96786EAafa590183FaB71249B7B147] = 14734000000000000000000;
bountyMembersAmounts[0x0649c8c75aea1148b3e51b5f7189ff49ff4b3fd5] = 725850000000000000000;
bountyMembersAmounts[0x98EA6b4E05Af3181001E6eD3A87bcA27C8A7ddFe] = 6425350000000000000000;
bountyMembersAmounts[0x3cAb02429D5c33864f45887e53Df506EaC05bEC1] = 750360000000000000000;
bountyMembersAmounts[0x68B4683475747E28a83596e94b58187d452099Cf] = 6684000000000000000000;
bountyMembersAmounts[0x52E1Da12ee737a70f10f8DD0B996b49aB448F0E4] = 13616740000000000000000;
bountyMembersAmounts[0xe6863861818c31bad6fc3e38d0a236f73bc1c6c0] = 139640000000000000000;
bountyMembersAmounts[0xe7DF67F33b74CEbB0fD3a05b15FABFca756D4abB] = 100000000000000000000;
bountyMembersAmounts[0xfdd831e295a94d63BDF7dd912833bfAe229dbe6d] = 4344600000000000000000;
bountyMembersAmounts[0x8a4B11DFf9A535Bd3931db9d438c02C284F43Bb4] = 100000000000000000000;
bountyMembersAmounts[0x7Bf3EeEF640DEC6069F451426e9D8CDb4bEb2956] = 1000000000000000000000;
bountyMembersAmounts[0x63B56909257c89953E888c9a4FA83816d3d24Dc2] = 100000000000000000000;
bountyMembersAmounts[0xaB60bCC2d56910d12654692b74E9f44Dc5A7faaF] = 5969340000000000000000;
bountyMembersAmounts[0x7D0c737248Aa04754a58ca66630b39f1B81534b8] = 1297750000000000000000;
bountyMembersAmounts[0xa9D5fC61D27569195f77E25ef9C816B3cc9b3c4B] = 2448960000000000000000;
bountyMembersAmounts[0x7526AEd3F7Ee8DCe9Cd7083F80f2E6B931Cb3A41] = 4011000000000000000000;
bountyMembersAmounts[0x592782a5adcB83f8D13646b316514314EE3e72f4] = 863100000000000000000;
bountyMembersAmounts[0x7cd156863e8e7473426f566626e0d94d29d023a9] = 1138860000000000000000;
bountyMembersAmounts[0x63e73058e65Ba0FE3f925d2948988782d2617ab2] = 108000000000000000000;
bountyMembersAmounts[0x8D57020414261E8A4C619F78951Bec41d65Ee02A] = 100000000000000000000;
bountyMembersAmounts[0x656118F75fc3C0D17a25eDc12d58FC9a9d4a64fF] = 1186000000000000000000;
bountyMembersAmounts[0x63D87F83E307493517e46e3BDA4704Bcf8838b87] = 2911320000000000000000;
bountyMembersAmounts[0xA65306BF7b9FBB4483dc3610A2f4BD2743cdBBA1] = 3342000000000000000000;
bountyMembersAmounts[0xD71d50bf40A8eF3A29504671c45b24507D7a2bE9] = 41814450000000000000000;
bountyMembersAmounts[0xd7c63d3c978acc3518cb61f2f6f1a86ad3c4bc9b] = 711000000000000000000;
bountyMembersAmounts[0x5cB42C674c1971DB7701A845e9A0c6AAe156d597] = 12031200000000000000000;
bountyMembersAmounts[0x6567CD78Fb8f75308A43ec6a936313b19Ff4cCEa] = 16742100000000000000000;
bountyMembersAmounts[0x1dc522072850Bc59bb2945a950E8647be72D9dF3] = 5771400000000000000000;
bountyMembersAmounts[0x764A8Db8ec617A8415992a4E87bd5543CDC20890] = 765740000000000000000;
bountyMembersAmounts[0x22dC6dB1e1FD097d35E3957806859442C02B79ff] = 100000000000000000000;
bountyMembersAmounts[0xC006B26d5A4f718063772c323184CaE52929d4ac] = 9500920000000000000000;
bountyMembersAmounts[0xD110a0298FBdB68B9f3B937B3a04cc65b65559b2] = 755000000000000000000;
bountyMembersAmounts[0xdd8E3B1FC8acEeF62c2aaE07ab6B39118fD38bC4] = 3839729500000000000000;
bountyMembersAmounts[0xDac17FDFdD48C8e17539abb9074fa40a103259b3] = 21274100000000000000000;
bountyMembersAmounts[0x96ea5C1f31872d655c7f302E895Ff56C8e39a403] = 1317550000000000000000;
bountyMembersAmounts[0xd5AF150E79Ab52859f28Ce2cE3D47D2fa3721cC8] = 2821630000000000000000;
bountyMembersAmounts[0xeaBFadf9724a8A8dd81732925F409d659B837eff] = 10000000000000000000000;
bountyMembersAmounts[0xCe6754a176B23ACcbaf4197Fd739e146811fe4c3] = 1072600000000000000000;
bountyMembersAmounts[0xfc2Ee8b8C9301968eb5cc5Ba896E20DF35aB0152] = 1846000000000000000000;
bountyMembersAmounts[0x25cC08B2E4a5Ce990d6f9b09E108C0E7753ED78f] = 5212190000000000000000;
bountyMembersAmounts[0x5Ce01b55Ac1750A8BEA447c70d2c5c4B2745a078] = 27664563000000000000000;
bountyMembersAmounts[0x5Cc2e30e3af89363c437342a3AbB5762C09d0A58] = 100000000000000000000;
bountyMembersAmounts[0x740a5c3677a7018f367c38d8655f00b458eed9ab] = 2226640000000000000000;
bountyMembersAmounts[0x1B7376e2a05f187dF562Fc91eeb3B78998849C6d] = 4958827500000000000000;
bountyMembersAmounts[0x539B9B4b5b8f6494f0aD62851d8765Cb350aCe62] = 19666240000000000000000;
bountyMembersAmounts[0x470234E7E3e386f519BaCEBfe6ebfd239d0d6133] = 54786800000000000000000;
bountyMembersAmounts[0x726356cF0ED11183a093d5c454deb6F9543831f7] = 104000000000000000000;
bountyMembersAmounts[0x43dbc504A778db4bE3e43911BB793EA459203284] = 2000000000000000000000;
bountyMembersAmounts[0x1C1c278C75ab20EfD30cd418907A669B83e23A4B] = 2460000000000000000000;
bountyMembersAmounts[0x522aB87522A15A7004DFaa4b358d4f2c8b9f2fAE] = 129000000000000000000;
bountyMembersAmounts[0x96fC8Ae2d1404e9978485491cdbB2760dC013128] = 2460000000000000000000;
bountyMembersAmounts[0x655D8C74e55E8b2bf58B68ff714392F7A126a578] = 2460000000000000000000;
bountyMembersAmounts[0x561032144b0535fef28C1764e504dB2EB523C082] = 2460000000000000000000;
bountyMembersAmounts[0x41e27C9a3EDE803a1D3548935E233a3A5e7A500b] = 2460000000000000000000;
bountyMembersAmounts[0x2C0073a2Da29b6511cBB37bda40449c515567D31] = 105000000000000000000;
bountyMembersAmounts[0xb33d01dD954888Ae2FdA24403e64b2e1daD84DFF] = 149000000000000000000;
bountyMembersAmounts[0x8778Ec54b00c6240A75794Fd658b7E6178396831] = 100000000000000000000;
bountyMembersAmounts[0x507d933F8763Ba40dfFa8F1602ffd0Ed6A88BFbF] = 4907000000000000000000;
bountyMembersAmounts[0xec0a22287657C85a317a8919b679Ce8eDD8411F9] = 2460000000000000000000;
bountyMembersAmounts[0x09FA7F2fbb1F08FC325d39317d5548bA868559F3] = 2460000000000000000000;
bountyMembersAmounts[0xc80e94b74b577ECC134AD5eAB05477aBA09afC93] = 2460000000000000000000;
bountyMembersAmounts[0x80D840E635C6B6C86207a6F898E6Ed94053bEd1E] = 2460000000000000000000;
bountyMembersAmounts[0x7E2a9b9e8576F4377E2079d3CB361aF872a0B68e] = 2460000000000000000000;
bountyMembersAmounts[0xF9650CDC299b94c244102d20b872FE3614Fea171] = 3073000000000000000000;
bountyMembersAmounts[0x10c9D209898e8926157faa9aAE0398F6B81D483F] = 3073000000000000000000;
bountyMembersAmounts[0x04194AD8E4b82cb65c43E4860Ccb8397A6e10c20] = 2460000000000000000000;
bountyMembersAmounts[0x0b653d2e8347b61c0064972684B5700686D73902] = 3073000000000000000000;
bountyMembersAmounts[0xE6618fEe9B5f3aEf3e6aEd4f050cA7343f081994] = 2458000000000000000000;
bountyMembersAmounts[0x93711F2B2291574D170bCaD2fD2b688F642E255A] = 1848000000000000000000;
bountyMembersAmounts[0x22abD036efE57F0d70Cc9d246a645f0e53109bE8] = 1848000000000000000000;
bountyMembersAmounts[0xD0B1bc752d6bF1029c92264D1e0ab42f7f26C25D] = 4295000000000000000000;
bountyMembersAmounts[0xf3232ADc8e87ead9F29E1fec347B293b65BC07BF] = 1848000000000000000000;
bountyMembersAmounts[0x9a48dE73c9BaB5644CeF0F9d82BcDd50F006A63D] = 5244000000000000000000;
bountyMembersAmounts[0x5D155d0dC0b13ddf0a27230f53360a230C55337d] = 5758000000000000000000;
bountyMembersAmounts[0xf3d66152EbA7F5D29d8beE4159F161Eb93372c9B] = 6322000000000000000000;
bountyMembersAmounts[0x656dbA82000b71A9DF73ACA17F941C53e5673b8d] = 119000000000000000000;
bountyMembersAmounts[0x2Fb2f81b31C0124aE9180E5cE33FC384b18ffE49] = 100000000000000000000;
}
}