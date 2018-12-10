const bluenoteToken = artifacts.require('./BluenoteToken.sol');
const assertExpectedArguments = require('./utils/assertExpectedArguments');
const { assertRevert } = require('./utils/assertRevert');

contract('BluenoteToken', ([owner, receiver, spender]) => {
  const supply = 12500000000000000000000000000;
  const NAME = 'Bluenote World Token';
  const SYMBOL = 'BNOW';
  const DECIMALS = 18;

  let blockNumber = web3.eth.blockNumber;
  const lockTimestamp = web3.eth.getBlock(blockNumber).timestamp;
  const nullAddress = 0x0000000000000000000000000000000000000000;
  const increaseTime = function(duration) {
    web3.currentProvider.sendAsync(
      {
        jsonrpc: '2.0',
        method: 'evm_increaseTime',
        params: [duration],
        id: lockTimestamp
      },
      (err, resp) => {
        if (!err) {
          web3.currentProvider.send({
            jsonrpc: '2.0',
            method: 'evm_mine',
            params: [],
            id: lockTimestamp + 1
          });
        }
      }
    );
  };

  context('given invalid params', () => {
    it('error if supplied with params', () =>
      assertExpectedArguments(0)(bluenoteToken.new(12)));
  });

  context('given no params', () => {
    let token;

    before(async () => {
      token = await bluenoteToken.new();
    });

    it('can be created', () => {
      assert.ok(token);
    });

    it('has the right balance for the contract owner', async () => {
      const balance = await token.balanceOf(owner);
      const totalBalance = await token.totalBalanceOf(owner);
      const totalSupply = await token.totalSupply();
      assert.equal(balance.toNumber(), supply);
      assert.equal(totalBalance.toNumber(), supply);
      assert.equal(totalSupply.toNumber(), supply);
    });

    it('has the right details', async () => {
      const name = await token.name();
      const symbol = await token.symbol();
      const decimals = await token.decimals();
      assert.equal(name, NAME);
      assert.equal(symbol, SYMBOL);
      assert.equal(decimals.toNumber(), DECIMALS);
    });

  });
});
