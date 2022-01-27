pragma solidity ^0.5.6;

import "hardhat/console.sol";
import "./rira-utils/Strings.sol";
import "./klaytn-contracts/token/KIP17/KIP17Full.sol";
import "./klaytn-contracts/token/KIP17/KIP17Mintable.sol";
import "./klaytn-contracts/token/KIP17/KIP17Pausable.sol";

contract RiraTomoz is KIP17Full("Rira Institute of Technology TOMOZ", "TOMO"), KIP17Mintable, KIP17Pausable {

    event SetVariableBaseUri(address indexed minter, string uri);
    event SetTomoUriIndex(uint256 tokenId, uint256 index);
    mapping (uint256 => string) private _variableBaseUris;
    mapping (uint256 => uint256) private _tomoUriIndex;

    uint256 public mintLimit = 10000;

    //return baseURI + token id
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for nonexistent token");
        string memory _uri = _variableBaseUris[_tomoUriIndex[tokenId]];
        return string(abi.encodePacked(_uri, Strings.fromUint256(tokenId)));
    }

    function variableBaseUri(uint256 index) public view returns (string memory) {
        return _variableBaseUris[index];
    }

    function setVariableBaseUri(uint256 index, string memory uri) public onlyMinter {
        _variableBaseUris[index] = uri;
        emit SetVariableBaseUri(msg.sender, uri);
    }

    function setTomoUriIndex(uint256 tokenId, uint256 index) public onlyMinter {
        require(_exists(tokenId), "KIP17Metadata: URI query for nonexistent token");
        _tomoUriIndex[tokenId] = index;
        emit SetTomoUriIndex(tokenId, index);
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