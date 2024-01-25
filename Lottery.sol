// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 < 0.9.0;

contract Lottery {
    // 'manager' variable stores the address of the contract creator (manager of the lottery)
    address public manager;

    // 'participants' array stores the addresses of participants who send Ether to the contract
    address payable[] public participants;

    // Constructor is executed once during contract deployment
    constructor() {
        // 'msg.sender' is a built-in variable referring to the address of the contract caller
        // It sets 'manager' to the address of the contract creator
        manager = msg.sender;
    }

    // 'receive' function is a special function that is executed when the contract receives Ether
    // It adds the sender's address to the 'participants' array
    receive() external payable {
    
        require(msg.value==1 ether);
        participants.push(payable(msg.sender));
    }

    // 'getBalance' function is a view function that returns the current balance of the contract
    // It uses 'address(this).balance' to get the contract's Ether balance
    // 'uint' is the return type specifying that the function returns an unsigned integer
    function getBalance() public view returns (uint) {
       
        require(msg.sender==manager); // to check the initial deployement address of the contract with the current one
        return address(this).balance;
    }

    function random() public view returns (uint) {
    // keccak256 is a hashing function used to create a cryptographic hash
    // abi.encodePacked concatenates the arguments and converts them into a byte array
    // The arguments for abi.encodePacked include block.difficulty, block.timestamp, and participants.length

    //NOTE:- Keep in mind that while this method can introduce some randomness, it's not fully secure for cryptographic purposes. If high-security randomness is essential (especially in applications like lotteries), it's recommended to use more advanced techniques, possibly involving external oracles or decentralized randomness services. Using block.timestamp for randomness can be manipulated by miners to some extent, and it may not provide the level of unpredictability needed for fairness.

    //block.difficulty-It is a measure of how difficult it is to find a new block in the blockchain.
    // Use block.prevrandao instead of block.difficulty- mor e secure

    //block.timestamp-It represents the time when the block was mined. 
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }



    
function selectWinner() public {
    // Ensure that the caller of the function is the manager of the lottery
    require(msg.sender == manager, "Only the manager can call this function");

    // Require that there are at least three participants for a winner to be selected
    require(participants.length >= 3, "Not enough participants to select a winner");

    // Call the random function to generate a pseudo-random number
    uint r = random();

    // Calculate the index of the winner based on the random number and the number of participants
    uint index = r % participants.length;

    // Declare a variable to store the address of the winner
    address payable winner;

    // Assign the winner's address based on the calculated index
    winner = participants[index];

    // Transfer the entire balance of the contract to the winner
    winner.transfer(getBalance());

    // Reset the participants array to an empty state for the next round
    participants=new address payable[](0);
}

}