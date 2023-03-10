# No_RUG Nft project

等待修改：

1. code 加上备注
2. 退款机制加上 uniswap 的转换（不太可行，contract 只能存储 eth）

## Project overview

This project purpose a new way for NFT projects to raise funds much easier and aims to build a NFT marketplace which mainly solve the problem of RUG for investors by using refund mechanism.
Nowdays, project founder can make coin funding or DAO funding by smart contracts, there will be a treasury holding all the assets, which is kind of transparent. As a result, RUG becomes difficult.
However, NFT project has such huge potential problem of RUG, and the investors may do not know their rights for holding those NFTs explictly, which will cause the dilemma. On the one hand, the investors get a great resistance of entering a NFT project, cause they need to do enough due dilligence to make sure they cannot be scammed. On the other hand, the raisers need to provide much more details on their projects.

## 项目简介

该项目旨在为 NFT 项目提供一种更容易筹集资金的新方式旨在建立一个 NFT 市场。主要通过使用退款机制为投资者解决 RUG 问题。
当前阶段 Token 项目方进行的 ICO 融资，所有资产都会有国库且 tokenEconomics 都可以被 write in code，因此相对来说比较透明, RUG 也会相对困难。然而，NFT 项目却存在 RUG 巨大的潜在问题，投资者可能并不清楚自己明确持有这些 NFT 的权利，这将导致 NFT 项目方和投资者的困境。
一方面，投资者在进入 NFT 项目时遇到很大的阻力，因为他们需要做足够的尽职调查以尽可能确保他们不会被 RUG。另一方面，筹款人需要将自己的项目细节尽可能多的进行披露。这就会导致 NFT 项目在融资的时候不能够快速高效的拿到初始融资。
因为 NFT 作为资产是永久存在在链上的，所以大部分的权益都是永久的或者是较长一段时间的。因为 ERC721 的 NFT 和 ERC20 的 token 的发行取决于项目特点，普遍来说，NFT 的流通性要远远差于 token，因此退款机制是有必要的。有了退款机制之后，NFT 的投资人加入社区，享受一定的权益，如果在一定时间内不满意可以退出。这不仅对投资人是一种保护，更能提高项目方的融资效率，促进 NFT 项目的繁荣发展。

1. `1day-10day`: 筹款人可以在 10day 内 withdraw 资金池的 10%，投资人在 1day 后可以 refund 资金池的 90%（gas 费用除外，二次交易有版权费）
2. `10day-365day`: 实施资金池递减机制，筹款人可以 withdraw 90% x-10/（365-10），投资人可以 refund 90% 365-x /（365-10）/（mintedAmount - refundAmount）

## Notes

1. Refund 会将该 nft 会发送到收取版权费用的地址，因此该地址不可以 call refund function 从而抽干

## There are mainly two parts for this NoRug marketplace contract functions

1.  simple list and buy all the nfts across the chain

    1. `listItem`: take(nftAddress,tokenId,price)
    2. `buyItem`: take(nftaddress tokenId)
    3. `cancelItem`: take(nftAddress tokenId)
    4. `updateListing`: take(nftAddress, tokenId, newPrice)
    5. `withdrawBalance`: withdraw payments for common sale
    6. `refund`: refund

2.  First public sale part for the NoRugERC721 standard NFT

    1.  `publicSale`: take(nftAddress, price, amount): 1. only NoRugERC721 standard NFT address owner can call this function to first sell their NFT 2. store the time when this public sale starts
    2.  `publicBuy`: take(nftAddress) 1. call the mintNft function of the NoRugERC721 standard NFT address

    3.  `publicSaleCancel`: public sale withdraw from here
    4.  `withdrawBalancePublic`: call \_getWithdrawBalancePublic function to calculate the balance that can be withdraw from publicSale

    5.  `refundPublicSale`: take(nftAddress, publicSalesCount, tokenId) call getRefund to calculate the refund and refund to the owner

3.  Get FUNCTION
    1. getpublicSaleCount
    2. getTimePeriodOne
    3. getTimePeriodTwo
    4. getList
    5. getPublicList
    6. getPublicSaleTimeStamp
    7. getBalance
    8. getPublicBalance
