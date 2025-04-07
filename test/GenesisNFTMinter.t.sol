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
  GenesisNFTMinter.Tier[] public tiers;

  function setUp() public {
    tiers = new GenesisNFTMinter.Tier[](3);
    tiers[0] = GenesisNFTMinter.Tier(0, 2, 100_000_000, 50_000_000_000);
    tiers[1] = GenesisNFTMinter.Tier(0, 8, 200_000_000, 25_000_000_000);
    tiers[2] = GenesisNFTMinter.Tier(0, 20, 300_000_000, 10_000_000_000);

    nft = new GenesisNFT();
    stableCoin = new MockERC20();
    minter = new GenesisNFTMinter(nft, stableCoin, address(this), tiers);

    vm.startPrank(ADMIN);
    nft.grantRole(nft.MINT_ROLE(), address(minter));
    vm.stopPrank();
  }

  struct Participate {
    address participant;
    uint8 tier1amount;
    uint8 tier2amount;
    uint8 tier3amount;
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

      (
        uint8 tier1Minted,
        uint8 tier1Max,
        uint32 tier1Prefix,
        uint64 tier1StableCoinsPerNft
      ) = minter.tiers(0);
      (
        uint8 tier2Minted,
        uint8 tier2Max,
        uint32 tier2Prefix,
        uint64 tier2StableCoinsPerNft
      ) = minter.tiers(1);
      (
        uint8 tier3Minted,
        uint8 tier3Max,
        uint32 tier3Prefix,
        uint64 tier3StableCoinsPerNft
      ) = minter.tiers(2);

      uint8[] memory participationAmount = new uint8[](3);
      participationAmount[0] = participation.tier1amount;
      participationAmount[1] = participation.tier2amount;
      participationAmount[2] = participation.tier3amount;

      uint8[] memory leftAmount = new uint8[](3);
      leftAmount[0] = tier1Max - tier1Minted;
      leftAmount[1] = tier2Max - tier2Minted;
      leftAmount[2] = tier3Max - tier3Minted;

      uint8[] memory receiveAmount = new uint8[](3);
      for (uint256 j = 0; j < 3; j++) {
        if (participationAmount[j] > leftAmount[j]) {
          receiveAmount[j] = leftAmount[j];
        } else {
          receiveAmount[j] = participationAmount[j];
        }
      }

      uint256 funds = participation.tier1amount *
        tier1StableCoinsPerNft +
        participation.tier2amount *
        tier2StableCoinsPerNft +
        participation.tier3amount *
        tier3StableCoinsPerNft;
      uint256 expectedTakenFunds = minter.getStableCoinAmount(receiveAmount);
      stableCoin.setBalance(participation.participant, funds);

      uint256 nftsBefore = nft.balanceOf(participation.participant);
      uint256 stableCoinsBefore = stableCoin.balanceOf(address(this));

      vm.startPrank(participation.participant);
      stableCoin.approve(address(minter), funds);
      minter.mint(participationAmount);
      vm.stopPrank();

      vm.assertEq(
        stableCoin.balanceOf(participation.participant),
        funds - expectedTakenFunds
      );
      vm.assertEq(
        nft.balanceOf(participation.participant),
        nftsBefore + receiveAmount[0] + receiveAmount[1] + receiveAmount[2]
      );
      vm.assertEq(
        stableCoin.balanceOf(address(this)),
        stableCoinsBefore + expectedTakenFunds
      );
    }
  }
}
