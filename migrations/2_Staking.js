var Staking= artifacts.require("./Staking.sol");
var CrowdsaleERC20Chainlink = artifacts.require("./CrowdsaleERC20Chainlink.sol");

module.exports = function(deployer) {
    deployer.then(async () => {        
        await deployer.deploy(CrowdsaleERC20Chainlink);
        await deployer.deploy(Staking, CrowdsaleERC20Chainlink.address);	
	
    });
};