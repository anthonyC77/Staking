// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.1;
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './MyErc20Token.sol';
import './BankERC20.sol';

contract Staking {
       
     
    constructor() public {
      tokenANTC = new MyErc20Token(10000000000000000000000, 'ANTMONEY', 'ANTC');
    }  
     
    MyErc20Token public tokenANTC;
    AggregatorV3Interface internal priceFeed;
    IERC20 public ERC20Interface;
    uint public tempRewardsUSD;
    uint public tempRewards;
    uint public elapsedTime;
    
    mapping(address => staker) stakers;
    
    // objet staker avec temps debut fin quantité contrat staking user 
    struct staker{
        uint startStaking;
        uint stopStaking;
        uint amount;
        address contractMoney;
        uint amountReward;
    }
     
    function approveContract(address tokenAddress, uint256 amount ) external{
        MyErc20Token(tokenAddress).approve(address(this), amount);
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
   
    function UnStake(address bank) external {  // pause
        stakers[msg.sender].stopStaking = block.timestamp;
        unstakeERC20();
        stakers[msg.sender].amountReward = CalculRewards(bank);
        tokenANTC.approve(msg.sender, stakers[msg.sender].amountReward);
    }  
    
    function unstakeERC20() internal { // pause
        ERC20Interface = ERC20(stakers[msg.sender].contractMoney);  
        ERC20Interface.approve(msg.sender, stakers[msg.sender].amount);
        ERC20Interface.transferFrom(address(this), msg.sender, stakers[msg.sender].amount);  
    }

    function getPrice(address pairAdress) public view returns (uint) {
        if(pairAdress == 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e)
            return 184751000000;
        else 
            return 27689496448;
    }

    /*function getAdressToken(address bankAddress, address chainlinkAdress) external returns(address){
	   return BankERC20(bankAddress).getERC20Adress(chainlinkAdress);
    }*/
    
    function CalculRewards(address bankAddress) internal returns(uint) {
        uint256 priceMoneyUSD = BankERC20(bankAddress).getThePriceByErc20(stakers[msg.sender].contractMoney); // div 8 or decimals token
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
    
    // return the price of the amount staked in USD 
    function getUSDPriceOfTokenERC20Staked() internal returns(uint){ // lock
        priceFeed = AggregatorV3Interface(stakers[msg.sender].contractMoney);
        if(priceFeed.decimals() == 18) { // ETH
            // get value in USD from ETH
            getThePrice();
        }
        
        // return usd price of token staked
        return getThePrice();
    }
    
    function getOwnTokenUSDPrice() internal returns(uint){
        // call chainlink get error and set token by usd  example 20 by one usd
        priceFeed = AggregatorV3Interface(address(tokenANTC));
        // error return 10
        return 10;
    }
     
     /*function getThePrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }*/
    
    function getThePrice() public pure returns (uint) {
        return 1000;
    }
}