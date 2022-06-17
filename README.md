# Simple DeFi Banking Protocol Proof of Concept

## How It Works:
***Depositing***: Users are given two options: supplying ETH to Compound or suppyling ETH to Aave. Since both Compound and Aave give their own interest bearing tokens in return for supplying ETH, this bank protocol allows users to not hold any interest bearing tokens in their own wallet. Rather, any deposit plus interest would be stored by this smart contract. Therefore, users would not have to directly interact with the DeFi protocols as this contract would interact with them on their behalf and track their balances.

***Withdrawing***: After users deposit their ETH into Compound or Aave, they can withdraw their deposit amount plus any interest accrued. Something to note is that Compound's interest is accrued through their rising exchange rate for cTokens and Aave's interest is accrued directly by the aToken balance increasing for the holder.

## How the Protocol Stores User's Balances: 
***For Compound***: The main bank contract stores users' cToken (CETH) balances through a mapping.

***For Aave***: A separate user deposit contract stores users' aToken (AWETH) balances since interest is accrued directly. The addresses of these contracts are stored in a mapping.

## Note:
Currently, there is no borrowing functionality for users. The *hardhat* folder contains the framework that was used to develop this protocol with tests to check for functionality. The *poc* folder contains the smart contracts for this protocol. (Users will need to download the some OpenZeppelin modules that are used throughout the contracts)
