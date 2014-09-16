function image_correlation_registration

%% Get best correlated image and register the data with it

close all
warning off

% If flag = 1, just find top and bottom best match and assign other stacks
% according to z-distance. Flag = 0, find best match for each stack
flag = 1;
z_data_dist = 9;
z_rep_dist = 1.88;
num_stk_data = 5;
num_rep_data = 31;

% Folders and variable declaration
Data_Folder =  '~/Desktop/Image_Register/Fish056_Before/';
Data_Corr_Folder =  '~/Desktop/Image_Register/Fish056_Before/Corr_Images/';
Rep_Image_Folder =  '~/Desktop/Image_Register/1011_GCamp3_KR11_KissPeptinreceptor_F2/';


%Find best match using the corr offset
for ii = 1:num_stk_data
    
    if flag == 1 && sum(ii == [1,num_stk_data])==0
        continue
    else
        load([Data_Corr_Folder, 'Stack_', int2str(ii)]);
        X(:,ii) = squeeze(corr_off_stk(2,:));
        Y(:,ii) = squeeze(corr_off_stk(1,:));
    end
    
end

if flag == 1
    [~, Z_best(1)] = min(abs(Y(:,1)));
    [~, Z_best(num_stk_data)] = min(abs(Y(:,num_stk_data)));
    for ii = 2:num_stk_data-1
        Z_best(ii) = Z_best(ii-1) - round(Z_best(ii)+(z_data_dist/z_rep_dist));
    end
end
