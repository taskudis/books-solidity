// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;
pragma abicoder v2;

import "./WETH.sol";

contract ETHWrapper {

	WETH public WETHToken;

	event LogETHWrapped(address sender, uint256 amount);
	event LogETHUnwrapped(address sender, uint256 amount);

	constructor() public {
		WETHToken = new WETH();
	}

	function wrap() public payable {
		require(msg.value > 0, "We need to wrap at least 1 wei");
		WETHToken.mint(msg.sender, msg.value);
		emit LogETHWrapped(msg.sender, msg.value);
	}

	function unwrap(uint value) public {
		require(value > 0, "We need to unwrap at least 1 wei");
		WETHToken.transferFrom(msg.sender, address(this), value); // returns the LIB from the userAddress to the TokenContract address
		WETHToken.burn(value); // removes them from the tokenContract
		msg.sender.transfer(value);
		emit LogETHUnwrapped(msg.sender, value);
	}

	 function rent() public payable {
		// TODO:: this doesnt work
		// Transfers LIB from the caller to the wrapper contract
		WETHToken.approve(address(this), '2');
    	WETHToken.transferFrom(msg.sender, address(this), '1');
	}
}