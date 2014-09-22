function get_img_correlations(Data_Folder, Rep_Image_Folder, Result_Folder, num_stk_data, num_stk_rep, ...
    x_lim_rep1, x_lim_rep2, y_lim_rep_left1,y_lim_rep_left2, y_lim_rep_right1, y_lim_rep_right2,...
    x_lim_data1, x_lim_data2, y_lim_data_left1, y_lim_data_left2, y_lim_data_right1, y_lim_data_right2)

%% Take a representative stack and look for closely matched image with data

%Loop through each data stack and representative stack and find the best
%correlated image
for ii = 1:num_stk_data
    
    %If the after images have been registered with before lesion images
    if exist([Data_Folder, 'Registered_with_Before_Raw_Z=', int2str(ii),'_Max.jpg'], 'file')
        Stack_Image(:,:) = imread([Data_Folder, 'Registered_with_Before_Raw_Z=', int2str(ii),'_Max.jpg']);
    else
        Stack_Image(:,:) = imread([Data_Folder, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    end
    
    % Do some preprocessing to remove non habenula and very low intensity ROIs
    Stack_Image(:,1:620) = 0;
    Stack_Image(Stack_Image<20) = 0;
    temp_Stack_Image_Left = eval(['Stack_Image(',int2str(y_lim_data_left1),':', int2str(y_lim_data_left2),',', int2str(x_lim_data1),':', int2str(x_lim_data2), ')']);
    temp_Stack_Image_Right = eval(['Stack_Image(',int2str(y_lim_data_right1),':', int2str(y_lim_data_right2),',', int2str(x_lim_data1),':', int2str(x_lim_data2), ')']);
    
    for jj = 1:num_stk_rep
        
        disp(['Stack_Image ', int2str(ii), ' Gcamp_Image ',int2str(jj)])
        
        %Load Gcamp
        Gcamp = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',jj), '_c01.tif']);
        Gcamp_Left = eval(['Gcamp(',int2str(y_lim_rep_left1),':', int2str(y_lim_rep_left2), ...
            ',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
        Gcamp_Right = eval(['Gcamp(',int2str(y_lim_rep_right1),':', int2str(y_lim_rep_right2), ...
            ',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
        
        %Find correlation and offset
        corr_offset_left(:,jj,ii) = find_correlation(temp_Stack_Image_Left,Gcamp_Left);
        corr_offset_right(:,jj,ii) = find_correlation(temp_Stack_Image_Right,Gcamp_Right);
        
        % Plot and save these images for left and right habenula
        fs1 = figure(1);
        set(fs1, 'visible','off', 'color', 'white')
        
        subplot(2,2,1)
        imshow(Gcamp_Left)
        title(['Representative Image Left Habenula', int2str(jj)])
        subplot(2,2,2)
        imshow(temp_Stack_Image_Left)
        title(['Offset y ', int2str(corr_offset_left(1,jj,ii)), ' Offset x ', int2str(corr_offset_left(2,jj,ii))]);
        
        subplot(2,2,3)
        imshow(Gcamp_Right)
        title(['Representative Image Right Habenula', int2str(jj)])
        subplot(2,2,4)
        imshow(temp_Stack_Image_Right)
        title(['Offset y ', int2str(corr_offset_right(1,jj,ii)), ' Offset x ', int2str(corr_offset_right(2,jj,ii))]);
        
        %Create a pdf figure
        name_file = ['Image Correlation with All Representative Images-Stack ', int2str(ii)];
        if jj == 1 && exist([Result_Folder, name_file, '.pdf'], 'file')
            delete([Result_Folder, name_file, '.pdf'])
        end
        export_fig([Result_Folder, name_file], '-pdf', '-append');
        
        disp(['Offset for left habenula y ', int2str(corr_offset_left(1,jj,ii)), ' Offset x ', int2str(corr_offset_left(2,jj,ii))])
        disp(['Offset for right habenula y ', int2str(corr_offset_right(1,jj,ii)), ' Offset x ', int2str(corr_offset_right(2,jj,ii))])
    end
    
    corr_off_stk_left = corr_offset_left(:,:,ii);
    corr_off_stk_right = corr_offset_right(:,:,ii);
    save([Result_Folder, 'Correlation_Offset_with_Rep_Stack_',int2str(ii),'.mat'], 'corr_off_stk_left', 'corr_off_stk_right')
    
    clear corr_off_stk_left corr_offset_right
end

end


function corr_offset = find_correlation(A,B)

cc = xcorr2(double(A), double(B));
temp_cc = squeeze(cc);
[~, imax] = max(abs(temp_cc(:)));
[ypeak, xpeak] = ind2sub(size(temp_cc),imax);
corr_offset = [(ypeak-size(A,1)) (xpeak-size(A,2))];

end
