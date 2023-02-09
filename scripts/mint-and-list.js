const { network, ethers } = require("hardhat")
const { moveBlock } = require("../utils/moveBlock")

const PRICE = ethers.utils.parseEther("0.1")

async function mintList({ getNamedAccounts }) {
    const NoRugMarketplace = await ethers.getContract("NoRugMarketplace")
    const noRugERC721 = await ethers.getContract("NoRugERC721")
    const chainId = network.config.chainId
    const { deployer } = await getNamedAccounts()

    console.log("Minting NFT...")
    const mintTx = await noRugERC721.mintNft(deployer.address)
    const mintTxRecipt = await mintTx.wait(1)
    const tokenId = mintTxRecipt.events[0].args.tokenId

    console.log("Approving marketplace...")
    const approveTx = await noRugERC721.approve(
        NoRugMarketplace.address,
        tokenId
    )
    await approveTx.wait(1)

    console.log("Listing NFT...")
    const listTx = await NoRugMarketplace.listItem(tokenId, PRICE, chainId)
    await listTx.wait(1)
    console.log("NFT listed!")
    if (network.config.chainId == 31337) {
        await moveBlock(1, (sleepAmount = 1000))
    }
}

mintList()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
