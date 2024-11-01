# NFT MARKET Contract

This is an enhanced NFT implementation in Clarity 6.0 featuring batch minting, burning, and URI update functionality.

## Features
- **Batch Minting**: Mint multiple NFTs in a single transaction.
- **Burning Tokens**: Allows owners to burn their NFTs.
- **Update Token URI**: Update the URI associated with an NFT.
- **Read-Only Functions**: Retrieve token URI, owner information, and token status.

## Constants
- `contract-owner`: The owner of the contract.
- `err-owner-only`: Error for unauthorized access.
- `err-not-token-owner`: Error when a non-owner tries to access a token.
- `err-token-exists`: Error when a token already exists.
- `err-token-not-found`: Error when a token does not exist.
- `err-invalid-token-uri`: Error for invalid token URIs.
- `err-burn-failed`: Error when a burn operation fails.
- `err-already-burned`: Error when a token has already been burned.
- `err-not-token-owner-update`: Error for unauthorized URI updates.
- `err-invalid-batch-size`: Error for invalid batch sizes.
- `err-batch-mint-failed`: Error when batch minting fails.
- `max-batch-size`: Maximum number of tokens that can be minted in a single batch.

## Data Variables
- `simple-nft`: Non-fungible token definition.
- `last-token-id`: Variable to track the last minted token ID.

## Maps
- `token-uri`: Stores the URI for each token.
- `burned-tokens`: Tracks the status of burned tokens.
- `batch-metadata`: Stores metadata for batch operations.

## Private Functions
- **is-token-owner**: Checks if the sender is the owner of the token.
- **is-valid-token-uri**: Validates the token URI length.
- **is-token-burned**: Checks if a token has been burned.
- **mint-single**: Mints a single NFT and updates the token URI.

## Public Functions
- **mint**: Mints a single NFT with a given URI.
- **batch-mint**: Mints multiple NFTs in a single transaction.
- **burn**: Burns a specified NFT.
- **transfer**: Transfers ownership of a token from one user to another.
- **update-token-uri**: Updates the URI of a specified NFT.

## Read-Only Functions
- **get-token-uri**: Retrieves the URI for a given token ID.
- **get-owner**: Gets the owner of a specific token.
- **get-last-token-id**: Returns the last minted token ID.
- **is-burned**: Checks if a token has been burned.
- **get-batch-token-ids**: Retrieves a batch of token IDs and their details.

## Contract Initialization
The contract initializes the `last-token-id` to zero upon deployment.

---

This contract is designed to be extensible and can be integrated into various applications that require NFT functionality on the Stacks blockchain.
