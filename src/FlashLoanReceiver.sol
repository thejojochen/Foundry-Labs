
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import { FlashLoanReceiverBase } from "../node_modules/@aave/protocol-v2/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import { ILendingPool } from "../node_modules/@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "../node_modules/@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import { IERC20 } from "../node_modules/@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import  "../node_modules/@aave/protocol-v2/contracts/protocol/lendingpool/LendingPool.sol";

contract FlashLoanReceiver is FlashLoanReceiverBase {

    constructor() FlashLoanReceiverBase(ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5)) public {
        //ADDRESSES_PROVIDER = provider;
        //LENDING_POOL = ILendingPool(provider.getLendingPool());
    }
        
        function executeOperation (
            address[] calldata assets,
            uint256[] calldata amounts,
            uint256[] calldata premiums,
            address initiator,
            bytes calldata params
        )
            external
            override
            returns (bool)
        {

            uint256 amountToRepay = amounts[0] + premiums[0];
            require(amountToRepay > 100000000000000000000, amountToRepay.toString() );
            //
            // This contract now has the funds requested.
            // Your logic goes here.
            //
            
            // At the end of your logic above, this contract owes
            // the flashloaned amounts + premiums.
            // Therefore ensure your contract has enough to repay
            // these amounts.
            
            // Approve the LendingPool contract allowance to *pull* the owed amount
            for (uint i = 0; i < assets.length; i++) {
                uint amountOwing = amounts[i].add(premiums[i]);
                IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
            }
            
            return true;
        }


        function configureAndExecuteFlashloan() public {
            address receiverAddress = address(this);

            address[] memory assets = new address[](1);
            assets[0] = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); //USDT
            //assets[1] = address(INSERT_ASSET_TWO_ADDRESS);

            uint256[] memory amounts = new uint256[](1);
            amounts[0] = 50;
            //amounts[1] = INSERT_ASSET_TWO_AMOUNT;

            // 0 = no debt, 1 = stable, 2 = variable
            uint256[] memory modes = new uint256[](1);
            modes[0] = 0;
            //modes[1] = INSERT_ASSET_TWO_MODE;

            address onBehalfOf = address(this);
            bytes memory params = "";
            uint16 referralCode = 0;

            //LendingPool LENDING_POOL = LendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
            LENDING_POOL.flashLoan(
                receiverAddress,
                assets,
                amounts,
                modes,
                onBehalfOf,
                params,
                referralCode
            );
        }


}