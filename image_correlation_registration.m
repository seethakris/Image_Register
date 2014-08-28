function image_correlation_registration

%% Get best correlated image and register the data with it

close all
clear all
warning off

%If flag = 1, just find top and bottom best match and assign other stacks
%according to z-distance. Flag = 0, find best match for each stack
flag = 1;
z_data_dist = ;

% Folders and variable declaration
Data_Folder =  '~/Desktop/Image_Register/Fish056_Before/Corr_Images/';
Rep_Image_Folder =  '~/Desktop/Image_Register/1011_GCamp3_KR11_KissPeptinreceptor_F2/';

