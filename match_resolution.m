function match_resolution

%% For Experiments taken with a different objective or zoom, match resolution before registering

Data_Folder =  '~/Desktop/Image_Register/Data/Fish104_Block2_Blue&UV1/'; %Folder containing the data
Exp_Name = 'Fish104_Block2_Blue&UV1'; %Experiment Name

%Template Image size 1024,1024
Template_Image_x = 1024;
Template_Image_y = 1024;
Template_Image = uint8(zeros(Template_Image_x,Template_Image_y));

%Assign some variables
Zoom = 1.6;
num_stk_data = 5;
num_tim_data = 301;
actual_z = 5;



for ii = 1:num_stk_data
    
    %Find offset between Before and After Image and register
    Before_Image = imread([Data_Folder, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    Resize_Image = imresize(Before_Image, 1/Zoom);
    [Resize_Image_x, Resize_Image_y] = size(Resize_Image);
    
    temp_x = (Template_Image_x - Resize_Image_x)/2;
    temp_y = (Template_Image_y - Resize_Image_y)/2;
    
    Template_Image(temp_x:temp_x+Resize_Image_x-1,temp_y:temp_y+Resize_Image_y-1)  = Resize_Image;
    
    A = imread('~/Desktop/Image_Register/Data/Fish056_Before/Raw_Z=1_Max.jpg');
    
    subplot(1,2,1)
    imshow(Template_Image)
    subplot(1,2,2)
    imshow(A)
    
    for jj = 1:num_tim_data
    end
end

