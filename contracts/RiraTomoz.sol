pragma solidity ^0.5.6;

import "hardhat/console.sol";
import "./rira-utils/Strings.sol";
import "./klaytn-contracts/token/KIP17/KIP17Full.sol";
import "./klaytn-contracts/token/KIP17/KIP17Mintable.sol";
import "./klaytn-contracts/token/KIP17/KIP17Pausable.sol";

contract RiraTomoz is KIP17Full("Rira Institute of Technology TOMOZ", "TOMO"), KIP17Mintable, KIP17Pausable {

    event SetBaseURI(address indexed minter, string uri);

    string private _baseURI = "https://IPFS_Gateway_endpoint";
    uint256 public mintLimit = 10000;

    //return baseURI + token id
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_baseURI, Strings.fromUint256(tokenId)));
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    // Set IPFS Gateway endpoint
    function setBaseURI(string memory uri) public onlyMinter {
        _baseURI = uri;
        emit SetBaseURI(msg.sender, uri);
    }

    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        require(totalSupply() < mintLimit, "Mint limit exceeded");
        return super.mint(to, tokenId);
    }

    function batchMint(address to, uint256[] calldata tokenId) external onlyMinter {
        for (uint256 i = 0; i < tokenId.length; i ++) {
            mint(to, tokenId[i]);
        }
    }

    function batchTransfer(address to, uint256[] calldata tokenId) external {
        for (uint256 i = 0; i < tokenId.length; i ++) {
            transferFrom(msg.sender, to, tokenId[i]);
        }
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }
}