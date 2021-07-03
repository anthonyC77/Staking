const CrowdsaleERC20Chainlink = artifacts.require("./Contract/CrowdsaleERC20Chainlink.sol");
const { BN, ether } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const {expectRevert} = require('@openzeppelin/test-helpers');


contract("CrowdsaleERC20Chainlink", accounts => {
  const BNBAdress = "0xcf0f51ca2cDAecb464eeE4227f5295F2384F84ED";
	
  beforeEach(async function () {
	this.CrowdsaleERC20ChainlinkInstance = await CrowdsaleERC20Chainlink.deployed();
  });
	
  it("getAddressERC20 BNB is not 0x0...", async () => {
    const CrowdsaleERC20ChainlinkInstance = await CrowdsaleERC20Chainlink.deployed();
	const data = await StakingInstance.getAddressERC20(BNBAdress,{ from: user });
    expect(data != "0x0000000000000000000000000000000000000000").to.be.true;
  });
  
  it("getThePrice BNB is not 0", async () => {
    const CrowdsaleERC20ChainlinkInstance = await CrowdsaleERC20Chainlink.deployed();
	const data = await StakingInstance.getThePrice(BNBAdress,{ from: user });
    expect(data != 0).to.be.true;
  });
  
  it("receiveToken BNB", async () => {
    const CrowdsaleERC20ChainlinkInstance = await CrowdsaleERC20Chainlink.deployed();
	await CrowdsaleERC20ChainlinkInstance.receiveToken(BNBAdress, 10, { from: user });
	const balance = CrowdsaleERC20ChainlinkInstance.balanceOfToken(BNBAdress);
    expect(balance >= 10).to.be.true;
  });
  
});
