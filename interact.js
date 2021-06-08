const { ethers } = require('ethers');
const BookLibrary = require('./build/BookLibrary.json');
const TOKEN = require('./build/LibToken.json');
const WRAPPER = require('./build/LIBWrapper.json');

const run = async function() {
	const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
    const wallet = new ethers.Wallet("0x7ab741b57e8d94dd7e1a29055646bafde7010f38a900f55bbd7647880faa6ee8", provider);
	const bookLibAddress = '0x214EF3FDcF79800E49744De20E38fa77de11eD12';
	const wrapperAddress = '0x2fa72DaDB0De5De164E316E074B7A7bb2EEbd354';

	const bookLibContract = new ethers.Contract(bookLibAddress, BookLibrary.abi, wallet);

	const tokenAddress = await bookLibContract.LIBToken();
	const tokenContract = new ethers.Contract(tokenAddress, TOKEN.abi, wallet);
	const wrapperContract = new ethers.Contract(wrapperAddress, WRAPPER.abi, wallet);
    const wrapValue = ethers.utils.parseEther("10");

	// let userBalance = await tokenContract.balanceOf(wallet.address);
	// console.log("User balance is: ", userBalance.toString());

	// let bookLibBalance = await tokenContract.balanceOf(bookLibAddress);
	// console.log("bookLibBalance balance is: ", bookLibBalance.toString());

	// await wrapperContract.wrap({value: wrapValue});

	// userBalance = await tokenContract.balanceOf(wallet.address);
	// console.log("User balance is: ", userBalance.toString());

	// await tokenContract.approve(bookLibAddress, wrapValue);
	// const allowance = await tokenContract.allowance(wallet.address, bookLibAddress);
	// console.log('Book lib allowance ', allowance.toString());

	// const addBookTransaction = await bookLibContract.addBook('Lord', 1);
	// await addBookTransaction.wait();

	// const rentABookTransaction = await bookLibContract.borrowBook('Lord');
	// await rentABookTransaction.wait();

	// userBalance = await tokenContract.balanceOf(wallet.address);
	// console.log("User balance is: ", userBalance.toString());

	// bookLibBalance = await tokenContract.balanceOf(bookLibAddress);
	// console.log("bookLibBalance balance is: ", bookLibBalance.toString());

	// const returnBook = await bookLibContract.returnBook('Lord', 1);
	// await returnBook.wait();

	// const withdrawT = await bookLibContract.withdrawLibraryAmount();
	// await withdrawT.wait();

	// userBalance = await tokenContract.balanceOf(wallet.address);
	// console.log("User balance is: ", userBalance.toString());

	// bookLibBalance = await tokenContract.balanceOf(bookLibAddress);
	// console.log("bookLibBalance balance is: ", bookLibBalance.toString());

	////////////////////////

	// 1. Add Book
	// const addBookTransaction = await bookLibContract.addBook('Lord', 1);
	// await addBookTransaction.wait();

	// 2. Checks all stored books
	// let storedBooks = await bookLibContract.getStoredBooks();
	// console.log("Stored Books", storedBooks);

	// // 3. Borrow a book
	// const rentABookTransaction = await bookLibContract.borrowBook('Lord');
	// await rentABookTransaction.wait();

	// 2. Checks all stored books
	// storedBooks = await bookLibContract.getStoredBooks();
	// console.log("Stored Books", storedBooks);

	// 5. Checks the availability of the book
	// const isAvailable = await bookLibContract.isAvailable('Lord');
	// console.log("Is the book Available", isAvailable);

	// 6. Returns a book
	// const returnBook = await bookLibContract.returnBook('Lord', 1);
	// await returnBook.wait();

	// 2. Checks all stored books
	storedBooks = await bookLibContract.getStoredBooks();
	console.log("Stored Books", storedBooks);

	// const book = await bookLibContract.getBook('Lord');
	// console.log('Book', book);

	// const borrowers = await bookLibContract.getBorrowers('Lord');
	// console.log(borrowers);
}

run();