// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
@title InstitutionDegreeSigner
@author Charles Simon-Meunier
*/
contract InstitutionDegreeSigner {
    address[][] private _addresses;
    uint256 private _layers;
    bool private signatureInProgress = false;

    struct sSignature {
        bool[][] _signed;
        bytes32[][] _hashes;
        bytes[][] _signatures;
        bool init;
    }

    mapping(address => sSignature) _signatures;

    constructor(uint256 layers, address[][] memory addresses) {
        _addresses = new address[][](layers);
        _layers = layers;
        for (uint256 i = 0; i < layers; i++) {
            _addresses[i] = new address[](addresses[i].length);
            for (uint256 j = 0; j < addresses[i].length; j++) {
                _addresses[i][j] = addresses[i][j];
            }
        }
    }

    function recoverSigner(bytes32 hash, bytes memory signature) public pure returns (address) {
        bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return ECDSA.recover(messageDigest, signature);
    }

    function getAddresses() public view returns (address[][] memory) {
        return _addresses;
    }

    function getNumberOfLayers() public view returns (uint256) {
        return _layers;
    }

    function getAddressesByLayer(uint256 layer)
        public
        view
        returns (address[] memory)
    {
        return _addresses[layer];
    }

    /**
    @notice Get the status of the signature of a student for a layer and an index
    @dev This should be the documentation of the function for the developer docs
    @param layer The layer of the signature
    @param index The index inside the layer
    @param wallet The address of the student wallet
    @return {
        "true": "if the signature is present",
        "false": "if the signature is not present"
    }
    */
    function getSignedStatus(
        uint256 layer,
        uint256 index,
        address wallet
    ) public view returns (bool) {
        if (!_signatures[wallet].init) {
            return false;
        }
        return _signatures[wallet]._signed[layer][index];
    }

    function getAddressOfSigner(uint256 layer, uint256 index)
        public
        view
        returns (address)
    {
        return _addresses[layer][index];
    }

    function getSignerNumber(uint256 layer) public view returns (uint256) {
        return _addresses[layer].length;
    }

    function isSigned(uint256 layer, address wallet)
        public
        view
        returns (bool)
    {
        if (!_signatures[wallet].init) {
            return false;
        }
        for (
            uint256 i = 0;
            i < _signatures[wallet]._signed[layer].length;
            i++
        ) {
            if (!_signatures[wallet]._signed[layer][i]) {
                return false;
            }
        }
        return true;
    }

    function isSigner(address signer)
        public
        view
        returns (
            bool,
            uint256,
            uint256
        )
    {
        for (uint256 i = 0; i < _layers; i++) {
            for (uint256 j = 0; j < _addresses[i].length; j++) {
                if (_addresses[i][j] == signer) {
                    return (true, i, j);
                }
            }
        }
        return (false, 0, 0);
    }

    function hasSigned(
        address signer,
        uint256 layer,
        address wallet
    ) public view returns (bool) {
        if (!_signatures[wallet].init) {
            return false;
        }
        for (uint256 i = 0; i < _addresses[layer].length; i++) {
            if (_addresses[layer][i] == signer) {
                return _signatures[wallet]._signed[layer][i];
            }
        }
        return false;
    }

    function initSignature(address wallet) public {
        if (_signatures[wallet].init) {
            return;
        }
        _signatures[wallet]._signed = new bool[][](_addresses.length);
        for (uint256 i = 0; i < _layers; i++) {
            _signatures[wallet]._signed[i] = new bool[](_addresses[i].length);
            _signatures[wallet]._hashes[i] = new bytes32[](_addresses[i].length);
            _signatures[wallet]._signatures[i] = new bytes[](_addresses[i].length);
        }
        _signatures[wallet].init = true;
    }

    function sign(address wallet, uint256 layer, bytes32 hash, bytes memory signature) public {
        require(!signatureInProgress, "Signature in progress");
        signatureInProgress = true;
        if (!_signatures[wallet].init) {
            initSignature(wallet);
        }
        (bool _isSigner, , uint256 index_in_layer) = isSigner(msg.sender);
        address[] memory addressesInLayer = getAddressesByLayer(layer);
        bool isInLayer = false;
        for (uint256 i = 0; i < addressesInLayer.length; i++) {
            if (addressesInLayer[i] == msg.sender) {
                isInLayer = true;
                break;
            }
        }
        require(_isSigner, "Only signers can sign");
        require(recoverSigner(hash, signature) == msg.sender, "Signature not valid");
        require(isInLayer, "Only signers in this layer can sign");
        require(
            !_signatures[wallet]._signed[layer][index_in_layer],
            "You have already signed"
        );
        _signatures[wallet]._signed[layer][index_in_layer] = true;
        _signatures[wallet]._hashes[layer][index_in_layer] = hash;
        _signatures[wallet]._signatures[layer][index_in_layer] = signature;
        emit Signature(msg.sender, wallet, layer, index_in_layer, hash, signature);
        if (isCompletelySigned(wallet)) {
            emit CompletelySigned(wallet);
        }
        signatureInProgress = false;
    }

    function getStatus(address wallet) public view returns (bool[][] memory) {
        if (!_signatures[wallet].init) {
            revert();
        }
        return _signatures[wallet]._signed;
    }

    function getLayerStatus(address wallet, uint256 layer)
        public
        view
        returns (bool[] memory)
    {
        if (!_signatures[wallet].init) {
            revert();
        }
        return _signatures[wallet]._signed[layer];
    }

    function isCompletelySigned(address wallet) public view returns (bool) {
        if (!_signatures[wallet].init) {
            return false;
        }
        for (uint256 i = 0; i < _signatures[wallet]._signed.length; i++) {
            if (!isSigned(i, wallet)) {
                return false;
            }
        }
        return true;
    }

    event Signature (
        address signer,
        address wallet,
        uint256 layer,
        uint256 index,
        bytes32 hash,
        bytes signature
    );

    event CompletelySigned(address wallet);
}
