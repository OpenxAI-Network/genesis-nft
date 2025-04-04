// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {GenesisNFT, ADMIN} from "../src/GenesisNFT.sol";
import {GenesisNFTMinter} from "../src/GenesisNFTMinter.sol";

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor() ERC20("Mock ERC20", "TEST") {}

  function setBalance(address account, uint256 amount) external {
    uint256 currentBalance = balanceOf(account);
    if (amount > currentBalance) {
      _mint(account, amount - currentBalance);
    } else if (amount < currentBalance) {
      _burn(account, currentBalance - amount);
    }
  }
}

contract GenesisNFTMinterTest is Test {
  GenesisNFT public nft;
  MockERC20 public stableCoin;
  GenesisNFTMinter public minter;

  function setUp() public {
    nft = new GenesisNFT();
    stableCoin = new MockERC20();
    minter = new GenesisNFTMinter(nft, stableCoin, address(this));

    vm.startPrank(ADMIN);
    nft.grantRole(nft.MINT_ROLE(), address(minter));
    vm.stopPrank();
  }

  struct Participate {
    address participant;
    uint8 amount;
  }

  function test(Participate[] memory participations) public {
    for (uint256 i = 0; i < participations.length; i++) {
      vm.assume(
        participations[i].participant != address(0) &&
          participations[i].participant != address(this)
      ); // cannot receive ERC20
    }

    for (uint256 i = 0; i < participations.length; i++) {
      Participate memory participation = participations[i];

      uint8 receiveAmount = participation.amount;
      uint8 nftsLeft = minter.maxMinted() - minter.currentlyMinted();
      if (receiveAmount > nftsLeft) {
        receiveAmount = nftsLeft;
      }

      uint256 funds = participation.amount * minter.stableCoinsPerNft();
      stableCoin.setBalance(participation.participant, funds);

      uint256 nftsBefore = nft.balanceOf(participation.participant);

      vm.startPrank(participation.participant);
      stableCoin.approve(address(minter), funds);
      minter.mint(participation.amount);
      vm.stopPrank();

      vm.assertEq(
        stableCoin.balanceOf(participation.participant),
        (participation.amount - receiveAmount) * minter.stableCoinsPerNft()
      );
      vm.assertEq(
        nft.balanceOf(participation.participant),
        nftsBefore + receiveAmount
      );
      vm.assertEq(
        stableCoin.balanceOf(address(this)),
        minter.currentlyMinted() * minter.stableCoinsPerNft()
      );
    }
  }
}
