/*Instantiates camera and returns the camera object*/
function proj_getCam(){
	cam = LT_C920(:file = "/dev/video0");
};


/*function that streams live image*/
function proj_camStream(cam){
	v4l2_streamoff(cam);	
	v4l2_streamon(cam);
	for(Tk_Button_Set(:text="Grab1", :bell=t);
    	!Tk_Button_Pressed();
    	gshow(img1=v4l2_grab(cam),:tk_img="ltech",:update_now=t));
	v4l2_streamoff(cam);
	x;
};

/*function grabs an image and returns an image object*/
function proj_grabImage(cam){
	v4l2_streamon(cam);    	
   	img=v4l2_grab(cam);
   	gshow(img,:rescale=t);
	v4l2_streamoff(cam);
	img;
};

/*function inputs an image and displays it*/
function proj_showImage(img){
	gshow(img,:rescale=t);
};

/*function inputs two images and returns x,y of the center of gravity of the new image*/
function proj_getCenter(img1,img2)
	"Find the center of gravity of an object denoted by img1 and img2"
{
    /*gshow(img1,:rescale=t);*/
    /*gshow(img2,:rescale=t);*/
	/*Take average of the RGB of each image, changes to gray scale*/
	img1 = (img1->r + img1->g + img1->b)/3.0;
	img2 = (img2->r + img2->g + img2->b)/3.0;
	/*Background subtraction between the images*/
	imd = img2-img1;
	/*dot product of the matrix with itself?*/
	imd*=imd;
	/*gshow(imd,:rescale=t);*/
	/*makes absolutely no sense*/
	imbin = imd>1500;
	/* same image but the additional image is labeled?*/
	imgcc = con_compon(imbin);
	/*gshow(imgcc,:rescale=t);*/

	gg = mk_uctmpl2(-1..1,-1..1,[[1,1,1],[1,1,1],[1,1,1]]);

	imbin1 = imbin(*)gg;
	imbin1 = imbin1(*)gg;
	imbin1 = ~( (~imbin1)(*)gg);
	imbin1 = ~( (~imbin1)(*)gg);
	/*gshow(imbin1,:rescale=t);*/

	imbin1 = ~( (~imbin1)(*)gg);
	imbin1 = ~( (~imbin1)(*)gg);
	imbin1 = imbin1(*)gg;
	imbin1 = imbin1(*)gg;
	/*gshow(imbin1,:rescale=t);*/

	imgcc = con_compon(imbin1);
	obj1img = select_iimg(imgcc,1);
	
	/*gshow(obj1img,:rescale = t);*/

	o1 = to_fimg(obj1img);

	sz = sum_fimg(o1); 

	c_x = sum_fimg(o1*x_img(o1->vsize,o1->hsize))/sz;

	c_y = sum_fimg(o1*y_img(o1->vsize,o1->hsize))/sz;

	printf("x:%f y:%f\n",c_x,c_y);
	xx = to_int(c_x);
	yy = to_int(c_y);
	obj1img[yy,xx] = 0;
	gshow(obj1img,:rescale=t);
	

	/* Return array with x, y of center of mass */

	mk_fvec(1..2, [c_x, c_y]);
};

function get_base_img(cam)
	"Takes an image of the empty work area"
{
	/* Move arm out of the way */
	rob_move_abs(0,90,0,0,0);
	sleep(5);
	/* Take image */
	v4l2_streamon(cam);
	base_img=v4l2_grab(cam);
	v4l2_streamoff(cam);
	sleep(2);
	/* Show image to user*/
	gshow(base_img,:rescale=t);
	
	/* return image */
	base_img;
};



