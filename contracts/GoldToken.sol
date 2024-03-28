pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// learn more: https://docs.openzeppelin.com/contracts/4.x/erc20

contract GoldToken is ERC20 {
	constructor() ERC20("Gold", "GLD") {
		_mint(address(msg.sender), 2000 * 10 ** 18);
	}
}
