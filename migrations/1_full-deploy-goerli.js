const { deployProxy, upgradeProxy, forceImport } = require('@openzeppelin/truffle-upgrades');

var platform_contract = artifacts.require("standardNFT_DB");

module.exports = async function(deployer) {

  let contract_uri = "ipfs://bafkreihdmavgdtchrabhqifb6sm6rgqp4di4xd2y6gs73ukmmmy4zis6iq";
  let contract_admins =  ["0xB312Dcf3Bd0BFEDf9c932C0f35fa1B3c3859e4a0"];
  let contract_name = "Test Contract";

  try
  {
    var contract = await platform_contract.deployed();
    var instance = await upgradeProxy(existing.address, platform_contract, { deployer });
  }
  catch(error)
  {
    console.error("Console Error: " + error)
    var contract = await deployProxy(platform_contract, [contract_uri,contract_admins, contract_name], { deployer });
  }
  
};