/*it generates the data_points matrix 6x4 to get the PPinv*/
function generate_imgcoords(cam)
{
	
	/*To generate the U,V coordinates*/
	/*- take the base image and save it in base_img*/
	/*- give the object to the arm, have it put the object at a position given*/
	/*- get the arm out away*/
	/*- take a picture and calculat the center of gravity*/
	/*- save the U,V coordinates in the matrix ( write them down for data safety)*/

	/* this matrix contains 6 data points [X,Y,u,v]*/
	data_points = mk_fmat(1..6, 1..4);
	
	/*input the X,Y values in the data_points matrix*/
	data_points[1,1] = 11.0;
	data_points[1,2] = 4.5;
	
	data_points[2,1] = 20;
	data_points[2,2] = 4.5;
	
	data_points[3,1] = 20;
	data_points[3,2] = -4.5;
	
	data_points[4,1] = 11;
	data_points[4,2] = -4.5;
	
	data_points[5,1] = 15.5;
	data_points[5,2] = 0;
	
	data_points[6,1] = 15;
	data_points[6,2] = 4.5;
	
	/*generate the u,v values*/
	/*take the base_img*/	
	
	/*rob_move_abs(0,90,0,0,0);*/
	sleep(4);
	base_img = proj_grabImage(cam);
	
	/*go to the base position and grab the object*/
	CRSinvkin (-15, 0, 1);
	sleep(4);
	servo_close(50);
	sleep(4);
	servo_ready();
	sleep(4);
	
	for(i=1; i<=data_points->vsize;i++)
	{
	 
	    /*delivers the object to the x,y position given*/
	    CRSinvkin(data_points[i,1], data_points[i,2], 1);
	    sleep(4);
	    servo_open(50);
	    sleep(4);
	    rob_move_abs(0,90,0,0,0);
	    sleep(4);
	    img2 = proj_grabImage(cam);
	    
	    /*use base_img and ref_img to calculate a u,v using ass1*/
	    pixle_point = proj_getCenter(base_img,img2);

	    /*add this pixle point to the data_points matrix*/
	    data_points[i,3] = pixle_point[1];
	    data_points[i,4] = pixle_point[2];

	    /*go to where the object is, grab it and return to the ready position*/
	    CRSinvkin(data_points[i,1], data_points[i,2], 1);
	    sleep(4);
	    servo_close(50);
	    sleep(4);
	    rob_move_abs(0,90,0,0,0);
	};
	data_points;
	
};

/* takes four values u,v,X,Y and returns the matrix AAi  */
function amat(X,Y,u,v)
{ 
	AAi = mk_fmat(1..3,1..9);

	AAi[1,4] = -X;
	AAi[1,5] = -Y;
	AAi[1,6] = -1;
	AAi[1,7] = v * X;
	AAi[1,8] = v * Y;
	AAi[1,9] = v;
	AAi[2,1] = X;
	AAi[2,2] = Y;
	AAi[2,3] = 1;
	AAi[2,7] = -u * X;
	AAi[2,8] = -u * Y;
	AAi[2,9] = -u;
	AAi[3,1] = -v * X;
	AAi[3,2] = -v * Y;
	AAi[3,3] = -v;
	AAi[3,4] = u * X;
	AAi[3,5] = u * Y;
	AAi[3,6] = u;
	
	AAi;
};


/* Takes n * 4 matrix, each row contains value for X,Y,u,v and returns camera matrix PPinv (3x3)*/
function cameraMat(m)
{
	avec = mk_fvec(3*9*m->vsize);
	amat(m[1,1],m[1,2],m[1,3],m[1,4]);
	cmat = AAi;
	
	for (i=2; i < m->vsize+1; i++)
	{
		amat(m[i,1],m[i,2],m[i,3],m[i,4]);
		cmat = cmat <|> AAi;
	
	};
	svd = SVD(cmat^T*cmat);

	p = svd[3][1..svd[3]->vsize,minind_fvec(svd[2])];
	pmat = unstack_vec(p,3,3);
	pmat = pmat^T;
	inner_prtMat(pmat);
	pinv = inverse_mat(pmat);
	pinv;
};


/* Given an image point (x and y) and camera matrix, return the corresponding real world position vector */  
function findWorldPosition(x,y,PP)
{
	ivec = mk_fvec(1..3, [x,y,1]);
	pvec = PP * ivec;
	pvec = normalizeVec(pvec);
	printf("X: %f\tY:%f\tZ:%f\n",pvec[1],pvec[2],pvec[3]);
};


