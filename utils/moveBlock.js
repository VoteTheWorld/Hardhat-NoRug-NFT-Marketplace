const { network } = require("hardhat")

function sleepTime(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
}
async function moveBlock(amount, sleepAmount = 0) {
    console.log("Moving block...")
    for (let i = 0; i < amount; i++) {
        await network.provider.request({ method: "evm_mine", params: [] })
        if (sleepAmount > 0) {
            console.log(`Sleeping for${sleepAmount}ms`)
            await sleepTime(sleepAmount)
        }
    }
    console.log(`Moved block by ${amount} blocks`)
}
module.exports = {
    moveBlock,
    sleepTime,
}
