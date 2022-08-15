// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
@title InstitutionDegreeSigner
@author Charles Simon-Meunier
*/
abstract contract IInstitutionDegreeSigner {
    function isCompletelySigned(address wallet)
        public
        view
        virtual
        returns (bool);

    function initSignature(address wallet) public virtual;
}

contract InstitutionDegree is ERC721, ERC721URIStorage, Ownable {
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

    IInstitutionDegreeSigner private _signatures; // Interface for the EpitaDegreeSigner contract

    constructor(
        address diplomasSignatures,
        string memory school_name,
        string memory promo_name
    ) ERC721(school_name, promo_name) {
        _signatures = IInstitutionDegreeSigner(diplomasSignatures);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function claimDegree() public {
        require(_studentsIds[msg.sender]._isPresent, "You are not eligible to claim this degree");
        require(!_students[_studentsIds[msg.sender]._id]._minted, "You have already claimed your degree");
        require(_students[_studentsIds[msg.sender]._id]._eligible, "You are not eligible");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_students[_studentsIds[msg.sender]._id]._address, tokenId);
        _setTokenURI(
            tokenId,
            "QmRPQVTWYStrXin4p5WtLoh4ptdV4rn8fahgnQFDc7dVeu/"
        ); // TODO: change this
        _students[_studentsIds[msg.sender]._id]._minted = true;
        _totalMinted.increment();
    }

    function _burn(uint256)
        internal
        override(ERC721, ERC721URIStorage)
    {
       revert Soulbound();
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
        _signatures.initSignature(student);
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

    function updateStudentsEligibility() public onlyOwner {
        for (uint256 i = 0; i < _currentStudentId.current(); i++) {
            _students[i]._eligible = _signatures.isCompletelySigned(_students[i]._address);
        }
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

    error Soulbound();

    /// @notice This function was disabled to make the token Soulbound. Calling it will revert
    function approve(address, uint256) public virtual override(ERC721) {
        revert Soulbound();
    }

    /// @notice This function was disabled to make the token Soulbound. Calling it will revert
    function isApprovedForAll(address, address)
        public
        view
        virtual
        override(ERC721)
        returns (bool)
    {
        revert Soulbound();
    }

    /// @notice This function was disabled to make the token Soulbound. Calling it will revert
    function getApproved(uint256)
        public
        view
        virtual
        override(ERC721)
        returns (address)
    {
        revert Soulbound();
    }

    /// @notice This function was disabled to make the token Soulbound. Calling it will revert
    function setApprovalForAll(address, bool) public virtual override(ERC721) {
        revert Soulbound();
    }
}
