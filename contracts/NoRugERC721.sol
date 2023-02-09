//SPDX-License-Identifier: MIT

/** There are two differences between NoRUGERC721 and ERC721 standard as following:
 * First, the mintNft function is only callable by the specifc market address
 * which is a parameter for the contract constrcutor;
 * Second, the contract has a stoarge variable which store the owner addres.
 * Third, can only be mint thorugh NoRug Markerplace Address */

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error NoRugERC721__NotProperMarket();

contract NoRugERC721 is ERC721 {
    uint256 private s_tokenCounter;
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    address public s_owner;
    address public immutable i_MarketAddress;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address MarketAddress
    ) ERC721(tokenName, tokenSymbol) {
        s_tokenCounter = 0;
        s_owner = msg.sender;
        i_MarketAddress = MarketAddress;
    }

    function mintNft(address mintObject) public {
        if (msg.sender != i_MarketAddress) {
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
