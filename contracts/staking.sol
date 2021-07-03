// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.1;
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "./CrowdsaleERC20Chainlink.sol";

contract Staking {
     
    constructor(address crowdAddress) public {
      tokenANTC = new ERC20Chainlink('ANTMONEY', 'ANTC');
      crowd = CrowdsaleERC20Chainlink(crowdAddress);
    }  
     
    ERC20Chainlink public tokenANTC;
    AggregatorV3Interface internal priceFeed;
    IERC20 public ERC20Interface;
    uint public tempRewardsUSD;
    uint public tempRewards;
    uint public elapsedTime;
    CrowdsaleERC20Chainlink public crowd;
    
    mapping(address => staker) stakers;
    // gestion events
    // objet staker avec temps debut fin quantité contrat staking user 
    struct staker{
        uint startStaking;
        uint stopStaking;
        uint amount;
        uint amountReward;
        address chainlinkAddress;
        address tokenERC20Address;
        bool isStaking;
        bool unstaked;
    }
    
    event StakeToken(address user, address chainlinkAddress);
    event UnStakeToken(address user, address chainlinkAddress);
    event ErrorGetTheprice(bytes reason);
    
    // Public Functions
    
    // approve contract ERC20 with amount before by user to stake 
    function Stake(address chainlinkAddress, uint256 amount) external {
        // we could stake only one token by time for one user
        require(!stakers[msg.sender].isStaking, "You have already stake one token");
        
        if(stakers[msg.sender].unstaked){
            delete(stakers[msg.sender]);
        }
        
        distributeERC20(crowd.getAddressERC20(chainlinkAddress), amount);
        stakers[msg.sender] = staker(block.timestamp,0,amount, 0, chainlinkAddress,crowd.getAddressERC20(chainlinkAddress),true, false);
        emit StakeToken(msg.sender ,chainlinkAddress);
    } 
    
    // Approve token and then hive the calculated reward depending of time and price of the token staked
    function UnStake() external {  // pause
        stakers[msg.sender].stopStaking = block.timestamp;
        unstakeERC20();
        stakers[msg.sender].amountReward = CalculRewards();
        tokenANTC.approve(msg.sender, stakers[msg.sender].amountReward);
        approveContract();
        GiveRewards();
        stakers[msg.sender].unstaked = true;
        stakers[msg.sender].isStaking = false;
        emit UnStakeToken(msg.sender ,stakers[msg.sender].chainlinkAddress);
    } 
    
    // End Public Functions
    
    // Private Functions
    
    // to give rewards the house token must be approved 
    // to do get in the mapping object the amount of the reward
    function approveContract() internal{
        ERC20Chainlink(address(tokenANTC)).approve(address(this), stakers[msg.sender].amountReward);
    }
    
    function GetTokenANTCAddress() view external returns(address) {
      return address(tokenANTC);
    }
    
    function getTokenPrice(address chainlinkAddress) public view returns(uint){
        return crowd.getThePrice(chainlinkAddress);
    }
    
    // get the reward stored in stakers
    function getTokenRewardByUser() public view returns(uint){
        return stakers[msg.sender].amountReward;
    }
    
    function getDataUser() public view returns(staker memory) {
        return stakers[msg.sender];
    }

    // take the token sent by user to be staked 
    function distributeERC20(address tokenAddress, uint256 amount) internal {
        ERC20Chainlink(tokenAddress).approve(address(this), amount);
        ERC20Chainlink(tokenAddress).transferFrom(msg.sender,address(this), amount);
    }
    
    // unstaked the token to give it back to user
    function unstakeERC20() internal {  
        ERC20(stakers[msg.sender].tokenERC20Address).approve(msg.sender, stakers[msg.sender].amount);
        ERC20(stakers[msg.sender].tokenERC20Address).transferFrom(address(this), msg.sender, stakers[msg.sender].amount);  
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
    
    // send to the user the reward with the tokenANTC 
    function GiveRewards() internal {
        require(stakers[msg.sender].amountReward != 0, "Reward is not yet calculated");
        tokenANTC.transferFrom(address(this), msg.sender, stakers[msg.sender].amountReward);
    }
    
    function getRewardTime() internal view returns(uint) {
        // 10% for one year
        uint apy = SafeMath.div(SafeMath.mul(10, 1e18), 100);
        uint oneYearInSeconds = 30758400;
        uint elpasedTime = block.timestamp - stakers[msg.sender].startStaking;
        uint apyElapsedTime = SafeMath.div(SafeMath.mul(apy, elpasedTime), oneYearInSeconds);
        return apyElapsedTime;
    }
    
    // we call chainlink price for our token and intercept error since the token is not listed
    // by convention we sent 10 token for one USD
    function getOwnTokenUSDPrice() internal returns(uint){
        try crowd.getThePrice(address(tokenANTC)) returns(uint res){
            return res;
        }
        catch Error(string memory){
           return 10; 
        } catch (bytes memory reason) {
            emit ErrorGetTheprice(reason);
            return 10;
        }
    }
    
    // End private Functions
}