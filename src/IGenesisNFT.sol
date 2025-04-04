// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGenesisNFT {
  event NFTMinted(address indexed by, uint256 indexed id);

  /// @notice Mints a token to an address.
  /// @param to The address receiving the token.
  /// @param tokenId The id of the token to be minted.
  /// @dev This should be behind a permission/restriction.
  function mint(address to, uint256 tokenId) external;
}
