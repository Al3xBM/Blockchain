// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {
    
    string public name = "Sample Token";
    string public symbol = "TOK";

    uint256 public totalSupply;
    
    event Transfer(address indexed _from,
                   address indexed _to,
                   uint256 _value);

    event Approval(address indexed _owner,
                   address indexed _spender,
                   uint256 _value);

    event Mint(address indexed _to,
               uint256 _value);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply) {
        balanceOf[msg.sender] = _initialSupply;

        totalSupply = _initialSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        
        return true;
    }

    function mint(address _to, uint256 _value) public returns (bool) {
        totalSupply += _value;
        balanceOf[_to] += _value;
        allowance[_to][msg.sender] += _value;

        emit Mint(_to, _value);
        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}

contract SampleTokenSale {
    SampleToken public tokenContract;
    uint256 public tokenPrice;
    address owner;

    uint256 public tokensSold;
    uint256 previousStep;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        previousStep = 0;
    }

    function checkApproval() public view returns (uint256){
        return tokenContract.allowance(
            owner, 
            address(this));
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value >= _numberOfTokens * tokenPrice);

        uint256 returnValue = msg.value - (_numberOfTokens * tokenPrice);
        tokensSold += _numberOfTokens;
        uint256 oldValue = previousStep;
        previousStep = tokensSold / 10000;

        // this check could be wrong
        if(checkApproval() != 0) {
            require(tokenContract.balanceOf(address(owner)) >= _numberOfTokens);
            require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens));
        }
        else {
            require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
            require(tokenContract.transfer(msg.sender, _numberOfTokens));
        }

        if(previousStep > oldValue) {
            tokenContract.mint(owner, previousStep - oldValue);
        }

        if(returnValue > 0) {
            payable(msg.sender).transfer(returnValue);
        }

        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        require(msg.sender == owner);

        payable(msg.sender).transfer(address(this).balance);
    }

    function changePrice(uint256 _value) public {
        require(msg.sender == owner);

        tokenPrice = _value;
    }
}

contract Auction {
    SampleToken public tokenContract;

    address payable internal auction_owner;
    uint256 public auction_start;
    uint256 public auction_end;
    uint256 public highestBid;
    address public highestBidder;
 

    enum auction_state{
        CANCELLED,STARTED
    }

    struct  car{
        string  Brand;
        string  Rnumber;
    }
    
    car public Mycar;
    address[] bidders;

    mapping(address => uint) public bids;

    auction_state public STATE;


    modifier an_ongoing_auction() {
        require(block.timestamp <= auction_end && STATE == auction_state.STARTED);
        _;
    }
    
    modifier only_owner() {
        require(msg.sender==auction_owner);
        _;
    }
    
    function bid(uint _tokensBid) public virtual payable returns (bool) {}
    function withdraw() public virtual returns (bool) {}
    function cancel_auction() external virtual returns (bool) {}
    
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);  
    event AutoWithdrawalEvent(address withdrawer, uint256 amount);
}

contract MyAuction is Auction {  
    constructor (SampleToken _tokenContract, uint _biddingTime, address payable _owner, string memory _brand, string memory _Rnumber) {
        tokenContract = _tokenContract;

        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime*1 hours;
        STATE = auction_state.STARTED;
        Mycar.Brand = _brand;
        Mycar.Rnumber = _Rnumber;
    } 
    
    function get_owner() public view returns(address) {
        return auction_owner;
    }
    
    function bid(uint _tokensBid) public payable an_ongoing_auction override returns (bool) {
        require(bids[msg.sender] == 0, "You already placed a Bid");
        require(_tokensBid > highestBid, "You can't bid, Make a higher Bid");

        highestBidder = msg.sender;
        highestBid = _tokensBid;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;

        tokenContract.transferFrom(msg.sender, address(this), _tokensBid);
        emit BidEvent(highestBidder,  highestBid);

        return true;
    } 
    
    function cancel_auction() external only_owner an_ongoing_auction override returns (bool) {
        STATE = auction_state.CANCELLED;

        emit CanceledEvent("Auction Cancelled", block.timestamp);
        
        return true;
    }
    
    function withdraw() public override returns (bool) {   
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't withdraw, the auction is still open");
        require(msg.sender != highestBidder, "The winner cannot withdraw his offer");
        uint amount;

        amount = bids[msg.sender];
        bids[msg.sender] = 0;
        
        tokenContract.transfer(msg.sender, amount);
        emit WithdrawalEvent(msg.sender, amount);
        
        return true;
    }

    function withdraw_winnings() public only_owner returns (bool) {
        bids[highestBidder] = 0;

        tokenContract.transfer(auction_owner, highestBid);
        emit WithdrawalEvent(auction_owner, highestBid);
        
        return true;
    }
    
    function destruct_auction() external only_owner returns (bool) {     
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED, "You can't destruct the contract, The auction is still open");
        
        for(uint i = 0; i < bidders.length; i++)
        {
            address withdrawer = bidders[i];
            uint amount = bids[bidders[i]];

            tokenContract.transfer(withdrawer, amount);
            emit AutoWithdrawalEvent(withdrawer, amount);
        }

        selfdestruct(auction_owner);

        return true;
    } 

    fallback () external payable {
        
    }
    
    receive () external payable {
        
    }
}