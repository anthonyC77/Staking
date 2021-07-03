// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
import './MyErc20Token.sol';
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract BankERC20 {  
  MyErc20Token public token;
  mapping(address => address) aggregToERC20;
  mapping(address => address) ERC20ToChainlink;
  mapping(address => AggregatorV3Interface) aggreg;
  
  constructor() public {
      AddToken(10000000000000000000000,'BINANCEToken','BNB', 0xcf0f51ca2cDAecb464eeE4227f5295F2384F84ED);
      AddToken(10000000000000000000000,'BraveToken','BAT', 0x031dB56e01f82f20803059331DC6bEe9b17F7fC9);
      AddToken(10000000000000000000000,'SyntheticNetwork','SNX', 0xE96C4407597CD507002dF88ff6E0008AB41266Ee);
      AddToken(100000000,'Etherum','ETH', 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
  }  
  
   function AddToken(uint256 amount,string memory moneyName, string memory coinName, address chainlinkAddress) public{
        MyErc20Token tokenToTrade = new MyErc20Token(amount,moneyName,coinName);
        fillAggreg(chainlinkAddress,address(tokenToTrade));
    }
    
    function fillAggreg(address chainlinkAddress, address erc20Address) internal{
        aggreg[chainlinkAddress] = AggregatorV3Interface(chainlinkAddress);
        aggregToERC20[chainlinkAddress] = erc20Address;
        ERC20ToChainlink[erc20Address] = chainlinkAddress;
    }
     
   function getERC20Adress(address chainlinkAddress) view public returns(address){
        return(aggregToERC20[chainlinkAddress]);
   }
   
  function receiveToken(address chainlinkAddress) external payable {
       address tokenAddress = aggregToERC20[chainlinkAddress];
       uint256 val = SafeMath.div(SafeMath.mul(getThePrice(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e),1e8), getThePrice(chainlinkAddress));
       uint256 amount = msg.value * val;
       amount = SafeMath.div(amount,1e8);
       distribute(msg.sender, amount, tokenAddress);
  }

  function distribute(address to, uint256 amount, address tokenAddress) internal {
       require(msg.value >= 0.1 ether, "you can't sent less than 0.1 ether");
       
       ERC20(tokenAddress).transfer(to, amount);
  }
  
  /*function getThePrice(address chainlinkAddress) public view returns (uint) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = aggreg[chainlinkAddress].latestRoundData();
        return uint(price);
    }*/
    
    // ERC20ToChainlink[erc20Address]
    function getThePriceByErc20(address erc20Address) public view returns (uint) {
        return getThePrice(ERC20ToChainlink[erc20Address]);
    }
    
    function getThePrice(address pairAdress) public view returns (uint) {
        if(pairAdress == 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e)
            return 184751000000;
        else 
            return 27689496448;
    }
  
}