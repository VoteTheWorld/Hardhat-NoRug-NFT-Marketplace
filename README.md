# No_RUG Nft project

该项目旨在为 NFT 项目提供一种更容易筹集资金的新方式，旨在建立一个 NFT 市场，主要通过使用退款机制为投资者解决 RUG 问题。
现在项目发起人可以通过智能合约进行 ICO 或者 DAO 融资，所有资产都会有国库相对来说比较透明。 因此 RUG 会变得困难。
然而，NFT 项目却存在 RUG 巨大的潜在问题，投资者可能并不清楚自己明确持有这些 NFT 的权利，这将导致困境。 一方面，投资者在进入 NFT 项目时遇到很大的阻力，因为他们需要做足够的尽职调查以确保他们不会被骗。另一方面，筹款人需要将自己的项目细节尽可能多的进行批露。这就会导致 NFT 项目在融资的时候不能够快速高效的拿到初始融资。
因为 NFT 作为资产是永久存在在链上的，所以大部分的权益都是永久的或者是较长一段时间的。因为 ERC721 的 NFT 和 ERC20 的 token 的发行取决于项目特点，一般来说，NFT 的流通性要远远差于 token，因此退款机制是非常有必要的。有了退款机制之后，NFT 的投资人不管是加入社区也好，享受一定的权益也好，如果在一定时间内不满意可以退出。这样不仅对于投资人是一种保护，更能更好地提高融资效率，促进 NFT 项目的快速发展。

This project purpose a new way for NFT projects to raise funds much easier and aims to build a NFT marketplace which mainly solve the problem of RUG for investors by using refund mechanism.
Nowdays, project founder can make coin funding or DAO funding by smart contracts, there will be a treasury holding all the assets, which is kind of transparent. As a result, RUG becomes difficult.
However, NFT project has such huge potential problem of RUG, and the investors may do not know their rights for holding those NFTs explictly, which will cause the dilemma. On the one hand, the investors get a great resistance of entering a NFT project, cause they need to do enough due dilligence to make sure they cannot be scammed. On the other hand, the raisers need to provide much more details on their projects.

本项目将会通过智能合约的方式托管售卖 NFT 得到的资金，并且以时间递减的方式将资金发放给筹款人。
refund 之后该 nft 会发送到版权收取费用的地址，该地址不可以 call refund function

1. `1day-10day`: 筹款人可以在 10day 内 withdraw 资金池的 10%，投资人在 1day 后可以 withdraw 资金池的 10%（gas 费用除外，二次交易有版权费）
2. `10day-365day`: 实施资金池递减机制，筹款人可以 withdraw 90% x-10/（365-10），投资人可以 refund 90% 365-x /（365-10）/（mintedAmount - refundAmount）

marketplace contract function

3. `listItem`: list nft
4. `buyItem`: buy nft
5. `cancelItem`: cancel list
6. `updateListing`: update the price
7. `withdrawBalance`: withdraw payments for my brought nfts
8. `refund`: refund

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
