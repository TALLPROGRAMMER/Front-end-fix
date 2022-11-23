# How to Deploy using hardhat

1. Clone the repo.
2. CD into the repo directory and run `npm install`.
3. create .env file, copy and replace the content in the .env.example file to the .env file.
   1. Variables should remain the same as not to change the configuration.
   2. Get your BSCSCAN API key from bscscan.com and replace the dummy text with it (this is optional if you dont wish to verify the contracts).
   3. Paste the private key of the address you would be using into the env file. (Make sure you have enough tbnb or bsc for the transaction on testnet or mainnet respectively).
   4. Save the file
4. In the directory on your terminal run `npx hardhat compile` to compile the contracts and generate their artifacts (IMPORTANT!).
5. Run `npx hardhat run scripts/deploy.ts --network bscTestnet` to delpoy on bsc testnet or `npm hardhat run scripts/deploy.ts --network bscMainnet` to deploy on bsc mainnet.

## Contract verification

6. To verify the contracts:
   1. PNK Token
      - Run `npx hardhat verify --network bscTestnet <pnk token address> "<pnk airdrop contract address>"` (TAKE NOTE OF THE QUOTATIONS).
   2. PNK Airdrop contract - Run `npx hardhat verify --network bscTestnet <pnk airdrop contract address>`.

NB: To verify on mainnet, just switch `--network bscTestnet` to `--network bscMainnet`. If the above step fails, then you'd have to do it manually via the bscscan explorer.
