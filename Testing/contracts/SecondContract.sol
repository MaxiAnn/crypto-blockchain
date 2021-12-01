pragma solidity <0.9.0;
// SPDX-License-Identifier: MIT

import "./Game.sol";

contract SecondContract {
    Game MainContract;
    
    function set_contract_address(address contract_address) public {
        MainContract = Game(contract_address);
    }
 
    // Начинаем игру
    function start_game() public {
        MainContract.start_game();
    }
    
    // сбрасываем все значения
    function flush_game() public {
        MainContract.flush_game();
    }

    // получаем адрес победителя
    function get_winner() public returns (address) {
        return MainContract.game_winner();
    }

    // коммитим хэш через второй контракт
    function commit(bytes32 data) public {
        MainContract.commit(data);
    }

    // раскрываем секрет через второй контракт
    function reveal(string memory choice, string memory password) public {
        MainContract.reveal(choice, password);
    }
} 