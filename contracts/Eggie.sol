//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Eggie is ERC721, Ownable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string constant private _collectionURI = "Qmf1nHSmhbA4PGuAaj8SSAsgefpSaZdX3P6JiK5aYQSJUm/";
    string public baseURI = "https://gateway.pinata.cloud/ipfs/";

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC721("EGG", "Eggplants") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _tokenIdCounter.increment();
    }

    // merkle tree
    function redeemMerkle(address account, uint256 tokenId, bytes32[] calldata proof)
    external
    {
        require(_verify(_leaf(account, tokenId), proof), "Invalid merkle proof");
        _safeMint(account, tokenId);
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

    function _hash(address account, uint256 tokenId) public pure returns (bytes32) { // change back to internal
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(account, tokenId)));
    }

    function _verify(bytes32 hashDigest, bytes memory signature) private view returns (bool) {
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
        require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
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
    // function isApprovedForAll(address owner, address operator)
    //     override
    //     public
    //     view
    //     returns (bool)
    // {
    //     // Whitelist OpenSea proxy contract for easy trading.
    //     ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    //     if (address(proxyRegistry.proxies(owner)) == operator) {
    //         return true;
    //     }

    //     return super.isApprovedForAll(owner, operator);
    // }
}
