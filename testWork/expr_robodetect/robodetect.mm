/*the robot must detect where the next player moved his/her piece*/
/*robot moves first, and takes a picture: 1.ppm*/
/*human moves and tells the robot to make next move*/
/*robot takes a picture and finds the center of gravity of the new obj*/
/*robot compares this point to the 9 points to determine the one closest*/
/*then it marks it in a separate matrix*/

/*read the experimental pictures in: if robot starts only 1 and 2 are required*/
back = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr_robodetect/back.ppm");
m1 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr_robodetect/1m.ppm");
m2 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr_robodetect/2m.ppm");
/*--Break--*/
m3 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr_robodetect/3m.ppm");
m4 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr_robodetect/4m.ppm");
m5 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr_robodetect/5m.ppm");
/*--Break--*/
/*find the center of gravity of the new object in m2 comparing to m1*/
c = proj_getCenter(m1,m2);