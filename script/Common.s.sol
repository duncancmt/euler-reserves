// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IERC20Meta {
  function transfer(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function allowance(address, address) external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function totalSupply() external view returns (uint256);

  event Transfer(address indexed, address indexed, uint256);
  event Approval(address indexed, address indexed, uint256);

  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

interface IEToken is IERC20Meta {
  function reserveBalanceUnderlying() external view returns (uint256);
  function balanceOfUnderlying(address) external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
}

interface IDToken is IERC20Meta {
  function balanceOf(address) external view returns (uint256); // returns balance in underlying
}

interface IMarkets {
  function underlyingToEToken(IERC20Meta) external view returns (IEToken);
  function underlyingToDToken(IERC20Meta) external view returns (IDToken);
}


// Because try ... catch in Solidity is a piece of shit, we have to do our own
// manual checking of the ABIEncoding to avoid spurious reverts. Strictly
// speaking, this is slightly too lax in the checking, but in practice it works
// well enough.
library SafeERC20Meta {
  function safeName(IERC20Meta token) internal view returns (bool, string memory) {
    (bool success, bytes memory returnData) = address(token).staticcall(abi.encodeCall(token.name, ()));
    if (success && returnData.length > 64) {
      return (true, abi.decode(returnData, (string)));
    }
    return (false, "");
  }

  function safeSymbol(IERC20Meta token) internal view returns (bool, string memory) {
    (bool success, bytes memory returnData) = address(token).staticcall(abi.encodeCall(token.symbol, ()));
    if (success && returnData.length > 64) {
      return (true, abi.decode(returnData, (string)));
    }
    return (false, "");
  }

  function safeDecimals(IERC20Meta token) internal view returns (bool, uint8) {
    (bool success, bytes memory returnData) = address(token).staticcall(abi.encodeCall(token.decimals, ()));
    if (success && returnData.length >= 32) {
      return (true, abi.decode(returnData, (uint8)));
    }
    return (false, 0);
  }
}

abstract contract Common is Script {
  using SafeERC20Meta for IERC20Meta;

  address internal constant _EULER = 0x27182842E098f60e3D576794A5bFFb0777E025d3;
  bytes32 internal constant _ETOKEN_IMPL_SLOT = 0x808d1a1e48dd4ab99cb7d5984bb45542b205ab6ccb19608b922097f06df90bf7;
  address internal constant _ETOKEN_IMPL_ADDRESS = 0xbb0D4bb654a21054aF95456a3B29c63e8D1F4c0a;
  bytes32 internal constant _DTOKEN_IMPL_SLOT = 0x6074b2cb7ae76823e3f549465b08b3f693d837cb66960bba9594ed84da63ca26;
  address internal constant _DTOKEN_IMPL_ADDRESS = 0x29DaDdfdA3442693c21A50351a2B4820DDbBFF79;
  IMarkets internal constant _MARKETS = IMarkets(0x3520d5a913427E6F0D6A83E07ccD4A4da316e4d3);
  uint256 internal constant _FORK_BLOCK = 16_819_246; // the block before the final freeze

  IERC20Meta[] internal _UNDERLYINGS;
  address[] internal _USERS;

  function setUp() public {
    // retrieved by parsing the MarketActivated events on _EULER
    address[] memory tokensRaw = vm.parseJsonAddressArray(vm.readFile("./tokens.json"), ".tokens");
    for (uint256 i; i < tokensRaw.length; i++) {
      _UNDERLYINGS.push(IERC20Meta(tokensRaw[i]));
    }
    // retrieved from https://raw.githubusercontent.com/brian0641/euler_hack/master/account_state_fetch/all_events.log
    _USERS = vm.parseJsonAddressArray(vm.readFile("./users.json"), ".users");
  }

  function _fork() internal returns (uint256 forkId) {
    string memory forkRpc = vm.envString("FORK_RPC");
    console.log("creating fork from", forkRpc, "at", _FORK_BLOCK);
    forkId = vm.createSelectFork(forkRpc, _FORK_BLOCK);
    console.log("\tfork created");
    vm.store(_EULER, _ETOKEN_IMPL_SLOT, bytes32(uint256(uint160(_ETOKEN_IMPL_ADDRESS))));
    vm.store(_EULER, _DTOKEN_IMPL_SLOT, bytes32(uint256(uint160(_DTOKEN_IMPL_ADDRESS))));
  }

  function _metaToJson(string memory dst, IERC20Meta token) internal returns (string memory json) {
    {
      (bool success, string memory name) = token.safeName();
      if (success) {
        json = vm.serializeString(dst, "name", name);
      }
    }
    {
      (bool success, string memory symbol) = token.safeSymbol();
      if (success) {
        json = vm.serializeString(dst, "symbol", symbol);
      }
    }
    {
      (bool success, uint8 decimals) = token.safeDecimals();
      if (success) {
        json = vm.serializeUint(dst, "decimals", decimals);
      }
    }
  }
}
