const { network, ethers, getNamedAccounts } = require("hardhat")
const { moveBlock } = require("../utils/moveBlock")

const PRICE = ethers.utils.parseEther("0.01")

async function mintList() {
    const noRugMarketplace = await ethers.getContract("NoRugMarketplace")
    const noRugERC721 = await ethers.getContract("NoRugERC721")

    const chainId = network.config.chainId
    const { deployer } = await getNamedAccounts()

    console.log("Minting NFT...")

    // list item on NFT marketplace
    console.log("public sale openning...")

    const publicListTx = await noRugMarketplace.publicSale(
        noRugERC721.address,
        PRICE,
        100
    )
    await publicListTx.wait(1)

    console.log("mint on NoRugMarketplace")
    const mintTx = await noRugMarketplace.publicBuy(noRugERC721.address, {
        value: PRICE,
        gasLimit: 30000000,
    })
    await mintTx.wait(1)

    console.log("Approving marketplace...")
    const approveTx = await noRugERC721.approve(noRugMarketplace.address, 1)
    await approveTx.wait(1)

    console.log("Listing NFT...")

    const listTx = await noRugMarketplace.listItem(
        noRugERC721.address,
        1,
        PRICE,
        {
            gasLimit: 30000000,
        }
    )
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
