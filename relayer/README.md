### Steps to setup a relayer between WBA & Wasmd local chain

```
https://github.com/confio/ts-relayer
sudo npm i -g @confio/relayer@main

# binaries: ibc-setup, ibc-relayer

# ~/.ibc-setup, mangla = wasmd mainnet
ibc-setup init --src local_wasm --dest local_wba
# error? open the registry.yaml, and replace all "," -> "" nothing. not sure why there are there.

then we need to add the WBA chain to the config file
```

```yaml
  local_wba:
    chain_id: wba-t1
    prefix: wba
    gas_price: 0.025uwba
    hd_path: m/44'/118'/0'/0/0
    ics20_port: 'transfer'
    estimated_block_time: 7000,
    estimated_indexer_time: 250,
    rpc:
      - http://127.0.0.1:26657

# also update local_wasm since we use another chain id
  local_wasm:
    chain_id: wasmd-1
    prefix: wasm
    gas_price: 0.025ucosm
    hd_path: m/44'/1234'/0'/2'
    estimated_block_time: 400
    estimated_indexer_time: 60
    rpc:
      - http://localhost:26659
```


```bash
ibc-setup init --src local_wasm --dest local_wba
# Saved configuration to /home/reece/.ibc-setup/app.yaml
# Source address: wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc
# Destination address: wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk

# get both of these addresses from your relayer keys
ibc-setup keys list | grep "local_wasm\|local_wba"



# on chain startup, ensure to send both tokens

# open app.yaml in the relayer directory
# use the following mnemonic for testing purposes only (This way we know the wba & wasm keys on start & can add-genesis-account balances to them)
src: local_wasm
dest: local_wba
mnemonic: term egg forest panic canvas equip way artefact access lunar taste fringe


# Ensure that you add the above wasm address to the ./ci-scripts/wasmd/generate_template.sh if not already like so:
# docker run --rm \
#   -e PASSWORD=my-secret-password \
#   -e CHAIN_ID \
#   --mount type=bind,source="$SCRIPT_DIR/template",target=/root \
#   "$REPOSITORY:$VERSION" \
#   /opt/setup.sh \
#   wasm14qemq0vw6y3gc3u3e0aty2e764u4gs5lndxgyk \
#   wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc




# start wasmd docker node
./ci-scripts/wasmd/start.sh

# ensure that the account relayer has a balance
wasmd q bank balances wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc --node http://localhost:26659

# and then that wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk is in the ./test_node script to give balance


# start both now
./test_node.sh

# creates a new connection  on both src & destination chains
# saves to app.yaml
# creates a new connection
ibc-setup ics20 -v

# ERROR
# verbose: Queried unbonding period {"seconds":1814400}
# verbose: Create Tendermint client
# verbose: Queried unbonding period {"seconds":1814400}
# verbose: Create Tendermint client
# info: Connection open init: 07-tendermint-0 => 07-tendermint-0
# verbose: Get latest commit
# verbose: Get validator set for height 380
# verbose: Get header for height 380
# verbose: Get validator set for height 323
# verbose: Get header for height 323
# verbose: Update Tendermint client 07-tendermint-0
# info: Connection open try: 07-tendermint-0 => 07-tendermint-0 (connection-0)
# verbose: Get latest commit
# verbose: Get validator set for height 21
# verbose: Get header for height 21
# verbose: Get validator set for height 17
# verbose: Get header for height 17
# verbose: Update Tendermint client 07-tendermint-0
# info: Connection open ack: connection-0 => connection-0
# verbose: Get latest commit
# verbose: Get validator set for height 450
# verbose: Get header for height 450
# verbose: Get validator set for height 381
# verbose: Get header for height 381
# verbose: Update Tendermint client 07-tendermint-0
# info: Connection open confirm: connection-0
# Created connections [wasmd-1, connection-0, 07-tendermint-0] <=> [wba-t1, connection-0, 07-tendermint-0]
# info: Create channel with sender wasmd-1: transfer => transfer
# verbose: Channel open init: transfer => transfer (connection-0)
# verbose: Get latest commit
# verbose: Get validator set for height 497
# verbose: Get header for height 497
# verbose: Get validator set for height 451
# verbose: Get header for height 451
# verbose: Update Tendermint client 07-tendermint-0
# verbose: Channel open try: transfer => transfer (channel-0)
# error: Query failed with (6): failed to execute message; message index: 0: could not retrieve module from port-id: ports/transfer: capability not found: unknown request


# start
ibc-relayer start -v --poll 15
# send tokens vias IBC channel after above works
wasmd tx ibc-transfer transfer transfer <channel-id> $(junod keys show -a receiver) 200usponge --from $(wasmd keys show -a sender) --node http://localhost:26659 --chain-id wasmd-1 --fees 2000usponge --packet-timeout-height 0-0
```