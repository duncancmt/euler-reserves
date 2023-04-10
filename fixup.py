#!/usr/bin/env python3

import json
import os.path

result = {}

for i in range(0, 7000, 100):
    try:
        with open(f"./balances_out/balances.{i}.json", "r") as f:
            result.update(json.load(f));
    except FileNotFoundError:
        pass

with open("./reserves.json", "r") as f:
    tokenInfo = json.load(f)
for token in tokenInfo.keys():
    del tokenInfo[token]["reserve"]

for user in result.keys():
    for token in result[user].keys():
        result[user][token].update(tokenInfo[token])

with open("./balances.json", "w") as f:
    json.dump(result, f, indent=2)
