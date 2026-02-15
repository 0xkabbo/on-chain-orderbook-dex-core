// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract OrderBook is ReentrancyGuard {
    enum Side { Buy, Sell }

    struct Order {
        uint256 id;
        address trader;
        Side side;
        uint256 amount;
        uint256 price;
        uint256 filled;
    }

    uint256 public nextOrderId;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(uint256 => Order) public orders;

    event OrderPlaced(uint256 indexed id, address indexed trader, Side side, uint256 amount, uint256 price);
    event TradeExecuted(uint256 indexed buyId, uint256 indexed sellId, uint256 amount, uint256 price);

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;
    }

    function placeOrder(Side side, uint256 amount, uint256 price, address baseToken, address quoteToken) external nonReentrant {
        if (side == Side.Sell) {
            require(balances[msg.sender][baseToken] >= amount, "Insufficient base balance");
        } else {
            require(balances[msg.sender][quoteToken] >= (amount * price), "Insufficient quote balance");
        }

        uint256 orderId = nextOrderId++;
        orders[orderId] = Order(orderId, msg.sender, side, amount, price, 0);

        emit OrderPlaced(orderId, msg.sender, side, amount, price);
    }

    function matchOrders(uint256 takerOrderId, uint256 makerOrderId, address baseToken, address quoteToken) external nonReentrant {
        Order storage taker = orders[takerOrderId];
        Order storage maker = orders[makerOrderId];

        require(taker.side != maker.side, "Same side matching not allowed");
        require(taker.price == maker.price, "Price mismatch for simple match");

        uint256 takerRemaining = taker.amount - taker.filled;
        uint256 makerRemaining = maker.amount - maker.filled;
        uint256 fillAmount = takerRemaining < makerRemaining ? takerRemaining : makerRemaining;

        taker.filled += fillAmount;
        maker.filled += fillAmount;

        _settleTrade(taker, maker, fillAmount, baseToken, quoteToken);

        emit TradeExecuted(takerOrderId, makerOrderId, fillAmount, taker.price);
    }

    function _settleTrade(Order memory taker, Order memory maker, uint256 amount, address baseToken, address quoteToken) internal {
        address buyer = taker.side == Side.Buy ? taker.trader : maker.trader;
        address seller = taker.side == Side.Sell ? taker.trader : maker.trader;
        uint256 cost = amount * taker.price;

        balances[seller][baseToken] -= amount;
        balances[buyer][baseToken] += amount;

        balances[buyer][quoteToken] -= cost;
        balances[seller][quoteToken] += cost;
    }
}
