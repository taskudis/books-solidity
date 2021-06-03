const { ethers } = require('ethers');
const BookLibrary = require('./build/BookLibrary.json');

const run = async function() {
	const provider = new ethers.providers.InfuraProvider("ropsten", "40c2813049e44ec79cb4d7e0d18de173");
    const wallet = new ethers.Wallet("cb44501c75a77824a48a5b0a273ab4898dec507a5a901ca1d0dbe1f1cc4049d5", provider);
	const bookLibContract = new ethers.Contract("0x9662496e354849EeB5195512725925a448d06571", BookLibrary.abi, wallet);

	// 1. Add Book
	const addBookTransaction = await bookLibContract.addBook('Lord', 1);
	const addBookTransactionReceipt = await addBookTransaction.wait();

	if (addBookTransactionReceipt.status != 1) {
		console.log("Transaction was not successfull")
		return;
	}
	// 2. Checks all stored books
	const storedBooks = await bookLibContract.getStoredBooks();
	console.log("Stored Books", storedBooks);

	// 3. Borrow a book // TODO:: this throws an error?
	// VM Exception while processing transaction: invalid opcode ??
	// const rentABookTransaction = await bookLibContract.borrowBook('Lord of the rings');
	// const rentABookTransactionReceipt = await rentABookTransaction.wait();

	// if (rentABookTransactionReceipt.status != 1) {
	// 	console.log("Rent a book transaction was not successfull")
	// 	return;
	// }

	// 4. Checks all available books
	const availableBooks = await bookLibContract.getAvailableBooks();
	console.log("Available Books", availableBooks);

	// 5. Checks the availability of the book
	const isAvailable = await bookLibContract.isAvailable('Lord');
	console.log("Is the book Available", isAvailable);


	// 6. Returns a book
	const returnBook = await bookLibContract.returnBook('Lord', 2);
	const returnBookR = await returnBook.wait();

	if (returnBookR.status != 1) {
		console.log("Rent a book transaction was not successfull");
		return;
	}

	const storedBooksAfterReturn = await bookLibContract.getStoredBooks();
	console.log("Stored Books after return", storedBooksAfterReturn);

}

run();