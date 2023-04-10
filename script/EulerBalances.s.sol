// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Common, IERC20Meta, IEToken, IDToken} from "./Common.s.sol";

contract EulerBalances is Common {
  uint256 internal constant _DUST = 10 wei;

  function run(uint256 start, uint256 stop) public {
    _fork();

    string memory outputKey = "outputKey";
    string memory outputJson;

    if (start >= _USERS.length) {
      start = _USERS.length - 1;
    }
    if (stop >= _USERS.length) {
      stop = _USERS.length - 1;
    }
    for (uint256 j = start; j < stop; j++) {
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
      // if a user has no collateral or borrow in a token, that token is
      // omitted. If a user has no collaterals or borrows, that user is omitted.
      //
      // `userKey` is used both as the identifier for the temporary object and
      // as the key it's stored at in the `outputKey` object. `underlyingKey`
      // does not get reused because it confuses the JSON serializer.
      string memory userKey = vm.toString(user);
      string memory userJson;

      for (uint256 i; i < _UNDERLYINGS.length; i++) {
        IERC20Meta underlying = _UNDERLYINGS[i];
        IEToken eToken = _MARKETS.underlyingToEToken(underlying);
        IDToken dToken = _MARKETS.underlyingToDToken(underlying);
        //uint256 eTokenBalance = eToken.balanceOf(user);
        uint256 collateral = eToken.balanceOfUnderlying(user);
        uint256 borrow = dToken.balanceOf(user);

        if (collateral > _DUST || borrow > _DUST) {
          string memory underlyingAddress = vm.toString(address(underlying));
          string memory underlyingKey = string.concat(userKey, underlyingAddress);
          string memory underlyingJson; // = _metaToJson(underlyingKey, underlying);

          if (collateral > _DUST) {
            underlyingJson = vm.serializeUint(underlyingKey, "collateral", collateral);
          }
          if (borrow > _DUST) {
            underlyingJson = vm.serializeUint(underlyingKey, "borrow", borrow);
          }
          // Store the object for the underlying asset in the user object.
          userJson = vm.serializeString(userKey, underlyingAddress, underlyingJson);
        }
      }
      if (bytes(userJson).length > 0) {
        // Store the object for the user in the global output object.
        outputJson = vm.serializeString(outputKey, userKey, userJson);
      }
    }
    vm.writeJson(outputJson, string.concat("./balances_out/balances.", vm.toString(start), ".json"));
  }
}
