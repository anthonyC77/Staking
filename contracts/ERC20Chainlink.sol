// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Chainlink is ERC20 {
    
    constructor(string memory nameMoney, string memory nameCoin) public ERC20(nameMoney, nameCoin) {
     _mint(msg.sender, 10000000000000000000000);
  }
}