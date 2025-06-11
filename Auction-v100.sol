// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {

    // DATA STRUCTURES ---------------------------------------------------------------------------------------

    // Bid related data
    struct Bid {
        address bidder;     // the bidder
        uint amount;        // the amount of the bid
        uint time;          // timestamp when this bid is made
        bool claimed;       // whether this bid has been claimed or not by the user
    }

    // Auction data structure
    struct AuctionData {
        address owner;        // the one who creates the auction
        uint auctionStart;    // auction start timestamp
        uint auctionEnd;      // when the auction will end
        bool auctionClosed;   // whether the auction is closed or not
        bool refundsDone;     // whether refunds have been processed
        uint feesCollected;   // accumulated fees collected
        Bid highestBid;       // the bid with the highest amount
        Bid[] bidHistory;     // all the bid history of this auction
    }

    // Auction data
    AuctionData public auctionData;

    // CONSTANTS ----------------------------------------------------------------------------------------------
    uint public constant MINIMUM_BID = 1 ether;                // minimum bid amount
    uint public constant AUCTION_DURATION = 1 days;            // auction duration
    uint public constant AUCTION_FEE = 2;                      // fee % collected when refunding non-winners bids
    uint public constant EXTENSION_TIME_WINDOW = 10 minutes;   // time added when bid occurs near auction end
    uint public constant MIN_BID_INCREMENT_PCT = 5;            // required % increase over highest bid

    // EVENTS -------------------------------------------------------------------------------------------------

    event AuctionStart(
        address indexed owner,
        uint startTime,
        uint endTime
    );

    event NewBid(
        address indexed bidder,
        uint amount,
        uint time
    );

    event AuctionClosed(
        address winner,
        uint amount
    );

    event BidClaimed(
        address indexed bidder, 
        uint refundedAmount
    );

    // CONSTRUCTOR --------------------------------------------------------------------------------------------

    // Creates the auction and starts it
    constructor() {
        auctionData.owner = msg.sender;
        auctionData.auctionStart = block.timestamp;
        auctionData.auctionEnd = block.timestamp + AUCTION_DURATION;
        auctionData.auctionClosed = false;
        auctionData.refundsDone = false;
        auctionData.feesCollected = 0;

        emit AuctionStart(msg.sender, auctionData.auctionStart, auctionData.auctionEnd);
    }

    // MODIFIERS ----------------------------------------------------------------------------------------------

    // Checks if auction is open
    modifier isAuctionOpen() {
        require(!auctionData.auctionClosed, "Auction already closed");
        _;
    }

    // Checks if auction is closed
    modifier isAuctionClosed() {
        require(auctionData.auctionClosed, "Auction not closed yet");
        _;
    }

    // Checks if caller is the owner
    modifier isOwner() {
        require(msg.sender == auctionData.owner, "Only owner can call this");
        _;
    }

    // FUNCTIONS -----------------------------------------------------------------------------------------------

    // Accept a bid
    function bid() external payable isAuctionOpen {
        require(msg.value >= MINIMUM_BID, "Bid below minimum");

        // check if it is a valid bid
        if (auctionData.highestBid.amount > 0) {
            uint requiredMin = auctionData.highestBid.amount +
                (auctionData.highestBid.amount * MIN_BID_INCREMENT_PCT) / 100;
            require(msg.value >= requiredMin, "Bid must exceed minimum increment");
        }

        // there is a new bid, so keep it
        Bid memory newBid = Bid({
            bidder: msg.sender,
            amount: msg.value,
            time: block.timestamp,
            claimed: false
        });

        auctionData.highestBid = newBid;
        auctionData.bidHistory.push(newBid);

        emit NewBid(msg.sender, msg.value, block.timestamp);

        // extends time if necessary
        uint timeLeft = auctionData.auctionEnd > block.timestamp ? auctionData.auctionEnd - block.timestamp : 0;
        if (timeLeft < EXTENSION_TIME_WINDOW) {
            auctionData.auctionEnd = block.timestamp + EXTENSION_TIME_WINDOW;
        }
    }

    // Allow bidders to claim refundable bids when auction is still open, except for winning bid
    function claimMyBid() external isAuctionOpen {
        uint totalRefund = 0;

        // accumulate funds from caller without applying a fee
        for (uint i = 0; i < auctionData.bidHistory.length; i++) {
            Bid storage thisBid = auctionData.bidHistory[i];
            if (
                thisBid.bidder == msg.sender &&
                thisBid.bidder != auctionData.highestBid.bidder &&
                !thisBid.claimed
            ) {
                totalRefund += thisBid.amount;
                thisBid.claimed = true;
            }
        }

        require(totalRefund > 0, "No refundable bids");

        // do the claim
        payable(msg.sender).transfer(totalRefund);
        emit BidClaimed(msg.sender, totalRefund);
    }

    // Refund losing bidders deducting fee
    function refundAll() internal {
        require(!auctionData.refundsDone, "Refunds already processed");

        uint totalFeesCollected = 0;

        // loop all bidders and refund if not claimed before or is the winner bid
        for (uint i = 0; i < auctionData.bidHistory.length; i++) {
            Bid storage thisBid = auctionData.bidHistory[i];

            if (thisBid.bidder == auctionData.highestBid.bidder || thisBid.claimed) {
                continue;
            }

            uint fee = (thisBid.amount * AUCTION_FEE) / 100;
            uint refundAmount = thisBid.amount - fee;
            totalFeesCollected += fee;

            thisBid.claimed = true;

            // do the refund
            if (refundAmount > 0) {
                payable(thisBid.bidder).transfer(refundAmount);
                emit BidClaimed(thisBid.bidder, refundAmount);
            }
        }

        auctionData.feesCollected += totalFeesCollected;
        auctionData.refundsDone = true;
    }

    // Owner closes auction and refunds losing bidders regardless if its open or closed
    function closeAuction() external isOwner {
        auctionData.auctionClosed = true;

        emit AuctionClosed(auctionData.highestBid.bidder, auctionData.highestBid.amount);

        refundAll();
    }

    // Withdraw contract balance after auction is closed
    function withdraw() external isOwner isAuctionClosed {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(auctionData.owner).transfer(balance);
    }

    // View function for auction progress
    function getAuctionProgress() external view returns (
        uint auctionStartTime,
        uint auctionEndTime,
        uint timeRemaining,
        address highestBidder,
        uint highestBidAmount,
        uint highestBidTime
    ) {
        auctionStartTime = auctionData.auctionStart;
        auctionEndTime = auctionData.auctionEnd;

        if (block.timestamp >= auctionData.auctionEnd) {
            timeRemaining = 0;
        } else {
            timeRemaining = auctionData.auctionEnd - block.timestamp;
        }

        highestBidder = auctionData.highestBid.bidder;
        highestBidAmount = auctionData.highestBid.amount;
        highestBidTime = auctionData.highestBid.time;
    }

    // Show all bidders data for owner only
    function showBiddersData() external view isOwner isAuctionOpen returns (Bid[] memory) {
        return auctionData.bidHistory;
    }

    // Get current highest bid info
    function getWinnerBid() external view isAuctionOpen returns (address, uint, uint) {
        Bid memory winner = auctionData.highestBid;
        return (winner.bidder, winner.amount, winner.time);
    }

    // Show bidders (addresses, amounts, times) to anyone while auction open (optional)
    function showBidders() external view isAuctionOpen returns (address[] memory, uint[] memory, uint[] memory) {
        uint length = auctionData.bidHistory.length;

        address[] memory bidders = new address[](length);
        uint[] memory amounts = new uint[](length);
        uint[] memory times = new uint[](length);

        for (uint i = 0; i < length; i++) {
            Bid storage thisBid = auctionData.bidHistory[i];
            bidders[i] = thisBid.bidder;
            amounts[i] = thisBid.amount;
            times[i] = thisBid.time;
        }

        return (bidders, amounts, times);
    }

}
