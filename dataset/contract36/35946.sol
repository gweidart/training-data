pragma solidity ^0.4.10;
contract balancesImporter1   {
address[] public addresses1;
uint256[] public balances1;
function balancesImporter1()    {
addresses1=[
0x0CE83A420AaDd92620644593958fC4C2AbB54e04,
0x1860DE65733b4c6340B311828D615bB3494FB28E,
0x26c66f18Bde464bE7f892aa01E22eD33C6C73b99,
0x9549C1B252821f625103B1261Ca036bc4336Ee93,
0x9980988ca611C2a51ceC4F81BAbDff9B36eD97b3,
0x48FC76Abd9787E9587CCFE122E6FDf8C223b7F30,
0xB86fc5B069A27fD75551676071f6B2BaB6820358,
0xAEb463CfB52f2d58a1b31B5366aE7C46251826c1,
0x7FE8D693d12AfaD5D105C12074008594B2b79118,
0x2c99623Bbb16283ceFCbd927F093687BFFc4A413,
0x16958617d1f183d4093e711c16C8f093d0Be0262,
0xc4d57535ae3522069f91c77ea98c9c973dc70386,
0xa41feb56136699987Ff0C1CF05ea7E4e74cACD35,
0x9AA1C56AdC3331524f2c544A8B30F6ec0edA281e,
0x3c8B4d2586732Cd4e7EFcd3C68E66eBb3534CcC2,
0x7AA65d6D4F9BC1359b5FBc6BEc06155a4CE955df,
0x07513563a931d13fd2f0221dcaa51c328ceeb592,
0x541EA757F2d106eEEB8dDcA70cA1310AE760EB54,
0x2c99623Bbb16283ceFCbd927F093687BFFc4A413,
0x635966FeE0b5e9701F1aF924AACc8859159c4C56,
0xaab9ACe9eaF702131e2A1091f7d7568216AFF40C,
0x12192d986bc92308e15242f5c4440c8d83777d46,
0x005DD6696563718a2c60fEdC602C66a078394570,
0xa92083dAa368fde48c7918f0B9cF23e4FeF4a034,
0x0BC37573450341b17b637986C48350682176c605,
0x4EA9602a6C2144FE6f5F1982A51Ef9ac405adF91,
0xeee2605478D189d9CB673104Cd46643450Dc8941,
0xf5e896B91a8a8d7F6F414C383eA1404a1173c6F5,
0xA7Eba7FdA7E463C5509519EdF03137C57f3eBe73,
0x0815A0e171dc871665A509Ea7Ac2C1002844d1c0
];
balances1=[
34687420306050000000000,
49073751207690000000000,
236078473614360000000000,
4619874888290000000000,
18150184103500000000000,
1269157052950000000000,
68710021465990000000000,
165104083691270000000000,
556400000000000000000000,
58595030099680000000000,
2575532161290000000000,
43182094741250000000000,
55414808670070000000000,
7600488968080000000000,
2327046318690000000000,
11076433324840000000000,
1278094237530000000000,
1167545795080000000000,
108962222525770000000000,
444493412500000000000,
1996000000000000000000,
14964367669460000000000,
557697015416990000000000,
9293330843950000000000,
2162238413600000000000,
2293451206380000000000,
537333405470000000000,
3293988212180000000000,
5000000000000000000000,
11520000000000000000000
];
elixor elixorContract=elixor(0x898bf39cd67658bd63577fb00a2a3571daecbc53);
elixorContract.importAmountForAddresses(balances1,addresses1);
}
}
contract elixor  {
function importAmountForAddresses(uint256[] amounts,address[] addressesToAddTo);
}