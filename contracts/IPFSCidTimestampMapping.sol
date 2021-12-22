//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract IPFSCidTimeInfoMapping is AccessControl {
    struct TimeInfo {
        uint256 timestamp;
        uint256 blockNumber;
    }

    mapping(string => TimeInfo) public cidTimeInfoMapping;

    event TimeInfoSaved(string cid);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function mint(string memory cid) public onlyRole(MINTER_ROLE) {
        require(
            cidTimeInfoMapping[cid].timestamp == 0,
            "The CID has been minted"
        );

        cidTimeInfoMapping[cid] = TimeInfo({
            timestamp: block.timestamp,
            blockNumber: block.number
        });

        emit TimeInfoSaved(cid);
    }

    function burn(string memory cid) public onlyRole(ADMIN_ROLE) {
        delete cidTimeInfoMapping[cid];
    }

    function getCIDTimeInfo(string memory cid)
        public
        view
        returns (uint256, uint256)
    {
        require(
            cidTimeInfoMapping[cid].timestamp != 0,
            "The CID has not been minted"
        );

        return (
            cidTimeInfoMapping[cid].timestamp,
            cidTimeInfoMapping[cid].blockNumber
        );
    }
}
