const { assert, expect } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("NoRugMarketplace Test", function () {
          const Price = ethers.utils.parseEther("0.1")
          const Amount = 100
          const TokenId = 0
          beforeEach(async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              player = accounts[1]
              await deployments.fixture(["all"])
              NoRugMarketplace = await ethers.getContract("NoRugMarketplace")
              NoRugERC721 = await ethers.getContract("NoRugERC721")
          })

          it("publicList can be brought", async () => {
              await NoRugMarketplace.publicSale(
                  NoRugERC721.address,
                  Price,
                  Amount
              )
              const playerConnectNoRugMarketplace =
                  NoRugMarketplace.connect(player)
              await playerConnectNoRugMarketplace.publicBuy(
                  NoRugERC721.address,
                  { value: Price }
              )
              const buyer = await NoRugERC721.ownerOf(TokenId)
              const OwnerBalance = await NoRugMarketplace.getPublicBalance(
                  deployer.address
              )
              assert(buyer.toString() == player.address.toString())
              assert(OwnerBalance.toString() == Price.toString())
          })
      })
