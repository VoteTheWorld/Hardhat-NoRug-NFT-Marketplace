const { network, ethers } = require("hardhat")
const fs = require("fs")

const frontEndContractsFile =
    "../nextjs-norug-nftmarketplace/constants/contractMapping.json"
const frontEndAbiContractsFile = "../nextjs-norug-nftmarketplace/constants/"

module.exports = async () => {
    if (process.env.UPDATE_FRONT_END) {
        console.log("Updating front end contract address and abi...")
        await updateFrontEnd()
        await updateAbi()
    }
}
async function updateAbi() {
    const nftMarketplace = await ethers.getContract("NoRugMarketplace")
    const nft = await ethers.getContract("NoRugERC721")
    fs.writeFileSync(
        `${frontEndAbiContractsFile}NoRugMarketplace.json`,
        nftMarketplace.interface.format(ethers.utils.FormatTypes.json)
    )
    fs.writeFileSync(
        `${frontEndAbiContractsFile}NoRugERC721.json`,
        nft.interface.format(ethers.utils.FormatTypes.json)
    )
}

async function updateFrontEnd() {
    const nftMarketplace = await ethers.getContract("NoRugMarketplace")
    const chainId = network.config.chainId
    const contractAddress = JSON.parse(
        fs.readFileSync(frontEndContractsFile, "utf8")
    )
    if (chainId in contractAddress) {
        if (
            !contractAddress[chainId]["NoRugMarketplace"].includes(
                nftMarketplace.address
            )
        ) {
            contractAddress[chainId]["NoRugMarketplace"].push(
                nftMarketplace.address
            )
        }
    } else {
        contractAddress[chainId] = {
            NoRugMarketplace: [nftMarketplace.address],
        }
    }

    fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddress))
}

module.exports.tags = ["all", "frontend"]
