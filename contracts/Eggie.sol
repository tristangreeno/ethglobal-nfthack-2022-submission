//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


import "./meta-transactions/ContentMixin.sol";
import "./meta-transactions/NativeMetaTransaction.sol";

contract OwnableDelegateProxy {}

/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Eggie is
    ERC721,
    Ownable,
    AccessControl,
    ContextMixin,
    NativeMetaTransaction
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    string private constant _name = "Eggie";
    string private constant _symbol = "EGG";
    string private constant _collectionURI =
        "Qmf1nHSmhbA4PGuAaj8SSAsgefpSaZdX3P6JiK5aYQSJUm/";
    string public constant baseURI = "https://gateway.pinata.cloud/ipfs/";
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address private constant mumbaiProxyRegistryAddress =
        0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c;
    address private constant polygonProxyRegistryAddress =
        0x58807baD0B376efc12F5AD86aAc70E78ed67deaE;
    bytes32 public immutable root;


    constructor(bytes32 merkleroot) ERC721("EGG", "Eggplants") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _tokenIdCounter.increment();
        _initializeEIP712(_name);
        root = merkleroot;
    }

    // merkle tree
    function redeemMerkle(uint256 tokenId, bytes32[] calldata proof)
    external
    {
        require(_verifyMerkle(_leaf(msg.sender, tokenId), proof), "Invalid merkle proof");
        _safeMint(msg.sender, tokenId);
    }

    function _leaf(address account, uint256 tokenId)
    internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(tokenId, account));
    }

    function _verifyMerkle(bytes32 leaf, bytes32[] memory proof)
    internal view returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }

    function publicMint() external returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        return tokenId;
    }

    function safeMint(address account, bytes calldata signature) external {
        // uint256 tokenId = _tokenIdCounter.current();
        // require(_verify(_hash(account, tokenId), signature), "invalid signature");
        // _tokenIdCounter.increment();
        // _safeMint(account, tokenId);
    }

    function _hash(address account, uint256 tokenId)
        public
        pure
        returns (bytes32)
    {
        // change back to internal
        return
            ECDSA.toEthSignedMessageHash(
                keccak256(abi.encodePacked(account, tokenId))
            );
    }

    function _verify(bytes32 hashDigest, bytes memory signature)
        private
        view
        returns (bool)
    {
        address temp = ECDSA.recover(hashDigest, signature);
        // spoof a minter role
        return hasRole(MINTER_ROLE, temp);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: query for nonexistent token"
        );
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")
            );
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // OpenSea Whitelisting
    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry mumbaiProxyRegistry = ProxyRegistry(
            mumbaiProxyRegistryAddress
        );
        ProxyRegistry polygonProxyRegistry = ProxyRegistry(
            polygonProxyRegistryAddress
        );
        if (
            address(mumbaiProxyRegistry.proxies(owner)) == operator ||
            address(polygonProxyRegistry.proxies(owner)) == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender() internal view override returns (address sender) {
        return ContextMixin.msgSender();
    }
}
