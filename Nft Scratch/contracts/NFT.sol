// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contract/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Pokemon is VRFConsumerBaseV2, ERC7221URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //global variables
    // constant variables are gas efficient
    uint16 constant REQUEST_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;
    // immutable variables are gas efficient
    VRFCoordinatorV2Interface immutable i_VRFCoordinator;
    uint64 immutable i_subscriptionId;
    bytes32 immutable keyhash;
    uint256 public fee;
    uint32 immutable i_gasLimit;
    address immutable i_VRFCoordinatorV2;

    uint256 public i_requestId;
    uint256[] public i_randomWords;
    address owner;

    // request randomness
    // fulfill randomness
    // mapping for nfts
    // mapping for request id received from coordinator
    // function for determining which nft youreceive / rarirty

    mapping(bytes32 => address) requestIdToSender;
    mapping(bytes32 => string) requestIdToTokenUri;
    event requestedCollectiblee(bytes32 indexed requestId);

    constructor(
        address VRFCoordinatorV2,
        uint64 subscriptionId,
        uint32 gasLimit,
        uint256 requestId,
        string[10] memory pokemonTokenUris
    ) ERC721("Pokemon", "PKM") VRFConsumerBaseV2(VRFCoordinatorV2) {
        i_subscriptionId = subscriptionId;
        i_keyhash = keyhash;
        i_fee = .1 * 10**18; // 0.1 Link
        i_gasLimit = gasLimit;
        i_requestId = requestId;
        i_VRFCoordinatorV2 = VRFCoordinatorV2Interface(VRFCoordinatorV2);
        owner = msg.sender;
        i_ pokemonTokenUris = pokemonTokenUris;
    }

    function createCollectible() external returns (bytes32) {
        i_requestId = i_VRFCoordinatorV2(
            keyhash,
            REQUEST_CONFIRMATIONS,
            i_subscriptionId,
            NUM_WORDS,
            i_gasLimit
        );
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenUri[requestId] = pokemonTokenUri;
        emit requestedCollectible(requestId);
        return tokenURI;
    }

    function fulfillRandomness(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        i_randomWords = randomWords;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    // award nft to minter by setting a newItemId = tokenId
    // using the built int mint function
    // using the built in _setTokenURI(newItemId, tokenURI); function
    // increment tokwn id
    //return newTokenId
    function awardPokemon(address owner, string memory tokenURI)
        public
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        uint256 moddedRng = randomWords[0] % 11;
        uint256 breed = getPokemonFromModdedRng(moddedRng);
        _safeMint(owner, newItemId);
        _setTokenURI(newItemId, pokemonTokenUris[breed]);
        _tokenIds.increment();
        return newTokenId;
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    }

    function getPokemonFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (uint256)
    {
        uint256 sum = 0;
        uint256[10] memory chanceArray = getChanceArray();

        for (uint256 i = 0; i < chanceArray.lenght; i++) {
            if (moddedRng >= sum && moddedRng < sum + chanceArray[i]) {
                return i;
            }
            sum = sum + chanceArray[1];
        }
    }
}
