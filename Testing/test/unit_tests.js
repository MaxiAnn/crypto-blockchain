const MainContract = artifacts.require("Game");

contract("Unit testing", function() {
    it("Check empty values in init stage...", async () => {
        // деплоим контракт
        Game = await MainContract.deployed();
        let player_1 = await Game.choices.call(0);
        let player_2 = await Game.choices.call(1);

        // проверяем, что адреса, хэши и выборы пустые 
        assert.equal(player_1.player_addr, '0x0000000000000000000000000000000000000000');
        assert.equal(player_2.player_addr, '0x0000000000000000000000000000000000000000');
        assert.equal(player_1.choice_hash, '0x0000000000000000000000000000000000000000000000000000000000000000');
        assert.equal(player_2.choice_hash, '0x0000000000000000000000000000000000000000000000000000000000000000');
        assert.equal(player_1.choice, '');
        assert.equal(player_2.choice, '');
    });
    it("Check correctness of commitments...", async () => {
        await Game.commit('0x8967b7f06516baafeab1c1ee2c60e05d534787c38b54b33e15fccf2c198120fc');
        await Game.commit('0xeda61565c0daa3597a0bea2c298d82d2b095292d405e4f23fa8885845e8db8b2');
        player_1 = await Game.choices.call(0);
        player_2 = await Game.choices.call(1);

        // проверяем, что значения установлены корректно
        assert.equal(player_1.choice_hash,'0x8967b7f06516baafeab1c1ee2c60e05d534787c38b54b33e15fccf2c198120fc');
        assert.equal(player_2.choice_hash,'0xeda61565c0daa3597a0bea2c298d82d2b095292d405e4f23fa8885845e8db8b2');
        assert.equal(player_1.choice,'');
        assert.equal(player_2.choice,'');
        // поскольку адрес кошелька, с которого проводятся тесты, может меняться, сделаем проверку на ненулевое значение
        assert.notEqual(player_1.player_addr, '0x0000000000000000000000000000000000000000')
        assert.notEqual(player_2.player_addr, '0x0000000000000000000000000000000000000000')
    });
    it("Check limit of commitments...", async () => {
        // проверяем, что нельзя сделать больше двух коммитов
        let could_commit = true;
        try {
            await Game.commit('0x8967b7f06516baafeab1c1ee2c60e05d534787c38b54b33e15fccf2c198120fc');
        } catch (err) {
            could_commit = false;
        }
        assert.equal(could_commit, false)
    });
    it("Check reveal correctness #1...", async () => {
        // проверяем, что если подать неправильное значение на reveal, то сработает исключение
        let could_reveal = true;
        try {
            await Game.reveal('scissors', 'pass123'); // correct pass is pass1
        } catch (err) {
            could_reveal = false;
        }
        assert.equal(could_reveal, false)
    });
    it("Check reveal correctness #2...", async () => {
        // проверяем, что если подать правильное значение на reveal, то запишется choice и исключения не будет
        let could_reveal = true;
        try {
            await Game.reveal('scissors', 'pass1'); // correct pass is pass1
        } catch (err) {
            could_reveal = false;
        }
        assert.equal(could_reveal, true)
        player_1 = await Game.choices.call(0);
        assert.equal(player_1.choice, 'scissors')
    });
})