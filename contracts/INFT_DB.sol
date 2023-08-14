// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev External interface of Custom NFTPlatform declared to support ERC165 detection.
 */
interface INFT_DB
{
    //Interface Methods definition

    /**
     * @dev return custom collection name, for legacy purposes (eg. etherscan visualization)
     *
     * @return name: string, contract collection name defined during construction
     */
    function name() external view returns (string memory);

    /**
     * @dev return custom collection URI, for legacy purposes
     *
     * @return _contractLevelMetadataURI: string, the contract URI assigned from the constructor
     */
    function tokenURI() external view returns (string memory);

    /**
     * @dev return custom contract URI (collection metadata) as described by OpenSea: https://docs.opensea.io/docs/contract-level-metadata
     *
     * @return contractURI: string, contractURI as defined in OpenSea standards.
     */
    function contractURI() external view returns (string memory);

    /**
     * @dev custom Mint implementation. Allows to check for custom contract_uri and burnable tokens.
     *
     * @param to: address, the target of our mintToken
     * @param tokenId: uint, token id we want to mintToken (can be both existent or not)
     * @param amount: uint, amount of tokenId we want to mintToken
     * @param contract_uri: string, URI we want to assign to tokenID, is set only if it's the first time minting the specific tokenId
     * @param burnable: bool, allows the user to burn token with the burnToken() function.
     *
     */
    function mintToken(address to, uint256 tokenId, uint256 amount, string memory contract_uri, bool burnable, bool nonMutable) external;

        /**
     * @dev token burn custom implementation. Allows to control which tokenId is burnable (by the mintToken function) and to effectively burn its instances
     * from the blockchain.
     *
     * @param contract_address: address, of tokenId owner
     * @param tokenId: uint, token id we want to burn
     * @param amount: uint, amount of tokenId we want to burn
     *
     */
    function burnToken(address contract_address, uint256 tokenId, uint256 amount) external;

    /**
     * @dev Custom tokenID check implementation. Allow to check if a specific tokenId exist.
     *
     * @param tokenId: uint, token id of which we want to check the existence
     * @return tokenExists: bool, says if token exist
     */
    function exists(uint256 tokenId) external view returns (bool);

    /**
     * @dev Custom _SetTokenURI ERC721 implementation. Allows URIs to be different for each tokenId
     *
     * @param tokenId: integer, the ID of which we want to change URI
     * @param token_uri: string, valid internet URI reachable by the blockchain on which there's a JSON Stored following
     * OpenSeas's metadata standards: https://docs.opensea.io/docs/metadata-standards
     *
     */
    function setTokenUri(uint256 tokenId, string memory token_uri) external;

    /**
     * @dev This function returns an array of addresses associated with custom "role" account
     *
     * Requirements: AccessControlEnumerable imported in custom contract
     *
     * @param role: string, role that will be converted in bytes of which we want to enumerate addresses
     * @return addresses: address[], an array of addresses that are members of specific role
     */
    function getCurrentPrivilegedAccounts(string memory role) external view returns (address[] memory);

}