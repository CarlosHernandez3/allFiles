// SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;
// importing token standard & VRF
//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFCoonsumerBase {
    bytes32 internal keyshash;
    uint256 public fee;
    uint256 public tokenCounter;

    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => uint256) public requestIdtoTokenId;
    event requestedCollectible(bytes32 indexed requestId);

    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyhash
    )
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("Doggies", "DOG")
    {
        keyhash = _keyhash;
        fee = 0.1 * 10**18; //0.1 Link
        tokenCounter = 0;
    }

    function createCollectible(uint256 userProvidedSeed, string memory tokenURI)
        public
        returns (bytes32)
    {
        bytes32 requestId = requestRandomness(keyhash, fee, userProvidedSeed);
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI[requestId] = tokenURI;
        emit requestedCollectible(requestId);
    }

    function fulfilllRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        address dogOwner = requestIdToSender[requestId];
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomNumber % 3);
        tokenIdToBreed[newTokenId] = breed;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;

        function SetTokenURI(uint256 tokenId, string memory _tokenURI) public {
            require(
                _isApprovedOrOwner(_msg.sender(), tokenid),
                "ERC721: transfer caller is not owner or approved"
            );
            _setTokrnURI(tokenId, _tokenURI);
        }
    }
}
// 55:00 video
