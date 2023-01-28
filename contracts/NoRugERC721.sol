//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error NoRugERC721__NotProperMarket();

contract NoRugERC721 is ERC721 {
    uint256 private s_tokenCounter;
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    address public s_owner;
    address public s_MarketAddress;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address MarketAddress
    ) ERC721(tokenName, tokenSymbol) {
        s_tokenCounter = 0;
        s_owner = msg.sender;
        s_MarketAddress = MarketAddress;
    }

    function mintNft(address mintObject) public {
        if (msg.sender != s_MarketAddress) {
            revert NoRugERC721__NotProperMarket();
        }
        _safeMint(mintObject, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getOwner() public view returns (address) {
        return s_owner;
    }
}
