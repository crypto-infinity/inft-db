const { deployProxy, upgradeProxy, forceImport } = require('@openzeppelin/truffle-upgrades');

var platform_contract = artifacts.require("ERC1155PlatformUpgradeable");
var utilities = artifacts.require("Utilities");

module.exports = async function(deployer) {
  // deployment steps when new contract is deployed

  //const contract = await deployProxy(platform_contract, ["ipfs://bafkreihdmavgdtchrabhqifb6sm6rgqp4di4xd2y6gs73ukmmmy4zis6iq","0xB312Dcf3Bd0BFEDf9c932C0f35fa1B3c3859e4a0"], { deployer });

  // deployment steps when proxy is updated

  const existing = await platform_contract.deployed();
  const instance = await upgradeProxy(existing.address, platform_contract, { deployer }); 

};