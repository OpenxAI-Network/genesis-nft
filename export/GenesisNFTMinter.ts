export const GenesisNFTMinterContract = {
  abi: [
    {
      type: "constructor",
      inputs: [
        { name: "_nft", type: "address", internalType: "contract IGenesisNFT" },
        {
          name: "_stableCoin",
          type: "address",
          internalType: "contract IERC20",
        },
        { name: "_receiver", type: "address", internalType: "address" },
        {
          name: "_tiers",
          type: "tuple[]",
          internalType: "struct GenesisNFTMinter.Tier[]",
          components: [
            { name: "currentlyMinted", type: "uint8", internalType: "uint8" },
            { name: "maxMinted", type: "uint8", internalType: "uint8" },
            { name: "tierPrefix", type: "uint32", internalType: "uint32" },
            {
              name: "stableCoinsPerNft",
              type: "uint64",
              internalType: "uint64",
            },
          ],
        },
      ],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "getStableCoinAmount",
      inputs: [{ name: "amount", type: "uint8[]", internalType: "uint8[]" }],
      outputs: [{ name: "total", type: "uint256", internalType: "uint256" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "mint",
      inputs: [{ name: "amount", type: "uint8[]", internalType: "uint8[]" }],
      outputs: [],
      stateMutability: "nonpayable",
    },
    {
      type: "function",
      name: "nft",
      inputs: [],
      outputs: [
        { name: "", type: "address", internalType: "contract IGenesisNFT" },
      ],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "receiver",
      inputs: [],
      outputs: [{ name: "", type: "address", internalType: "address" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "stableCoin",
      inputs: [],
      outputs: [{ name: "", type: "address", internalType: "contract IERC20" }],
      stateMutability: "view",
    },
    {
      type: "function",
      name: "tiers",
      inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
      outputs: [
        { name: "currentlyMinted", type: "uint8", internalType: "uint8" },
        { name: "maxMinted", type: "uint8", internalType: "uint8" },
        { name: "tierPrefix", type: "uint32", internalType: "uint32" },
        { name: "stableCoinsPerNft", type: "uint64", internalType: "uint64" },
      ],
      stateMutability: "view",
    },
    {
      type: "error",
      name: "SafeERC20FailedOperation",
      inputs: [{ name: "token", type: "address", internalType: "address" }],
    },
  ],
} as const;
