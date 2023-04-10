// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Common, IERC20Meta} from "./Common.s.sol";

contract EulerReserves is Common {
  function run() public {
    _fork();

    string memory outputKey = "outputKey";
    string memory outputJson;

    for (uint256 i; i < _UNDERLYINGS.length; i++) {
      // get Euler reserve
      IERC20Meta underlying = _UNDERLYINGS[i];
      uint256 reserve = _MARKETS.underlyingToEToken(underlying).reserveBalanceUnderlying();

      // structure output as:
      //   "0xTokenAddress": {
      //     decimals?: number,
      //     name?: string,
      //     reserve: number,
      //     symbol?: string
      //   },
      //   ...
      // underlyingKey is used both as the identifier for the temporary object
      // and as the key that it's stored at in the outputKey object
      string memory underlyingKey = vm.toString(address(underlying));
      _metaToJson(underlyingKey, underlying);
      string memory underlyingJson = vm.serializeUint(underlyingKey, "reserve", reserve);
      // Store the temporary object in the global object at outputKey. The
      // intermediate JSON is stored in outputJson before we write it to disk.
      outputJson = vm.serializeString(outputKey, underlyingKey, underlyingJson);
    }
    vm.writeJson(outputJson, "./reserves.json");
  }
}
