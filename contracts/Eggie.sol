//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Eggie is ERC721, Ownable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC721("EGG", "Eggplants") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function publicMint(address account, uint256 tokenId) external onlyRole(MINTER_ROLE) {
            uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(account, tokenId);
    }
    
    // account address, tokenId, signature
    // signature is generated by hashing account address + token Id, abiEncode // signature is bytes32
    function safeMint(address account, uint256 tokenId, bytes calldata signature) external {
        require(_verify(_hash(account, tokenId), signature), "invalid signature");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(account, tokenId);
    }

    function _hash(address account, uint256 tokenId) public pure returns (bytes32) { // change back to internal
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(account, tokenId)));
    }

    function _verify(bytes32 hashDigest, bytes memory signature) private view returns (bool) {
        address temp = ECDSA.recover(hashDigest, signature);
        // spoof a minter role
        return hasRole(MINTER_ROLE, temp);
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
