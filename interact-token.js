const { ethers } = require("ethers");
const ETHWrapper = require('./build/ETHWrapper.json')
const WETH = require('./build/WETH.json');

const run = async function() {

	const providerURL = "http://localhost:8545";
	const walletPrivateKey = "0x7ab741b57e8d94dd7e1a29055646bafde7010f38a900f55bbd7647880faa6ee8";
	const wrapperContractAddress = "0x626A72d22809C6a1836A140340758171e6AaAB86";

	const provider = new ethers.providers.JsonRpcProvider(providerURL)
	const wallet = new ethers.Wallet(walletPrivateKey, provider)
	const wrapperContract = new ethers.Contract(wrapperContractAddress, ETHWrapper.abi, wallet)
	const wethAddress = await wrapperContract.WETHToken();
    const tokenContract = new ethers.Contract(wethAddress, WETH.abi, wallet);

    const wrapValue = ethers.utils.parseEther("1");
    const allowValue = ethers.utils.parseEther("2");
    const wrapTx = await wrapperContract.wrap({value: wrapValue});
	await wrapTx.wait();

	// let balance = await tokenContract.balanceOf(wallet.address)
	// console.log("Balance after wrapping:", balance.toString())

	// let contractETHBalance = await provider.getBalance(wrapperContractAddress);
	// console.log("Contract ETH balance after wrapping:", contractETHBalance.toString())

    // const approveTx = await tokenContract.approve(wrapperContractAddress, wrapValue)
	// await approveTx.wait()

	// const unwrapTx = await wrapperContract.unwrap(wrapValue)
	// await unwrapTx.wait()

	// balance = await tokenContract.balanceOf(wallet.address)
	// console.log("Balance after unwrapping:", balance.toString())

	// contractETHBalance = await provider.getBalance(wrapperContractAddress);
	// console.log("Contract ETH balance after unwrapping:", contractETHBalance.toString())

    // - Allow the users to send ETH to a contract and get back LIB in 1:1 relation (similar to wrapping).

	// send 1 ETH to the wrapper contract
	// const wrapValue = ethers.utils.parseEther("1");
	// - this is going to send 1 ETH to the wrapperContract
	// - this is going to mint 1 LIB to the address of the caller
    // const wrapTx = await wrapperContract.wrap({value: wrapValue})
	// await wrapTx.wait();

	// Check the LIB amount of the address of the caller it should be 1
	// let balance = await tokenContract.balanceOf(wallet.address)
	// console.log("Balance after wrapping:", balance.toString())

	// Check the Eth amount of the wrapper it should be 1
	// const contractETHBalance = await provider.getBalance(wrapperContractAddress);
	// console.log("Contract ETH balance after wrap:", contractETHBalance.toString());

	let contractLIBBalance = await tokenContract.balanceOf(wrapperContractAddress);
	console.log("Contract LIB balance before rent:", contractLIBBalance.toString());

	let userLIBBalance = await tokenContract.balanceOf(wallet.address);
	console.log("user LIB balance before rent:", userLIBBalance.toString());

	// Rent 1 LIB to the wrapperContract
	const allowTx = await tokenContract.approve(wrapperContractAddress, allowValue);
	const allowance = await tokenContract.allowance(wallet.address, wrapperContractAddress);
    const rentTx = await tokenContract.transferFrom( wallet.address ,wrapperContractAddress, wrapValue);
    // const rentTx = await tokenContract.transfer(wrapperContractAddress, wrapValue);
    // const rentTx = await wrapperContract.rent({value: wrapValue});
	await rentTx.wait();

	// // Check the LIB amount of the wrapper it should be + 1
	contractLIBBalance = await tokenContract.balanceOf(wrapperContractAddress);
	console.log("Contract LIB balance after rent:", contractLIBBalance.toString());

	userLIBBalance = await tokenContract.balanceOf(wallet.address);
	console.log("user LIB balance after rent:", userLIBBalance.toString());

	// This transfers ETH to the current account
	// require(msg.value > 0, "We need to unwrap at least 1 wei");
	// address(this).call{value: msg.value}("");

	// - Allow the library admin to convert the LIBs inside the library smart contract into ETH and withdraw them to their account

}

run()