// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Common, IERC20Meta, IEToken, IDToken} from "./Common.s.sol";

contract EulerBalances is Common {
  function run() public {
    _fork();

    string memory outputKey = "outputKey";
    string memory outputJson;

    for (uint256 j; j < _USERS.length; j++) {
      // for convenience of parsing, we put the user as the top-level object,
      // even though it's more natural and gas efficient to put the underlying
      // token there instead
      address user = _USERS[j];

      // structure output as:
      //   "0xAccountAddress": {
      //     "0xTokenAddress": {
      //       decimals?: number,
      //       name?: string,
      //       symbol?: string
      //       collateral?: number,
      //       borrow?: number,
      //     },
      //     ...
      //   },
      //   ...
      // if a user has no collateral or borrow in a token, that token is omitted.
      //
      // `userKey` is used both as the identifier for the temporary object and
      // as the key it's stored at in the `outputKey` object. Likewise, we
      // reused `underlyingKey` below.
      string memory userKey = vm.toString(user);
      string memory userJson;

      for (uint256 i; i < _UNDERLYINGS.length; i++) {
        IERC20Meta underlying = _UNDERLYINGS[i];
        IEToken eToken = _MARKETS.underlyingToEToken(underlying);
        IDToken dToken = _MARKETS.underlyingToDToken(underlying);
        //uint256 eTokenBalance = eToken.balanceOf(user);
        uint256 collateral = eToken.balanceOfUnderlying(user);
        uint256 borrow = dToken.balanceOf(user);

        if (collateral > 0 || borrow > 0) {
          string memory underlyingKey = vm.toString(address(underlying));
          string memory underlyingJson = _metaToJson(underlyingKey, underlying);

          if (collateral > 0) {
            underlyingJson = vm.serializeUint(underlyingKey, "collateral", collateral);
          }
          if (borrow > 0) {
            underlyingJson = vm.serializeUint(underlyingKey, "borrow", borrow);
          }
          // Store the object for the underlying asset in the user object.
          userJson = vm.serializeString(userKey, underlyingKey, underlyingJson);
        }
      }
      // Store the object for the user in the global output object.
      outputJson = vm.serializeString(outputKey, userKey, userJson);
    }
    vm.writeJson(outputJson, "./balances.json");
  }
}
