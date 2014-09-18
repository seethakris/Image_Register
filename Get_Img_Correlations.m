function get_img_correlations(Data_Folder, Rep_Image_Folder, Result_Folder, num_stk_data, num_stk_rep, ...
    x_lim_rep1, x_lim_rep2, x_lim_data1, x_lim_data2)
%% Take a representative stack and look for closely matched image with data

%Loop through each data stack and representative stack and find the best
%correlated image
for ii = 1:num_stk_data
    Stack_Image(:,:) = imread([Data_Folder, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    Stack_Image(:,1:620) = 0;
    Stack_Image(Stack_Image<20) = 0;
    temp_Stack_Image = eval(['Stack_Image(:,', int2str(x_lim_data1),':', x_lim_data2, ')']);
    
    for jj = 1:num_stk_rep
        disp(['Stack_Image ', int2str(ii), ' Gcamp_Image ',int2str(jj)])
        Gcamp = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',jj), '_c01.tif']);
        
        %Find correlation and offset
        cc(:,:,jj,ii) = xcorr2(double(temp_Stack_Image), double(eval(['Gcamp(:,', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')'])));
        temp_cc = squeeze(cc(:,:,jj,ii));
        [max_cc(jj,ii), imax(jj,ii)] = max(abs(temp_cc(:)));
        [ypeak(jj,ii), xpeak(jj,ii)] = ind2sub(size(temp_cc),imax(jj,ii));
        corr_offset(:,jj,ii) = [ (ypeak(jj,ii)-size(temp_Stack_Image,1)) (xpeak(jj,ii)-size(temp_Stack_Image,2)) ];
        
        
        % Plot and save these images
        fs1 = figure(1);
        set(fs1, 'visible','off', 'color', 'white')
        subplot(1,2,1)
        imshow(eval(['Gcamp(:,', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']))
        title(['Representative Image ', int2str(jj)])
        subplot(1,2,2)
        imshow(temp_Stack_Image)
        title(['Offset y ', int2str(corr_offset(1,jj,ii)), ' Offset x ', int2str(corr_offset(2,jj,ii))]);
        
        %Create a pdf figure
        name_file = ['Image Correlation Stack ', int2str(ii)];
        if exist([Result_Folder, name_file, '.pdf'], 'file')
            delete([Result_Folder, name_file, '.pdf'])
        end
        export_fig([Result_Folder, name_file], '-pdf', '-append');
        
        disp(['Offset y ', int2str(corr_offset(1,jj,ii)), ' Offset x ', int2str(corr_offset(2,jj,ii))])
    end
    
    corr_off_stk = corr_offset(:,:,ii);
    save([Result_Folder, 'Correlation_Offset_Stack_',int2str(ii),'.mat'], 'corr_off_stk')
    
    clear corr_off_stk
end

%Save all variables for future use
save([Result_Folder,filesep, 'Correlation_Offset_All_Stack_Variables.mat'])


