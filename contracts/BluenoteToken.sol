pragma solidity 0.4.24;

import "./LockableToken.sol";
import "../../openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";


contract BluenoteToken is LockableToken, ERC20Detailed {


  /**
   * @dev constructor to call constructors for LockableTocken and ERC20Detailed
   *
   */
    constructor() public
        ERC20Detailed("Bluenote World Token", "BNOW", 18)
        LockableToken(12500000000000000000000000000) {
        //
    }


}
