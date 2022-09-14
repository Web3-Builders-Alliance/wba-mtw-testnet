# Ensure eve is installed first.

KEY="wba1"
KEY2="wba2"
CHAINID="wba-t1"
MONIKER="localeve"
KEYALGO="secp256k1"
KEYRING="test" # export EVE_KEYRING="TEST"
LOGLEVEL="info"
TRACE="" # "--trace"


wbad config keyring-backend $KEYRING
wbad config chain-id $CHAINID
wbad config output "json"

command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

from_scratch () {

  echo "Building WBA executable from ./build.sh file"
  sh build.sh # some have issues with 'make install'

  # remove existing daemon
  rm -rf ~/.wbad/* 
    
  # Create 2 accounts from the KEY variables (only the first is a validator, DO NOT USE THESE FOR ANYTHING OTHER THAN TESTING)
  # wba1hj5fveer5cjtn4wd6wstzugjfdxzl0xpcfe228
  echo "decorate bright ozone fork gallery riot bus exhaust worth way bone indoor calm squirrel merry zero scheme cotton until shop any excess stage laundry" | wbad keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --recover
  # wba13unas8vt8lz8dzyxhqjc8kw54423qm50ve9hp9
  echo "suggest spike coral earth bring smart again entry quick setup alpha help ahead program give cup fashion pact citizen three wave harsh run ramp" | wbad keys add $KEY2 --keyring-backend $KEYRING --algo $KEYALGO --recover

  # Set moniker and chain-id for Wba
  wbad init $MONIKER --chain-id $CHAINID 

  # Function updates the config based on a jq argument as a string
  update_test_genesis () {
    # update_test_genesis '.consensus_params["block"]["max_gas"]="100000000"'
    cat $HOME/.wbad/config/genesis.json | jq "$1" > $HOME/.wbad/config/tmp_genesis.json && mv $HOME/.wbad/config/tmp_genesis.json $HOME/.wbad/config/genesis.json
  }

  # Set gas limit in genesis
  update_test_genesis '.consensus_params["block"]["max_gas"]="100000000"'
  update_test_genesis '.app_state["gov"]["voting_params"]["voting_period"]="15s"'  
  update_test_genesis '.app_state["staking"]["params"]["bond_denom"]="uwba"'
  # update_test_genesis '.app_state["bank"]["params"]["send_enabled"]=[{"denom": "uwbanottransferable","enabled": false}]'
  update_test_genesis '.app_state["staking"]["params"]["min_commission_rate"]="0.050000000000000000"'
  update_test_genesis '.app_state["mint"]["params"]["mint_denom"]="uwba"'  
  update_test_genesis '.app_state["gov"]["deposit_params"]["min_deposit"]=[{"denom": "uwba","amount": "1000000"}]'
  update_test_genesis '.app_state["crisis"]["constant_fee"]={"denom": "uwba","amount": "1000"}'


  # Allocate genesis accounts, first is validator  
  wbad add-genesis-account $KEY 1000000000uwba --keyring-backend $KEYRING
  wbad add-genesis-account $KEY2 100000000uwba,100uowba2token --keyring-backend $KEYRING  
  wbad add-genesis-account wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk 100000000uwba --keyring-backend $KEYRING   # rly

  # give relayer some tokens
  wbad add-genesis-account wba1lwwr2junyeej0mts25rmjshqw2cw8w6604mfsk 1000000000uwba --keyring-backend $KEYRING  

  # create gentx with 1 wba
  wbad gentx $KEY 10000000uwba --keyring-backend $KEYRING --chain-id $CHAINID

  # Collect genesis tx
  wbad collect-gentxs

  # Run this to ensure everything worked and that the genesis file is setup correctly
  wbad validate-genesis
}

from_scratch

# Opens the RPC endpoint to outside connections
sed -i '/laddr = "tcp:\/\/127.0.0.1:26657"/c\laddr = "tcp:\/\/0.0.0.0:26657"' ~/.wbad/config/config.toml
sed -i 's/cors_allowed_origins = \[\]/cors_allowed_origins = \["\*"\]/g' ~/.wbad/config/config.toml

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
wbad start --pruning=nothing  --minimum-gas-prices=0uwba