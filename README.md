## MYSELF

### Environment Setup

```shell
source .env
```

- Create a Foundry project:

```shell
forge init
```

### Testing

- Run a specific test with verbose output:

```shell
forge test --match-test test_get_version -vvvvv --rpc-url $SEPOLIA_RPC
```

- Generate a coverage report:

```shell
forge coverage -vvvvv --rpc-url $BINANCE_RPC
```

- Testing follows three stages:
  1. **Arrange**: Set up the test environment.
  2. **Act**: Execute the function or action being tested.
  3. **Assert**: Verify the expected outcome.

### Compilation

- Compile the contracts:

```shell
forge build
```

- Compile with a specific Solidity version:

```shell
forge build --compiler-version 0.8.19
```

### Deployment

- Deploy a contract interactively:

```shell
forge create FundMeSiya --rpc-url http://127.0.0.1:8545 --interactive --broadcast
```

- Run a script to deploy a contract:

```shell
forge script script/Counter.s.sol:CounterScript --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Interacting with Contracts

- Send a transaction to a contract:

```shell
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "setNumber(uint256 newNumber)" 2 --rpc-url http://127.0.0.1:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

- Call a function on a contract:

```shell
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "getNumber()" --rpc-url http://127.0.0.1:8545
```

### Cast Utility

- Convert to hex:

```shell
cast to-hex 1234
```

- Convert to decimal:

```shell
cast to-dec 0x4d2
```

### Cast Wallet

- Create a new wallet:

```shell
cast wallet import ArminMainWallet --interactive
```

- Get the Cast wallet list:

```shell
cast wallet list
```

- Use a specific wallet for transactions:

```shell
forge script script/Counter.s.sol:CounterScript --rpc-url $SEPOLIA_RPC --broadcast --account ArminMainWallet --sender 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

### Gas Analysis

- Get gas usage for a specific test:

```shell
forge snapshot --mt withdraw
```

### Storage Layout

- Inspect the storage layout of a contract:

```shell
forge inspect FundMeSiya storageLayout
```

- Retrieve a specific storage slot value:

```shell
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 2
```

### Miscellaneous

- Get the function signature for a given function name:

```shell
cast sig "armin()"
```

- Generate a gas report for tests:

```shell
forge test --gas-report
```

### CEI Pattern

- **CEI**: Check-Effects-Interactions pattern is a best practice for writing secure smart contracts. It helps prevent reentrancy attacks by ensuring that all state changes (effects) are made before any external calls (interactions).
  1. **Check**: Validate conditions and inputs.
  2. **Effects**: Update the contract's state.
  3. **Interactions**: Call external contracts or transfer funds.
- **Example**: In the `withdraw` function, first check if the caller is the owner, then update the balance, and finally transfer funds to the owner. This order prevents reentrancy attacks by ensuring that the state is updated before any external calls are made.

### Foundry cheatcodes
- **Cheatcodes**: Foundry provides a set of cheatcodes that allow you to manipulate the EVM state during testing. These cheatcodes can be used to simulate various scenarios, such as reverting transactions, manipulating block timestamps, and more.

- **start broadcasting**: You can use the `vm.startBroadcast()` cheatcode to start broadcasting transactions. This is useful for testing how your contract behaves when called by different addresses.
- **stop broadcasting**: You can use the `vm.stopBroadcast()` cheatcode to stop broadcasting transactions. This is useful for testing how your contract behaves when called by different addresses.
- **create an address**: You can use the `vm.makeAddr()` cheatcode to create a new address. This is useful for testing how your contract behaves when called by different addresses.
- **add balance**: You can use the `vm.deal()` cheatcode to add balance to an address. This is useful for testing how your contract behaves when called with different balances.
- **Prank the sender of the transaction**: You can use the `vm.prank()` cheatcode to change the sender of a transaction. This is useful for testing how your contract behaves when called by different addresses
- **start pranking**: You can use the `vm.startPrank()` cheatcode to start a prank. This is useful for testing how your contract behaves when called by different addresses.
- **stop pranking**: You can use the `vm.stopPrank()` cheatcode to stop a prank. This is useful for testing how your contract behaves when called by different addresses.
- **set the block timestamp**: You can use the `vm.warp()` cheatcode to set the block timestamp. This is useful for testing time-dependent logic in your contracts.
- **set the block number**: You can use the `vm.roll()` cheatcode to set the block number. This is useful for testing block-dependent logic in your contracts.
- **expect revert**: You can use the `vm.expectRevert()` cheatcode to expect a transaction to revert. This is useful for testing how your contract behaves when called with invalid inputs.
- **expect emit**: You can use the `vm.expectEmit()` cheatcode to expect an event to be emitted. This is useful for testing how your contract behaves when called with valid inputs.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

this link is for chain link vrf v2.5 example contract
https://docs.chain.link/samples/VRF/v2-5/VRFD20.sol

https://remix.ethereum.org/#url=https://docs.chain.link/samples/VRF/v2-5/VRFD20.sol&autoCompile=true&lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.19+commit.7dd6d404.js
