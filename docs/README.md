## What is this?
This project is a base layer 1 chain from the CosmosSDK [SimApp](https://github.com/cosmos/cosmos-sdk/tree/v0.46.1/simapp)
It has had all its test gutted to be the bare minimum needed to help teach cadets about the CosmosSDK.

---

## How was it done
We took a CosmosSDK layer 1 (Eve, credit in readme) which was a fork of the SimApp. From here we removed all its custom modules, logic, and keepers.
By doing this we were left with just a functioning chain, but it still had the old name "eved" and "eve".
To resolve this we ctrl + shift + h in the VSCode terminal to open a find and replace.
We then replaced all instances of "eved" and "wbad" and "ueve" to "uwba" respectively.

This way the home folder would be ~/.wbad/ to store the configs, chain data, and the genesis file.
Another option is to use the ignite CLI, however, learning how it is done under the hood is a good exercise to understand the CosmosSDK.

You can follow the [INSTALL](./INSTALL.md) file to install this chain, or reference the main README.md for other information.

---

## How the CosmosSDK App works (high level)
- TODO (go.mod, app.go, root.go, genesis, validators, CLI flags, CLI commands, proto)

## Future
The goal of this repo is to run a custom WBA chain + a Wasmd on different ports.
Then once that is completed, run a Hermes and/or ts-relayer between both and transfer tokens locally.
Initially, this will be done by running 3 scripts manually however in the future this will be all via docker-compose.

## Video In Action
- TODO

