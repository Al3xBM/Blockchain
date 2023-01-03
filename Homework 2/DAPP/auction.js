var contractAddress = "0x86E9B8daDe985E5892001E29250C9dA41Ca90D25"; // Ganache

const ethEnabled = () => {
    // EIP-1193: Ethereum Provider JavaScript API  - https://eips.ethereum.org/EIPS/eip-1193
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      return true;
    }
    return false;
}
  
if (!ethEnabled()) {
      alert("Please install an Ethereum-compatible browser or extension like MetaMask to use this dApp!");
}  

window.onload = async function init() {

    // RPC methods https://eips.ethereum.org/EIPS/eip-1474
    // https://docs.metamask.io/guide/getting-started.html#connecting-to-metamask
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    window.bidder = accounts[0];
    console.log(accounts);
    
    //web3.eth.defaultAccount = bidder;
    var myauctionContractABI = [{"inputs":[{"internalType":"uint256","name":"_biddingTime","type":"uint256"},{"internalType":"address payable","name":"_owner","type":"address"},{"internalType":"string","name":"_brand","type":"string"},{"internalType":"string","name":"_Rnumber","type":"string"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"highestBidder","type":"address"},{"indexed":false,"internalType":"uint256","name":"highestBid","type":"uint256"}],"name":"BidEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"message","type":"string"},{"indexed":false,"internalType":"uint256","name":"time","type":"uint256"}],"name":"CanceledEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"withdrawer","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"WithdrawalEvent","type":"event"},{"stateMutability":"payable","type":"fallback"},{"inputs":[],"name":"Mycar","outputs":[{"internalType":"string","name":"Brand","type":"string"},{"internalType":"string","name":"Rnumber","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"STATE","outputs":[{"internalType":"enum Auction.auction_state","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"auction_end","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"auction_start","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"indexed":false,"internalType":"uint256","name":"_tokensBid","type":"uint256"}],"name":"bid","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"bids","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"cancel_auction","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"destruct_auction","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"get_owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"highestBid","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"highestBidder","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"withdraw","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}];

    window.auction = new web3.eth.Contract(myauctionContractABI, contractAddress);
      
    auction.methods.auction_end().call().then(function(endTimestamp){
        const tsMs = endTimestamp * 1000; // convert to ms
        const endDate = new Date(tsMs);
        document.getElementById("auction_end").innerHTML=endDate.toLocaleString();
    });

    auction.methods.highestBidder().call().then(function(result){
        document.getElementById("HighestBidder").innerHTML=result;
    }); 
    
    auction.methods.highestBid().call().then(function(result){
        var bidEther = result; // web3.utils.fromWei(result, 'ether');
        document.getElementById("HighestBid").innerHTML=bidEther;
    }); 
    
    auction.methods.STATE().call().then(function(result){
        document.getElementById("STATE").innerHTML=result;
    }); 

	auction.methods.Mycar().call().then(function(result){
        document.getElementById("car_brand").innerHTML= result[0];
        document.getElementById("registration_number").innerHTML= result[1];
    }); 

    auction.methods.bids(bidder).call().then(function(result){
        var bidEther = result; // web3.utils.fromWei(result, 'ether');
        document.getElementById("MyBid").innerHTML=bidEther;
    }); 
   
    var auction_owner=null;
    auction.methods.get_owner().call().then(function(result){
                auction_owner=result;
                console.log(result);
                if(bidder.toLowerCase()!=auction_owner.toLowerCase())
                    $("#auction_owner_operations").hide();
            }
    ); 
   
   
auction.getPastEvents('BidEvent', {
    fromBlock: 0,
    toBlock: 'latest'
}, function(error, events){ console.log(events); })
.then(function(bidEvents){
  bidEvents.forEach((bidEvent) => {
   $("#eventslog").append(bidEvent.returnValues.highestBidder + ' has bidden(' + bidEvent.returnValues.highestBid  + ' TOK)<br>');
  })
});
    
    /*filter.get(callback): Returns all of the log entries that fit the filter.
    filter.watch(callback): Watches for state changes that fit the filter and calls the callback. See this note for details.*/
    var BidEvent = auction.events.BidEvent(
        {
            filter: {
                fromBlock: 0,
                toBlock: 'latest',
                address: contractAddress,
                topics: [web3.utils.sha3('BidEvent(address,uint256)')]
            }
        },
        function(error, result){
            if (!error) {
                console.log(result);
                $("#eventslog").append(result.returnValues.highestBidder + ' has bidden(' + result.returnValues.highestBid + ' TOK) <br>');
            } else {
                console.log(error);
            }
        }
    ).on('data', function(event){
       $("#eventslog").append(result.returnValues.highestBidder + ' has bidden(' + result.returnValues.highestBid + ' TOK) <br>');
      console.log(event); // same results as the optional callback above
    }); 

        
    var CanceledEvent = auction.events.CanceledEvent(
        function(error, result){
            if (!error) {
                console.log(result);
                $("#eventslog").html(result.returnValues.message+' at '+result.returnValues.time);
            } else {
                console.log(error);
            }
        }
    );
}  


//alternative to ethereum.request({ method: 'eth_requestAccounts' });
ethereum.on('accountsChanged', function (accounts) {
    window.bidder = accounts[0];
});

document.getElementById("bid_button").onclick = function bid() {
    var mybid = document.getElementById('value').value;
    // Automatically determines the use of call or sendTransaction based on the method type
    auction.methods.bid(mybid).send(
        {
            from: window.bidder,
            value: 0, // web3.utils.toWei(mybid, "ether"), 
            gas: 200000
        }, 
        function(result, result){
            if(!error) {
                document.getElementById("biding_status").innerHTML="Think to bidding higher"; 
            }
            if (result)
                document.getElementById("biding_status").innerHTML="Successfull bid"; 
        }
    );
} 
	
document.getElementById("cancel_button").onclick = function cancel_auction(){
    auction.methods.cancel_auction().send(
    {
        from: window.bidder
    },
    function(error, result){
        console.log(result);
    }); 
}

document.getElementById("destruct_button").onclick = function Destruct_auction(){
    auction.methods.destruct_auction().send(
    {
        from: window.bidder
    },
    function(error, result){
        console.log(result);
    }); 
}