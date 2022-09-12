#!/bin/sh
# Uploads, instantiates, and executes a wasm contract + queries

export KEY="wba1" # wba1hj5fveer5cjtn4wd6wstzugjfdxzl0xpcfe228
export KEYALGO="secp256k1"
export WBAD_CHAIN_ID="wba-t1"
export WBAD_KEYRING_BACKEND="os"
export WBAD_NODE="http://localhost:26657"
export WBAD_COMMAND_ARGS="--gas-prices="0.025uwba" --gas 5000000 -y --from $KEY"

export KEY_ADDR="wba1hj5fveer5cjtn4wd6wstzugjfdxzl0xpcfe228"
echo "decorate bright ozone fork gallery riot bus exhaust worth way bone indoor calm squirrel merry zero scheme cotton until shop any excess stage laundry" | wbad keys add $KEY --keyring-backend $wbad_KEYRING_BACKEND --algo $KEYALGO --recover


# For some reason eve returns all values in base64 & not human readable. Need to fix that
getCodeID() {
    TX_HASH=$1
    # wbad q tx $TX_HASH --output json | jq -r '.events[] | select(.type=="store_code").attributes[0].value' | base64 --decode
    wbad q tx $TX_HASH --output json | jq -r '.logs[].events[] | select(.type=="store_code").attributes[0].value'
}

echo "STORING CW721 TO CHAIN"
TX721=$(wbad tx wasm store cw721_base.wasm -y --broadcast-mode block --output json $wbad_COMMAND_ARGS | jq -r '.txhash')
# CODE_ID_721=$(wbad query tx $TX721 --output json | jq -r '.logs[0].events[-1].attributes[0].value')
CODE_ID_721=`getCodeID $TX721`
echo "CW721 WAS STORED, WITH CODE ID $CODE_ID_721"
NFT721_TX_UPLOAD=$(wbad tx wasm instantiate "$CODE_ID_721" '{"name": "wbad-721","symbol": "ctest","minter": "eve1hj5fveer5cjtn4wd6wstzugjfdxzl0xpysfwwn"}' --label "base_cw_721" $wbad_COMMAND_ARGS --output json --broadcast-mode block -y --admin $KEY_ADDR | jq -r '.txhash')
echo "INSTANCE instantiate'd"
ADDR721=$(wbad query tx $NFT721_TX_UPLOAD --output json | jq -r '.logs[0].events[0].attributes[0].value') && echo "ADDR 721: $ADDR721"
# eve1wkwy0xh89ksdgj9hr347dyd2dw7zesmtrue6kfzyml4vdtz6e5wsj3vejy

function mintToken() {
    CONTRACT_ADDR=$1
    TOKEN_ID=$2
    OWNER=$3
    TOKEN_URI=$4

    export EXECUTED_MINT_JSON=`printf '{"mint":{"token_id":"%s","owner":"%s","token_uri":"%s"}}' $TOKEN_ID $OWNER $TOKEN_URI`
    TXMINT=$(wbad tx wasm execute "$CONTRACT_ADDR" "$EXECUTED_MINT_JSON" --from $KEY --yes --output json --broadcast-mode block | jq -r '.txhash') && echo $TXMINT
}

# mint a token with id 1 to the contract
mintToken $ADDR721 1 "wba1hj5fveer5cjtn4wd6wstzugjfdxzl0xpcfe228" "https://ipfs.io/ipfs/QmNLijobERK4VhSDZdKjt5SrezdRM6k813qcSHd68f3Mqg"

# query the token data directly
echo $(wbad q wasm contract-state smart "$ADDR721" '{"all_nft_info":{"token_id":"1"}}' --output json) | jq -r '.data.info.token_uri'

# query all token_ids in a given contract
wbad query wasm contract-state smart $ADDR721 '{"tokens":{"owner":"wba1hj5fveer5cjtn4wd6wstzugjfdxzl0xpcfe228","start_after":"0","limit":50}}'