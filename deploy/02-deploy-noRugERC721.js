const { network, ethers } = require("hardhat")
const {
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    NoRugMarketplace = await ethers.getContract("NoRugMarketplace")
    NoRugMarketplaceAddress = NoRugMarketplace.address
    const waitBlockConfirmation = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
    args = ["norug", "NR", NoRugMarketplaceAddress]
    const NoRugERC721 = await deploy("NoRugERC721", {
        from: deployer,
        args: args,
        log: true,
        waitComfirmation: waitBlockConfirmation,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("verifying...")
        await verify(NoRugERC721.address, args)
    }
}

module.exports.tags = ["all", "NoRugERC721"]
