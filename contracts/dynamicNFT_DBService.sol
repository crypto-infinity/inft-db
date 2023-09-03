// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol"; //implements RBAC for its current token
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol"; //Chainlink interface assembly
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //Reentrancy guard

/**
 * @dev IERCPlatform decentralized database for custodial and mutable NFTs for customers. Relies on chainlink blockchain.
 */
contract dynamicNFT_DBService is
    ReentrancyGuard,
    AutomationCompatible,
    AccessControlEnumerable
{
    //Access Control Roles declaration
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); //has admin permissions on state-changing functions

    address private contract_admin;
    address[] private INFT_DB_CONTRACTS;

    event test(string);

    constructor(address admin, address[] memory contracts) 
    {
        contract_admin = admin;
        INFT_DB_CONTRACTS = contracts;
    }

    //Chainlink Automation Compatible Interface implementation

    function checkUpkeep(bytes calldata checkData) 
        cannotExecute
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        string memory testo = abi.decode(checkData,(string));
        bytes memory data = abi.encode(testo);
        return(true, data); //passa i dati a performUpkeep
    }

    function performUpkeep(bytes calldata performData) external override 
    {
        string memory testo = abi.decode(performData, (string));
        emit test(testo);
    }

    function updateNFT_DBContracts(address[] memory contracts) public onlyRole(ADMIN_ROLE)
    {
        delete INFT_DB_CONTRACTS;
        INFT_DB_CONTRACTS = contracts;
    }

    //PRIVATE AND INTERNAL UTILITY FUNCTIONS DECLARATION

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function getCurrentPrivilegedAccounts(string memory role)
        public
        view
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (address[] memory)
    {
        bytes32 role_bytes = keccak256(abi.encodePacked(role));

        address[] memory members = new address[](
            getRoleMemberCount(role_bytes)
        );
        for (uint256 i = 0; i < getRoleMemberCount(role_bytes); i++) {
            members[i] = getRoleMember(role_bytes, i);
        }

        return members;
    }
    
}
