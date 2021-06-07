// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;
pragma abicoder v2;

import "./LIB.sol";

contract LIBWrapper {

	LIB public LIBToken;

	event LogLIBrapped(address sender, uint256 amount);
	event LogLIBnwrapped(address sender, uint256 amount);
	event LogETHWrapped(address receiver, uint256 amount);


	constructor() public {
		LIBToken = new LIB();
	}

	function wrap() public payable {
		require(msg.value > 0, "We need to wrap at least 1 wei");

		LIBToken.mint(msg.sender, msg.value);
		emit LogLIBrapped(msg.sender, msg.value);
	}

	function unwrap(uint value) public {
		require(value > 0, "We need to unwrap at least 1 wei");

		LIBToken.transferFrom(msg.sender, address(this), value); // returns the LIB from the userAddress to the TokenContract address
		LIBToken.burn(value); // removes them from the tokenContract
		msg.sender.transfer(value);
		emit LogLIBnwrapped(msg.sender, value);
	}

	function wrapWithSignature(bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s, address receiver) public payable {
		require(msg.value > 0, "We need to wrap at least 1 wei");
		require(recoverSigner(hashedMessage, v,r,s) == receiver, 'Receiver does not signed the message');
		LIBToken.mint(receiver, msg.value);
		emit LogETHWrapped(receiver, msg.value);
	}

	function recoverSigner(bytes32 hashedMessage, uint8 v, bytes32 r, bytes32 s) internal returns (address) {
		bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashedMessage));
    	return ecrecover(messageDigest, v, r, s);
	}
}