import { Address, Deployer } from "../web3webdeploy/types";

export interface DeploymentSettings {
  forceRedeploy?: boolean;
}

export interface Deployment {
  nft: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: DeploymentSettings
): Promise<Deployment> {
  if (settings?.forceRedeploy !== undefined && !settings.forceRedeploy) {
    const existingDeployment = await deployer.loadDeployment({
      deploymentName: "nft.json",
    });
    if (existingDeployment !== undefined) {
      return existingDeployment;
    }
  }

  const nft = await deployer
    .deploy({
      id: "GenesisNFT",
      contract: "GenesisNFT",
    })
    .then((deployment) => deployment.address);

  const deployment = {
    nft: nft,
  };
  await deployer.saveDeployment({
    deploymentName: "nft.json",
    deployment: deployment,
  });
  return deployment;
}
