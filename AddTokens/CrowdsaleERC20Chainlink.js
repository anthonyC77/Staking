const CrowdsaleERC20Chainlink = artifacts.require("./Contract/CrowdsaleERC20Chainlink.sol");

const CrowdsaleERC20ChainlinkInstance = await CrowdsaleERC20Chainlink.deployed();    
await CrowdsaleERC20ChainlinkInstance.receiveToken("0x568A188F6f9A0092FBCE936462575460b14D0fe1", { from: accounts[0] });
await CrowdsaleERC20ChainlinkInstance.createMoney("ChainLink","LINK", "0xd8bD0a1cB028a31AA859A21A3758685a95dE4623", { from: accounts[0] });
await CrowdsaleERC20ChainlinkInstance.createMoney("LiteCoin","LTC", "0x4d38a35C2D87976F334c2d2379b535F1D461D9B4", { from: accounts[0] });
await CrowdsaleERC20ChainlinkInstance.createMoney("SynthetixNetwork","SNX", "0xE96C4407597CD507002dF88ff6E0008AB41266Ee", { from: accounts[0] });
await CrowdsaleERC20ChainlinkInstance.createMoney("Tron","TRX", "0xb29f616a0d54FF292e997922fFf46012a63E2FAe", { from: accounts[0] });
await CrowdsaleERC20ChainlinkInstance.createMoney("Ripple","XRP", "0xc3E76f41CAbA4aB38F00c7255d4df663DA02A024", { from: accounts[0] });
await CrowdsaleERC20ChainlinkInstance.createMoney("0xCoin","ZRX", "0xF7Bbe4D7d13d600127B6Aa132f1dCea301e9c8Fc", { from: accounts[0] });
