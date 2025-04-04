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

  const nft = "0x";
  const stableCoin = "0x";
  const receiver = "0x";
  const minter = await deployer.deploy({
    id: "GenesisNFTMinter",
    contract: "GenesisNFTMinter",
    args: [nft, stableCoin, receiver],
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
