const { ethers, run, network } = require("hardhat")

async function main() {
    // DEPLOY CONTRACT:
    const SimpleStorageFactory = await ethers.getContractFactory("SimpleStorage")
    console.log("Deploying contract...")
    const simpleStorage = await SimpleStorageFactory.deploy()
    await simpleStorage.waitForDeployment()

    console.log(`Deployed contract to: ${simpleStorage.target}`)

    // VERIFY ON ETHERSCAN:
    if(network.config.chainId === 11155111 && process.env.ETHERSCAN_API_KEY){
        console.log("Waiting for block txes...")
        await simpleStorage.deploymentTransaction().wait(6)
        await verify(simpleStorage.target, [])
    }

    // INTERACT WITH CONTRACT:
    const currentValue = await simpleStorage.retrieve()
    console.log(`Current Value is: ${currentValue}`)

    // Update the current value
    const transactionResponse = await simpleStorage.store(7)
    await transactionResponse.wait(1)
    const updatedValue = await simpleStorage.retrieve()
    console.log(`Updated Value is: ${updatedValue}`)
}

async function verify(contractAddress, args) {
    console.log("Verifying contract...")
    try{
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } 
    catch (e) {
        if (e.message.toLowerCase().includes("already verified")){
            console.log("Already verified!")
        }
        else{
            console.log(e)
        }
    }

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })