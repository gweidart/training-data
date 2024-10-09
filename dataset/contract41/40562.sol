contract ParallelGambling {
uint[3] private deposit;
uint private feesThousandth = 10;
uint private time_max = 6 * 60 * 60;
uint private fees = 0;
uint private first_prize = 170;
uint private second_prize = 130;
uint private third_prize = 0;
uint[3] private Balance;
uint[3] private id;
uint[3] private cursor;
uint[3] private nb_player ;
uint[3] private last_time ;
uint256 private toss1;
uint256 private toss2;
address private admin;
function ParallelGambling() {
admin = msg.sender;
uint i;