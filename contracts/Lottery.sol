// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Lottery {
    address owner;
    uint256 maxTickets;
    uint256 ticketsAvailable;
    address payable[] ticketBuyers;
    uint256 ticketPrice;

    constructor(uint256 _maxTickets, uint256 _price){
        owner = msg.sender;
        maxTickets = _maxTickets;
        ticketPrice = _price;
        ticketsAvailable = maxTickets;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function buyTicket() public payable {
        require(ticketsAvailable > 0, "No Tickets Available");
        require(msg.value >= ticketPrice, "Invalid amount sent");
        ticketBuyers.push(payable(msg.sender));
        ticketsAvailable--;
    }

    function endGame() public payable {
        require(ticketsAvailable == 0, "Game is yet to end");
        uint256 winnerId = block.timestamp % maxTickets;
        address payable winnerAddress = ticketBuyers[winnerId];
        (bool sent, bytes memory data) = winnerAddress.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
        ticketBuyers = new address payable[](0);
        ticketsAvailable = maxTickets;
    }

    function checkGameStatus() public view returns (string memory) {
        if(ticketsAvailable > 0) {
            return "Game still on";
        }
        else {
            return "Game over!";
        }
    }

    function checkTicketsAvailable() public view returns (uint256) {
        return ticketsAvailable;
    }
}
