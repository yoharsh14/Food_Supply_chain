const { ethers, network } = require("hardhat");
const fs = require("fs");
const developmentChains = ["localhost", "hardhat"];

const frontend_Contract_Address_File_Location =
  "../frontend/src/constants/networkMapping.json";
const frontend_Contract_ABI_File_Location = "../frontend/src/constants/";
const read = "artifacts/contracts/foodTracking.sol/trackFood.json";
module.exports = async () => {
  if (
    process.env.UPDATE_FRONT_END &&
    !developmentChains.includes(network.name)
  ) {
    console.log("updating frontend...");
    await updateContractAddress();
    await updateabi();
  }
};

const updateContractAddress = async () => {
  const contract = await ethers.getContract("trackFood");
  const chainId = network.config.chainId.toString();
  const contractAddress = await contract.getAddress();

  const JSON_READ_FILE = JSON.parse(
    fs.readFileSync(frontend_Contract_Address_File_Location, "utf8")
  );
  if (chainId in JSON_READ_FILE) {
    if (!JSON_READ_FILE[chainId]["trackFood"].includes(contractAddress)) {
      JSON_READ_FILE[chainId]["trackFood"].push(contractAddress);
    }
  } else {
    JSON_READ_FILE[chainId] = { trackFood: [contractAddress] };
  }
  fs.writeFileSync(
    frontend_Contract_Address_File_Location,
    JSON.stringify(JSON_READ_FILE)
  );
};

const updateabi = async () => {
  const readFile = JSON.parse(fs.readFileSync(read, "utf8"));
  // console.log()
  const abi = JSON.stringify(readFile.abi);
  fs.writeFileSync(`${frontend_Contract_ABI_File_Location}trackFood.json`, abi);
};
