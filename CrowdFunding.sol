// SPDX-License-Identifier: Unlicense

pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding {
    
    mapping(address=>uint) public contributors;//links the address to the contributors.... address-> ether

    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target ;
    uint public raisedAmount;
    uint public noOfContributors;



  // Define a struct to represent a spending request.
   struct Request {
    string description;             // Description of the spending request.
    address payable recipient;      // Recipient address to send the funds.
    uint value;                     // Amount of Ether (in Wei) to be sent.
    bool completed;                 // Flag indicating whether the request has been completed.
    uint noOfVoters;                // Number of voters who have voted on the request.
    mapping(address => bool) voters; // Mapping to track which addresses have voted on the request.
   
   }

    // Mapping to store multiple spending requests, each identified by a unique index (uint).
    mapping(uint => Request) public requests;

    // Variable to keep track of the total number of spending requests.
    uint public numRequests;


    constructor(uint _target, uint _deadline){
        target=_target;
        deadline= block.timestamp+_deadline;
        minimumContribution= 100 wei;
        manager=msg.sender;//The creator of the contract becomes the manager.
    }

    
    // Function to allow contributors to send Ether to the contract.
    function sendEth() public payable {
        // Require that the deadline has not passed.
        require(block.timestamp < deadline, "Deadline has been passed");

        // Require that the sent value is greater than or equal to the minimum contribution.
        require(msg.value >= minimumContribution, "Minimum Contribution not met");

        // If the contributor is contributing for the first time, increment the contributor count.
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }

        // Update the contributor's contribution amount and total raised amount.
        contributors[msg.sender] += msg.value; //msg.value: This represents the amount of Ether (in Wei) sent with the transaction.    
        raisedAmount += msg.value;
    } 


    // Function to get the current balance of the smart contract.
    function getContractBalance() public view returns(uint) {
    return address(this).balance; // Returns the balance of the contract in terms of Ether.
    }



    // Function to process refunds for contributors.
    function refund() public {
    // Require that the deadline has passed and the target amount is not reached.
    require(block.timestamp > deadline && raisedAmount < target, "You are not eligible for a refund");

    // Require that the caller has made a contribution.
    require(contributors[msg.sender] > 0);

    // Convert the sender's address to a payable address.
    address payable user = payable(msg.sender);

    // Transfer the contributed amount back to the contributor.
    user.transfer(contributors[msg.sender]);

    // Set the contributor's contribution amount to zero after the refund.
    contributors[msg.sender] = 0;
}



// Modifier to restrict access to only the manager.
modifier onlyManager() {
    require(msg.sender == manager, "Only manager can call this function");
    _; // Continue with the execution of the modified function.
}



// Function to create spending requests, accessible only by the manager.
function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager {
    // Create a new Request object and reference it using storage.
    Request storage newRequest = requests[numRequests];

    // Increment the total number of requests.
    numRequests++;

    // Initialize the properties of the new request.
    newRequest.description = _description;
    newRequest.recipient = _recipient;
    newRequest.value = _value;
    newRequest.completed = false;
    newRequest.noOfVoters = 0;
}



// Function to allow contributors to vote on a spending request.
function voteRequest(uint _requestNo) public {
    // Require that the caller is a contributor.
    require(contributors[msg.sender] > 0, "You must be a contributor");

    // Retrieve the specified spending request using the request number.
    Request storage thisRequest = requests[_requestNo];

    // Require that the caller has not already voted on this request.
    require(thisRequest.voters[msg.sender] == false, "You have already voted");

    // Mark the caller as a voter for this request.
    thisRequest.voters[msg.sender] = true;

    // Increment the number of voters for this request.
    thisRequest.noOfVoters++;
}


// Function to make a payment to the recipient of a spending request, accessible only by the manager.
    function makePayment(uint _requestNo) public onlyManager {
        // Require that the total amount raised is greater than or equal to the target amount.
        require(raisedAmount >= target);

        // Retrieve the specified spending request using the request number.
        Request storage thisRequest = requests[_requestNo];

        // Require that the spending request has not been completed.
        require(thisRequest.completed == false, "The request has been completed");

        // Require that the majority of contributors support the spending request.
        require(thisRequest.noOfVoters > noOfContributors / 2, "Majority does not support");

        // Transfer the requested amount to the recipient.
        thisRequest.recipient.transfer(thisRequest.value);

        // Mark the spending request as completed.
        thisRequest.completed = true;
    }


}