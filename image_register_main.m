function image_register_main

%% Main script that call sub scripts to analyse images

close all
clear all
warning off

% Define Data Folders
Representative_Image_Folder =  '~/Desktop/Image_Register/Data/1011_GCamp3_KR11_KissPeptinreceptor_F2/'; %Folder that contains the representative KIss images
Data_Folder =  '~/Desktop/Image_Register/Data/Fish056_Before/'; %Folder containing the data

% Define Variables
num_stack_data = 5; %Number of stacks in data
num_stack_rep = 31; %Number of stacks in the representative stack

%Variables for cropping the image to use only the habenula
x_lim_rep1 = 446;  %in rep image
x_lim_rep2 = 850;

x_lim_data1 = 620; %in data
x_lim_data2 = 'end';


%Addpath to export_fig folder
addpath('~/Desktop/export_fig/');

%% Step 1. Correlate the data stacks with all stacks of the representative image. Save the x and y offsets for each stack
Result_Folder = [Data_Folder, 'Correlated_Images']; %Folder where the results are saved
mkdir(Result_Folder)

get_img_correlations(Data_Folder, Representative_Image_Folder, Result_Folder, num_stack_data, num_stack_rep, ...
    x_lim_rep1, x_lim_rep2, x_lim_data1, x_lim_data2) 


%% Step 2. 
