// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

//import "hardhat/console.sol";

abstract contract IDiplomasSignatures {
    function isCompletelySigned(address wallet)
        public
        view
        virtual
        returns (bool);
}

contract DiplomasNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _currentStudentId;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _totalMinted;

    struct Student {
        address _address;
        bool _eligible;
        bool _minted;
    }

    struct CheckId {
        uint256 _id;
        bool _isPresent;
    }

    uint256 _totalSupply; // number of students in the promo, determines

    mapping(address => CheckId) _studentsIds; // Maps student address to their id
    mapping(uint256 => Student) _students; // Maps id to a student struct

    IDiplomasSignatures private _signatures; // Interface for the DiplomasSignatures contract

    constructor(
        address diplomasSignatures,
        string memory school,
        string memory year
    ) ERC721(school, year) {
        _signatures = IDiplomasSignatures(diplomasSignatures);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function mintAll() public onlyOwner {
        for (uint256 i = 0; i < _currentStudentId.current(); i++) {
            if (_students[i]._minted || !_students[i]._eligible) continue;
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_students[i]._address, tokenId);
            _setTokenURI(
                tokenId,
                "QmRPQVTWYStrXin4p5WtLoh4ptdV4rn8fahgnQFDc7dVeu/"
            ); // TODO: change this
            _students[i]._minted = true;
            _totalMinted.increment();
        }
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function setTotalSupply(uint256 totalSupply) public onlyOwner {
        _totalSupply = totalSupply;
    }

    function addStudent(address student) public onlyOwner {
        require(
            !_studentsIds[student]._isPresent,
            "Duplicate address in students container"
        );

        uint256 tokenId = _currentStudentId.current();
        _students[tokenId] = Student(student, false, false);
        _studentsIds[student] = CheckId(tokenId, true);
        _currentStudentId.increment();
    }

    function setStudentValidity(address student, bool valid) public onlyOwner {
        _students[_studentsIds[student]._id]._eligible = valid;
    }

    function updateEligibility(address wallet) public returns (bool) {
        Student storage student = _students[_studentsIds[wallet]._id];
        student._eligible = _signatures.isCompletelySigned(wallet);
        return student._eligible;
    }

    // Getters

    function getTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getStudentValidity(address student) public view returns (bool) {
        return _students[_studentsIds[student]._id]._eligible;
    }

    function getStudentMint(address student) public view returns (bool) {
        return _students[_studentsIds[student]._id]._minted;
    }

    function isStudentAdded(address student) public view returns (bool) {
        return _studentsIds[student]._isPresent;
    }

    function getStudentCount() public view returns (uint256) {
        return _currentStudentId.current();
    }

    function getTotalMinted() public view returns (uint256) {
        return _totalMinted.current();
    }

    function getSignaturesAddress() public view returns (address) {
        return address(_signatures);
    }
}
