//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface INoRugERC721 is IERC721 {
    function mintNft(address mintObject) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function getTokenCounter() external view returns (uint256);

    function getOwner() external view returns (address);
}
