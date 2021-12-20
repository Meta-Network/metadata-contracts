//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract IPFSCidTimestampMapping is AccessControl {
    struct TimeStamp {
        uint256 timestamp;
        uint256 blockNumber;
    }

    mapping(string => TimeStamp) public cidTimestampMapping;

    event TimestampSaved(string cid);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function mint(string memory cid) public onlyRole(MINTER_ROLE) {
        require(
            cidTimestampMapping[cid].timestamp == 0,
            "The CID has been minted"
        );

        cidTimestampMapping[cid] = TimeStamp({
            timestamp: block.timestamp,
            blockNumber: block.number
        });

        emit TimestampSaved(cid);
    }

    function burn(string memory cid) public onlyRole(ADMIN_ROLE) {
        delete cidTimestampMapping[cid];
    }
}
