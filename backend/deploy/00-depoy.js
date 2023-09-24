const { network } = require("hardhat");
const developmentChains = ["localhost", "hardhat"];
const { verify } = require("../utils/verify");
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const contract = await deploy("trackFood", {
    from: deployer,
    log: true,
    args: [],
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  if (!developmentChains.includes(network.name)) {
    await verify(contract.address, []);
  }
};
module.exports.tags = [];
