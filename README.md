# Auction Demo
Basic auction demo for learning purposes in Solidity for Ethereum.
This contract aims to handle an auction from its start to its end.

### Data Structures
* Bid: Holds all data related to a bid. The address of a bidder, amount of bid, timestamp of bid and a flag indicating if it's has been claimed or not.
* AuctionData: all data of the auction. Who is the owner, when started, when finished, what bids its have, what claims has been done, if it is open or not.
* Constants: all fixed attributes used when the auction is created.

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
Purpose: Accepts a bid, anyone can bid
Signature: `function bid()`
Parameters: none

##### Claim My Bid
Purpose: Allow bidders to claim refundable bids when auction is still open, except for winning bid
Signature: `function claimMyBid()`

##### Get Auction Progress
Purpose: Show auction start time, end time, remaining time, highest bidder, amount of higher bid and timestamp of higher bid
Signature: function getAuctionProgress()

##### Get Winner Bid
Purpose: Show highest bidder, amount of higher bid and timestamp of higher bid
Signature: `function getWinnerBid()`

##### Show Bidders
Purpose: Show all bidders (addresses, amounts and timestamps)
Signature: `function showBidders()`

##### Show Bidders Data (privileged)
Purpose: Show all bidders (addresses, amounts, timestamps, claimed flag)
Signature: `function showBidders()`

##### Close Auction (privileged)
Purpose: Owner could close auction, refunding all non-winning bids keeping a fee
Signature: `function closeAuction()`

#### Auction is Closed

##### Withdraw (privileged)
Purpose: Owner get all remaining funds from the contract
Signature: `function withdraw()`

