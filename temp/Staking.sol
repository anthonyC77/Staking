// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.1;
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './MyErc20Token.sol';

contract Staking {
     
    constructor() public {
      tokenANTC = new MyErc20Token(10000000000000000000000,"ANTMONEY","ANTC");
      fillAggreg(0xcf0f51ca2cDAecb464eeE4227f5295F2384F84ED);
      fillAggreg(0xECe365B379E1dD183B20fc5f022230C044d51404);
    }  
    
    function fillAggreg(address pairAdress) internal{
        aggreg[pairAdress] = AggregatorV3Interface(pairAdress);
    }
     
    MyErc20Token public tokenANTC;
    AggregatorV3Interface internal priceFeed;
    IERC20 public ERC20Interface;
    uint public tempRewardsUSD;
    uint public tempRewards;
    uint public elapsedTime;
    
    mapping(address => staker) stakers;
    mapping(address => AggregatorV3Interface) aggreg;
    
    // objet staker avec temps debut fin quantité contrat staking user 
    struct staker{
        uint startStaking;
        uint stopStaking;
        uint amount;
        address contractMoney;
        uint amountReward;
    }
    
    function getPriceOfPair(address pairAddress) external returns(uint){
        priceFeed = AggregatorV3Interface(pairAddress);
        return getThePrice(pairAddress);
    }
     
    function approveContract(address tokenAddress, uint256 amount ) external{
        ERC20(tokenAddress).approve(address(this), amount);
    }
    
    function getTokenRewardByUser() public view returns(uint){
        return stakers[msg.sender].amountReward;
    }
     
    // approve contract ERC20 with amount before by user to stake 
    function Stake(address tokenAdress, uint256 amount) external {
        // require only stake one money
        distributeERC20(tokenAdress, amount);
        require(stakers[msg.sender].startStaking == 0, "You have already stake one token");
        stakers[msg.sender] = staker(block.timestamp,0,amount, tokenAdress,0);
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
        ERC20Interface = ERC20(stakers[msg.sender].contractMoney);  
        ERC20Interface.approve(msg.sender, stakers[msg.sender].amount);
        ERC20Interface.transferFrom(address(this), msg.sender, stakers[msg.sender].amount);  
    }
    
    function CalculRewards() internal returns(uint) {
        uint rewardUSD = SafeMath.mul(getRewardTime(), getUSDPriceOfTokenERC20Staked());
        tempRewardsUSD = rewardUSD;
        uint tokenReward = SafeMath.div(rewardUSD, getOwnTokenUSDPrice());
        tempRewards = tokenReward;
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
    
    // return the price of the amount staked in USD 
    function getUSDPriceOfTokenERC20Staked() internal returns(uint){ // lock
        priceFeed = AggregatorV3Interface(stakers[msg.sender].contractMoney);
        if(priceFeed.decimals() == 18) { // ETH
            // get value in USD from ETH
            getThePrice(stakers[msg.sender].contractMoney);
        }
        
        // return usd price of token staked
        return getThePrice(stakers[msg.sender].contractMoney);
    }
    
    function getOwnTokenUSDPrice() internal pure returns(uint){
        // call chainlink get error and set token by usd  example 20 by one usd
        return 10;
    }
     
     function getThePrice(address pairAdress) public view returns (uint) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = aggreg[pairAdress].latestRoundData();
        return uint(price);
    }
    
    /*function getThePrice() public pure returns (uint) {
        return 1000;
    }*/
}