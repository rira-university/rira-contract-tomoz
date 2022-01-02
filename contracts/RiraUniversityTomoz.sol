pragma solidity ^0.5.6;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "./klaytn-contracts/token/KIP17/KIP17Full.sol";
import "./klaytn-contracts/token/KIP17/KIP17Mintable.sol";
import "./klaytn-contracts/token/KIP17/KIP17MetadataMintable.sol";
import "./klaytn-contracts/token/KIP17/KIP17Burnable.sol";
import "./klaytn-contracts/token/KIP17/KIP17Pausable.sol";

contract RiraUniversityTomoz is KIP17Full("Rirauniversity TOMOZ", "TOMOZ"), KIP17Mintable, KIP17MetadataMintable, KIP17Burnable, KIP17Pausable {

    function batchMint(address to, uint256[] calldata tokenId) external onlyMinter {
        for (uint256 i = 0; i < tokenId.length; i++) {
            mint(to, tokenId[i]);
        }
    }

    function batchMintWithTokenURI(address to, uint256[] calldata tokenId, string[] calldata tokenURI) external onlyMinter {
        for (uint256 i = 0; i < tokenId.length; i++) {
            mintWithTokenURI(to, tokenId[i], tokenURI[i]);
        }
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _tokensOfOwner(owner);
    }

    function setTokenURI(uint256 tokenId, string memory uri) public onlyMinter {
        _setTokenURI(tokenId, uri);
    }
}