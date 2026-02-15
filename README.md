# On-Chain Orderbook DEX Core

This repository provides a high-performance, expert-level implementation of a Limit Order Book (LOB) designed for the Ethereum Virtual Machine (EVM). Unlike automated market makers (AMMs), this DEX uses a traditional matching engine approach.

### Features
* **Limit Orders:** Users can specify exact prices for buying or selling assets.
* **Partial Fills:** Orders are filled incrementally if matching liquidity is available at the target price.
* **Order Cancellation:** Secure logic to allow users to withdraw active orders before execution.
* **Gas-Optimized Storage:** Uses structured mappings to handle the order queue with minimal computational overhead.

### Technical Flow
1. **Deposit:** Users deposit ERC-20 tokens into the DEX balance.
2. **Submit Order:** A user places a Buy or Sell limit order at a specific price.
3. **Matching:** The contract iterates through the opposite side of the book to find compatible prices.
4. **Settlement:** Funds are transferred internally between the buyer and seller balances.

### License
MIT