/*function takes a list and displays the content*/
function proj_prtList(list){	

	for(x=1;x<=list->vsize;x++){
   	printf("=> %d\n",list[x]);
   };
};

/*prints an image variable to a file*/
function proj_writeImage(img,name){
	ppm = ".ppm";
	/*location = "/eecs/home/hydramin/Documents/4421/Project//testWork/exper/";*/
	location = "/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/exper/";
	file = str_concat(location,name,ppm);
	write_img(img,file);
};

/*Reads an image from location provided*/
/*read_img("absolute path");*/

/*gets the robot out of the way of the camera, vertically upward*/
function proj_readyPos(){
    rob_move_abs(0,90,0,0,0);
    servo_open(30);    
};

/*given 2 3x3 matrices for the center of gravities, print them merged*/
function proj_prtCenters(xm,ym){
    for(i=1;i<=3;i++){
        for(j=1;j<=3;j++){
            printf("(%.2f,%.2f) ",xm[i,j],ym[i,j]);
        };
        printf("\n");
    };
};

/*input the refX,refY matrices and a point, calculate the distance from each point*/
/*this calculates the pixle distance*/
function proj_getDistance(xm,ym,pt){
    
    /*dx is refX - ptx*/
    dx = xm - inner_fillMat(pt[1]);
    dy = ym - inner_fillMat(pt[2]);
    dxsq = inner_squareMat(dx);
    dysq = inner_squareMat(dy);
    dxysum = dxsq + dysq;
    /*dxyfinal contains distance of the point pt from each of the reference center of gravities*/
    dxyfinal = inner_sqrtMat(dxysum);
    inner_prtMat(dxyfinal);
    dxyfinal;
};

/*given a distance matrix 3x3, outputs the entry index as vector (r,c) with the min value*/
function proj_getMinIndex(mat){
    index = mk_ivec(1..2,[0,0]);
    min = mat[1,1];
    for(i = 1;i<=3;i++){
        for(j = 1;j<=3;j++){
           if(mat[i,j] < min){
                min = mat[i,j];
                index[1] = i;
                index[2] = j;
           }; 
        };
    };
    index;
};


/*square each values of a matrix*/
function inner_squareMat(mat){
    mat1 = mk_fmat(1..3,1..3);
    for(i = 1;i<=3;i++){
        for(j = 1;j<=3;j++){
           mat1[i,j] = mat[i,j]^2;
        };
    };            
    /*inner_prtMat(mat1);*/
    mat1;
};

/*square roots each entry of a 3x3 matrix*/
function inner_sqrtMat(mat){
    mat1 = mk_fmat(1..3,1..3);
    for(i = 1;i<=3;i++){
        for(j = 1;j<=3;j++){
           mat1[i,j] = sqrt(mat[i,j]);           
        };
    };
    /*inner_prtMat(mat1);*/
    mat1;
};

function inner_prtMat(mat){
    for(i=1;i<=3;i++){
        for(j=1;j<=3;j++){
            printf("%.2f ",mat[i,j]);
        };
        printf("\n");
    };
    0;
};

function normalizeVec(v){
    f = mk_fvec(1..3);
    f = v/v[3];
    f;
};

/*generates a 3x3 square matrix filled with the input param*/
function inner_fillMat(x){
    mat = mk_fmat(1..3,1..3,[[x,x,x],[x,x,x],[x,x,x]]);
};

/*G is a 9x2 matrix that holds ref values, vector <x,y> are the newly identified real world points*/
/*x,y are obtained from the matrix calibration*/
/*it spits out the index (1 .. 9) of where the min value was found*/
function proj_minDistIndex(pt, G)
{
    x = pt[1];
    y = pt[2];
    c = mk_fvec(9);
    cx=(G[1..9,1] - x);
    cy=(G[1..9,2] - y);
    for(i=1;i< 10; i++){
        a = cx[i]^2;
        b = cy[i]^2;
        c[i] = sqrt(a+b);
    };
    gridPosition = minind_fvec(c);
};

