// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LIBWrapper.sol";
import "./LIB.sol";

contract BookLibrary is Ownable {
  LIB public LIBToken;
  LIBWrapper public LIBWrapperContract;

  address payable public wrapperAddress;
  uint public rent = 1000000000000;

  struct Book {
      string id;
      uint8 count;
      bool exists;
      address[] borrowers;
  }

  string[] public booksStored;
  mapping (bytes32 => Book) private books;
  mapping (bytes32 => mapping (address => bool)) private userBooks; // turn it book > user > bool

  // Events
  event BookAdded(string name);
  event BookBorrowed(string name);
  event BookReturned(string name);

  constructor(address LIBTokenAddress, address payable LIBWrapperAddress) public {
    LIBToken = LIB(LIBTokenAddress);
    LIBWrapperContract = LIBWrapper(LIBWrapperAddress);
    wrapperAddress = LIBWrapperAddress;
  }

  // Getters
  function getStoredBooks () public view returns (string[] memory) {
      return booksStored;
  }

  function getBorrowers(string memory _id) public view returns (address[] memory) {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));
    require(books[bookHash].exists, "The requested book doesn't exists !");
    return books[bookHash].borrowers;
  }
  // Interactions
  function addBook(string memory _id, uint8 _count) public onlyOwner {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));
    bool exists = books[bookHash].exists;

    if (!exists) {
      address[] memory borrowers;
      Book memory newBook = Book({ id: _id, count: _count, exists: true, borrowers: borrowers });

      booksStored.push(_id);
      books[bookHash] = newBook;
    } else {
      books[bookHash].count += 1;
    }

    emit BookAdded(_id);
  }

  function borrowBook(string memory _id) public {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));

    require(books[bookHash].exists, "Sorry the book doesn't exists yet !");
    require(books[bookHash].count != 0, "Sorry there is not enough counts of the book !");
    require(!userBooks[bookHash][msg.sender], "Sorry the user has already borrowed one copy of the book");

    LIBToken.transferFrom(msg.sender, address(this), rent);

    books[bookHash].count -= 1;
    books[bookHash].borrowers.push(msg.sender);

    userBooks[bookHash][msg.sender] = true;
    emit BookBorrowed(_id);
  }

  function borrowBookBySignature(string memory _id, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));

    require(books[bookHash].exists, "Sorry the book doesn't exists yet !");
    require(books[bookHash].count != 0, "Sorry there is not enough count of the book !");
    require(!userBooks[bookHash][msg.sender], "Sorry the user has already borrowed one copy of the book");

    uint nonce = LIBToken.nonces(msg.sender);
    require( LIBToken.checkPermit(msg.sender, address(this), _value, _deadline, _v,_r,_s, nonce) == msg.sender, "The permit verification failed !");

    LIBToken.permit(msg.sender, address(this), _value, _deadline, _v,_r,_s);
		LIBToken.transferFrom(msg.sender, address(this), rent);

    books[bookHash].count -= 1;
    books[bookHash].borrowers.push(msg.sender);

    userBooks[bookHash][msg.sender] = true;
    emit BookBorrowed(_id);
  }

  function withdrawLibraryAmount() public onlyOwner {
      uint256 libraryAmount = LIBToken.balanceOf(address(this));
      LIBToken.approve(wrapperAddress, libraryAmount);

      LIBWrapperContract.unwrap(libraryAmount);
  }

  function returnBook(string memory _id, uint8 count) public {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));

    require(books[bookHash].exists, "The user is trying to return a book which doesn't exist yet !");
    require(userBooks[bookHash][msg.sender], "The user haven't rented that book !");

    books[bookHash].count += count;
    userBooks[bookHash][msg.sender] = false;

    emit BookReturned(_id);
  }

  function getBook(string memory _id) public view returns (Book memory) {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));
    require(books[bookHash].exists, "Sorry the book doesn't exists yet !");
    return books[bookHash];
  }
  // Flags
  function isAvailable(string memory _id) public view returns (bool) {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));

    return books[bookHash].count != 0;
  }

  function isRented(string memory _id) public view returns (bool) {
    bytes32 bookHash = keccak256(abi.encodePacked(_id));
    return userBooks[bookHash][msg.sender];
  }
  // Fallbacks
  receive() external payable {}
}