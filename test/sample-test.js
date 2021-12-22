const chai = require('chai')
const expect = chai.expect
chai.use(require('chai-as-promised'))
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });


});

describe("IPFSCidTimeInfoMapping", function () {

  let contract;
  let minterRoleSymbol;
  let owner;
  let manager;
  let cidForTest = 'bafybeidw4gt6i3liupy7ytcmi62cu4uazk5gwp4pjo7kivo57ldpts4u2m';


  it("Grant MINTER_ROLE to new manager.", async function () {
    const IPFSCidTimeInfoMapping = await ethers.getContractFactory("IPFSCidTimeInfoMapping");
    contract = await IPFSCidTimeInfoMapping.deploy();
    await contract.deployed();

    minterRoleSymbol = await contract.MINTER_ROLE();
    let signers = await ethers.getSigners();

    owner = signers[0];
    manager = signers[1];

    await contract.grantRole(minterRoleSymbol, manager.address);
    const minterRoleStatus = await contract.connect(manager).hasRole(minterRoleSymbol, manager.address);
    expect(minterRoleStatus).to.equal(true);
  });

  it("Generate cid", async function () {
    await contract.connect(manager).mint(cidForTest);
    const mapping = await contract.cidTimeInfoMapping(cidForTest);
    console.log(`now timestamp`, ethers.utils.formatUnits(mapping.timestamp, 0));
    console.log(`now block`, ethers.utils.formatUnits(mapping.blockNumber, 0));
    expect(mapping.timestamp).to.be.above(0);
    expect(mapping.blockNumber).to.be.above(0);
  });

  it("Try generate cid again", async function () {
    const badFn = async function () {
      await contract.mint(cidForTest);
    };
    await expect(badFn()).to.be.rejectedWith(Error);
  });

  it("Delete cid mapping by admin", async function () {
    await contract.burn(cidForTest);
    const deletedMapping = await contract.cidTimeInfoMapping(cidForTest);
    expect(deletedMapping.timestamp).to.equal(0);
    expect(deletedMapping.blockNumber).to.equal(0);

  });

  it("Get time info from a null CID", async function () {
    const badFn = async function () {
      await contract.getCIDTimeInfo("notExistCID");
    };
    await expect(badFn()).to.be.rejectedWith(Error);
  });




});