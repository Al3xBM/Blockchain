How to run (din directorul DAPP):
npm install
npm start


For contract deployment, a local network was created using Ganache. Remix was then used to connect to this network and deploy the contracts.
Aside from changes concerning those so that the displayed values would be relative to the token used, and not ETH, changes were also made 
in auction.js to myauctionContractABI, line 25 and the send call to auction.methods.bid, line 124. These changes were made so that the call
to the bid method would match that of the contract itself, takine one parameter.
