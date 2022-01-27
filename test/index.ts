import { expect } from "chai";
import { ethers, waffle } from "hardhat";

describe("TOMOZ Contract", function () {
  it("Deploy, Mint, Batch", async function () {
    const provider = waffle.provider;
    //const [minter] = await ethers.getSigners();
    const [minter, user] = provider.getWallets();
    const ipfsEndpoint = "https://mock-ipfs-endpoint/metadata/"
    const RiraTomoz = await ethers.getContractFactory("RiraTomoz");
    const tomoz = await RiraTomoz.deploy();
    await tomoz.deployed();

    //set ipfs endpoint
    await tomoz.setVariableBaseUri(0, ipfsEndpoint);

    //mint 1 TOMO
    await tomoz.mint(minter.address, 0);
  
    //mint duplicate
    await expect(tomoz.mint(minter.address, 0)).to.be.revertedWith("KIP17: token already minted");

    //set token ids for batchmint (1~9999)
    let tokenIds: number[] = [];
    let endId  = 9999;
    for(let i = 1; i <= endId; i++){
      tokenIds.push(i);

      if((i % 200 == 0) || i == endId){
        console.log("batch minting : "+ tokenIds[0] + " ~ " + + tokenIds[tokenIds.length - 1] + " (size:" + tokenIds.length + ")");
        const batchMintTx = await tomoz.batchMint(minter.address, tokenIds);
        await batchMintTx.wait();
        tokenIds = []; //clear buffer
      }
    }

    //check mint
    expect(await tomoz.tokenURI(9999)).to.be.equal(ipfsEndpoint + "9999");
    await expect(tomoz.mint(minter.address, 0)).to.be.revertedWith("Mint limit exceeded");
    await expect(tomoz.tokenURI(10000)).to.be.revertedWith("KIP17Metadata: URI query for nonexistent token");

    //test batchTrasnfer
    for(let i = 1; i <= 50; i++){
      tokenIds.push(i);
    }
    const batchTransferTx = await tomoz.batchTransfer(user.address, tokenIds);
    await batchTransferTx.wait();

    expect(await tomoz.balanceOf(minter.address)).to.be.equal(9950);
    expect(await tomoz.balanceOf(user.address)).to.be.equal(50);

    //tomo#99 base uri index is 1
    expect(await tomoz.tokenURI(99)).to.be.equal(ipfsEndpoint + "99");
    const tomoUriTx = await tomoz.setTomoUriIndex(99, 1);
    await tomoUriTx.wait();
    expect(await tomoz.tokenURI(99)).to.be.equal("99");

    //set base uri index1 is https://google.com/
    const baseUriTx = await tomoz.setVariableBaseUri(1, "https://google.com/");
    await baseUriTx.wait();
    expect(await tomoz.tokenURI(99)).to.be.equal("https://google.com/" + "99");
    expect(await tomoz.tokenURI(98)).to.be.equal(ipfsEndpoint + "98");

  });
});
