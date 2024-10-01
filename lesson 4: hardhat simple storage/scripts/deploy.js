const { ethers } = require("hardhat")

async function main() {
    const SimpleStorageFactory = await ethers.getContractFactory("SimpleStorage")
    console.log("Deploying contract...")
    const simpleStorage = await SimpleStorageFactory.deploy()
    await simpleStorage.waitForDeployment()

    console.log(`Deployed contract to: ${simpleStorage.target}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })