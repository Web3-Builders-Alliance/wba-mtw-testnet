## Commands / Guide


## Ensure you install from main
sudo npm i -g @confio/relayer@main

## Init the src & dest chains
ibc-setup init --src local_wasm --dest local_wba
(THIS WILL FAIL)

open the registry.yaml, and replace all "," -> "" nothing. not sure why there are there.
(ctrl + f, , -> (nothing in the 2nd box), replace all)

Update the following
```yaml
  local_wba:
    chain_id: wba-t1
    prefix: wba
    gas_price: 0.025uwba
    hd_path: m/44'/118'/0'/0/0 # we just use standard 118 = cosmos path
    ics20_port: 'transfer'
    estimated_block_time: 7000
    estimated_indexer_time: 250
    rpc:
      - http://127.0.0.1:26657

  # also update local_wasm since we use another chain id for here
  local_wasm:
    chain_id: wasmd-1
    prefix: wasm
    gas_price: 0.025ucosm
    hd_path: m/44'/1234'/0'/2' # wasmd keys add relayer --recover --hd-path "m/44'/1234'/0'/2'"
    estimated_block_time: 400
    estimated_indexer_time: 60
    rpc:
      - http://localhost:26659 # the docker exposed port we use
```

## now this will work & create an app.yaml
ibc-setup init --src local_wba --dest local_wasm

Change the app.yaml mnemonic to the following
```yaml
mnemonic: term egg forest panic canvas equip way artefact access lunar taste fringe
```
(This is so we get the same testing keys for our test environment)


## setup channel between both
So long as both accounts have tokens & they were imported correctly, lets setup the ics20 (transfer) connection in verbose mode.

```bash
ibc-setup ics20 -v

# ...
# Created channel:
#   wasmd-1: transfer/channel-0 (connection-0)
#   craft-v5: transfer/channel-0 (connection-0)
```
*This will take a little bit since our main chain => 6-7s blocks*


Once you see the above you can start a relayer & begin querying for packets!
```bash
ibc-relayer start -v --poll 7
# Where 7 = 7 seconds of sleeping between chains.
# Set this as slow as you like, or as fast as the slowest chains blocktimes
# Ex: chain1=2s, chain2=10s, set poll to 10s+ as it is the bottleneck. 
```


# Sending tokens between

We need to send some uwba tokens to an address on another chain. Here is how that is done

wbad send some 690uwba to OTHER_CHAIN_ACCOUNT from OUR_WBA_ACCOUNTon the src connection of channel-0 (init channel)

```bash
wbad tx ibc-transfer transfer transfer channel-0 wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc 72uwba --from wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk --node http://127.0.0.1:26657 --chain-id wba-t1 --fees 5000uwba --packet-timeout-height 0-0

# add --yes to the end to auto sign a broadcast

# ensure it went through you can query the Tx hash on the WBA chain
wba q tx <TXHASHHERE> --node http://127.0.0.1:26657

# in this case we are sending from wba1lw -> wasm18e
# we use the wba node RPC 26657 since that is the SRC chain.
# relayers pay fees, in this case we set 5000uwba as default.

# When we generate the Tx you will see gas_amount, this is typically 200,000.
# With this we can estimate the cost of this transaction given the 0.025uwba
# 0.025uwba gas price * 200000 gas likely to be used  = 5000uwba fee to chain
```


After a few seconds, the relayer will pick up the Tx, and transfer it over to the other chain & you now have your WBA there! But wait... How do you check?

We need to query the receiving address to ensure they have the WBA denom of 72uwba!
```bash
wasmd q bank balances wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc --node http://localhost:26659
# of what ever port you are running the wasmd / other chain on which is not the WBA chain

# balances:
# - amount: "72"
#   denom: ibc/EC389C35C5F7180B6B6677A1AD112DB1BADA6655B38D7B1FB673F06DD9BD9666
```

What is this denom? That's not WBA token... Well, it is, but it is a voucher of the WBA token which gets updates as it moves chains. While this token IS WBA under the hood, any chain it is on makes it another version of that WBA token.
*(Even tho it is a WBA token voucher, the supply is BURNED from the source chain so there can be no duplication of tokens)*

WBA on Juno is not the same as WBA on osmosis, but it is always redeemable back on the WBA chain directly which is the same token.

now we query it & ensure it is WBA token
```bash
wasmd q ibc-transfer denom-trace EC389C35C5F7180B6B6677A1AD112DB1BADA6655B38D7B1FB673F06DD9BD9666 --node http://localhost:26659
# denom_trace:
#   base_denom: uwba
#   path: transfer/channel-0
```

And just like that, we have the uwba token on the wasmd chain! 

The power of IBC is that any chain can send tokens to any other in a permissions fashion (so long as you have some initial tokens and the computer to relay). This means you could send your WBA token to osmosis now, then create a pool with it and osmosis.
In a testnet setting this does not make sense, but for a mainnet it is super easy and powerful to transfer tokens between chains!