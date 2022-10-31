// In this simple game, players can first need to join the game by using the function join().To join the game, players need to input a seed, which will
// be used to generate the random number of dice. After that, players need to deposit at least 5 Ether through deposit() function to start the game.
// After there are two players and they have both deposited the money, any one of these two players can choose to roll the dice by using the function Rolling()
// If the dice number is 1~3, the player A wins , otherwise player B wins
// If player A rolls the dice, then he can not withdraw the money and B will need to withdraw the money by using the function withdraw().
// After one of the player withdraws the money, the winner will get his reward including his deposit, the loser will get his deposit subtracting the lost money
// Then, the game can be restarted by using the function New(), which requires the gamer to input the seed again and deposit 5 ETH again, then they can follow the proceduces above to finish the game
// To end the game, any player can choose to use the function End() to leave the game. Once they leave the game, their info will be deleted.
pragma solidity >=0.7.0 <0.9.0;
contract RollDice{
    //Dice number
    uint256 public Dice;
    // Record the number of rolling
    uint256 Rollcount;
    // Record the current number of players online
    uint256 player_number;

    // Flag for checking if the current ends or not
    bool game_end=false;

    // record the address which already rolled the dice' 
    address Lastrolled;
    struct Player{
        //player's address
        address player_address;

        // player's balance
        uint256 player_balance;

        // check if the player join the game
        bool if_join;

        // player's seed
        string player_seed;

        // the time when the player join
        uint256 join_time;
    }

    Player playerA;
    Player playerB;
    
    // This function is used to deposit the money from the player to the contract account, player is required to deposit at least 5 Ether to start the game
    // This function will first check if the current player is in the game, if not it will send a error message
    function deposit () public payable{
        // check if the sender is the player in the game
        require(playerA.player_address == msg.sender || playerB.player_address == msg.sender, "You are not in the game!!!" );

        // For each game, either player A or player B needs to deposit at least 5 ether in the contract account.
        require(msg.value >=5 ether , "Please deposit at least five ether!!");

        

        if(msg.sender == playerA.player_address){
            playerA.player_balance = playerA.player_balance + msg.value;
        }
         else if (msg.sender == playerB.player_address)
        {
            playerB.player_balance = playerB.player_balance + msg.value;
        }
    }
    // This function is used to end the game.
    // First, it will check if the current player is in the game. If not it will send an error message
    // Then, it will check if the game has already ended, if not it will send an error message
    // Anyone of these two players leave the game, their information will be removed, and their money will be back
    function EndGame() public
    {
        require(playerA.player_address== msg.sender || playerB.player_address == msg.sender, "You are not in the game !!!");
        require(game_end==true,"The game doesn't end!!!");
        // playerA left
        if(msg.sender == playerA.player_address){
           uint256 reward_A = playerA.player_balance;
           playerA.player_balance=0;
           playerA.if_join=false;
           payable(playerA.player_address).transfer(reward_A);
           delete playerA;
           player_number=player_number-1;
        }
        // playerB left
        else
        {
           uint256 reward_B = playerB.player_balance;
           playerB.player_balance=0;
           playerB.if_join=false;
           payable(playerB.player_address).transfer(reward_B);
           delete playerB;
           player_number=player_number-1;
        }
        Dice = 0;
    }
    // Each player needs to input the new player's seed to start the new game
    // This function will fisrt have four different require message, which will check if the game already end, if player is in the game, if the player input seed, and if the dice has been reset
    // Then new timestamp will be used to update the new join time
    function New(string memory seed) public
    {
      require(game_end==true,"The game doesn't end!!!");
      require(playerA.player_address== msg.sender || playerB.player_address == msg.sender, "You are not in the game !!!");
      require(bytes(seed).length != 0, "At least input one single letter");
      require(Dice==0,"The dice is not reset!!");
      Dice =0;
      if (bytes(playerA.player_seed).length != 0 && bytes(playerB.player_seed).length != 0  )
      {
          game_end=false;
      }
      if(msg.sender == playerA.player_address)
      {
            playerA.player_seed= seed;
            playerA.join_time=block.timestamp;
      }
      else
       {
           playerB.player_seed = seed;
           playerB.join_time=block.timestamp;
       }
    }
    // This function is used for players to join the game.
    // It has three different require function, which will be used to check wehter the spots are full
    // And if you are already in the game, you can not join twice.
    // It will also check if you input a complete seed to generate the random number
    function join (string memory seed) public
    {
        // Check if player A's address  or player B's address is the same as the sender's address, if they are both not equal to that
        // It means both A and B are already in the game,there is no spot
        require(player_number<=2,"There are no spots");
        require(playerA.player_address != msg.sender && playerB.player_address != msg.sender, "You can not join twice");

        // require the player to input something to set the seed
        require(bytes(seed).length != 0,"At least input one single letter");
        
        // if the spot A is empty, then the first player who joins the game is the player A
        if (playerA.if_join==false)
        {
           // set the address;
           playerA.player_address = msg.sender;

           // Now player is in the game
           playerA.if_join = true;

           // set the seed
           playerA.player_seed = seed;

           //set the time when the player join the game
           playerA.join_time=block.timestamp;
           player_number=player_number+1;
        }
        else
        {
           // set the address;
           playerB.player_address = msg.sender;

           // Now player is in the game
           playerB.if_join = true;

           // set the seed
           playerB.player_seed = seed;

           //set the time when the player join the game
           playerB.join_time=block.timestamp;

           player_number=player_number+1;
        }
    }
    // This function is used for one of the players to roll the dice.
    // It will first check if the player is in the game and then check if there are enough players in the game
    // Also, if the player wants to roll the dice, he needs to make sure that his has enough money in his account
    // If the game hasn't ended yet, the dice should not be rolled again
    function Rolling () public
    {
        // check if the player is in the game
        require(playerA.player_address == msg.sender || playerB.player_address == msg.sender, "You are not in the game!!!" );

        // check if player A and player B are both in the game
        require(playerA.if_join ==true && playerB.if_join ==true, "There should be two players in the game!!" );
        
        //check if both of the players' accounts have enough money.
        require(playerA.player_balance>=5 && playerB.player_balance>=5,"The account money is not enough!!" );

        // if the current game doesn't end, then it should not be rolled
        require(Rollcount==0,"One rolling in one sigle game !!!");

        if (msg.sender==playerA.player_address)
        {
            //generate the random number in the  range from(1,6)
            Dice=uint(keccak256(abi.encodePacked(playerA.join_time,playerA.player_seed,playerB.player_address))) % 6;
            Dice=Dice+1;
            Rollcount=Rollcount+1;
            Lastrolled=playerA.player_address;
        }
        else 
        {
            Dice=uint(keccak256(abi.encodePacked(playerB.join_time,playerB.player_seed,playerA.player_address))) % 6;
            Dice=Dice+1; 
            Rollcount=Rollcount+1;
            Lastrolled=playerB.player_address;
        }

    }
    // Display the player A's balance
    function show_A_balance() public view returns (uint256)
    {
        if (playerA.if_join == false)
        {
            return 0;
        }
        else
        {
            return playerA.player_balance;
        }
    }

    // Display the player B's balance
    function show_B_balance() public view returns (uint256)
    {
        if (playerB.if_join == false)
        {
            return 0;
        }
        else
        {
            return playerB.player_balance;
        }
    }
        function show_player_number() public view returns(uint256)
    {
        return player_number;
    }
    // This function will be used for these players to withdraw money from the contract account.
    function withdraw() public
    {
       // First check if the dicenumber, make sure that the dice is already rolled.
        require(Dice != 0, "Please roll the dice first");
        //Make sure the player who wants to withdraw the money is the player in the game
        require(playerA.player_address== msg.sender || playerB.player_address == msg.sender, "You are not in the game !!!");
        
        // The player who has already rolled dice can not withdraw and it another palyer's turn to withdraw the money in order to save the gas fee by reducing 
        // the number of operations.
        require(msg.sender!=Lastrolled,"Please let the other player withdraw money");
        // dice number is regarded as 1~6 Wei in the game, so if the player wants withdraw money in units of ehter, it has to multiply 10^18
        // To avoid the reentrancy attack, before using the dice number, dice number is set as zero, so a temp variable is initialised to store the Dice number.
        uint256 temp= Dice * 1000000000000000000;
        uint256 temp_A_balance = playerA.player_balance;
        uint256 temp_B_balance = playerB.player_balance;
        //To avoid reentrancy attack, the dice number is set as zero, and all of the players' balance are set as zero to prevented being called back
        playerA.player_balance = 0;
        playerB.player_balance= 0;
        Dice = 0;

        //Dice: 1~3
        if(temp>= 1000000000000000000 && temp <= 3000000000000000000){
            uint256 reward_A = temp + temp_A_balance;
            uint256 reward_B = temp_B_balance - temp;
            
            // In this case, player A win this game and win money of dicenumber and get his original money back
            payable(playerA.player_address).transfer(reward_A);

            // For player B, he lost this game and lost the money that A wins and get the rest of his money back
            payable(playerB.player_address).transfer(reward_B);
        }
        // Dice:4~6
        else{
            uint256 reward_A= temp_A_balance + 3000000000000000000 - temp;
            uint256 reward_B = temp_B_balance + temp - 3000000000000000000;
            payable(playerA.player_address).transfer(reward_A);
            payable(playerB.player_address).transfer(reward_B);
        }
        // After each game, each player's seed is set as empty.
        playerA.player_seed = "";
        playerB.player_seed = "";
        Rollcount=0;
        game_end=true;
    }
    
}