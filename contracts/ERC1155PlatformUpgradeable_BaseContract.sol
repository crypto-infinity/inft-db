// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; //implements UUIP pattern for upgrades
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol"; //ERC1155 STD - Upgradeable
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol"; //reentrancy guard - Upgradeable
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; //onlyOwner modifier - Upgradeable
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol"; //implements RBAC for its current token - Upgradeable
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol"; //implements UUIP pattern for upgrades
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol"; //implements pausable pattern for upgrades

contract ERC1155PlatformUpgradeable is
    Initializable,
    ERC1155PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    AccessControlEnumerableUpgradeable,
    UUPSUpgradeable
{
    mapping(uint256 => string) private _tokenURIs; //keep track of token URIs
    mapping(uint256 => bool) private tokenMinted; //keep track of already minted tokenIds
    mapping(uint256 => bool) private isBurnable; //keep track of burnable tokens

    address[] public childNFT_address; //keep track of minted ERC20 objects in the blockchain. NOT YET IMPLEMENTED

    string internal _contractURI; //opensea contract-level metadata : https://docs.opensea.io/docs/contract-level-metadata

    //Access Control Roles declaration
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); //has minting permissions (can create CustomNFT istances)
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); //has burn permissions (can burn custom NFTs)
    bytes32 public constant CONTRACT_METADATA_ROLE = keccak256("CONTRACT_METADATA_ROLE"); //has read permission about roles and CustomNFT objects
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE"); //has the permission to call pause() and unpause() functions

    //RESERVING STORAGE SLOTS FOR FUTURE UPGRADES
    uint256[50] __gap;

    //Metadata variables declaration
    string private _name;
    string private _symbol;

    function initialize(string memory contract_uri, address admin, string memory contract_name, string memory contract_symbol)
        public
        initializer
    {
        //Dependencies initialization:
        __ERC1155_init(contract_uri);
        __Ownable_init();
        __ReentrancyGuard_init();

        //Contract first setup
        _contractURI = contract_uri;
        _name = contract_name;
        _symbol = contract_symbol;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        if (admin != address(0)) {
            _grantRole(DEFAULT_ADMIN_ROLE, admin);
        } //allows a centralized admin control, if wanted.
    }

    /**
     * @dev return custom collection URI, for legacy purposes
     *
     * @return _contractURI: string, the contract URI assigned from the constructor
     */
    function tokenURI() public view returns (string memory) {
        return _contractURI;
    }

    /**
     * @dev return custom collection name, for legacy purposes (eg. etherscan visualization)
     *
     * @return name: string, contract collection name defined during construction
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev return custom collection symbol, for legacy purposes (eg. etherscan visualization)
     *
     * @return contractURI: string, contract collection symbol defined during construction
     */
    function symbol() public view returns (string memory) {
        return _symbol;
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

    /**
     * @dev return custom contract URI (collection metadata) as described by OpenSea: https://docs.opensea.io/docs/contract-level-metadata
     *
     * @return contractURI: string, contractURI as defined in OpenSea standards.
     */
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    /**
     * @dev custom Mint implementation. Allows to check for custom contract_uri and burnable tokens.
     *
     * @param to: address, the target of our mint
     * @param tokenId: uint, token id we want to mint (can be both existent or not)
     * @param amount: uint, amount of tokenId we want to mint
     * @param contract_uri: string, URI we want to assign to tokenID, is set only if it's the first time minting the specific tokenId
     * @param burnable: bool, allows the user to burn token with the burnToken() function.
     *
     */
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        string memory contract_uri,
        bool burnable
    ) public nonReentrant onlyRole(MINTER_ROLE) {
        if (_exists(tokenId)) {
            _mint(to, tokenId, amount, "");
        }
        //if it exist already, just mint the NFT
        else {
            _mint(to, tokenId, amount, "");
            tokenMinted[tokenId] = true;
            _setTokenUri(tokenId, contract_uri); //if token URI is empty, token is considered ERC20 like

            //allows users to block current token burn. this is permanent.
            if (burnable) {
                isBurnable[tokenId] = true;
            }
        }
    }

    /**
     * @dev token burn custom implementation. Allows to control which tokenId is burnable (by the mint function) and to effectively burn its instances
     * from the blockchain.
     *
     * @param contract_address: address, of tokenId owner
     * @param tokenId: uint, token id we want to burn
     * @param amount: uint, amount of tokenId we want to burn
     *
     */
    function burnToken(
        address contract_address,
        uint256 tokenId,
        uint256 amount
    ) public nonReentrant onlyRole(BURNER_ROLE) {
        require(_exists(tokenId), "Token not existent!");
        require(isBurnable[tokenId], "Token is not burnable!");

        _burn(contract_address, tokenId, amount);
        _tokenURIs[tokenId] = ""; //restore mapping to default value
        tokenMinted[tokenId] = false;

        //no need to emit event, ERC721 takes care of this with a Transfer to the 0 address by default
    }

    /**
     * @dev _exists custom ERC1155 implementation. Allow to check if a specific tokenId exist.
     *
     * @param tokenId: uint, token id of which we want to check the existence
     * @return tokenExists: bool, says if token exist
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenMinted[tokenId];
    }

    /**
     * @dev uri function override, allows to assign a custom URI for each token ID
     *
     * @param tokenId: uint, token id of which we want to get the URI set by _SetTokenURI
     * @return URI: string, URI address of tokenId token
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC1155: query for non-existent object");
        return (_tokenURIs[tokenId]);
    }

    /**
     * @dev Custom _SetTokenURI ERC721 implementation. Allows URIs to be different for each tokenId
     *
     * @param tokenId: integer, the ID of which we want to change URI
     * @param token_uri: string, valid internet URI reachable by the blockchain on which there's a JSON Stored following
     * OpenSeas's metadata standards: https://docs.opensea.io/docs/metadata-standards
     *
     */
    function _setTokenUri(uint256 tokenId, string memory token_uri) private {
        _tokenURIs[tokenId] = token_uri;
        emit URI(uri(tokenId), tokenId);
    }

    /**
     * @dev This function returns an array of addresses associated with custom "role" account
     *
     * Requirements: AccessControlEnumerable imported in custom contract
     *
     * @param role: string, role that will be converted in bytes of which we want to enumerate addresses
     * @return addresses: address[], an array of addresses that are members of specific role
     */
    function getPrivilegedAccounts(string memory role)
        public
        view
        onlyRole(CONTRACT_METADATA_ROLE)
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

    /**
     * @dev public setURI implementation. Allows to change the ERC1155 contract URI on a later time.
     *
     * @param newuri: string, the new contract URI
     *
     */
    function setURI(string memory newuri) public onlyRole(CONTRACT_METADATA_ROLE) {
        _setURI(newuri);      
    }

    /**
     * @dev pausable public implementation, allows admins to block contract operation from an unpaused state. Only callable from PAUSER_ROLE members.
     *
     */
    function pause() public onlyRole(PAUSER_ROLE) whenNotPaused {
        _pause();
    }

    /**
     * @dev pausable public implementation, allows admins to unblock contract operation from a paused state. Only callable from PAUSER_ROLE members.
     *
     */
    function unpause() public onlyRole(PAUSER_ROLE) whenPaused {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlEnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
