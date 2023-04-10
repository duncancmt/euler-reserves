#!/bin/bash

set -eufo pipefail

for i in $(seq 0 100 7000) ; do
    echo $i >&2
    time forge script EulerBalances --sig 'run(uint256,uint256)' "$(cast abi-encode 'foo(uint256)' $i)" "$(cast abi-encode "foo(uint256)" $((i + 100)))"
done
