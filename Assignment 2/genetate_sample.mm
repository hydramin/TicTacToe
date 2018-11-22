function generate_imgcoords(){
	
		/*To generate the U,V coordinates*/
			/*- take the base image and save it in base_img*/
			/*- give the object to the arm, have it put the object at a position given*/
			/*- get the arm out away*/
			/*- take a picture and calculat the center of gravity*/
			/*- save the U,V coordinates in the matrix ( write them down for data safety)*/
	
	/* this matrix contains 6 data points [X,Y,u,v]*/
	data_points = mk_fmat(1..6, 1..4);
	
	/*input the X,Y values in the data_points matrix*/
	data_points[1,1] = 12.5;
	data_points[1,2] = 3;
	
	data_points[2,1] = 12.5;
	data_points[2,2] = 9;
	
	data_points[3,1] = 12.5;
	data_points[3,2] = 12;
	
	data_points[4,1] = 18.5;
	data_points[4,2] = 6;
	
	data_points[5,1] = 18.5;
	data_points[5,2] = 9;
	
	data_points[6,1] = 18.5;
	data_points[6,2] = 12;
	
	/*generate the u,v values*/
	/*take the base_img*/	
	
	base_img = get_base_img();
	
	/*give the arm the object and make it take the object to an x,y position for a photo shoot*/
	rob_ready();
	servo_open(30);
	sleep(5);
	servo_close(30);
	/*delivers the object to the x,y position given*/
	CRSinvkin(data_points[1,1], data_points[1,1], 0);
	servo_open(30);	
	ref_img1 = get_base_img();
	/*use base_img and ref_img to calculate a u,v using ass1*/
	pixle_point = diffimgobj(img1,img2);
	/*add this pixle point to the data_points matrix*/
	data_points[1,3] = pixle_point[1];
	data_points[1,4] = pixle_point[2];
	
	/*give the arm the object and make it take the object to an x,y position for a photo shoot*/
	rob_ready();
	servo_open(30);
	sleep(5);
	servo_close(30);
	/*delivers the object to the x,y position given*/
	CRSinvkin(data_points[2,1], data_points[2,1], 0);
	servo_open(30);	
	ref_img1 = get_base_img();
	/*use base_img and ref_img to calculate a u,v using ass1*/
	pixle_point = diffimgobj(img1,img2);
	/*add this pixle point to the data_points matrix*/
	data_points[2,3] = pixle_point[1];
	data_points[2,4] = pixle_point[2];
	
	/*give the arm the object and make it take the object to an x,y position for a photo shoot*/
	rob_ready();
	servo_open(30);
	sleep(5);
	servo_close(30);
	/*delivers the object to the x,y position given*/
	CRSinvkin(data_points[3,1], data_points[3,1], 0);
	servo_open(30);	
	ref_img1 = get_base_img();
	/*use base_img and ref_img to calculate a u,v using ass1*/
	pixle_point = diffimgobj(img1,img2);
	/*add this pixle point to the data_points matrix*/
	data_points[3,3] = pixle_point[1];
	data_points[3,4] = pixle_point[2];
	
	/*give the arm the object and make it take the object to an x,y position for a photo shoot*/
	rob_ready();
	servo_open(30);
	sleep(5);
	servo_close(30);
	/*delivers the object to the x,y position given*/
	CRSinvkin(data_points[4,1], data_points[4,1], 0);
	servo_open(30);	
	ref_img1 = get_base_img();
	/*use base_img and ref_img to calculate a u,v using ass1*/
	pixle_point = diffimgobj(img1,img2);
	/*add this pixle point to the data_points matrix*/
	data_points[4,3] = pixle_point[1];
	data_points[4,4] = pixle_point[2];
	
	/*give the arm the object and make it take the object to an x,y position for a photo shoot*/
	rob_ready();
	servo_open(30);
	sleep(5);
	servo_close(30);
	/*delivers the object to the x,y position given*/
	CRSinvkin(data_points[5,1], data_points[5,1], 0);
	servo_open(30);	
	ref_img1 = get_base_img();
	/*use base_img and ref_img to calculate a u,v using ass1*/
	pixle_point = diffimgobj(img1,img2);
	/*add this pixle point to the data_points matrix*/
	data_points[5,3] = pixle_point[1];
	data_points[5,4] = pixle_point[2];
	
	/*give the arm the object and make it take the object to an x,y position for a photo shoot*/
	rob_ready();
	servo_open(30);
	sleep(5);
	servo_close(30);
	/*delivers the object to the x,y position given*/
	CRSinvkin(data_points[6,1], data_points[6,1], 0);
	servo_open(30);	
	ref_img1 = get_base_img();
	/*use base_img and ref_img to calculate a u,v using ass1*/
	pixle_point = diffimgobj(img1,img2);
	/*add this pixle point to the data_points matrix*/
	data_points[6,3] = pixle_point[1];
	data_points[6,4] = pixle_point[2];
	
};

