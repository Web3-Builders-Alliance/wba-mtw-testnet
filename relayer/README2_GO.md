https://github.com/cosmos/relayer

git clone https://github.com/cosmos/relayer.git
git checkout v2.1.0-rc1
make install


rly config init --memo "Reeces Relayer"


code ~/.relayer/config/config.yaml

# normal way, how do do it for custom chains?
rly chains add cosmoshub osmosis


# to do that we do
touch local_wba.json
put data from https://raw.githubusercontent.com/cosmos/relayer/main/docs/example-configs/cosmoshub-4.json
into that file & modify to what we need


rly chains add --file relayer/local_wba.json wba

rly chains add --file relayer/local_wasm.json wasm
rly chains add --file relayer/craft.json craft


### wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk
rly keys restore wba relayer "term egg forest panic canvas equip way artefact access lunar taste fringe"

### wasm1lwwr2junyeej0mts25rmjshqw2cw8w66mvpyle
rly keys restore wasm relayer "term egg forest panic canvas equip way artefact access lunar taste fringe"

## craft1lwwr2junyeej0mts25rmjshqw2cw8w66sxrxnw
rly keys restore craft relayer "term egg forest panic canvas equip way artefact access lunar taste fringe"

(wasmd is to quick with blocks, so using craft testnet as a way to have 2 test chains for this example. Wallet has 1k fees)

# change keynames in the ~/.relayer/config/config.yaml file to 'relayer' (or your key names)


# rly paths new wasmd-1 wba-t1 wasmwba

# rly paths new wba-t1 craft-v5 wc


<!-- rly transact client wba wasm wasmwba -->
OR
rly transact link wasmwba # ensure both chaions have the proper fees setup

# for more control ^^
https://github.com/cosmos/relayer/blob/main/docs/create-path-across-chain.md


## how to create chnanel?
rly transact channel wasmwba --src-port transfer --dst-port transfer --order unordered --version ics20-1



wbad tx ibc-transfer transfer transfer channel-0 craft1lwwr2junyeej0mts25rmjshqw2cw8w66sxrxnw 72uwba --from wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk --node http://127.0.0.1:26657 --chain-id wba-t1 --fees 5000uwba --packet-timeout-height 0-0 --yes


