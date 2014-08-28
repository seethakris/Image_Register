function Get_Img_Correlations
%% Take a representative stack and look for closely matched image with data

close all
clear all
warning off

% Folders and variable declaration

Data_Folder =  '~/Desktop/Image_Register/Fish056_Before/';
Rep_Image_Folder =  '~/Desktop/Image_Register/1011_GCamp3_KR11_KissPeptinreceptor_F2/';


Result_Folder = [Data_Folder, 'Corr_Images'];
mkdir(Result_Folder)


num_stk_data = 5;
num_stk_rep = 31;

%Loop through each data stack and representative stack and find the best
%correlated image

for ii = 1:num_stk_data
    
    Stack_Image(:,:) = imread([Image_Folder1, 'Raw_Z=', int2str(ii),'_Max.jpg']);
    Stack_Image(:,1:620) = 0;
    Stack_Image(Stack_Image<20) = 0;
    temp_Stack_Image = Stack_Image(:,620:end);

    
    for jj = 1:num_stk_rep
        
        disp(['Stack_Image ', int2str(ii), ' Gcamp_Image ',int2str(jj)])
        
        Gcamp = imread([Image_Folder2,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',jj), '_c01.tif']);
        
        %Find correlation and offset
        cc(:,:,jj,ii) = xcorr2(temp_Stack_Image,Gcamp(:,445:850) );
        temp_cc = squeeze(cc(:,:,jj,ii));
        [max_cc(jj,ii), imax(jj,ii)] = max(abs(temp_cc(:)));
        [ypeak(jj,ii), xpeak(jj,ii)] = ind2sub(size(temp_cc),imax(jj,ii));
        corr_offset(:,jj,ii) = [ (ypeak(jj,ii)-size(temp_Stack_Image,1)) (xpeak(jj,ii)-size(temp_Stack_Image,2)) ];
        
        
        % Plot and save
        fs1 = figure(1);
        set(fs1, 'visible','off')
        subplot(1,2,1)
        imshow(Gcamp(:,445:850))
        subplot(1,2,2)
        imshow(temp_Stack_Image)
        title(['Offset y ', int2str(corr_offset(1,jj,ii)), ' Offset x ', int2str(corr_offset(2,jj,ii))]);
        name_file = ['Image Correlation : Stack_Image ', int2str(ii), ' Gcamp_Image ', int2str(jj)];
        saveas(fs1, [Result_Folder, filesep, name_file], 'jpg');
        
    end
    
    corr_off_stk = corr_offset(:,:,ii);
    save([Result_Folder,filesep, 'Stack_',int2str(ii),'.mat'], 'corr_off_stk')
    clear corr_off_stk
end

%Save all variables for future use
save([Result_Folder,filesep, 'All_Stack_Variables.mat'])


