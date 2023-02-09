const { network } = require("hardhat")
const {
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const waitBlockComfirmation = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
    args = []

    const NoRugMarketplace = await deploy("NoRugMarketplace", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmation: waitBlockComfirmation,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("...verifying")
        await verify(NoRugMarketplace.address, args)
    }
}

module.exports.tags = ["all", "NoRugMarketplace"]
