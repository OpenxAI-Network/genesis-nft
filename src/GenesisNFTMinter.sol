// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGenesisNFT} from "./IGenesisNFT.sol";
import {IERC20, SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract GenesisNFTMinter {
  IGenesisNFT public immutable nft;
  IERC20 public immutable stableCoin;
  address public receiver;

  uint8 public currentlyMinted;
  uint8 public constant maxMinted = 50;

  uint256 public constant stableCoinsPerNft = 10000000000;

  constructor(IGenesisNFT _nft, IERC20 _stableCoin, address _receiver) {
    nft = _nft;
    stableCoin = _stableCoin;
    receiver = _receiver;
  }

  function mint(uint8 amount) external {
    uint8 leftToMint = maxMinted - currentlyMinted;
    if (amount > leftToMint) {
      amount = leftToMint;
    }

    SafeERC20.safeTransferFrom(
      stableCoin,
      msg.sender,
      receiver,
      amount * stableCoinsPerNft
    );
    currentlyMinted += amount;
    while (amount != 0) {
      nft.mint(msg.sender, currentlyMinted - amount);
      --amount;
    }
  }
}
