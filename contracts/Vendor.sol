pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./GoldToken.sol";
import "hardhat/console.sol";

error Vendor__SendingTokensFailed(
	address buyer,
	uint256 amountOfETH,
	uint256 amountOfTokens
);

error Vendor__FailToWithdraw(address owner, uint256 amountOfETH);
error Vendor__FailedToTransferTokens(
	address userAddress,
	uint256 amountOfTokens
);
error Vendor__FailedToTransferETH(address userAddress, uint256 amountOfETH);
error Vendor__NoBalanceForBuyTokens();

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event WithdrawSuccess(address owner, uint256 amountOfETH);
	event SellTokens(
		address seller,
		uint256 amountOfETH,
		uint256 amountOfTokens
	);

	GoldToken public goldToken;
	uint256 public constant tokensPerEth = 100;

	constructor(address tokenAddress) {
		goldToken = GoldToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		uint256 amountOfETH = msg.value;
		uint256 amountOfToken = (amountOfETH * tokensPerEth) *
			(10 ** goldToken.decimals() / 10 ** 18);
		bool success = goldToken.transfer(address(msg.sender), amountOfToken);
		if (!success) {
			revert Vendor__SendingTokensFailed(
				address(msg.sender),
				amountOfETH,
				amountOfToken
			);
		}
		emit BuyTokens(address(msg.sender), amountOfETH, amountOfToken);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public payable onlyOwner {
		uint256 balance = address(this).balance;
		(bool success, ) = address(msg.sender).call{ value: balance }("");
		if (!success) {
			revert Vendor__FailToWithdraw(msg.sender, balance);
		}
		emit WithdrawSuccess(msg.sender, balance);
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 amount) public {
		uint256 amountOfETH = (amount / tokensPerEth) *
			(10 ** 18 / 10 ** goldToken.decimals());
		if (address(this).balance < amountOfETH) {
			revert Vendor__NoBalanceForBuyTokens();
		}
		bool transferSuccess = goldToken.transferFrom(
			msg.sender,
			address(this),
			amount
		);
		if (!transferSuccess) {
			revert Vendor__FailedToTransferTokens(msg.sender, amount);
		}
		(bool success, ) = address(msg.sender).call{ value: amountOfETH }("");
		if (!success) {
			revert Vendor__FailedToTransferETH(msg.sender, amountOfETH);
		}
		emit SellTokens(msg.sender, amountOfETH, amount);
	}
}
