pragma solidity ^0.6.12;

import "../src/SimpleStorageContract.sol";
import "../src/FlashLoanReceiver.sol";
import { IERC20 } from "../node_modules/@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";


contract Lab is Test {

    uint256 mainnetFork;
    uint256 optimismFork;

    string MAINNET_RPC_URL  = vm.envString("MAINNET_RPC_URL" );
    string OPTIMISM_RPC_URL = vm.envString("OPTIMISM_RPC_URL");

    address aliceAddr;
    uint256 aliceKey;

    // ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);


    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        optimismFork = vm.createFork(OPTIMISM_RPC_URL);

        (address aliceAddr, uint256 aliceKey) = makeAddrAndKey("alice");
    }

    function testUniqueForks() public view {
        assert(mainnetFork != optimismFork);
    }

    function testForkSelection() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

    function testSwitchForks() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        vm.selectFork(optimismFork);
        assertEq(vm.activeFork(), optimismFork);
    }

    function testCreateAndSelectFork() public {
        uint256 newFork = vm.createSelectFork(MAINNET_RPC_URL);
        assertEq(vm.activeFork(), newFork);
    }

    function testChangeBlockTimestamp() public {
        vm.selectFork(mainnetFork);
        vm.rollFork(1_337_000);
        assertEq(block.number, 1_337_000);
    }

    function testCreateContract() public {
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        SimpleStorageContract simple = new SimpleStorageContract();

        simple.set(100);
        assertEq(simple.value(), 100);
    }

    function testReadValueOfWETHDecimals() public {

        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);

        address wrappedEtherAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        bytes32 decimals = vm.load(wrappedEtherAddress, bytes32(uint256(2)));
        console.log("Wrapped Ether Decimals: %s", uint256(decimals));
    }

    function testDepositIntoWETH() public {
        // vm.selectFork(mainnetFork);
        // assertEq(vm.activeFork(), mainnetFork);

        // vm.startPrank(aliceAddr);
        // vm.deal(aliceAddr, 1 ether);
        // assertEq(address(aliceAddr).balance, 1 ether);

        // address wrappedEtherAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        // WETH9 wrappedEther = WETH9(wrappedEtherAddress);
        // vm.mockCall(
        //     wrappedEtherAddress,
        //     abi.encodeWithSignature("deposit()"),
        //     abi.encode(10)
        // );
        // just make a low level call into the weth address (pass in abi encoded function sig and parameter) or use cast 
    }

    function testAaveFlashLoan() public {

        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
        
        // IPool pool = IPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
        //pool.flashLoanSimple( address(this), 0x9Bab1E80E7beBB3c02019c45F17cB9A2E0bB423a, 5, abi.encode(0), 0);

        FlashLoanReceiver receiver = new FlashLoanReceiver();

        address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        deal(address(USDT), address(receiver), 10000e18);
        // alternative way to assign erc20 tokens through overwriting storage
        //writeTokenBalance(address(receiver), IERC20(USDT), 500 ether);
        console.log(IERC20(USDT).balanceOf(address(receiver)));
        receiver.configureAndExecuteFlashloan();
        }

    function writeTokenBalance(
        address who,
        IERC20 token,
        uint256 amt
    ) internal {
        stdstore
            .target(address(token))
            .sig(token.balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }
}






