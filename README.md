# Staking : défi Alyra (juillet 2021)

dApp de staking. On dépose des jetons ERC-20 ; au retrait, le contrat calcule la récompense selon la durée et le prix du jeton, lu sur un flux de prix Chainlink, et l'attribue en jeton ANTC.

- Contrats (Solidity 0.8.1, Truffle) : `Staking`, `CrowdsaleERC20Chainlink` (vente de jetons au prix Chainlink), `ERC20Chainlink`, `MyErc20Token`.
- Tests : `test/Staking.js` (7 cas) et `test/CrowdsaleERC20Chainlink.js`.
- Front : React et web3, dans `client/`.
- Configuré pour le réseau de test Rinkeby, abandonné depuis.

Exercice de formation, non maintenu.
