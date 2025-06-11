# Auction Demo
* Basic auction demo for learning purposes in Solidity for Ethereum.
* This contract aims to handle an auction from its start to its end.

### Data Structures

* Bid: Holds all data related to a single bid.
`
    // Bid related data
    struct Bid {
        address bidder;     // the bidder
        uint amount;        // the amount of the bid
        uint time;          // timestamp when this bid is made
        bool claimed;       // whether this bid has been claimed or not by the user
    }
`

* AuctionData: all data of the auction. Who is the owner, when started, when finished, what bids its have, what claims has been done, if it is open or not.
`
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
`

* Constants: all fixed attributes used when the auction is created.
`
    uint public constant MINIMUM_BID = 1 ether;                // minimum bid amount
    uint public constant AUCTION_DURATION = 1 days;            // auction duration
    uint public constant AUCTION_FEE = 2;                      // fee % collected when refunding non-winners bids
    uint public constant EXTENSION_TIME_WINDOW = 10 minutes;   // time added when bid occurs near auction end
    uint public constant MIN_BID_INCREMENT_PCT = 5;            // required % increase over highest bid
`

### Events
There are events issued when auction starts, a bid is accepted, auction is finished and a bid is claimed.

### Modifiers
Modifiers exists to check is an auction is active or not and if the caller is the owner or not.

### Auction Flow

#### Auction is Created
This occurs when contract is deployed. This auction accepts some fixed attributes:
  a) Bids has a minimum of 1 ETH
  b) Auction last for 1 day
  c) When auction is closed and non-winning bids has not claimed their funds, those funds are refunded but keeping a fee of 2%
  d) A window of 10 min is set, if a bid is accepted and auction is finalizing befor 10 min, auction ending is extended by 10 more minutes.
  e) A bid is accepted if is greater than maximum bid and exceeds a rate of 5%

#### Auction is Open
The following functions are applicable.

##### Bid
* Purpose: Accepts a bid, anyone can bid
* Signature: `function bid()`

##### Claim My Bid
* Purpose: Allow bidders to claim refundable bids when auction is still open, except for winning bid
* Signature: `function claimMyBid()`

##### Get Auction Progress
* Purpose: Show auction start time, end time, remaining time, highest bidder, amount of higher bid and timestamp of higher bid
* Signature: function getAuctionProgress()

##### Get Winner Bid
* Purpose: Show highest bidder, amount of higher bid and timestamp of higher bid
* Signature: `function getWinnerBid()`

##### Show Bidders
* Purpose: Show all bidders (addresses, amounts and timestamps)
* Signature: `function showBidders()`

##### Show Bidders Data (privileged)
* Purpose: Show all bidders (addresses, amounts, timestamps, claimed flag)
* Signature: `function showBidders()`

##### Close Auction (privileged)
* Purpose: Owner could close auction, refunding all non-winning bids keeping a fee
* Signature: `function closeAuction()`

#### Auction is Closed

##### Withdraw (privileged)
* Purpose: Owner get all remaining funds from the contract
* Signature: `function withdraw()`

