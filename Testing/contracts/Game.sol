// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// rock-paper-scissors commit reveal scheme

contract Game {
    
    struct Choice {
        bytes32 choice_hash; 
        string choice;
        address player_addr;
    }
    
    enum Step {
        first_choice,
        second_choice,
        first_reveal,
        second_reveal,
        start_game
    }
    
    
    // для рассылки ивентов
    event Commit(address player, bytes32 choice_hash);
    event Reveal(address player, string choice);
    event Winner(address player);
    
    
    Choice[2] public choices;
    Step public step_indicator = Step.first_choice;
    address public game_winner;
    
    
    
    // проверяем, что это этап, когда участники делают свои выборы
    modifier is_commit_step() {
        bool step = false;
        if (step_indicator == Step.first_choice || step_indicator == Step.second_choice) step = true;
        require(step == true, "The participants have already made their choices!");
        _;
    }
    
    // функция для принятия от участников хэшей от их выборов и секретов -> hash(choice, password)
    function commit(bytes32 choice_hash) public is_commit_step() {
        if (step_indicator == Step.first_choice ) {
            // сохраняем хэш выбора первого игрока и записываем его адрес
            choices[0].choice_hash = choice_hash;
            choices[0].player_addr = msg.sender;
            step_indicator = Step.second_choice;
        } else if  (step_indicator == Step.second_choice ) {
            // сохраняем хэш выбора второго игрока и записываем его адрес
            choices[1].choice_hash = choice_hash;
            choices[1].player_addr = msg.sender;
            step_indicator = Step.first_reveal;
        }
        emit Commit(msg.sender, choice_hash);
    }
    
    function flush_game() public {
        delete choices;
        step_indicator = Step.first_choice;
        delete game_winner;
    }
    
    // есть какая-то дефолтная функция сравнения строк? Пока пришлось сравнивать хеши
    function _compare_strings(string memory a, string memory b) internal returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    
    // проверяем, что пользователь отправил только валидный выбор
    // валидные значения - rock paper scissors
    modifier allowed_choice(string memory choice) {
        bool is_allowed = false;
        if (_compare_strings(choice, "rock")) is_allowed=true;
        else if (_compare_strings(choice, "paper")) is_allowed=true;
        else if (_compare_strings(choice, "scissors")) is_allowed=true;
        require(is_allowed == true, "Incorrect choice!");
        _;
        
    }
    
    // проверяем, что этап reveal
    modifier is_reveal_step() {
        bool reveal_step = false;
        if (step_indicator == Step.first_reveal || step_indicator == Step.second_reveal) reveal_step = true;
        require(reveal_step == true, "Now is not the reveal step!");
        _;
    }
    
    
    function check_hash(string memory choice, string memory password, bytes32 choice_hash) internal returns (bool) {
        return keccak256(abi.encodePacked(choice, password)) == choice_hash;
    }

    // раскрываем секреты пользователей
    // пользователи присылают выборы и пароли, берем хэш и сравниваем с тем, что уже записано
    // модифаеры должны быть именно в таком порядке
    function reveal(string memory choice, string memory password) public is_reveal_step() allowed_choice(choice) {
        if (choices[0].player_addr == msg.sender && bytes(choices[0].choice).length == 0) {
            //проверяем, что закоммиченный хэш совпадает с хэшем от переданных пользователем значениями
            require(check_hash(choice, password, choices[0].choice_hash) == true, "An attempt at deception has been detected!");
            // устанавливаем значение
            choices[0].choice = choice;
            // сдвигаем степ
            step_indicator = Step.second_reveal;
            
        } else if (choices[1].player_addr == msg.sender && bytes(choices[1].choice).length == 0) {
            //проверяем, что закоммиченный хэш совпадает с хэшем от переданных пользователем значениями
            require(check_hash(choice, password, choices[1].choice_hash) == true, "An attempt at deception has been detected!");
            // устанавливаем значение
            choices[1].choice = choice;
            // сдвигаем степ
            step_indicator = Step.start_game;
        } 
        emit Reveal(msg.sender, choice);
    }
    
    // проверяем, что все игроки раскрыли свои секреты и что можно начинать игру
    modifier is_game_step() {
        bool game_step = false;
        if (step_indicator == Step.start_game) game_step = true;
        require(game_step == true, "Now is not the game step!");
        _;
    }
    
    // начинаем игру и проверяем все значения
    // функция возвращает адрес победителя
    // если выборы равны, то возвращается пустой адрес
    function start_game() public is_game_step() returns (address) {
        address winner;
        if (_compare_strings(choices[0].choice, choices[1].choice)) {
            // никто не выиграл
            
        } else if (_compare_strings(choices[0].choice, "rock") &&  _compare_strings(choices[1].choice, "scissors")){
            // выиграл первый
            winner = choices[0].player_addr;
        } else if (_compare_strings(choices[0].choice, "scissors") &&  _compare_strings(choices[1].choice, "rock")){
            // выиграл второй
            winner = choices[1].player_addr;
        } else if (_compare_strings(choices[0].choice, "rock") &&  _compare_strings(choices[1].choice, "paper")){
            // выиграл второй
            winner = choices[1].player_addr;
        } else if (_compare_strings(choices[0].choice, "paper") &&  _compare_strings(choices[1].choice, "rock")){
            // выиграл первый
            winner = choices[0].player_addr;
        } else if (_compare_strings(choices[0].choice, "paper") &&  _compare_strings(choices[1].choice, "scissors")){
            // выиграл второй
            winner = choices[1].player_addr;
        } else if (_compare_strings(choices[0].choice, "scissors") &&  _compare_strings(choices[1].choice, "paper")){
            // выиграл первый
            winner = choices[0].player_addr;
        }
        emit Winner(winner);
        game_winner = winner;
        return winner;
    }
    
}
