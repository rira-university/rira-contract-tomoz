import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFT Contract", function () {
  it("DeployAndMint", async function () {
    const [minter] = await ethers.getSigners();
    const ipfsEndpoint = "https://mock-ipfs-endpoint/metadata/"

    const RiraTomoz = await ethers.getContractFactory("RiraTomoz");
    const tomoz = await RiraTomoz.deploy();
    await tomoz.deployed();

    //set ipfs endpoint
    await tomoz.setBaseURI(ipfsEndpoint);

    //mint 1 TOMO
    await tomoz.mint(minter.address, 1);
  
    //mint duplicate
    //await expect(await tomoz.mint(minter.address, 1)).to.revertedWith("KIP17: token already minted");

    //let batchMintData: number[] = [];
    //for(let i = 2; i ++; i <= 2000){
    //    batchMintData.push(i);
    //}

    //mint 1999 TOMOZ
    //const batchMintTx = await tomoz.batchMint(minter.address, batchMintData);
    //await batchMintTx.wait();

    //expect(await tomoz.tokenURI(2000)).to.equal(ipfsEndpoint + "2000");

  });
});
