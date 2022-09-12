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

```
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
```


```bash
ibc-setup init --src local_wasm --dest local_wba
# Saved configuration to /home/reece/.ibc-setup/app.yaml
# Source address: wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc
# Destination address: wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk

# get both of these addresses from your relayer keys
ibc-setup keys list | grep "local_wasm\|local_wba"

# local_wasm: wasm18ef4ede5mscprrx3270flk9d0w4f2mppw3e6sc
# local_wba: wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk

# on chain startup, ensure to send both tokens
```