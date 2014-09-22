function image_register_main

%% Main script that call sub scripts to analyse images
close all

% Define Data Folders
Representative_Image_Folder =  '~/Desktop/Image_Register/Data/1011_GCamp3_KR11_KissPeptinreceptor_F2/'; %Folder that contains the representative KIss images
Data_Folder =  '~/Desktop/Image_Register/Data/Fish056_Before/'; %Folder containing the data
Experiment_name = 'Fish056_Block8_Blue&US6'; %Experiment name as in the Z=1,Z=2, etc folders


% Define Variables
num_stack_data = 5; %Number of stacks in data
num_time_data = 301; %Number of time points in the data

num_stack_rep = 31; %Number of stacks in the representative stack

%Variables for cropping the image to use only the habenula
x_lim_rep1 = 446;  %in rep image
x_lim_rep2 = 860;
y_lim_rep_left1 = 1;
y_lim_rep_left2 = 500;
y_lim_rep_right1 = 501;
y_lim_rep_right2 = 1024;


%056 Before and After registering
x_lim_data1 = 610; %in data
x_lim_data2 = 1024;
y_lim_data_left1 = 1;
y_lim_data_left2 = 500;
y_lim_data_right1 = 501;
y_lim_data_right2 = 1024;

%Distance between z_stacks
z_data_dist = 9;  %in data
z_rep_dist = 1.88; % in rep image

%Addpath to export_fig folder
addpath('~/Desktop/export_fig/');

%% Step 1. Correlate the data stacks with all stacks of the representative image. Save the x and y offsets for each stack
Result_Folder = [Data_Folder, 'Correlated_Registered_Images/']; %Folder where the results are saved
if ~isdir(Result_Folder)
    mkdir(Result_Folder)
end

% Do all analysis on the left and right seperately
get_img_correlations(Data_Folder, Representative_Image_Folder, Result_Folder, num_stack_data, num_stack_rep, ...
    x_lim_rep1, x_lim_rep2, y_lim_rep_left1,y_lim_rep_left2, y_lim_rep_right1, y_lim_rep_right2,...
    x_lim_data1, x_lim_data2, y_lim_data_left1, y_lim_data_left2, y_lim_data_right1, y_lim_data_right2)


%% Step 2. Get the best correlated image using the offsets and register the stacks with it
flag = 0; % If flag = 1, just find top and bottom best match and assign other stacks
          % according to z-distance. Flag = 0, find best match for each stack
Data_Correlations_Folder = Result_Folder;           

image_correlation_registration(Experiment_name, Data_Folder, Data_Correlations_Folder, Representative_Image_Folder, Result_Folder, ...
    num_stack_data, num_time_data, x_lim_rep1, x_lim_rep2, y_lim_rep_left1,y_lim_rep_left2, y_lim_rep_right1, y_lim_rep_right2,...
    x_lim_data1, x_lim_data2, y_lim_data_left1, y_lim_data_left2, y_lim_data_right1, y_lim_data_right2,...
    flag, z_data_dist, z_rep_dist)

%% Step 3. Get overlapping pixels with kiss peptin from the representative stack. 
%% Look at intensity maps of ROIs corresponding to KISS vs Non Kiss
get_kiss_overlap(Experiment_name, Data_Folder, Data_Correlations_Folder, Representative_Image_Folder, Result_Folder,...
    num_stack_data, num_time_data,x_lim_rep1, x_lim_rep2, y_lim_rep_left1,y_lim_rep_left2, y_lim_rep_right1, y_lim_rep_right2)






