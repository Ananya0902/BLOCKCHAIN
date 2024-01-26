// SPDX-License-Identifier: Unlicense

pragma solidity >=0.5.0 < 0.9.0;

contract EventManagment {
    // Struct to represent an event
    struct Event {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    // Mapping to store events with unique IDs
    mapping(uint => Event) public events;

    // Mapping to store the number of tickets owned by each address for each event
    mapping(address => mapping(uint => uint)) public tickets;

    // Variable to track the next available event ID
    uint public nextId;

    // Function to create a new event
    function createEvent(string memory name, uint date, uint price, uint ticketCount) external {
        // Require that the event date is in the future
        require(date > block.timestamp, "You can organize an event for a future date");

        // Require that the event has available tickets
        require(ticketCount > 0, "You can organize an event only if you have tickets available");

        // Create a new event and store it in the mapping
        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        
        // Increment the event ID for the next event
        nextId++;
    }

    // Function to buy tickets for an event
    function buyTicket(uint id, uint quantity) external payable {
        // Require that the event exists
        require(events[id].date != 0, "This event does not exist");

        // Require that the event date is in the future
        require(events[id].date > block.timestamp, "This event has already occurred");

        // Get a reference to the event
        Event storage _event = events[id];

        // Require that the correct amount of Ether is sent for the tickets
        require(msg.value == (_event.price * quantity), "Ether sent is not enough");

        // Require that there are enough tickets available
        require(_event.ticketRemain >= quantity, "Not enough tickets available");

        // Reduce the available tickets and update the user's ticket count
        _event.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    // Function to transfer tickets to another address
    function transferTicket(uint id, uint quantity, address to) external {
        // Require that the event exists
        require(events[id].date != 0, "This event does not exist");

        // Require that the event date is in the future
        require(events[id].date > block.timestamp, "This event has already occurred");

        // Require that the sender has enough tickets to transfer
        require(tickets[msg.sender][id] >= quantity, "You do not have enough tickets");

        // Reduce the sender's ticket count and increase the recipient's ticket count
        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }
}
