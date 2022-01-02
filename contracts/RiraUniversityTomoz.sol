pragma solidity ^0.5.6;

import "hardhat/console.sol";
import "./rira-utils/Strings.sol";
import "./klaytn-contracts/token/KIP17/KIP17Full.sol";
import "./klaytn-contracts/token/KIP17/KIP17Mintable.sol";
import "./klaytn-contracts/token/KIP17/KIP17Pausable.sol";

contract RiraUniversityTomoz is KIP17Full("Rirauniversity TOMOZ", "TOMOZ"), KIP17Mintable, KIP17Pausable {

    event SetBaseURI(address indexed minter, string uri);

    string private _baseURI;
    uint256 public mintLimit = 10000;
    uint256 public mintIndex = 0;

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

    //for _INTERFACE_ID_KIP17_MINTABLE, not recommended
    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        require(tokenId > mintIndex, "tokenId must be greater than mintIndex.");
        require(tokenId <= mintLimit, "tokenId must be less than mintLimit.");
        _mint(to, tokenId);
        return true;
    }

    //Mint with auto increment Ids
    function mint(address to) public onlyMinter returns (bool) {
        require(mintIndex < mintLimit, "Mint limit exceeded");
        mintIndex = mintIndex.add(1);
        return super.mint(to, mintIndex);
    }

    //Batch mint with auto increment Ids
    function batchMint(address to, uint256 amount) external onlyMinter {
        for (uint256 i = 0; i < amount; i ++) {
            mint(to);
        }
    }

    //TODO
    //BATCH TRANSFER

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }
}