### Install Instructions

##### Step 1: Install local wbad blockchain

Run ```make install``` 
- Test that install was successful by running ```wbad```

If install was not successfull, install with go by running ```go install ./...``` in the root directory. 
- Then, install database by running ```go install -ldflags '-w -s -X github.com/cosmos/cosmos-sdk/types.DBBackend=pebbledb' -tags pebbledb ./...```

##### Step 2: Run local wbad blockchain 

Run ```./test_node.sh```
