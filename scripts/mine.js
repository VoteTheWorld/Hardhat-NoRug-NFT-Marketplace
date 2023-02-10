const { moveBlock } = require("../utils/moveBlock")

const BLOCKS = 5

async function mine() {
    await moveBlock(BLOCKS)
}

mine()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
