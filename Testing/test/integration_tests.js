const MainContract = artifacts.require("Game");
const SecondContract = artifacts.require("SecondContract");

contract("Integration testing", function() {
    it("Check impossibility of starting of not ready game", async () => {
        Game = await MainContract.deployed();
        subcontract = await SecondContract.deployed();
        subcontract.set_contract_address(Game.address);

        let could_start = true;
        try {
            await subcontract.start_game()
        } catch (err) {
            could_start = false;
        }
        assert.equal(could_start, false)
    });
    it("Check correctness of commitments via external contract", async () => {
        await subcontract.commit('0x8967b7f06516baafeab1c1ee2c60e05d534787c38b54b33e15fccf2c198120fc');
        player_1 = await Game.choices.call(0);
        player_2 = await Game.choices.call(1);
        // должен измениться только 1 игрок
        assert.equal(player_1.choice_hash,'0x8967b7f06516baafeab1c1ee2c60e05d534787c38b54b33e15fccf2c198120fc');
        assert.equal(player_2.choice_hash,'0x0000000000000000000000000000000000000000000000000000000000000000');
        assert.equal(player_1.choice,'');
        assert.equal(player_2.choice,'');
        // поскольку адрес кошелька, с которого проводятся тесты, может меняться, сделаем проверку на ненулевое значение
        assert.notEqual(player_1.player_addr, '0x0000000000000000000000000000000000000000')
        assert.equal(player_2.player_addr, '0x0000000000000000000000000000000000000000')
    });
    it("Check values after flashing game via external contract", async () => {
        await subcontract.flush_game();
        player_1 = await Game.choices.call(0);
        player_2 = await Game.choices.call(1);
        assert.equal(player_1.player_addr, '0x0000000000000000000000000000000000000000');
        assert.equal(player_2.player_addr, '0x0000000000000000000000000000000000000000');
        assert.equal(player_1.choice_hash, '0x0000000000000000000000000000000000000000000000000000000000000000');
        assert.equal(player_2.choice_hash, '0x0000000000000000000000000000000000000000000000000000000000000000');
        assert.equal(player_1.choice, '');
        assert.equal(player_2.choice, '');
    });
    
})
