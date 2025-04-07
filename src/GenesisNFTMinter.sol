// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGenesisNFT} from "./IGenesisNFT.sol";
import {IERC20, SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract GenesisNFTMinter {
  IGenesisNFT public immutable nft;
  IERC20 public immutable stableCoin;
  address public receiver;

  struct Tier {
    uint8 currentlyMinted;
    uint8 maxMinted;
    uint32 tierPrefix;
    uint64 stableCoinsPerNft;
  }

  Tier[] public tiers;

  constructor(
    IGenesisNFT _nft,
    IERC20 _stableCoin,
    address _receiver,
    Tier[] memory _tiers
  ) {
    nft = _nft;
    stableCoin = _stableCoin;
    receiver = _receiver;
    tiers = _tiers;
  }

  function getStableCoinAmount(
    uint8[] memory amount
  ) public view returns (uint256 total) {
    for (uint256 i; i < amount.length; i++) {
      total += amount[i] * uint256(tiers[i].stableCoinsPerNft);
    }
  }

  function mint(uint8[] memory amount) external {
    _maxNftsLeft(amount);
    uint256 stableCoinAmount = getStableCoinAmount(amount);

    SafeERC20.safeTransferFrom(
      stableCoin,
      msg.sender,
      receiver,
      stableCoinAmount
    );
    for (uint256 i; i < amount.length; i++) {
      tiers[i].currentlyMinted += amount[i];
      while (amount[i] != 0) {
        nft.mint(
          msg.sender,
          tiers[i].tierPrefix + tiers[i].currentlyMinted - amount[i]
        );
        amount[i] -= 1;
      }
    }
  }

  function _maxNftsLeft(uint8[] memory amount) internal view {
    for (uint256 i; i < amount.length; i++) {
      uint8 leftToMint = tiers[i].maxMinted - tiers[i].currentlyMinted;
      if (amount[i] > leftToMint) {
        amount[i] = leftToMint;
      }
    }
  }
}