function diffimgobj(img1,img2)
	"Find the center of gravity of an object denoted by img1 and img2"
{
	/*Take average of the RGB of each image, changes to gray scale*/
	img1 = (img1->r + img1->g + img1->b)/3.0;
	img2 = (img2->r + img2->g + img2->b)/3.0;
	/*Background subtraction between the images*/
	imd = img2-img1;
	/*dot product of the matrix with itself?*/
	imd*=imd;
	gshow(imd,:rescale=t);
	/*makes absolutely no sense*/
	imbin = imd>1500;
	/* same image but the additional image is labeled?*/
	imgcc = con_compon(imbin);
	gshow(imgcc,:rescale=t);

	gg = mk_uctmpl2(-1..1,-1..1,[[1,1,1],[1,1,1],[1,1,1]]);

	imbin1 = imbin(*)gg;
	imbin1 = imbin1(*)gg;
	imbin1 = ~( (~imbin1)(*)gg);
	imbin1 = ~( (~imbin1)(*)gg);
	gshow(imbin1,:rescale=t);

	imbin1 = ~( (~imbin1)(*)gg);
	imbin1 = ~( (~imbin1)(*)gg);
	imbin1 = imbin1(*)gg;
	imbin1 = imbin1(*)gg;
	gshow(imbin1,:rescale=t);

	imgcc = con_compon(imbin1);

	gshow(obj1img = select_iimg(imgcc,1),:rescale = t);

	o1 = to_fimg(obj1img);

	sz = sum_fimg(o1);

	c_x = sum_fimg(o1*x_img(o1->vsize,o1->hsize))/sz;

	c_y = sum_fimg(o1*y_img(o1->vsize,o1->hsize))/sz;

	printf("%d %d\n",c_x,c_y);

	/* Return array with x, y of center of mass */

	mk_fvec(1..2, [c_x, c_y]);
};

function get_base_img()
	"Takes an image of the empty work area"
{
	cam = LT_C920(:file = "/dev/video0");
	/* Move arm out of the way */
	rob_move_abs(0,90,0,0,0);
	sleep(15);
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


function CRSinvkin(y,x,z)
	"Move CRS PLUS robot arm to the position denoted by x, y, z	"
{
	/*Ensure that the arm is in a default state*/
	rob_ready();
	
	/*Most of these values are estimates from trial and error*/
	L1 = 10;
	L2 = 10;
	L3 = 10;
	L4 = 6.8;
	
	/*R is the vector from the origin to the desired location of {4}*/
	R = x^2 + y^2 + z^2;
	
	/*z must be adjusted to account for the height of the arm from the table and the length of the end effector*/
	/* z is made negative because for some reason, a positive z does not work*/
	/*may be due to the ordering of atan2*/
	z = -(z + (-L1 + L4));
	y = -y;
	
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
	
	/*Wrist must always be facing straight down, similar to a claw machine*/
	wrist = (f_Th2 - f_Th3) + 90;
	
	/*Move arm to specified location and activate the end effector*/
	rob_move_abs(f_Th1, f_Th2, f_Th3, wrist, 0); 
};

function rad_to_deg(val1)
	"Convert Radians to Degrees"
{
	val1 * (180 / PI);
};