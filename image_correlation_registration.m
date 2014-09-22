function image_correlation_registration(Exp_name, Data_Folder, Data_Corr_Folder, Rep_Image_Folder, Result_Folder, ...
    num_stk_data, num_tim_data, x_lim_rep1, x_lim_rep2, y_lim_rep_left1,y_lim_rep_left2, y_lim_rep_right1, y_lim_rep_right2,...
    x_lim_data1, x_lim_data2, y_lim_data_left1, y_lim_data_left2, y_lim_data_right1, y_lim_data_right2,...
    flag, z_data_dist, z_rep_dist)

%% Get best correlated image and register the data with it

% Declare some Folders
actual_z = num_stk_data;

% Find best match using the corr offset
for ii = 1:num_stk_data
    load([Data_Corr_Folder, 'Correlation_Offset_with_Rep_Stack_', int2str(ii)]);
    X_left(:,ii) = squeeze(corr_off_stk_left(2,:));
    Y_left(:,ii) = squeeze(corr_off_stk_left(1,:));
    X_right(:,ii) = squeeze(corr_off_stk_right(2,:));
    Y_right(:,ii) = squeeze(corr_off_stk_right(1,:));
end

Z_best = zeros(1,num_stk_data);

if flag == 1
    if num_stk_data == 1
        [~, Z_best_left(1)] = min(abs(Y_left(:,1))+abs(X_left(:,1)));
        [~, Z_best_right(1)] = min(abs(Y_right(:,1))+abs(X_right(:,1)));
        
    else
        [~, Z_best_left(1)] = min(abs(Y_left(:,1))+abs(X_left(:,1)));
        [~, Z_best_right(1)] = min(abs(Y_right(:,1))+abs(X_right(:,1)));
        for ii = 2:num_stk_data
            Z_best_left(ii) = Z_best_left(ii-1) - fix(Z_best_left(ii)+(z_data_dist/z_rep_dist));
            Z_best_right(ii) = Z_best_right(ii-1) - fix(Z_best_right(ii)+(z_data_dist/z_rep_dist));
            
        end
    end
else
    for ii = 1:num_stk_data
        [~, Z_best_left(ii)] = min(abs(Y_left(:,ii))+abs(X_left(:,ii)));
        [~, Z_best_right(ii)] = min(abs(Y_right(:,ii))+abs(X_right(:,ii)));
    end
end

disp(['Z_best Left are ', int2str(Z_best_left), ' Right are ', int2str(Z_best_right)]);


%Save the bext Zs
save([Data_Corr_Folder, 'Z_best.mat'], 'Z_best_left', 'Z_best_right')


