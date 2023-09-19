//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "../contracts/DecentralizedStableCoin.sol";
import {DSCEngine} from "../contracts/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import "./DeployHelpers.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    address[] public tokenAddresses;
    address[] public priceFeedAddersses;

    error InvalidPrivateKey(string);

    function run() external returns (DecentralizedStableCoin, DSCEngine, HelperConfig) {
        HelperConfig config = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            config.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddersses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        // uint256 deployerPrivateKey = setupLocalhostEnv();
        // if (deployerPrivateKey == 0) {
        //     revert InvalidPrivateKey(
        //         "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
        //     );
        // }
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast(deployerKey);
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine engine = new DSCEngine(tokenAddresses, priceFeedAddersses, address(dsc));
        dsc.transferOwnership(address(engine));
        console.logString(string.concat("DecentralizedStableCoin deployed at: ", vm.toString(address(dsc))));
        console.logString(string.concat("DSCEngine deployed at: ", vm.toString(address(engine))));
        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
        return (dsc, engine, config);
    }

    // function test() public {}
}
