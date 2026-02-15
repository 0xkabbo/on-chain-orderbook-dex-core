const hre = require("hardhat");

async function main() {
  const OrderBook = await hre.ethers.getContractFactory("OrderBook");
  const dex = await OrderBook.deploy();

  await dex.waitForDeployment();
  console.log(`OrderBook DEX deployed to: ${await dex.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
