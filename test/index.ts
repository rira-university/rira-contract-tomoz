import { Provider } from "@ethersproject/abstract-provider";
import { expect } from "chai";
import { ethers, waffle } from "hardhat";

describe("NFT Contract", function () {
  it("DeployAndMint", async function () {
    const provider = waffle.provider;
    //const [minter] = await ethers.getSigners();
    const [minter, user] = provider.getWallets();
    const ipfsEndpoint = "https://mock-ipfs-endpoint/metadata/"
    const RiraTomoz = await ethers.getContractFactory("RiraTomoz");
    const tomoz = await RiraTomoz.deploy();
    await tomoz.deployed();

    //set ipfs endpoint
    await tomoz.setBaseURI(ipfsEndpoint);

    //mint 1 TOMO
    await tomoz.mint(minter.address, 1);
  
    //mint duplicate
    await expect(tomoz.mint(minter.address, 1)).to.be.revertedWith("KIP17: token already minted");

    //set token ids for batchmint (2~2000)
    let tokenIds: number[] = [];
    let endId  = 10000;
    for(let i = 2; i <= endId; i++){
      tokenIds.push(i);

      if((i % 100 == 0) || i == endId){
        console.log("batch minting : "+ tokenIds[0] + " ~ " + + tokenIds[tokenIds.length - 1] + " (size:" + tokenIds.length + ")");
        const batchMintTx = await tomoz.batchMint(minter.address, tokenIds);
        await batchMintTx.wait();
        tokenIds = []; //clear buffer
      }
    }

    expect(await tomoz.tokenURI(10000)).to.be.equal(ipfsEndpoint + "10000");
    await expect(tomoz.mint(minter.address, 0)).to.be.revertedWith("Mint limit exceeded");
    await expect(tomoz.tokenURI(0)).to.be.revertedWith("KIP17Metadata: URI query for nonexistent token");
    await expect(tomoz.tokenURI(10001)).to.be.revertedWith("KIP17Metadata: URI query for nonexistent token");

    //test batchTrasnfer
    for(let i = 1; i <= 50; i++){
      tokenIds.push(i);
    }
    const batchTransferTx = await tomoz.batchTransfer(user.address, tokenIds);
    await batchTransferTx.wait();

    expect(await tomoz.balanceOf(minter.address)).to.be.equal(9950);
    expect(await tomoz.balanceOf(user.address)).to.be.equal(50);
  });
});
