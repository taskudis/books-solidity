const { ethers } = require('ethers');
const BookLibrary = require('./build/BookLibrary.json');

const run = async function() {
	const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
    const wallet = new ethers.Wallet("0x7ab741b57e8d94dd7e1a29055646bafde7010f38a900f55bbd7647880faa6ee8", provider);
	const bookLibContract = new ethers.Contract("0xc9707E1e496C12f1Fa83AFbbA8735DA697cdBf64", BookLibrary.abi, wallet);

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