const { expect } = require("chai");
const { ethers, web3 } = require("hardhat");
const { parseEther } = require("ethers/lib/utils");
const { BigNumber } = require("ethers");
const { time } = require("@openzeppelin/test-helpers");
const AWETH = require("./aweth.json");


describe("Bank Deposit", function () {

  const AWETH_ADDRESS = "0x030bA81f1c18d280636F32af80b9AAd02Cf0854e";

  let theBank;
  let deployer;
  let bob;
  let alice;
  let aweth;

  beforeEach(async function () {
    [deployer, bob, alice] = await ethers.getSigners();
    const bankContractFactory = await ethers.getContractFactory("TheBank");
    theBank = await bankContractFactory.deploy();
    aweth = new ethers.Contract(AWETH_ADDRESS, AWETH.abi, bob);
  });

  it("Deposit into Compound", async function () {
    console.log("\n", "---Bob deposits 100 ETH---");
    await theBank.connect(bob).depositIntoCompound({ value: parseEther("100") });
    console.log("\n", "---Alice deposits 100 ETH---");
    await theBank.connect(alice).depositIntoCompound({ value: parseEther("100") });
    console.log("\n", "---Bob deposits 50 ETH---");
    await theBank.connect(bob).depositIntoCompound({ value: parseEther("50") });
  });

  it.only("Withdraw from Compound", async function () {
    let accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
    console.log("\n", "---Bob deposits 100 ETH---");
    await theBank.connect(bob).depositIntoCompound({ value: parseEther("100") });
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);

    console.log("\n", "---Alice deposits 50 ETH---");
    await theBank.connect(alice).depositIntoCompound({ value: parseEther("50") });
    let accountEthBalance1 = await ethers.provider.getBalance(alice.address);
    console.log("\n", "Alice's ETH balance: ", accountEthBalance1 / 1e18);

    // Waiting until 200 blocks have passed
    const block = await web3.eth.getBlockNumber();
    await time.advanceBlockTo(block + 200);
    console.log("\n", "200 blocks passed...");

    console.log("\n", "---Bob withdraws 100 ETH---");
    await theBank.connect(bob).withdrawFromCompound(parseEther("100"));
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
    let bankBalance = await ethers.provider.getBalance(theBank.address);
    console.log("\n", "The Bank's ETH balance: ", bankBalance / 1e18);
  });

  it("Withdraw Max from Compound", async function () {
    let accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
    console.log("\n", "---Bob deposits 100 ETH---");
    await theBank.connect(bob).depositIntoCompound({ value: parseEther("100") });
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);

    console.log("\n", "---Alice deposits 50 ETH---");
    await theBank.connect(alice).depositIntoCompound({ value: parseEther("50") });
    let accountEthBalance1 = await ethers.provider.getBalance(alice.address);
    console.log("\n", "Alice's ETH balance: ", accountEthBalance1 / 1e18);

    // Waiting until 200 blocks have passed
    const block = await web3.eth.getBlockNumber();
    await time.advanceBlockTo(block + 200);
    console.log("\n", "200 blocks passed...");

    console.log("\n", "---Bob withdraws max ETH---");
    await theBank.connect(bob).withdrawMaxFromCompound();
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
    let bankBalance = await ethers.provider.getBalance(theBank.address);
    console.log("\n", "The Bank's ETH balance: ", bankBalance / 1e18);
  });

  it("Deposit into Aave", async function () {
    console.log("\n", "---Bob deposits 100 ETH---");
    await theBank.connect(bob).depositIntoAave({ value: parseEther("100") });
    console.log("\n", "---Alice deposits 100 ETH---");
    await theBank.connect(alice).depositIntoAave({ value: parseEther("100") });
    console.log("\n", "---Bob deposits 200 ETH---");
    await theBank.connect(bob).depositIntoAave({ value: parseEther("200") });
  });

  it("Withdraw from Aave", async function () {
    let accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
    console.log("\n", "---Bob deposits 100 ETH---");
    await theBank.connect(bob).depositIntoAave({ value: parseEther("100") });
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);

    // Waiting until 200 blocks have passed
    const block = await web3.eth.getBlockNumber();
    await time.advanceBlockTo(block + 200);
    console.log("\n", "200 blocks passed...");

    console.log("\n", "---Bob withdraws 100 ETH---");
    await theBank.connect(bob).withdrawFromAave(parseEther("100"));
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
  });

  it("Withdraw Max from Aave", async function () {
    let accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
    console.log("\n", "---Bob deposits 100 ETH---");
    await theBank.connect(bob).depositIntoAave({ value: parseEther("100") });
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);

    // Waiting until 200 blocks have passed
    const block = await web3.eth.getBlockNumber();
    await time.advanceBlockTo(block + 200);
    console.log("\n", "200 blocks passed...");

    console.log("\n", "---Bob withdraws max ETH---");
    await theBank.connect(bob).withdrawMaxFromAave();
    accountEthBalance = await ethers.provider.getBalance(bob.address);
    console.log("\n", "Bob's ETH balance: ", accountEthBalance / 1e18);
  });

  // it("Test", async function () {
  //   // await theBank.depositA({ value: parseEther("100") });
  //   const ethMantissa = 1e18;
  //   const blocksPerDay = 6570; // 13.15 seconds per block
  //   const daysPerYear = 365;

  //   let interestRate = await theBank.getAaveRate();
  //   interestRate = interestRate / 1e27;
  //   console.log(interestRate * 100);

  //   let cRate = await theBank.getCompoundRate();
  //   let apy = (((Math.pow((cRate / ethMantissa * blocksPerDay) + 1, daysPerYear))) - 1) * 100;
  //   console.log(`Supply APY for ETH ${apy} %`);


  // });

});
