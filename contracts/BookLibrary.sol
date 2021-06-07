// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LIBWrapper.sol";

contract BookLibrary is Ownable {
  IERC20 public LIBToken;
  LIBWrapper public LIBWrapperContract;

  address payable public wrapperAddress;
  uint public rent = 1000000000000;

  struct Book {
      string id;
      uint8 count;
      bool exists;
      address[] borrowers;
  }

  uint256 booksCount = 0;

  Book[] public booksStored;
  mapping (string => Book) private books;
  mapping (address => mapping (string => bool)) private userBooks;

  // Events
  event BookAdded(string name);
  event BookBorrowed(string name);
  event BookReturned(string name);

  constructor(address LIBTokenAddress, address payable LIBWrapperAddress) public {
    LIBToken = IERC20(LIBTokenAddress);
    LIBWrapperContract = LIBWrapper(LIBWrapperAddress);
    wrapperAddress = LIBWrapperAddress;
  }

  // Getters
  function getAvailableBooks() public view returns (Book[] memory) {
    require(booksCount != 0, "There are no saved books");
    // Count the available booksCount
    uint8 availableBooksCount = 0;
    for (uint8 i = 0; i < booksCount; i++) {
        if (booksStored[i].count != 0) {
            availableBooksCount++;
        }
    }

    // Create dynamic memory array
    Book[] memory dynamicMemoryArray = new Book[](availableBooksCount);
    uint8 counter = 0;
    for (uint8 i = 0; i < booksCount; i++) {
        if (booksStored[i].count != 0) {
            dynamicMemoryArray[counter] = booksStored[i];
            counter++;
        }
    }

    return dynamicMemoryArray;
  }

  function getStoredBooks () public view returns (Book[] memory) {
      return booksStored;
  }

  function getBorrowers(string memory id) public view returns (address[] memory) {
      require(books[id].exists, "The requested book doesn't exists !");
      return books[id].borrowers;
  }

  // Interactions
  function addBook(string memory id, uint8 count) public onlyOwner {
    bool exists = books[id].exists;

    // If the book is not present in the mapping
    if (!exists) {
      // Create new book
      address[] memory borrowers;
      Book memory newBook = Book({ id: id, count: count, exists: true, borrowers: borrowers });

      booksStored.push(newBook);
      books[id] = newBook;
      booksCount += 1;
    } else {
      // The book is present
      books[id].count += 1;

      // Update the booksStored array
      for (uint256 i = 0; i < booksStored.length; i++) {
        if (keccak256(abi.encodePacked((booksStored[i].id))) == keccak256(abi.encodePacked((id)))) {
            Book storage currentBook = booksStored[i];
            currentBook.count = books[id].count;
        }
      }
    }

    emit BookAdded(id);
  }

  function borrowBook(string memory id) public {
      require(books[id].exists, "Sorry the book doesn't exists yet !");
      require(books[id].count != 0, "Sorry there is not enough count of the book !");
      require(!userBooks[msg.sender][id], "Sorry the user has already borrowed one copy of the book");

      // The user must have allowance
      require(LIBToken.allowance(msg.sender, address(this)) >= rent, "Not enough LIB Token allowance !");
      require(LIBToken.balanceOf(msg.sender) > 0, "User balance is not enough to rent the book !");

      LIBToken.transferFrom(msg.sender, address(this), rent);

      // Update books mapping
      books[id].count -= 1;
      books[id].borrowers.push(msg.sender);

      // Update the booksStored array
      for (uint256 i = 0; i < booksStored.length; i++) {
          if (keccak256(abi.encodePacked((booksStored[i].id))) == keccak256(abi.encodePacked((id)))) {
              // Get the storage pointer of the Book
              Book storage currentBook = booksStored[i];
              currentBook.count = books[id].count;
              currentBook.borrowers = books[id].borrowers;
          }
      }

      // Add the book to the userBooks mapping
      userBooks[msg.sender][id] = true;
      emit BookBorrowed(id);
  }

  function withdrawLibraryAmount() public onlyOwner {
      uint256 libraryAmount = LIBToken.balanceOf(address(this));
      LIBToken.approve(wrapperAddress, libraryAmount);

      LIBWrapperContract.unwrap(libraryAmount);
  }

  function returnBook(string memory id, uint8 count) public {
      require(books[id].exists, "The user is trying to return a book which doesn't exist yet !");
      require(userBooks[msg.sender][id], "The user haven't rented that book !");

      // Update the books mapping
      books[id].count += count;

      // Update the booksStored array
      for (uint256 i = 0; i < booksStored.length; i++) {
          if (keccak256(abi.encodePacked((booksStored[i].id))) == keccak256(abi.encodePacked((id)))) {
              Book storage currentBook = booksStored[i];
              currentBook.count = books[id].count;
          }
      }

      // Remove the book from the userBooks mapping
      userBooks[msg.sender][id] = false;

      emit BookReturned(id);
  }

  // Flags
  function isAvailable(string memory id) public view returns (bool) {
    return books[id].count != 0;
  }

  function isRented(string memory id) public view returns (bool) {
    return userBooks[msg.sender][id];
  }

  // Fallbacks
  receive() external payable {}
}