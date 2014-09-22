function register_before_after_images

%% This function registers the corresponding stacks of the before and after lesion images in the same experiment to standardize the cell locations
%Before Image Folder
Data_Folder_B =  '~/Desktop/Image_Register/Data/Fish056_Before/'; %Folder containing the data
Experiment_name_B = 'Fish056_Block2_Blue&US1'; %Experiment name as in the Z=1,Z=2, etc folders


%After Image folder
Data_Folder_A =  '~/Desktop/Image_Register/Data/Fish056_After/'; %Folder containing the data
Experiment_name_A = 'Fish056_Block8_Blue&US6'; %Experiment name as in the Z=1,Z=2, etc folders


%Save Plot and Registered Images
Result_Folder = '~/Desktop/Image_Register/Data/Fish056_After/Correlated_Registered_Results/';
if ~exist(Result_Folder,'dir')
    mkdir(Result_Folder)
end
num_stk_data = 5;
num_tim_data = 301;
actual_z = 5;

for ii = 1:num_stk_data
    
    disp(['Correlation with Before..', int2str(ii)])
    
    %Find offset between Before and After Image and register
    Before_Image = imread([Data_Folder_B, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    After_Image = imread([Data_Folder_A, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    
    cc(:,:,ii) = xcorr2(double(After_Image), double(Before_Image));
    temp_cc = squeeze(cc(:,:,ii));
    [max_cc(ii), imax(ii)] = max(abs(temp_cc(:)));
    [ypeak(ii), xpeak(ii)] = ind2sub(size(temp_cc),imax(ii));
    corr_offset(:,ii) = [ (ypeak(ii)-size(Before_Image,1)) (xpeak(ii)-size(Before_Image,2)) ];
    
    
    %Register Raw Averaged images
    registered_After_Image = image_register(After_Image, corr_offset(2,ii), corr_offset(1,ii));
    imwrite(registered_After_Image, [Data_Folder_A,'Registered_with_Before_Raw_Z=', int2str(ii),'_Max.jpg'])
    
    %Save
    save([Result_Folder, 'Correlation_Offset_with_Before_Stack_',int2str(ii),'.mat'], 'corr_offset')
    
    % Plot and save these images
    fs1 = figure(1);
    set(fs1, 'visible','off', 'color', 'white')
    subplot(2,2,1)
    imshow(Before_Image)
    title(['Before Image Stack', int2str(ii)])
    subplot(2,2,2)
    imshow(After_Image)
    title(['After Image Stack', int2str(ii)])
    subplot(2,2,3)
    imshow(registered_After_Image)
    title(['Registered After Image Stack', int2str(ii)])
    subplot(2,2,4)
    imshowpair(Before_Image,registered_After_Image)
    title(['Before + After Registered', int2str(ii)])
    
    %Create a pdf figure
    name_file = 'After Lesion Registered with Before Lesion';
    if ii == 1 && exist([Result_Folder, name_file, '.pdf'], 'file')
        delete([Result_Folder, name_file, '.pdf'])
    end
    export_fig([Result_Folder, name_file], '-pdf', '-append');
    
    disp(['Offset y ', int2str(corr_offset(1,ii)), ' Offset x ', int2str(corr_offset(2,ii))])
    
    %Register Cell ROIs
    disp(['Registering Cell Outlines', int2str(ii)]);
    cell_roi_img = imread([Data_Folder_A, 'cellROI_Z=', int2str(ii),'.tif']);
    
    registered_image = image_register(cell_roi_img, corr_offset(2,ii), corr_offset(1,ii));
    name_file = ['Registered_with_Before_cellROI_Z=', int2str(ii), '.tif'];
    imwrite(registered_image, [Data_Folder_A, name_file]);
    
    
    %Register Each time point in each stack
    Time_Data_Folder = [Data_Folder_A, 'Z=', int2str(ii),'/'];
    
    for jj = 1:num_tim_data
        disp(['Registering...Stack_Image ', int2str(ii), 'Time Point..', int2str(jj)])
        t_data = imread([Time_Data_Folder, Experiment_name_A,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif']);
        t_data = imresize(t_data,2);
        
        registered_image = image_register(t_data, corr_offset(2,ii), corr_offset(1,ii));
        name_file = ['Registered_with_Before_', Experiment_name_A,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif'];
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


