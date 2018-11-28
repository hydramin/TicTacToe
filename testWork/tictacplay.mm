
function startGame()
{
    /*board = mk_imat(1..3, 1..3);*/
    printf("Initializing the game...\n");
    /*board = mk_fmat(1..3,1..3,[[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]]);*/ /*filled with -1*/
    board = mk_ivec(1..9,[-1,-1,-1,-1,-1,-1,-1,-1,-1]);

    /* Set Absolute position X and Y of the board */ 
    /*xm = mk_fmat(1..3,1..3,[[12.5,15.5,18.5],[12.5,15.5,18.5],[12.5,15.5,18.5]]);*/ 
    /*ym = mk_fmat(1..3,1..3,[[3,3,3],[0,0,0],[-3,-3,-3]]);*/
    xm = mk_fvec(1..9,[12.5,15.5,18.5,12.5,15.5,18.5,12.5,15.5,18.5]);
    ym = mk_fvec(1..9,[3,3,3,0,0,0,-3,-3,-3]);
    refM = mk_fmat(1..9,1..2);
    refM[1..9,1] = xm;
    refM[1..9,2] = ym;
    
    printf("Press Start if you're ready to play...\n");
    clicked = setButton("Start");
    while(!clicked){}; /*if button not clicked game wont proceed*/
    
    printf("Game starts...\n");
    printf("Let's decide who should go first... pick head(1) or tail(0)!\n");
    winner = coinToss(0);
    turn = winner; 
    
    while(checkWinner(board) != -1)
    {
        if(turn == 1)
	    {
            if(clicked)
            {
                img = proj_grabImage();
                /*dxy = proj_getDistance(xm,ym,proj_getCenter(background,img2));*/
                /*index = proj_getMinIndex(dxy);*/
                index = proj_minDistIndex(proj_getCenter(background,img2),refM);
                /*board[index[1]][index[2]] = 2;*/  
                board[index] = 2;
                printBoard(board);
                turn = 2;       
            }; 
	    }
        else
        {
            board = play(board);
	        background = proj_grabImage();
            printBoard(board);
	        clicked = setButton("Play!"); 
            turn = 1; 
        };
    };    

    winner = checkWinner(board);
    printf("Game is over! The winner is: ");
    if(winner == 1) {printf("Robot, I won!\n");}
    else if(winner == 2) {printf("Human, You won!\n");};
};

/* gridPosMat is the absolute position that the robot will go to to place the tile on the grid */
/*Input: board-model for the playing board with marks, gridPosmat-see above, */
function play(board,gridPosMat)
{
    i = to_int(random()*10); 
    for(i; board[i] != -1; i = to_int(random()*10));
    
    
    /* Move the robot should be added */
    placeIt(gridPosMat[i,1],gridPosMat[i,2]);
    
    printf("Your turn...\n");
    board; 
};

/* gridPos is the absolute position of the grid 1 to 9 */
/* It should have x and y absolute value of that grid */
function placeIt(gridPosx, )
{
    /* go to the base position to grab the piece */
    CRSinvkin (-15, 0, 1);
    sleep(5);
    servo_close(50);
    CRSinvkin(gridPos[1],gridPos[2],1);
    sleep(5);
    servo_open(50);
    sleep(3);
    rob_move_abs(0,90,0,0,0);
};



/*Input: 3x3 empty board, Output: all positons filled with -1*/
function initialize(board) 
{ 
    /* Initially the board is empty */ 
    for (i=1; i<=board->vsize; i++) 
    { 
        for (j=1; j<=board->hsize; j++)
        {
            board[i][j] = -1; 
        };    
    }; 
    board; 
}; 

/*Input: 3x3 playing board model, Output: below*/ 
/*  1 or 2 if game is over. */
/*  0 if game is draw.      */
/* -1 if game is still in progress.  */

function checkWinner(board)
{
    winner = -1;
    if (board[1,1] == board[1,2] && board[1,2] == board[1,3]) {winner = board[1,1];};
    if (board[2,1] == board[2,2] && board[2,2] == board[2,3]) {winner = board[2,1];};       
    if (board[3,1] == board[3,2] && board[3,2] == board[3,3]) {winner = board[3,1];};       
    if (board[1,1] == board[2,1] && board[2,1] == board[3,1]) {winner = board[1,1];};   
    if (board[1,2] == board[2,2] && board[2,2] == board[3,2]) {winner = board[1,2];};     
    if (board[1,3] == board[2,3] && board[2,3] == board[3,3]) {winner = board[1,3];};
    if (board[1,1] == board[2,2] && board[2,2] == board[3,3]) {winner = board[1,1];};
    if (board[1,3] == board[2,2] && board[2,2] == board[3,1]) {winner = board[1,3];};
    
    if (board[1,1] != -1 && board[1,2] != -1 && board[1,3] != -1 &&
        board[2,1] != -1 && board[2,2] != -1 && board[2,3] != -1 && board[3,1] 
        != -1 && board[3,2] != -1 && board[3,3] != -1){
        	winner = 0;
	};
	winner;
};


function printBoard(board)
{
    printf("\n\n\tTic Tac Toe\n\n");
    printf("Robot 1 (X)  -  Human 2 (O)\n\n\n");

    printf("     |     |     \n");
    printf("  %c  |  %c  |  %c \n", board[1,1], board[1,2], board[1,3]);
    printf("_____|_____|_____\n");
    printf("     |     |     \n");
    printf("  %c  |  %c  |  %c \n", board[2,1], board[2,2], board[2,3]);
    printf("_____|_____|_____\n");
    printf("     |     |     \n");
    printf("  %c  |  %c  |  %c \n", board[3,1], board[3,2], board[3,3]);
    printf("     |     |     \n\n");
};


/*Input: String for name of button, Output: returns value 1 when clicked*/
function setButton(message)
{
    clicked = 0; 
    Tk_Button_Set(:text=message, :bell=t);
    while(!Tk_Button_Pressed()){};
    clicked = 1;
};

/*Input: 0 or 1 for player ids, Output: 0 or 1 that determines who goes first*/
function coinToss(toss)
{
    winner = 0; 
    coin = random();
    if(coin >= 0.5) {coin = 1;}
    else {coin = 0;};
    
    if (coin == toss){printf("You won! You move first...\n"); winner = toss;}
    else {printf("I won! I move first...\n"); winner = 1;};
    winner; 
};

