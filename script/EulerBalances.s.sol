// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Common, IERC20Meta, IEToken, IDToken} from "./Common.s.sol";
import "forge-std/console.sol";

contract EulerBalances is Common {
  function run() public {
    _fork();

    string memory outputKey = "outputKey";
    string memory outputJson;

    for (uint256 j; j < _USERS.length; j++) {
      address user = _USERS[j];
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
          console.log(user, address(underlying), collateral, borrow);
          string memory underlyingKey = vm.toString(address(underlying));
          string memory underlyingJson = _metaToJson(underlyingKey, underlying);

          if (collateral > 0) {
            underlyingJson = vm.serializeUint(underlyingKey, "collateral", collateral);
          }
          if (borrow > 0) {
            underlyingJson = vm.serializeUint(underlyingKey, "borrow", borrow);
          }
          userJson = vm.serializeString(userKey, underlyingKey, underlyingJson);
        }
      }
      outputJson = vm.serializeString(outputKey, userKey, userJson);
    }
    vm.writeJson(outputJson, "./balances.json");
  }
}
