pragma solidity 0.4.24;

import "../../openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "./ERC1132.sol";


contract BNOWToken is ERC1132, ERC20, ERC20Detailed {

   /**
    * @dev Error messages for require statements
    */
    string internal constant ALREADY_LOCKED = "Tokens already locked";
    string internal constant NOT_LOCKED = "No tokens locked";
    string internal constant AMOUNT_ZERO = "Amount can not be 0";

   /**
    * @dev constructor to mint initial tokens
    * Shall update to _mint once openzepplin updates their npm package.
    */
    constructor(uint256 supply) public
        ERC20Detailed("Bluenote World Token", "BNOW", 18) {
        _mint(msg.sender, supply);
    }

    /**
     * @dev Locks a specified amount of tokens against an address,
     *      for a specified reason and time
     * @param reason The reason to lock tokens
     * @param amount Number of tokens to be locked
     * @param time Lock time in seconds
     */
    function lock(bytes32 reason, uint256 amount, uint256 time)
        public
        returns (bool)
    {
        uint256 validUntil = now.add(time); //solhint-disable-line

        // If tokens are already locked, then functions extendLock or
        // increaseLockAmount should be used to make any changes
        require(tokensLocked(msg.sender, reason) == 0, ALREADY_LOCKED);
        require(amount != 0, AMOUNT_ZERO);

        if (locked[msg.sender][reason].amount == 0)
            lockReason[msg.sender].push(reason);

        _transfer(msg.sender, address(this), amount);

        locked[msg.sender][reason] = lockToken(amount, validUntil, false);

        emit Locked(msg.sender, reason, amount, validUntil);
        return true;
    }

    /**
     * @dev Transfers and Locks a specified amount of tokens,
     *      for a specified reason and time
     * @param to adress to which tokens are to be transfered
     * @param reason The reason to lock tokens
     * @param amount Number of tokens to be transfered and locked
     * @param time Lock time in seconds
     */
    function transferWithLock(address to, bytes32 reason, uint256 amount, uint256 time)
        public
        returns (bool)
    {
        uint256 validUntil = now.add(time); //solhint-disable-line

        require(tokensLocked(to, reason) == 0, ALREADY_LOCKED);
        require(amount != 0, AMOUNT_ZERO);

        if (locked[to][reason].amount == 0)
            lockReason[to].push(reason);

        _transfer(msg.sender, address(this), amount);

        locked[to][reason] = lockToken(amount, validUntil, false);

        emit Locked(to, reason, amount, validUntil);
        return true;
    }

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason
     *
     * @param account The address whose tokens are locked
     * @param reason The reason to query the lock tokens for
     */
    function tokensLocked(address account, bytes32 reason)
        public
        view
        returns (uint256 amount)
    {
        if (!locked[account][reason].claimed)
            amount = locked[account][reason].amount;
    }

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified reason at a specific time
     *
     * @param account The address whose tokens are locked
     * @param reason The reason to query the lock tokens for
     * @param time The timestamp to query the lock tokens for
     */
    function tokensLockedAtTime(address account, bytes32 reason, uint256 time)
        public
        view
        returns (uint256 amount)
    {
        if (locked[account][reason].validity > time)
            amount = locked[account][reason].amount;
    }

    /**
     * @dev Returns total tokens held by an address (locked + transferable)
     * @param who The address to query the total balance of
     */
    function totalBalanceOf(address who)
        public
        view
        returns (uint256 amount)
    {
        amount = balanceOf(who);

        for (uint256 i = 0; i < lockReason[who].length; i++) {
            amount = amount.add(tokensLocked(who, lockReason[who][i]));
        }
    }

    /**
     * @dev Extends lock for a specified reason and time
     * @param reason The reason to lock tokens
     * @param time Lock extension time in seconds
     */
    function extendLock(bytes32 reason, uint256 time)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, reason) > 0, NOT_LOCKED);

        locked[msg.sender][reason].validity = locked[msg.sender][reason].validity.add(time);

        emit Locked(msg.sender, reason, locked[msg.sender][reason].amount, locked[msg.sender][reason].validity);
        return true;
    }

    /**
     * @dev Increase number of tokens locked for a specified reason
     * @param reason The reason to lock tokens
     * @param amount Number of tokens to be increased
     */
    function increaseLockAmount(bytes32 reason, uint256 amount)
        public
        returns (bool)
    {
        require(tokensLocked(msg.sender, reason) > 0, NOT_LOCKED);
        _transfer(msg.sender, address(this), amount);

        locked[msg.sender][reason].amount = locked[msg.sender][reason].amount.add(amount);

        emit Locked(msg.sender, reason, locked[msg.sender][reason].amount, locked[msg.sender][reason].validity);
        return true;
    }

    /**
     * @dev Returns unlockable tokens for a specified address for a specified reason
     * @param who The address to query the the unlockable token count of
     * @param reason The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address who, bytes32 reason)
        public
        view
        returns (uint256 amount)
    {
        if (locked[who][reason].validity <= now && !locked[who][reason].claimed) //solhint-disable-line
            amount = locked[who][reason].amount;
    }

    /**
     * @dev Unlocks the unlockable tokens of a specified address
     * @param account Address of user, claiming back unlockable tokens
     */
    function unlock(address account)
        public
        returns (uint256 unlockableTokens)
    {
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[account].length; i++) {
            lockedTokens = tokensUnlockable(account, lockReason[account][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[account][lockReason[account][i]].claimed = true;
                emit Unlocked(account, lockReason[account][i], lockedTokens);
            }
        }

        if (unlockableTokens > 0)
            _transfer(address(this), account, unlockableTokens);
    }

    /**
     * @dev Gets the unlockable tokens of a specified address
     * @param account The address to query the the unlockable token count of
     */
    function getUnlockableTokens(address account)
        public
        view
        returns (uint256 unlockableTokens)
    {
        for (uint256 i = 0; i < lockReason[account].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(account, lockReason[account][i]));
        }
    }
}
