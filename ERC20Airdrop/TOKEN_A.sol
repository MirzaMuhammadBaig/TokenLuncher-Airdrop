// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TOKEN_A is ERC20 {
    constructor(uint256 initialSupply) ERC20("TOKEN_A", "TKA") {
        _mint(msg.sender, initialSupply);
    }
}
