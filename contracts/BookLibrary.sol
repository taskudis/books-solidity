// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BookLibrary is Ownable {

  struct Book {
      string id;
      uint8 count;
      bool exists;
      address[] borrowers;
  }

  uint256 booksCount = 0;

  Book[] public booksStored;
  mapping (string => Book) private books;

  function getStoredBooks () public view returns (Book[] memory) {
      return booksStored;
  }

  function addBook(string memory id, uint8 count) public onlyOwner {
      bool exists = books[id].exists;

      // If the book is not present in the mapping
      if (!exists) {
          // Create new book
          address[] memory borrowers;
          Book memory newBook = Book({
              id: id,
              count: count,
              exists: true,
              borrowers: borrowers
          });

          booksStored.push(newBook);
          books[id] = newBook;
      } else {
          // The book is present
          books[id].count += count;
      }

      booksCount += 1;
  }

  function borrowBook(string memory id) public {
      require(books[id].exists);
      require(books[id].count != 0);

      books[id].count -= 1;
      books[id].borrowers.push(msg.sender);

      // Update the booksStored array
      for (uint256 i = 0; i < booksStored.length; i++) {
          if (keccak256(abi.encodePacked((booksStored[i].id))) == keccak256(abi.encodePacked((id)))) {
              booksStored[i].count = books[id].count;
          }
      }
  }

  function returnBook(string memory id, uint8 count) public {
      require(books[id].exists);
      books[id].count += count;
      // Update the booksStored array
      for (uint256 i = 0; i < booksStored.length; i++) {
          if (keccak256(abi.encodePacked((booksStored[i].id))) == keccak256(abi.encodePacked((id)))) {
              booksStored[i].count = books[id].count;
          }
      }
  }

  function getBorrowers(string memory id) public view returns (address[] memory) {
      require(books[id].exists);

      return books[id].borrowers;
  }
}