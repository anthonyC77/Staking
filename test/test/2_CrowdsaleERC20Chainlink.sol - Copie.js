var CrowdsaleERC20Chainlink= artifacts.require("./CrowdsaleERC20Chainlink.sol");
var Staking= artifacts.require("./Staking.sol");

module.exports = async function(deployer) {
  await deployer.deploy(CrowdsaleERC20Chainlink);
  const crowdInstance = await CrowdsaleERC20Chainlink.deployed();
  
  module.exports = function(deployer) { 
	const StakingInstance = deployer.deploy(Staking, crowdInstance.address)
	.then(() => console.log(StakingInstance.address))
  };
};
