//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Eggie is ERC721Tradable {
    constructor(address _proxyRegistryAddress)
        ERC721Tradable("Eggie", "EGG", _proxyRegistryAddress)
    {}

    function baseTokenURI() override public pure returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/Qmf1nHSmhbA4PGuAaj8SSAsgefpSaZdX3P6JiK5aYQSJUm/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://creatures-api.opensea.io/contract/opensea-creatures";
    }
}
