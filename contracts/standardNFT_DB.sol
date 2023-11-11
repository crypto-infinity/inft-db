// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; //implements UUIP pattern for upgrades
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol"; //implements pausable pattern for upgrades
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol"; //reentrancy guard - Upgradeable
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol"; //implements RBAC for its current token - Upgradeable
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol"; //implements UUIP pattern for upgrades
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol"; //implements UUIP pattern for upgrades

import "./INFT_DB.sol"; //ERCPlatform Custom Interface, contracts should support interface this

/**
 * @dev Standard INFT_DB decentralized database for custodial NFTs for customers.
 */
contract standardNFT_DB is
    Initializable,
    ERC165Upgradeable,
    ERC1155PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlEnumerableUpgradeable,
    UUPSUpgradeable,
    INFT_DB
{
    //Access Control Roles declaration
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); //has admin permissions on state-changing functions

    string private _contractLevelMetadataURI; //See https://docs.opensea.io/docs/contract-level-metadata

    //Metadata variables declaration
    string public name;

    //Mapping declaration
    mapping(address => uint256[]) private tokenMappings; //Keep track of who minted what on the blockchain - TO BE FIXED

    mapping(uint256 => string) private _tokenURIs; //tokenURI custom implementation
    mapping(uint256 => bool) private tokenMinted; //Check if tokenID has already been minted
    mapping(uint256 => bool) private isBurnable; //Check if tokenID is burnable
    mapping(uint256 => bool) private isMutable; //Check if tokenID URI is mutable, if his URI can be changed at a later time

    function initialize(
        string memory contract_uri,
        address[] memory admins,
        string memory contract_name
    ) public initializer {
        //Dependencies initialization:
        __ERC1155_init(contract_uri);
        __ReentrancyGuard_init();

        //Contract variables setup
        _contractLevelMetadataURI = contract_uri;
        name = contract_name;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        // This looks like an address but has an invalid checksum. Correct checksummed address: "0xB312Dcf3Bd0BFEDf9c932C0f35fa1B3c3859e4a0". If this is not used as an address, please prepend '00'. For more information please see https://docs.soliditylang.org/en/develop/types.html#address-literals

        if (admins.length > 0) { //first admin assignation
            for (uint256 i = 0; i < admins.length; i++) {
                _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
                _grantRole(ADMIN_ROLE, admins[i]);
            }
        }
    }

    /**
     * @dev uri function override, allows to assign a custom URI for each token ID
     *
     * @param tokenId: uint, token id of which we want to get the URI set by _SetTokenURI
     * @return URI: string, URI address of tokenId token
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId), "ERC1155: query for non-existent object");
        return (_tokenURIs[tokenId]);
    }

    /**
     * @dev return custom collection URI, for legacy purposes
     *
     * @return _contractLevelMetadataURI: string, the contract URI assigned from the constructor
     */
    function tokenURI() public view returns (string memory) {
        return _contractLevelMetadataURI;
    }

    /**
     * @dev Utility string comparation function. Allows to check if a and b are equal.
     *
     * @param a: string, the first string to compare
     * @param b: string, the second string to compare
     * @return equals: bool, says if a and b are equal
     */
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function contractURI() public view returns (string memory) {
        return _contractLevelMetadataURI;
    }

    function mintToken(
        address to,
        uint256 tokenId,
        uint256 amount,
        string memory contract_uri,
        bool burnable,
        bool nonMutable
    ) public nonReentrant onlyRole(ADMIN_ROLE) {
        if (exists(tokenId)) {
            _mint(to, tokenId, amount, "");
            tokenMappings[to].push(tokenId); //TO BE FIXED
        }
        //if it exist already, just mintToken the NFT
        else {
            _mint(to, tokenId, amount, "");
            tokenMappings[to].push(tokenId); //TO BE FIXED
            tokenMinted[tokenId] = true;
            _setTokenUri(tokenId, contract_uri); //if token URI is empty, token is considered ERC20 like

            //allows users to block current token burn. this is permanent.
            if (burnable) {
                isBurnable[tokenId] = true;
            }

            //allows customers to avoid tokenURI changes
            if (!nonMutable) {
                isMutable[tokenId] = false;
            }
        }
    }

    function burnToken(
        address contract_address,
        uint256 tokenId,
        uint256 amount
    ) public nonReentrant onlyRole(ADMIN_ROLE) {
        require(exists(tokenId), "Token not existent!");
        require(isBurnable[tokenId], "Token is not burnable!");

        _burn(contract_address, tokenId, amount);
        _tokenURIs[tokenId] = ""; //restore mapping to default value
        tokenMinted[tokenId] = false;

        //no need to emit event, ERC721 takes care of this with a Transfer to the 0 address by default
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

    function exists(uint256 tokenId)
        public
        view
        onlyRole(ADMIN_ROLE)
        returns (bool)
    {
        return tokenMinted[tokenId];
    }

    function setTokenUri(uint256 tokenId, string memory token_uri)
        public
        onlyRole(ADMIN_ROLE)
    {
        if (isMutable[tokenId]) {
            _setTokenUri(tokenId, token_uri);
        } else {
            if (hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
                _setTokenUri(tokenId, token_uri);
            } else
                revert("IERCPlatform: URI for specified tokenId is permanent!");
        }
    }

    /**
        @dev Returns all tokens owned in any quantity by a specific address
        @param who: The address to check

        @return tokenId[]: Array[uint256] - tokenIds associated with who. Can be duplicated, so it is compulsory to clean the array off-chain.
     */
    function getTokenMappings(address who)
        public
        view
        returns (uint256[] memory)
    {
        return tokenMappings[who];
    }

    /**
     * @dev pausable public implementation, allows admins to block contract operation from an unpaused state.
     *
     */
    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _pause();
    }

    /**
     * @dev pausable public implementation, allows admins to unblock contract operation from a paused state.
     *
     */
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) whenPaused {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC1155Upgradeable,
            AccessControlEnumerableUpgradeable,
            ERC165Upgradeable
        )
        returns (bool)
    {
        return
            interfaceId == type(INFT_DB).interfaceId || 
            super.supportsInterface(interfaceId);
    }

    //PRIVATE AND INTERNAL UTILITY FUNCTIONS DECLARATION

    function _setTokenUri(uint256 tokenId, string memory token_uri) private {
        _tokenURIs[tokenId] = token_uri;
        emit URI(uri(tokenId), tokenId);
    }

    /**
     * @dev See {ERC1967-Proxy}
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}

// /**
//  * @dev public setURI implementation. Allows to change the ERC1155 contract URI on a later time.
//  *
//  * @param newuri: string, the new contract URI
//  *
//  */
// function setURI(string memory newuri)
//     public
//     onlyRole(CONTRACT_METADATA_ROLE)
// {
//     _setURI(newuri);
// }
