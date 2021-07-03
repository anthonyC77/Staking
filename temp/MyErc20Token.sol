// ERC20Token.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyErc20Token is ERC20 {
constructor(uint256 initialSupply, string memory nameMoney, string memory nameCoin) public ERC20(nameMoney, nameCoin) {
    _mint(msg.sender, initialSupply);
 }
}