/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
function proj_getRef(xory){
/*now the robot analyzes the picture with background subtraction and determines a pixle location*/
/*a reference matrix that contains the center of gravities of the pixel locations is needed*/
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/*Generates the reference matrix for the center of gravities*/
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/

back = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/back.ppm");
img1 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img1.ppm");
img2 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img22.ppm");
img3 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img3.ppm");
img4 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img44.ppm");
img5 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img5.ppm");
img6 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img6.ppm");
img7 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img7.ppm");
img8 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img8.ppm");
img9 = read_img("/eecs/home/hydramin/Documents/4421/Project/TicTacToe/testWork/expr/img9.ppm");

/*calculate centers of gravities of the centers of all the grids*/
c1 = proj_getCenter(back,img1);
c2 = proj_getCenter(back,img2);
c3 = proj_getCenter(back,img3);
c4 = proj_getCenter(back,img4);
c5 = proj_getCenter(back,img5);
c6 = proj_getCenter(back,img6);
c7 = proj_getCenter(back,img7);
c8 = proj_getCenter(back,img8);
c9 = proj_getCenter(back,img9);

/*save all centers in a 3x3 matrix x values separated from y*/
/*refX is a metrix that contains all the x coordinates of the grid center of gravities*/
refX = mk_fmat(1..3,1..3,[
[c1[1],c2[1],c3[1]],
[c4[1],c5[1],c6[1]],
[c7[1],c8[1],c9[1]]
]);

/*refX is a metrix that contains all the x coordinates of the grid center of gravities*/
refY = mk_fmat(1..3,1..3,[
[c1[2],c2[2],c3[2]],
[c4[2],c5[2],c6[2]],
[c7[2],c8[2],c9[2]]
]);

if(xory = "X"){
  returnValue = refX;
};
if(xory = "Y"){
  returnValue = refY;
};


/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/*returnValue;*/
};

function CRSinvkin(x,y,z)
	"Move CRS PLUS robot arm to the position denoted by x, y, z	"
{
	/*Ensure that the arm is in a default state*/
	rob_ready();
	
	/*Most of these values are estimates from trial and error*/
	L1 = 11;
	L2 = 10;
	L3 = 11.5;
	L4 = 6.50;

	/*R is the vector from the origin to the desierd location of {4}*/
	R = x^2 + y^2 + z^2;
	
	/*z must be ajusted to acount for the hight of the arm from the table and the length of the end effactor*/
	/* z is made negative because for some reason, a positive z does not work*/
	/*may be due to the ordering of atan2*/
	z = -(z + (-L1 + L4));
	
	temp_D = (R - L3^2 - L2^2)/(2*L3*L2);
	rad_Th1 = atan2(y, x);
	rad_Th3 = atan2(sqrt(1 - temp_D^2), temp_D);
	rad_Th2 = atan2(sqrt(x^2+y^2), z) - atan2(L2 + L3* cos(rad_Th3), L3*sin(rad_Th3));
 	
	f_Th1 = rad_to_deg(rad_Th1);
	f_Th2 = rad_to_deg(rad_Th2);
	f_Th3 = rad_to_deg(rad_Th3);
	
	/*if Theta2 is negative, the arm joint would have to bend up. the CRS PLUS has not been designed with this feature in mind */
	/*In this case, Theta2 and Theta3 must be recalculated (with the second solution for Theta3)*/
	if (f_Th2 < 0){
		rad_Th3 = atan2(-sqrt(1-temp_D^2), temp_D);
		rad_Th2 = atan2(sqrt(x^2+y^2), z) - atan2(L2 + L3* cos(rad_Th3), L3*sin(rad_Th3));
		f_Th2 = rad_to_deg(rad_Th2);
		f_Th3 = rad_to_deg(rad_Th3);
	};
	
	/*Wrist must always be facing straight down, similar to a claw mechine*/
	wrist = (f_Th2 - f_Th3) + 90;
	
	/*Move arm to specefied location and activate the end effactor*/
	rob_move_abs(f_Th1, f_Th2, f_Th3, wrist, 0); 
};

function rad_to_deg(val1)
	"Convert Radians to Degrees"
{
	val1 * (180 / PI);
};
