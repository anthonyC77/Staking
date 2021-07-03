// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./ERC20Chainlink.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract CrowdsaleERC20Chainlink {  
  
  mapping(address => bool) mappChainlinkAddress;
  mapping(address => address) pairAddress;
  
  // to init some moneys of chainlink 
  function init() external{
      createMoney("Etherum","ETH", 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
      createMoney("BraveToken","BAT", 0x031dB56e01f82f20803059331DC6bEe9b17F7fC9);
      createMoney("BinanceCoin","BNB", 0xcf0f51ca2cDAecb464eeE4227f5295F2384F84ED);
      createMoney("ChainLink","LINK", 0xd8bD0a1cB028a31AA859A21A3758685a95dE4623);
      createMoney("LiteCoin","LTC", 0x4d38a35C2D87976F334c2d2379b535F1D461D9B4);
      createMoney("SynthetixNetwork","SNX", 0xE96C4407597CD507002dF88ff6E0008AB41266Ee);
      createMoney("Tron","TRX", 0xb29f616a0d54FF292e997922fFf46012a63E2FAe);
      createMoney("Ripple","XRP", 0xc3E76f41CAbA4aB38F00c7255d4df663DA02A024);
      createMoney("0xCoin","ZRX", 0xF7Bbe4D7d13d600127B6Aa132f1dCea301e9c8Fc);
  }
  
  function createMoney(string memory name, string memory coinName, address chainlinkAddress) internal{
      require(!mappChainlinkAddress[chainlinkAddress], "Error this address is already defined");
      ERC20Chainlink link = new ERC20Chainlink(name, coinName);
      pairAddress[chainlinkAddress] = address(link);
      mappChainlinkAddress[chainlinkAddress] = true;
  }
  
  function getAddressERC20(address chainlinkAddress) public view returns(address){
      return pairAddress[chainlinkAddress];
  }
  
  // Calcultate with the ETH sent the price of ETH and the price of token how many tokens we will have
  function getAmountWithEtherSent(address chainlinkAddress) internal returns(uint256){
      uint256 val = SafeMath.div(SafeMath.mul(getThePrice(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e),1e8), getThePrice(chainlinkAddress));
      uint256 amount = msg.value * val;
      amount = SafeMath.div(amount,1e8);
      return amount;
  }
  
  // buy with ether an amountof the chainlink token 
  function receiveToken(address chainlinkAddress, uint256 amount) external payable {
       require(mappChainlinkAddress[chainlinkAddress], "Error this address is not already defined");
       uint256 amountWithETH = getAmountWithEtherSent(chainlinkAddress);
       // to verify there is enough eth sent
       require(amountWithETH + 100000000000 > amount);
       distribute(msg.sender, amount, pairAddress[chainlinkAddress] );
  }
  
  function distribute(address to, uint256 amount, address tokenAddress) internal {
       require(msg.value >= 0.1 ether, "you can't sent less than 0.1 ether");
       ERC20(tokenAddress).transfer(to, amount);
  }
  
  function balanceOfToken(address chainlinkAddress) external view returns(uint256){
      address tokenAddress = getAddressERC20(chainlinkAddress);
      return ERC20(tokenAddress).balanceOf(msg.sender);
  }
  
  function getThePrice(address chainlinkAddress) public view returns (uint) {
       AggregatorV3Interface agg = AggregatorV3Interface(chainlinkAddress);
        (uint80 roundID,int price,uint startedAt,uint timeStamp,uint80 answeredInRound) = agg.latestRoundData();
        return uint(price);
  }
}