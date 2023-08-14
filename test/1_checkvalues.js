const contract = require("@truffle/contract");

var platform_contract = artifacts.require("ERC1155PlatformUpgradeable");


describe("ERC1155PlatformUpgradeable", () => { 
    it("Verifica valori di deploy", async () => {
        const contratto = platform_contract.deployed();

        await contratto.mint("0xB312Dcf3Bd0BFEDf9c932C0f35fa1B3c3859e4a0",0,1,"ipfs://bafkreic6j6yjo3d34vlrdspnjtbdz7fx6hofyddfrkzrrrdafkhzmaxos4",true);
        var uri = contratto.uri(0);
        console.log(uri);
        assert.equal(uri,"ipfs://bafkreic6j6yjo3d34vlrdspnjtbdz7fx6hofyddfrkzrrrdafkhzmaxos4");
    });
});