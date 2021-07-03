// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.1;
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './MyErc20Token.sol';
import "./CrowdsaleERC20Chainlink.sol";

contract Staking {
     
    constructor() public {
      tokenANTC = new ERC20Chainlink('ANTMONEY', 'ANTC');
      crowd = new CrowdsaleERC20Chainlink();
    }  
     
    ERC20Chainlink public tokenANTC;
    AggregatorV3Interface internal priceFeed;
    IERC20 public ERC20Interface;
    uint public tempRewardsUSD;
    uint public tempRewards;
    uint public elapsedTime;
    CrowdsaleERC20Chainlink public crowd;
    
    mapping(address => staker) stakers;
    
    // objet staker avec temps debut fin quantité contrat staking user 
    struct staker{
        uint startStaking;
        uint stopStaking;
        uint amount;
        uint amountReward;
        address chainlinkAddress;
        address tokenERC20Address;
    }
    
    // to give rewards the house token must be approved 
    // to do get in the mapping object the amount of the reward
    function approveContract(address tokenAddress, uint256 amount ) external{
        MyErc20Token(tokenAddress).approve(address(this), amount);
    }
    
    // make internal and get from approve contract
    // to do make one call to unstake approve and give reward
    function getTokenRewardByUser() public view returns(uint){
        return stakers[msg.sender].amountReward;
    }
     
    // approve contract ERC20 with amount before by user to stake 
    function Stake(address chainlinkAddress, uint256 amount) external {
        // require only stake one money
        distributeERC20(crowd.getAddressERC20(chainlinkAddress), amount);
        require(stakers[msg.sender].startStaking == 0, "You have already stake one token");
        stakers[msg.sender] = staker(block.timestamp,0,amount, 0, chainlinkAddress,crowd.getAddressERC20(chainlinkAddress));
    } 
    
    function getDataUser() public view returns(staker memory) {
        return stakers[msg.sender];
    }

    function distributeERC20(address tokenAddress, uint256 amount) internal {
        ERC20Interface = ERC20(tokenAddress);
        ERC20Interface.approve(address(this), amount);
        ERC20Interface.transferFrom(msg.sender,address(this), amount);
    }
   
    function UnStake() external {  // pause
        stakers[msg.sender].stopStaking = block.timestamp;
        unstakeERC20();
        stakers[msg.sender].amountReward = CalculRewards();
        tokenANTC.approve(msg.sender, stakers[msg.sender].amountReward);
    }  
    
    function unstakeERC20() internal { // pause
        ERC20Interface = ERC20(stakers[msg.sender].tokenERC20Address);  
        ERC20Interface.approve(msg.sender, stakers[msg.sender].amount);
        ERC20Interface.transferFrom(address(this), msg.sender, stakers[msg.sender].amount);  
    }
    
    function CalculRewards() internal returns(uint) {
        // get the price in USD of the ERC20 Token staked in the contract
        uint256 priceMoneyUSD = crowd.getThePrice(stakers[msg.sender].chainlinkAddress);
        // calcul the reward during the time of staking
        uint rewardUSD = SafeMath.mul(getRewardTime(), priceMoneyUSD);
        rewardUSD = SafeMath.mul(rewardUSD, stakers[msg.sender].amount);
        rewardUSD = SafeMath.div(rewardUSD, 1e18);
        rewardUSD = SafeMath.div(rewardUSD, 1e8);
        uint tokenReward = SafeMath.div(rewardUSD, getOwnTokenUSDPrice());
        return tokenReward;
    }
    
    function GiveRewards() external {
        require(stakers[msg.sender].amountReward != 0, "Reward is not yet calculated");
        tokenANTC.transferFrom(address(this), msg.sender, stakers[msg.sender].amountReward);
        delete stakers[msg.sender];
    }
    
    // reward for elpasedTime
    function getRewardTime() internal view returns(uint) {
        // 10% for one year
        uint apy = SafeMath.div(SafeMath.mul(10, 1e18), 100);
        uint oneYearInSeconds = 30758400;
        uint elpasedTime = block.timestamp - stakers[msg.sender].startStaking;
        uint apyElapsedTime = SafeMath.div(SafeMath.mul(apy, elpasedTime), oneYearInSeconds);
        return apyElapsedTime;
    }
    
    // call chainlink contract to have the price of my token
    // chainlink won't have it and through an exception
    // we send the value we want 
    function getOwnTokenUSDPrice() internal view returns(uint){
        try crowd.getThePrice(address(tokenANTC)) returns(uint res){
            return res;
        }
        catch Error(string memory){
           return 10; 
        } catch (bytes memory reason) {
            return 10;
        }
    }
}