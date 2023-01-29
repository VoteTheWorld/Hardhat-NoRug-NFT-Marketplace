//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../contracts/INoRugERC721.sol";

error NoRugMarketplace__PriceMustAboveZero();
error NoRugMarketplace__NotOwner();
error NoRugMarketplace__NotApproved();
error NoRugMarketplace__OnlyContractOwnerCanMakePublicSale();
error NoRugMarketplace__NotEnoughMoney();
error NoRugMarketplace__PublicSaleEnded();
error NoRugMarketplace__notListed();
error NoRugMarketplace__notPublicListed();
error NoRugMarketplace__NewPriceMustAboveZero();
error NoRugMarketplace__NothingToWithdraw();
error NoRugMarketplace__WithdrawFailed();
error NoRugMarketplace__PublicSaleNotStarted();
error NoRugMarketplace__RefundFailed();
error NoRugMarketplace__OverRefundTime();
error NoRugMarketplace__CannotWithdraw();
error NoRugMarketplace__ContractOwnerCanNotRefund();

contract NoRugMarketplace {
    struct Listing {
        uint256 Price;
        address Seller;
    }
    struct PublicListing {
        uint256 Price;
        address Seller;
        uint256 Amount;
        uint256 BroughtAmount;
        uint256 RefundAmount;
    }
    uint256 private s_publicSaleCount;
    uint256 public s_timePeriodOne = 10 days;
    uint256 public s_timePeriodTwo = 52 weeks;

    mapping(address => mapping(uint256 => Listing)) private s_listing;
    mapping(address => PublicListing) private s_publicListing;

    // nftaddress => publicSaleCount => timestamp
    mapping(address => mapping(uint256 => uint256)) private s_publicSale;
    mapping(address => uint256) private s_balance;
    mapping(address => uint256) private s_balancePublic;

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event PublicItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed price
    );
    event ItemBrought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event PublicBrought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed price
    );
    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    event PublicCanceled(address indexed seller, address indexed nftAddress);
    event WithdrawSucceed(address indexed owner, uint256 indexed balance);
    event ItemRefunded(
        address indexed refunder,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address sender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (sender != owner) {
            revert NoRugMarketplace__NotOwner();
        }
        _;
    }

    modifier isContractOwner(address nftAddress) {
        INoRugERC721 noRugNft = INoRugERC721(nftAddress);
        address owner = noRugNft.getOwner();
        if (owner == msg.sender) {
            revert NoRugMarketplace__ContractOwnerCanNotRefund();
        }
        _;
    }
    modifier notContractOwner(address nftAddress) {
        INoRugERC721 noRugNft = INoRugERC721(nftAddress);
        address owner = noRugNft.getOwner();
        if (owner != msg.sender) {
            revert NoRugMarketplace__OnlyContractOwnerCanMakePublicSale();
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory list = s_listing[nftAddress][tokenId];
        if (list.Price <= 0) {
            revert NoRugMarketplace__notListed();
        }
        _;
    }
    modifier isPublicListed(address nftAddress) {
        PublicListing memory list = s_publicListing[nftAddress];
        if (list.Price <= 0) {
            revert NoRugMarketplace__notPublicListed();
        }
        _;
    }

    constructor() {
        s_publicSaleCount = 0;
    }

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) {
            revert NoRugMarketplace__PriceMustAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NoRugMarketplace__NotApproved();
        }
        s_listing[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function publicSale(
        address nftAddress,
        uint256 price,
        uint256 amount
    ) external isContractOwner(nftAddress) {
        if (price <= 0) {
            revert NoRugMarketplace__PriceMustAboveZero();
        }
        s_publicListing[nftAddress] = PublicListing(
            price,
            msg.sender,
            amount,
            0,
            0
        );
        emit PublicItemListed(msg.sender, nftAddress, price);

        //store the time that was created
        s_publicSale[nftAddress][s_publicSaleCount] = block.timestamp;
        s_publicSaleCount++;
    }

    function buyItem(address nftAddress, uint256 tokenId) external payable {
        Listing memory ListItem = s_listing[nftAddress][tokenId];
        if (msg.value < ListItem.Price) {
            revert NoRugMarketplace__NotEnoughMoney();
        }
        s_balance[ListItem.Seller] += msg.value;
        delete (ListItem);
        IERC721(nftAddress).safeTransferFrom(
            ListItem.Seller,
            msg.sender,
            tokenId
        );
        emit ItemBrought(msg.sender, nftAddress, tokenId, ListItem.Price);
    }

    function publicBuy(address nftAddress) external payable {
        PublicListing memory ListItem = s_publicListing[nftAddress];
        if (msg.value < ListItem.Price) {
            revert NoRugMarketplace__NotEnoughMoney();
        }
        if (ListItem.Amount <= ListItem.BroughtAmount) {
            revert NoRugMarketplace__PublicSaleEnded();
        }
        s_balancePublic[ListItem.Seller] += msg.value;
        ListItem.BroughtAmount += 1;
        INoRugERC721(nftAddress).mintNft(msg.sender);
        emit PublicBrought(msg.sender, nftAddress, ListItem.Price);
    }

    function cancelList(
        address nftAddress,
        uint256 tokenId
    )
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        delete (s_listing[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function publicSaleCancel(
        address nftAddress
    ) external isContractOwner(nftAddress) isPublicListed(nftAddress) {
        delete (s_publicListing[nftAddress]);
        emit PublicCanceled(msg.sender, nftAddress);
    }

    function upgradeListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        if (newPrice <= 0) {
            revert NoRugMarketplace__NewPriceMustAboveZero();
        }
        s_listing[nftAddress][tokenId].Price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    function withdrawBalance() external payable {
        uint256 balance = s_balance[msg.sender];
        if (balance <= 0) {
            revert NoRugMarketplace__NothingToWithdraw();
        }
        s_balance[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        if (!success) {
            revert NoRugMarketplace__WithdrawFailed();
        }
        emit WithdrawSucceed(msg.sender, balance);
    }

    function withdrawBalancePublic(
        address nftAddress,
        uint256 publicSaleCount
    ) external payable {
        uint256 balance = _getWithdrawBalancePublic(
            nftAddress,
            publicSaleCount
        );
        s_balancePublic[msg.sender] -= balance;
        s_publicListing[nftAddress].RefundAmount += 1;
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        if (!success) {
            revert NoRugMarketplace__WithdrawFailed();
        }
        emit WithdrawSucceed(msg.sender, balance);
    }

    function _getWithdrawBalancePublic(
        address nftAddress,
        uint256 publicSaleCount
    ) internal view returns (uint256) {
        uint256 StartTime = s_publicSale[nftAddress][publicSaleCount];
        PublicListing memory Item = s_publicListing[nftAddress];
        if (block.timestamp - StartTime <= 0) {
            revert NoRugMarketplace__CannotWithdraw();
        } else if (
            block.timestamp - StartTime <= s_timePeriodOne &&
            block.timestamp - StartTime >= 0
        ) {
            return (Item.Price * Item.BroughtAmount * 1) / 10;
        } else if (
            block.timestamp - StartTime <= s_timePeriodTwo &&
            block.timestamp - StartTime >= s_timePeriodOne
        ) {
            return
                ((((block.timestamp - StartTime) /
                    (s_timePeriodTwo - s_timePeriodOne)) * (Item.Price * 9)) /
                    10) * (Item.BroughtAmount - Item.RefundAmount - 1);
        } else {
            revert NoRugMarketplace__OverRefundTime();
        }
    }

    function refundPublicSale(
        address nftAddress,
        uint256 publicSalesCount,
        uint256 tokenId
    )
        external
        payable
        isOwner(nftAddress, tokenId, msg.sender)
        notContractOwner(nftAddress)
    {
        INoRugERC721 nft = INoRugERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NoRugMarketplace__NotApproved();
        }
        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            s_publicListing[nftAddress].Seller,
            tokenId
        );
        uint256 refund = _getRefund(nftAddress, publicSalesCount);
        (bool success, ) = payable(msg.sender).call{value: refund}("");
        if (!success) {
            revert NoRugMarketplace__RefundFailed();
        }
        emit ItemRefunded(msg.sender, nftAddress, tokenId, refund);
    }

    function _getRefund(
        address nftAddress,
        uint256 publicSalesCount
    ) internal view returns (uint256) {
        uint256 StartTime = s_publicSale[nftAddress][publicSalesCount];
        if (block.timestamp - StartTime <= 0) {
            revert NoRugMarketplace__PublicSaleNotStarted();
        } else if (
            block.timestamp - StartTime <= s_timePeriodOne &&
            block.timestamp - StartTime >= 0
        ) {
            return (s_publicListing[nftAddress].Price * 9) / 10;
        } else if (
            block.timestamp - StartTime <= s_timePeriodTwo &&
            block.timestamp - StartTime >= s_timePeriodOne
        ) {
            return
                (s_publicListing[nftAddress].Price * 9) /
                10 -
                (((block.timestamp - StartTime) /
                    (s_timePeriodTwo - s_timePeriodOne)) *
                    (s_publicListing[nftAddress].Price * 9)) /
                10;
        } else {
            revert NoRugMarketplace__OverRefundTime();
        }
    }

    function getpublivSaleCount() external view returns (uint256) {
        return s_publicSaleCount;
    }

    function getTimePeriodOne() external view returns (uint256) {
        return (s_timePeriodOne);
    }

    function getTimePeriodTwo() external view returns (uint256) {
        return (s_timePeriodTwo);
    }

    function getList(
        address nftAddress,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return s_listing[nftAddress][tokenId];
    }

    function getPublicList(
        address nftAddress
    ) external view returns (PublicListing memory) {
        return s_publicListing[nftAddress];
    }

    function getPublicSaleTimeStamp(
        address nftAddress,
        uint256 publicSaleCount
    ) external view returns (uint256) {
        return s_publicSale[nftAddress][publicSaleCount];
    }

    function getBalance(address owner) external view returns (uint256) {
        return s_balance[owner];
    }

    function getPublicBalance(address owner) external view returns (uint256) {
        return s_balancePublic[owner];
    }
}
