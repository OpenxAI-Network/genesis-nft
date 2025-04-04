// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {IGenesisNFT} from "./IGenesisNFT.sol";

address constant ADMIN = 0x3e166454c7781d3fD4ceaB18055cad87136970Ea;

contract GenesisNFT is ERC721, AccessControl, IGenesisNFT {
  bytes32 public constant MINT_ROLE = keccak256("MINT");
  string private metadataUri = "https://erc721.openxai.org/metadata/ogn/";

  constructor() ERC721("OpenxAI Genesis NFT", "OGN") {
    _grantRole(DEFAULT_ADMIN_ROLE, ADMIN);
  }

  function supportsInterface(
    bytes4 _interfaceId
  ) public view virtual override(ERC721, AccessControl) returns (bool) {
    return
      ERC721.supportsInterface(_interfaceId) ||
      AccessControl.supportsInterface(_interfaceId);
  }

  /// @inheritdoc IGenesisNFT
  function mint(address to, uint256 tokenId) external onlyRole(MINT_ROLE) {
    _mint(to, tokenId);
  }

  function _baseURI() internal view override returns (string memory) {
    return metadataUri;
  }
}
