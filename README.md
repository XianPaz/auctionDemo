# Auction Demo
* Basic auction demo for learning purposes in Solidity for Ethereum.
* This contract aims to handle an auction from its start to its end.

### Data Structures

**Bid**: Holds all data related to a single bid.
```
    // Bid related data
    struct Bid {
        address bidder;     // the bidder
        uint amount;        // the amount of the bid
        uint time;          // timestamp when this bid is made
        bool claimed;       // whether this bid has been claimed or not by the user
    }
```

**AuctionData**: all data of the auction. Who is the owner, when started, when finished, what bids its have, what claims has been done, if it is open or not.
```
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
```

**Constants**: all fixed attributes used when the auction is created.
```
    uint public constant MINIMUM_BID = 1 ether;                // minimum bid amount
    uint public constant AUCTION_DURATION = 1 days;            // auction duration
    uint public constant AUCTION_FEE = 2;                      // fee % collected when refunding non-winners bids
    uint public constant EXTENSION_TIME_WINDOW = 10 minutes;   // time added when bid occurs near auction end
    uint public constant MIN_BID_INCREMENT_PCT = 5;            // required % increase over highest bid
```

### Events

**AuctionStart**: indicates the auction is started. Is issued once contract is deployed.
```
    event AuctionStart(
        address indexed owner,
        uint startTime,
        uint endTime
    );
```

**AuctionClosed**: shows when an auction is closed. Is triggered by the owner anytime.
```
    event AuctionClosed(
        address winner,
        uint amount
    );
```

**BidClaimed**: issued by any bidder when he/she decides to claim their funds.
```
    event BidClaimed(
        address indexed bidder, 
        uint refundedAmount
    );
```

### Modifiers
Modifiers exists to check is an auction is active or not and if the caller is the owner or not.

### Auction Flow

#### Auction is Created
This occurs when contract is deployed. This auction accepts some fixed attributes:

a) Bids has a minimum of 1 ETH <br/>
b) Auction last for 1 day <br/>
c) When auction is closed and non-winning bids has not claimed their funds, those funds are refunded but keeping a fee of 2%
d) A window of 10 min is set, if a bid is accepted and auction is finalizing befor 10 min, auction ending is extended by 10 more minutes
e) A bid is accepted if is greater than maximum bid and exceeds a rate of 5%

All this setup is done in constructor.

#### Auction is Open
The following functions are applicable:

**bid**: Accepts a bid, anyone can bid
* Signature: `function bid() external payable isAuctionOpen`
* Parameters: None
* Returns: None

**claimMyBid**: Allow bidders to claim refundable bids when auction is still open, except for winning bid
* Signature: `function claimMyBid() external isAuctionOpen`
* Parameters: None
* Returns: None

**getAuctionProgress**: Show auction times and winning bid
* Signature: `function getAuctionProgress() external view`
* Parametes: None
* Returns:
  * uint auctionStartTime: auction's start time
  * uint auctionEndTime: auction's end time
  * uint timeRemaining: auction's remaining time
  * address highestBidder: address of winner bidder
  * uint highestBidAmount: amount of winner bidder
  * uint highestBidTime: timestamp when winner bid was accepted

**getWinnerBid**: Show highest bidder, amount of higher bid and timestamp of higher bid
* Signature: `function getWinnerBid() external view isAuctionOpen`
* Parameters: None
* Returns: None

**showBidders**: Show all bidders (addresses, amounts and timestamps)
* Signature: `function showBidders() external view isAuctionOpen`
* Parameters: None
* Returns:
  * bidders: array of bidder's addesses
  * amounts: array of bidder's amounts
  * times: array of bidder's timestamps when the bid was accepted

**showBiddersData (privileged)**: Show all bidders (addresses, amounts, timestamps, claimed flag)
* Signature: `function showBiddersData() external view isOwner isAuctionOpen`
* Parameters: None
* Returns:
  * bidHistory: array of bid structure which holds address, amount, timestamp and claimed flag for all bidders

**closeAuction (privileged)**: Owner could close auction, refunding all non-winning bids keeping a fee whenever he/she wants (in an open or closed auction)
* Signature: `function closeAuction() external isOwner`
* Parameters: None
* Returns: None

#### Auction is Closed

**Withdraw (privileged)**: Owner get all remaining funds from the contract (winning bid amount plus fees of refunded non-winning bids
* Signature: `function withdraw() external isOwner isAuctionClosed`
* Parameters: None
* Returns: None
