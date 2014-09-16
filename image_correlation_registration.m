function image_correlation_registration

%% Get best correlated image and register the data with it

close all
warning off

% If flag = 1, just find top and bottom best match and assign other stacks
% according to z-distance. Flag = 0, find best match for each stack

% Define some variables
flag = 1;
z_data_dist = 9;
z_rep_dist = 1.88;
num_stk_data = 5;
num_stk_rep_data = 31;


x_lim_rep1 = 445;
x_lim_rep2 = 850;

x_lim_data1 = 620;
y_lim_data2 = 'end';


% Declare some Folders
Data_Folder =  '~/Desktop/Image_Register/Data/Fish056_Before/';
Data_Corr_Folder =  '~/Desktop/Image_Register/Data/Fish056_Before/Corr_Images/';
Rep_Image_Folder =  '~/Desktop/Image_Register/Data/1011_GCamp3_KR11_KissPeptinreceptor_F2/';

Result_Folder = [Data_Corr_Folder, 'Registered'];
mkdir(Result_Folder)

% Find best match using the corr offset
for ii = 1:num_stk_data
    load([Data_Corr_Folder, 'Stack_', int2str(ii)]);
    X(:,ii) = squeeze(corr_off_stk(2,:));
    Y(:,ii) = squeeze(corr_off_stk(1,:));
end

if flag == 1
    [~, Z_best(1)] = min(abs(Y(:,1))+abs(X(:,1)));
    [~, Z_best(num_stk_data)] = min(abs(Y(:,num_stk_data)));
    for ii = 2:num_stk_data-1
        Z_best(ii) = Z_best(ii-1) - fix(Z_best(ii)+(z_data_dist/z_rep_dist));
    end
end

%Save the bext Zs
save([Data_Corr_Folder, 'Z_best.mat'], 'Z_best')

%Register data to the best representative
for ii = 1:num_stk_data
    
    disp(['Registering...Stack_Image ', int2str(ii)])
    
    unreg_img_temp = imread([Data_Folder, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    unreg_img = eval(['unreg_img_temp(:,', int2str(x_lim_data1),':', y_lim_data2, ')']);
    clear unreg_img_temp
    
    registered_image = image_register(unreg_img, X(Z_best(ii),ii), Y(Z_best(ii),ii));
    name_file = ['Registered_Raw_Z=', int2str(ii),'_Max.tif'];
    imwrite(registered_image, [Data_Folder, filesep, name_file]);
    
    
    % Plot and save registered images
    fs1 = figure(1);
    set(fs1, 'visible','off')
    subplot(1,3,1)
    imshow(base_img)
    title('Base Image');
    subplot(1,3,2)
    imshow(unreg_img)
    title('Unregistered Image');
    subplot(1,3,3)
    imshow(registered_image)
    title(['Offset y ', int2str(Y(Z_best(ii),ii)), ' Offset x ', int2str(X(Z_best(ii),ii))]);
    
    name_file = ['Image Registration : Stack_Image ', int2str(ii), ' Gcamp_Image ', int2str(Z_best(ii))];
    saveas(fs1, [Result_Folder, filesep, name_file], 'jpg');
end

end

%% Register the image to the best match representative image
function registered = image_register(unregistered, xoff, yoff)

[yc,xc] = size(unregistered);

if xoff < 0
    xoffa = abs(xoff)+1;
else
    xoffa = xoff;
end
if yoff < 0
    yoffa = abs(yoff)+1;
else
    yoffa = yoff;
end

% Adjust according to peak correlation
registered = uint8(zeros(yc+abs(yoffa), xc+abs(xoffa)));

if xoff~=0 && yoff==0
    if xoff < 0
        registered(:, xoffa:(xc+xoffa-1)) = unregistered;
        registered(:,end-xoffa+1:end) = [];
    else
        registered(:, 1:xc) = unregistered;
        registered(:,1:xoffa) = [];
    end
    
elseif xoff==0 && yoff~=0
    if yoff < 0
        registered(yoffa:(yc+yoffa-1), :) = unregistered;
        registered(end-yoffa+1:end,:) = [];
    else
        registered(1:yc, :) = unregistered;
        registered(1:yoffa,:) = [];
    end
    
elseif xoff~=0 && yoff~=0
    if xoff < 0 && yoff < 0
        registered(yoffa:(yc+yoffa-1), xoffa:(xc+xoffa-1)) = unregistered;
        registered(end-yoffa+1:end,:) = [];
        registered(:,end-xoffa+1:end) = [];
    elseif xoff > 0 && yoff > 0
        registered(1:yc, 1:xc) = unregistered;
        registered(1:yoffa,:) = [];
        registered(:,1:xoffa) = [];
    elseif xoff < 0 && yoff > 0
        registered(1:yc, xoffa:(xc+xoffa-1)) = unregistered;
        registered(1:yoffa,:) = [];
        registered(:,end-xoffa+1:end) = [];
    elseif xoff > 0 && yoff < 0
        registered(yoffa:(yc+yoffa-1), 1:xc) = unregistered;
        registered(end-yoffa+1:end,:) = [];
        registered(:,1:xoffa) = [];
    end
    
elseif xoff==0 && yoff==0
    registered = unregistered;
end

end


