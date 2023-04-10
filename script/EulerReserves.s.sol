// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IERC20Meta {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

interface IEToken {
  function reserveBalanceUnderlying() external view returns (uint256);
}

interface IMarkets {
  function underlyingToEToken(address) external view returns (IEToken);
}


contract EulerReserves is Script {
  address private constant _EULER = 0x27182842E098f60e3D576794A5bFFb0777E025d3;
  bytes32 private constant _ETOKEN_IMPL_SLOT = 0x808d1a1e48dd4ab99cb7d5984bb45542b205ab6ccb19608b922097f06df90bf7;
  address private constant _ETOKEN_IMPL_ADDRESS = 0xbb0D4bb654a21054aF95456a3B29c63e8D1F4c0a;
  bytes32 private constant _DTOKEN_IMPL_SLOT = 0x6074b2cb7ae76823e3f549465b08b3f693d837cb66960bba9594ed84da63ca26;
  address private constant _DTOKEN_IMPL_ADDRESS = 0x29DaDdfdA3442693c21A50351a2B4820DDbBFF79;
  IMarkets private constant _MARKETS = IMarkets(0x3520d5a913427E6F0D6A83E07ccD4A4da316e4d3);
  uint256 private constant _FORK_BLOCK = 16_819_246; // the block before the final freeze

  function setUp() public {}

  function run() public {
    string memory forkRpc = vm.envString("FORK_RPC");
    console.log("creating fork from", forkRpc, "at", _FORK_BLOCK);
    uint256 forkId = vm.createSelectFork(forkRpc, _FORK_BLOCK);
    console.log("\tfork created");
    vm.store(_EULER, _ETOKEN_IMPL_SLOT, bytes32(uint256(uint160(_ETOKEN_IMPL_ADDRESS))));
    vm.store(_EULER, _DTOKEN_IMPL_SLOT, bytes32(uint256(uint160(_DTOKEN_IMPL_ADDRESS))));

    // retrieved by parsing the MarketActivated events on _EULER
    address[] memory underlyings = new address[](129);
    underlyings[0] = 0xEDB171C18cE90B633DB442f2A6F72874093b49Ef;
    underlyings[1] = 0xA2cd3D43c775978A96BdBf12d733D5A1ED94fb18;
    underlyings[2] = 0x888888435FDe8e7d4c54cAb67f206e4199454c60;
    underlyings[3] = 0xcB84d72e61e383767C4DFEb2d8ff7f4FB89abc6e;
    underlyings[4] = 0x9d409a0A012CFbA9B15F6D4B36Ac57A46966Ab9a;
    underlyings[5] = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
    underlyings[6] = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    underlyings[7] = 0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1;
    underlyings[8] = 0xDe30da39c46104798bB5aA3fe8B9e0e1F348163F;
    underlyings[9] = 0xDd1Ad9A21Ce722C151A836373baBe42c868cE9a4;
    underlyings[10] = 0xf1B99e3E573A1a9C5E6B2Ce818b617F0E664E86B;
    underlyings[11] = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;
    underlyings[12] = 0xc2544A32872A91F4A553b404C6950e89De901fdb;
    underlyings[13] = 0x000000007a58f5f58E697e51Ab0357BC9e260A04;
    underlyings[14] = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    underlyings[15] = 0x50D1c9771902476076eCFc8B2A83Ad6b9355a4c9;
    underlyings[16] = 0x92D6C1e31e14520e676a687F0a93788B716BEff5;
    underlyings[17] = 0xbC396689893D065F41bc2C6EcbeE5e0085233447;
    underlyings[18] = 0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b;
    underlyings[19] = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    underlyings[20] = 0x3b484b82567a09e2588A13D54D032153f0c0aEe0;
    underlyings[21] = 0x4a220E6096B25EADb88358cb44068A3248254675;
    underlyings[22] = 0xF629cBd94d3791C9250152BD8dfBDF380E2a3B9c;
    underlyings[23] = 0xD33526068D116cE69F19A9ee46F0bd304F21A51f;
    underlyings[24] = 0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3;
    underlyings[25] = 0x767FE9EDC9E0dF98E07454847909b5E959D7ca0E;
    underlyings[26] = 0x1a7e4e63778B4f12a199C062f3eFdD288afCBce8;
    underlyings[27] = 0x3832d2F059E55934220881F831bE501D180671A7;
    underlyings[28] = 0x6243d8CEA23066d098a15582d81a598b4e8391F4;
    underlyings[29] = 0x24A6A37576377F63f194Caa5F518a60f45b42921;
    underlyings[30] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    underlyings[31] = 0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF;
    underlyings[32] = 0x77777FeDdddFfC19Ff86DB637967013e6C6A116C;
    underlyings[33] = 0xd9Fcd98c322942075A5C3860693e9f4f03AAE07b;
    underlyings[34] = 0xd909C5862Cdb164aDB949D92622082f0092eFC3d;
    underlyings[35] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    underlyings[36] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    underlyings[37] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    underlyings[38] = 0x08A75dbC7167714CeaC1a8e43a8d643A4EDd625a;
    underlyings[39] = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    underlyings[40] = 0xdab396cCF3d84Cf2D07C4454e10C8A6F5b008D2b;
    underlyings[41] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    underlyings[42] = 0x586Aa273F262909EEF8fA02d90Ab65F5015e0516;
    underlyings[43] = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;
    underlyings[44] = 0xF4Dc48D260C93ad6a96c5Ce563E70CA578987c74;
    underlyings[45] = 0x6100dd79fCAA88420750DceE3F735d168aBcB771;
    underlyings[46] = 0x2C537E5624e4af88A7ae4060C022609376C8D0EB;
    underlyings[47] = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
    underlyings[48] = 0xF57e7e7C23978C3cAEC3C3548E3D615c346e79fF;
    underlyings[49] = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    underlyings[50] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    underlyings[51] = 0x8207c1FfC5B6804F6024322CcF34F29c3541Ae26;
    underlyings[52] = 0x0ab87046fBb341D058F17CBC4c1133F25a20a52f;
    underlyings[53] = 0x7945b0A6674b175695e5d1D08aE1e6F13744Abb0;
    underlyings[54] = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    underlyings[55] = 0xf1Dc500FdE233A4055e25e5BbF516372BC4F6871;
    underlyings[56] = 0x7b35Ce522CB72e4077BaeB96Cb923A5529764a00;
    underlyings[57] = 0xB62132e35a6c13ee1EE0f84dC5d40bad8d815206;
    underlyings[58] = 0xd1ba9BAC957322D6e8c07a160a3A8dA11A0d2867;
    underlyings[59] = 0x607F4C5BB672230e8672085532f7e901544a7375;
    underlyings[60] = 0xCC8Fa225D80b9c7D42F96e9570156c65D6cAAa25;
    underlyings[61] = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    underlyings[62] = 0xc944E90C64B2c07662A292be6244BDf05Cda44a7;
    underlyings[63] = 0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2;
    underlyings[64] = 0x53BcCB38A174aDCa09D5103D561D1cB99BFe97af;
    underlyings[65] = 0x6De037ef9aD2725EB40118Bb1702EBb27e4Aeb24;
    underlyings[66] = 0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b;
    underlyings[67] = 0x72e364F2ABdC788b7E918bc238B21f109Cd634D7;
    underlyings[68] = 0x2aF1dF3AB0ab157e1E2Ad8F88A7D04fbea0c7dc6;
    underlyings[69] = 0x0954906da0Bf32d5479e25f46056d22f08464cab;
    underlyings[70] = 0xAa6E8127831c9DE45ae56bB1b0d4D4Da6e5665BD;
    underlyings[71] = 0x0d438F3b5175Bebc262bF23753C1E53d03432bDE;
    underlyings[72] = 0x8Fc8f8269ebca376D046Ce292dC7eaC40c8D358A;
    underlyings[73] = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    underlyings[74] = 0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd;
    underlyings[75] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    underlyings[76] = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    underlyings[77] = 0xDc5864eDe28BD4405aa04d93E05A0531797D9D59;
    underlyings[78] = 0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0;
    underlyings[79] = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    underlyings[80] = 0x99ea4dB9EE77ACD40B119BD1dC4E33e1C070b80d;
    underlyings[81] = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    underlyings[82] = 0xf4d2888d29D722226FafA5d9B24F9164c092421E;
    underlyings[83] = 0x9D65fF81a3c488d585bBfb0Bfe3c7707c7917f54;
    underlyings[84] = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    underlyings[85] = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    underlyings[86] = 0x227c7DF69D3ed1ae7574A1a7685fDEd90292EB48;
    underlyings[87] = 0x3aaDA3e213aBf8529606924d8D1c55CbDc70Bf74;
    underlyings[88] = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32;
    underlyings[89] = 0xcaDC0acd4B445166f12d2C07EAc6E2544FbE2Eef;
    underlyings[90] = 0x4d224452801ACEd8B2F0aebE155379bb5D594381;
    underlyings[91] = 0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC;
    underlyings[92] = 0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44;
    underlyings[93] = 0xc5fB36dd2fb59d3B98dEfF88425a3F425Ee469eD;
    underlyings[94] = 0x8f8221aFbB33998d8584A2B05749bA73c37a938a;
    underlyings[95] = 0x6123B0049F904d730dB3C36a31167D9d4121fA6B;
    underlyings[96] = 0xEec2bE5c91ae7f8a338e1e5f3b5DE49d07AfdC81;
    underlyings[97] = 0xFe2e637202056d30016725477c5da089Ab0A043A;
    underlyings[98] = 0xba100000625a3754423978a60c9317c58a424e3D;
    underlyings[99] = 0xAf5191B0De278C7286d6C7CC6ab6BB8A73bA2Cd6;
    underlyings[100] = 0x23B608675a2B2fB1890d3ABBd85c5775c51691d5;
    underlyings[101] = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    underlyings[102] = 0x269616D549D7e8Eaa82DFb17028d0B212D11232A;
    underlyings[103] = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    underlyings[104] = 0x53a0340ED6BA1Fd460608e2CD0424A339B56D3E2;
    underlyings[105] = 0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5;
    underlyings[106] = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    underlyings[107] = 0x33349B282065b0284d756F0577FB39c158F935e6;
    underlyings[108] = 0x31c8EAcBFFdD875c74b94b077895Bd78CF1E64A3;
    underlyings[109] = 0x321C2fE4446C7c963dc41Dd58879AF648838f98D;
    underlyings[110] = 0x6BeA7CFEF803D1e3d5f7C0103f7ded065644e197;
    underlyings[111] = 0x4691937a7508860F876c9c0a2a617E7d9E945D4B;
    underlyings[112] = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    underlyings[113] = 0x9C4A4204B79dd291D6b6571C5BE8BbcD0622F050;
    underlyings[114] = 0x875773784Af8135eA0ef43b5a374AaD105c5D39e;
    underlyings[115] = 0x5dD57Da40e6866C9FcC34F4b6DDC89F1BA740DfE;
    underlyings[116] = 0x03ab458634910AaD20eF5f1C8ee96F1D6ac54919;
    underlyings[117] = 0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72;
    underlyings[118] = 0xa117000000f279D81A1D3cc75430fAA017FA5A2e;
    underlyings[119] = 0x111111111117dC0aa78b770fA6A738034120C302;
    underlyings[120] = 0x297D33e17e61C2Ddd812389C2105193f8348188a;
    underlyings[121] = 0x6468e79A80C0eaB0F9A2B574c8d5bC374Af59414;
    underlyings[122] = 0xb05097849BCA421A3f51B249BA6CCa4aF4b97cb9;
    underlyings[123] = 0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671;
    underlyings[124] = 0xA8b919680258d369114910511cc87595aec0be6D;
    underlyings[125] = 0x3472A5A71965499acd81997a54BBA8D852C6E53d;
    underlyings[126] = 0x954b890704693af242613edEf1B603825afcD708;
    underlyings[127] = 0x6DEA81C8171D0bA574754EF6F8b412F2Ed88c54D;
    underlyings[128] = 0x48C3399719B582dD63eB5AADf12A40B4C3f52FA2;

    string memory outputKey = "outputKey";
    string memory outputJson;
    for (uint256 i; i < underlyings.length; i++) {
      // get Euler reserve
      address underlying = underlyings[i];
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
