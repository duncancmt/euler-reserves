// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Common} from "./Common.s.sol";
import "forge-std/console.sol";

interface IERC20Meta {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

contract EulerReserves is Common {
  function run() public {
    _fork();

    string memory outputKey = "outputKey";
    string memory outputJson;
    for (uint256 i; i < _UNDERLYINGS.length; i++) {
      // get Euler reserve
      address underlying = _UNDERLYINGS[i];
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
      string memory underlyingKey = vm.toString(underlying);
      string memory underlyingJson = vm.serializeUint(underlyingKey, "reserve", reserve);

      // Because try ... catch in Solidity is a piece of shit, we have to do our
      // own manual checking of the ABIEncoding to avoid spurious
      // reverts. Strictly speaking, this is slightly too lax in the checking,
      // but in practice it works well enough.
      (bool success, bytes memory returnData) = underlying.staticcall(abi.encodeCall(IERC20Meta(underlying).name, ()));
      if (success && returnData.length > 64) {
        underlyingJson = vm.serializeString(underlyingKey, "name", abi.decode(returnData, (string)));
      }
      (success, returnData) = underlying.staticcall(abi.encodeCall(IERC20Meta(underlying).symbol, ()));
      if (success && returnData.length > 64) {
        underlyingJson = vm.serializeString(underlyingKey, "symbol", abi.decode(returnData, (string)));
      }
      (success, returnData) = underlying.staticcall(abi.encodeCall(IERC20Meta(underlying).decimals, ()));
      if (returnData.length >= 32) {
        underlyingJson = vm.serializeUint(underlyingKey, "decimals", abi.decode(returnData, (uint8)));
      }

      // Store the temporary object in the global object at outputKey. The
      // intermediate JSON is stored in outputJson before we write it to disk.
      outputJson = vm.serializeString(outputKey, underlyingKey, underlyingJson);
    }
    vm.writeJson(outputJson, "./output.json");
  }
}
