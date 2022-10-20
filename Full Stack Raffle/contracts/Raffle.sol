//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

error Raffle__SendMoreToEnterRaffle();
error Raffle__RaffleNotOpen();

contract Raffle{
    enum RaffleState {
        Open,
        Calculating
    }

    uint256 public immutable i_entreeFee;
    uint256 public immutable i_interval;
    RaffleState public s_raffleState; 
    address payable[] public s_players;
    uint256 public s_timeStamp;

    event RaffleEntered(address indexed player);


    constructor(uint256 entreeFee, uint256 interval){
        i_entreeFee = entreeFee;
        i_interval = interval;
        s_timeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        //require(msg.value >= i_entreeFee, "Not enough money sent!");
        if(msg.value < i_entreeFee){
            revert Raffle__SendMoreToEnterRaffle();
        }

        if(s_raffleState != RaffleState.Open){
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // 1. we want winner to be chosen automatically
    // 2. we want winner to be chosen at random
    
    // when should you pick a winner
    // 1. after some time interval
    // 2. lottery must be open
    // 3. the contract has eth 
    // 4. keepers has LINK

    function checkUpkeep(bytes memory /* checkData */) public view returns(bool upkeepNeeded, bytes memory /* performData */) {
        bool isOpen = RaffleState.Open == s_raffleState; 
        bool timePassed = ((block.timestamp - s_timeStamp) > i_interval);
        bool hasPlayers = s_players.length > 0;
        bool hasMoney = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasMoney);
        return(upkeepNeeded, "0x0");
    }



}