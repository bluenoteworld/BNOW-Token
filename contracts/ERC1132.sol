pragma solidity ^0.4.24;

/**
 * @title ERC1132 interface
 * @dev see https://github.com/ethereum/EIPs/issues/1132
 */

contract ERC1132 {
    /**
     * @dev Reasons why a user's tokens have been locked
     */
    mapping(address => bytes32[]) public lockReason;

    /**
     * @dev locked token structure
     */
    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    /**
     * @dev Holds number & validity of tokens locked for a given reason for
     *      a specified address
     */
    mapping(address => mapping(bytes32 => lockToken)) public locked;

    /**
     * @dev Records data of all the tokens Locked
     */
    event Locked(
        address indexed account,
        bytes32 indexed reason,
        uint256 amount,
        uint256 validity
    );

    /**
     * @dev Records data of all the tokens unlocked
     */
    event Unlocked(
        address indexed account,
        bytes32 indexed reason,
        uint256 amount
    );

    /**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     * @param reason The reason to lock tokens
     * @param amount Number of tokens to be locked
     * @param time Lock time in seconds
     */
    function lock(bytes32 reason, uint256 amount, uint256 time)
        public returns (bool);

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason
     *
     * @param account The address whose tokens are locked
     * @param reason The reason to query the lock tokens for
     */
    function tokensLocked(address account, bytes32 reason)
        public view returns (uint256 amount);

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specific time
     *
     * @param account The address whose tokens are locked
     * @param reason The reason to query the lock tokens for
     * @param time The timestamp to query the lock tokens for
     */
    function tokensLockedAtTime(address account, bytes32 reason, uint256 time)
        public view returns (uint256 amount);

    /**
     * @dev Returns total tokens held by an address (locked + transferable)
     * @param who The address to query the total balance of
     */
    function totalBalanceOf(address who)
        public view returns (uint256 amount);

    /**
     * @dev Extends lock for a specified reason and time
     * @param reason The reason to lock tokens
     * @param time Lock extension time in seconds
     */
    function extendLock(bytes32 reason, uint256 time)
        public returns (bool);

    /**
     * @dev Increase number of tokens locked for a specified reason
     * @param reason The reason to lock tokens
     * @param amount Number of tokens to be increased
     */
    function increaseLockAmount(bytes32 reason, uint256 amount)
        public returns (bool);

    /**
     * @dev Returns unlockable tokens for a specified address for a specified reason
     * @param who The address to query the the unlockable token count of
     * @param reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address who, bytes32 reason)
        public view returns (uint256 amount);

    /**
     * @dev Unlocks the unlockable tokens of a specified address
     * @param account Address of user, claiming back unlockable tokens
     */
    function unlock(address account)
        public returns (uint256 unlockableTokens);

    /**
     * @dev Gets the unlockable tokens of a specified address
     * @param account The address to query the the unlockable token count of
     */
    function getUnlockableTokens(address account)
        public view returns (uint256 unlockableTokens);

}
