import { GenesisNFTContract } from "../export/GenesisNFT";
import { Address, Deployer } from "../web3webdeploy/types";

export interface DeploymentSettings {
  forceRedeploy?: boolean;
}

export interface Deployment {
  minter: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: DeploymentSettings
): Promise<Deployment> {
  if (settings?.forceRedeploy !== undefined && !settings.forceRedeploy) {
    const existingDeployment = await deployer.loadDeployment({
      deploymentName: "minter.json",
    });
    if (existingDeployment !== undefined) {
      return existingDeployment;
    }
  }

  const nft = GenesisNFTContract.address;
  const stableCoin =
    deployer.settings.defaultChainId === 1
      ? "0xdAC17F958D2ee523a2206206994597C13D831ec7"
      : "0xC69258C33cCFD5d2F862CAE48D4F869Db59Abc6A";
  const receiver =
    deployer.settings.defaultChainId === 1
      ? "0x1807f6f41c8f7E886E3D325F5fb1F496446D4bCc"
      : "0xaF7E68bCb2Fc7295492A00177f14F59B92814e70";
  const tiers = [
    {
      currentlyMinted: 0,
      maxMinted: 2,
      tierPrefix: 100_000_000,
      stableCoinsPerNft: deployer.viem.parseUnits("50000", 6),
    },
    {
      currentlyMinted: 0,
      maxMinted: 8,
      tierPrefix: 200_000_000,
      stableCoinsPerNft: deployer.viem.parseUnits("25000", 6),
    },
    {
      currentlyMinted: 0,
      maxMinted: 20,
      tierPrefix: 300_000_000,
      stableCoinsPerNft: deployer.viem.parseUnits("10000", 6),
    },
  ];
  const minter = await deployer
    .deploy({
      id: "GenesisNFTMinter",
      contract: "GenesisNFTMinter",
      args: [nft, stableCoin, receiver, tiers],
    })
    .then((deployment) => deployment.address);

  await deployer.execute({
    id: "GenesisNFTMinterRole",
    abi: [...GenesisNFTContract.abi],
    to: GenesisNFTContract.address,
    function: "grantRole",
    args: [deployer.viem.keccak256(deployer.viem.toBytes("MINT")), minter],
    from: "0x3e166454c7781d3fD4ceaB18055cad87136970Ea",
  });

  const deployment = {
    minter: minter,
  };
  await deployer.saveDeployment({
    deploymentName: "minter.json",
    deployment: deployment,
  });
  return deployment;
}
