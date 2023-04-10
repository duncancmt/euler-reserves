// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import {Common, IEToken, IDToken} from "./Common.s.sol";
import "forge-std/console.sol";

contract EulerBalances is Common {
  address[] internal _USERS = [
    0x83a59Ce2eF545c019e77c542552eC0f0f58402B6
  ];

  function run() public {
    _fork();

    string memory outputKey = "outputKey";
    string memory outputJson;

    for (uint256 j; j < _USERS.length; j++) {
      address user = _USERS[j];
      string memory userKey = vm.toString(user);
      string memory userJson;

      for (uint256 i; i < _UNDERLYINGS.length; i++) {
        address underlying = _UNDERLYINGS[i];
        IEToken eToken = _MARKETS.underlyingToEToken(underlying);
        IDToken dToken = _MARKETS.underlyingToDToken(underlying);
        //uint256 eTokenBalance = eToken.balanceOf(user);
        uint256 collateral = eToken.balanceOfUnderlying(user);
        uint256 debt = dToken.balanceOf(user);

        if (collateral > 0 || debt > 0) {
          console.log(user, underlying, collateral, debt);
          string memory underlyingKey = vm.toString(underlying);
          string memory underlyingJson;

          if (collateral > 0) {
            underlyingJson = vm.serializeUint(underlyingKey, "collateral", collateral);
          }
          if (debt > 0) {
            underlyingJson = vm.serializeUint(underlyingKey, "debt", debt);
          }
          userJson = vm.serializeString(userKey, underlyingKey, underlyingJson);
        }
      }
      outputJson = vm.serializeString(outputKey, userKey, userJson);
    }
    vm.writeJson(outputJson, "./balances.json");
  }
}