%Register data to the best representative
for ii = 1:num_stk_data
    
    disp(['Registering...Stack_Image ', int2str(ii)])
    
    %% Average Plots
    % Register the averaged image, plot and save
    base_img_temp_left = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',Z_best_left(ii)), '_c01.tif']);
    base_img_left = eval(['base_img_temp_left(',int2str(y_lim_rep_left1),':', int2str(y_lim_rep_left2),',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
    base_img_temp_right = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',Z_best_right(ii)), '_c01.tif']);
    base_img_right = eval(['base_img_temp_right(',int2str(y_lim_rep_right1),':', int2str(y_lim_rep_right2),',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
    base_img = [base_img_left; base_img_right];
    
    
    %If the after images have been registered with before
    if exist([Data_Folder, 'Registered_with_Before_Raw_Z=', int2str(ii),'_Max.jpg'], 'file')
        unreg_img_temp = imread([Data_Folder, 'Registered_with_Before_Raw_Z=', int2str(ii),'_Max.jpg']);
    else
        unreg_img_temp = imread([Data_Folder, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    end
    unreg_img_left = eval(['unreg_img_temp(', int2str(y_lim_data_left1),':', int2str(y_lim_data_left2),',',...
        int2str(x_lim_data1),':', int2str(x_lim_data2),')']);
    unreg_img_right = eval(['unreg_img_temp(', int2str(y_lim_data_right1),':', int2str(y_lim_data_right2),',',...
        int2str(x_lim_data1),':', int2str(x_lim_data2),')']);
    unreg_img = [unreg_img_left; unreg_img_right];
    
    %Register Left Habenula
    registered_image_left = image_register(unreg_img_left, X_left(Z_best_left(ii),ii), Y_left(Z_best_left(ii),ii));
    registered_image_right = image_register(unreg_img_right, X_right(Z_best_right(ii),ii), Y_right(Z_best_right(ii),ii));
    registered_image = [registered_image_left; registered_image_right];
    
    
    name_file = ['Registered_with_Rep_Raw_Z=', int2str(ii),'_Max.tif'];
    imwrite(registered_image, [Data_Folder, filesep, name_file]);
    
    % Plot and save registered images
    fs1 = figure(1);
    set(fs1, 'visible','on', 'color', 'white')
    subplot(1,3,1)
    imshow(base_img)
    title(['Base Image Left Stack', int2str(Z_best_left(ii)), ' Right Stack ', int2str(Z_best_right(ii))]);
    subplot(1,3,2)
    imshow(unreg_img)
    title(['Unregistered Left Stack', int2str(Z_best_left(ii)), ' Right Stack ', int2str(Z_best_right(ii))]);
    subplot(1,3,3)
    imshowpair(base_img, registered_image, 'falsecolor','Scaling','joint');
    title(['Offset for LH y ', int2str(Y_left(Z_best_left(ii),ii)), ' x ', int2str(X_left(Z_best_left(ii),ii)),...
        ' RH y ', int2str(Y_right(Z_best_right(ii),ii)), ' x ', int2str(X_right(Z_best_right(ii),ii))]);
    name_file = 'Registered Images with Representative';
    
    if ii == 1 && exist([Result_Folder, name_file, '.pdf'], 'file')
        delete([Result_Folder, name_file, '.pdf'])
    end
    export_fig([Result_Folder, name_file], '-pdf', '-append');
    
    clear unreg_img_temp base_img_temp_left base_img_temp_right registered_image registered_image_left registered_image_right base_img
    
    %% Register other types of images
    
    %Do it for the cell outlines
    disp(['Cell Outlines', int2str(ii)]);
    %If the after images have been registered with before
    if exist([Data_Folder, 'Registered_with_Before_cellROI_Z=', int2str(ii),'.tif'], 'file')
        unreg_img_temp = imread([Data_Folder, 'Registered_with_Before_cellROI_Z=', int2str(ii),'.tif']);
    else
        unreg_img_temp = imread([Data_Folder, 'cellROI_Z=', int2str(ii),'.tif']);
    end
    
    unreg_img_left = eval(['unreg_img_temp(', int2str(y_lim_data_left1),':', int2str(y_lim_data_left2),',',...
        int2str(x_lim_data1),':', int2str(x_lim_data2),')']);
    unreg_img_right = eval(['unreg_img_temp(', int2str(y_lim_data_right1),':', int2str(y_lim_data_right2),',',...
        int2str(x_lim_data1),':', int2str(x_lim_data2),')']);
    unreg_img = [unreg_img_left; unreg_img_right];
    
    %Register Left Habenula
    registered_image_left = image_register(unreg_img_left, X_left(Z_best_left(ii),ii), Y_left(Z_best_left(ii),ii));
    registered_image_right = image_register(unreg_img_right, X_right(Z_best_right(ii),ii), Y_right(Z_best_right(ii),ii));
    registered_image = [registered_image_left; registered_image_right];
    
    name_file = ['Registered_with_Rep_cellROI_Z=', int2str(ii), '.tif'];
    imwrite(registered_image, [Data_Folder, filesep, name_file]);
    
    clear unreg_img_temp base_img_temp_left base_img_temp_right registered_image registered_image_left registered_image_right base_img
    
    
    %% Do it for each time point
    Time_Data_Folder = [Data_Folder, 'Z=', int2str(ii),'/'];
    
    for jj = 1:num_tim_data
        disp(['Registering...Stack_Image ', int2str(ii), 'Time Point..', int2str(jj)])
        
        %If the after images have been registered with before
        if exist([Time_Data_Folder, 'Registered_with_Before_',Exp_name,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif'], 'file')
            t_data = imread([Time_Data_Folder, 'Registered_with_Before_',Exp_name,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif']);
        else
            t_data = imread([Time_Data_Folder, Exp_name,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif']);
            t_data = imresize(t_data,2);
        end
        
        unreg_img_left = eval(['t_data(', int2str(y_lim_data_left1),':', int2str(y_lim_data_left2),',',...
            int2str(x_lim_data1),':', int2str(x_lim_data2),')']);
        unreg_img_right = eval(['t_data(', int2str(y_lim_data_right1),':', int2str(y_lim_data_right2),',',...
            int2str(x_lim_data1),':', int2str(x_lim_data2),')']);
        unreg_img = [unreg_img_left; unreg_img_right];
        
        %Register Left Habenula
        registered_image_left = image_register(unreg_img_left, X_left(Z_best_left(ii),ii), Y_left(Z_best_left(ii),ii));
        registered_image_right = image_register(unreg_img_right, X_right(Z_best_right(ii),ii), Y_right(Z_best_right(ii),ii));
        registered_image = [registered_image_left; registered_image_right];
        
        name_file = ['Registered_with_Rep_',Exp_name,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif'];
        imwrite(registered_image, [Time_Data_Folder, name_file]);
    end
    
    actual_z = actual_z-1;
end

end

%% Register the image to the best match representative image
function registered = image_register(unregistered, xoff, yoff)


%% Register image by calculating shift
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


