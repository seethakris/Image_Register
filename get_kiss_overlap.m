function get_kiss_overlap(Exp_name, Data_Folder, Data_Corr_Folder, Rep_Image_Folder, Result_Folder,...
    num_stk_data, num_tim_data, x_lim_rep1, x_lim_rep2, y_lim_rep_left1,y_lim_rep_left2, y_lim_rep_right1, y_lim_rep_right2)

%% Get overlapping pixels with kiss peptin from the representative stack and plot as a mask on data

%load the best Z
load([Data_Corr_Folder, 'Z_best.mat'])

actual_z = num_stk_data;

for ii = 1:num_stk_data
    
    %Import all sorts of data
    Data = imread([Data_Folder, 'Registered_with_Rep_Raw_Z=', int2str(ii),'_Max.tif']); % Data
    
    temp_Kiss_left = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',Z_best_left(ii)), '_c04.tif']);
    Kiss_left = eval(['temp_Kiss_left(',int2str(y_lim_rep_left1),':', int2str(y_lim_rep_left2),',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
    temp_Kiss_right = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',Z_best_right(ii)), '_c04.tif']);
    Kiss_right = eval(['temp_Kiss_left(',int2str(y_lim_rep_right1),':', int2str(y_lim_rep_right2),',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
    Kiss = [Kiss_left; Kiss_right]; % Kiss
    
    clear temp_Kiss_left temp_Kiss_right Kiss_left Kiss_right
    
    temp_Gcamp_left = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',Z_best_left(ii)), '_c01.tif']);
    Gcamp_left = eval(['temp_Gcamp_left(',int2str(y_lim_rep_left1),':', int2str(y_lim_rep_left2),',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
    temp_Gcamp_right = imread([Rep_Image_Folder,'1011_GCamp3_KR11_KissPeptinreceptor_F2_z', sprintf('%02.0f',Z_best_right(ii)), '_c01.tif']);
    Gcamp_right = eval(['temp_Gcamp_left(',int2str(y_lim_rep_right1),':', int2str(y_lim_rep_right2),',', int2str(x_lim_rep1), ':', int2str(x_lim_rep2),')']);
    Gcamp = [Gcamp_left; Gcamp_right];
    
    clear temp_Gcamp_left temp_Gcamp_right Gcamp_left Gcamp_right
    
    Data_bw = imread([Data_Folder, 'Registered_with_Rep_cellROI_Z=', int2str(ii),'.tif']);
    Data_bw = bwmorph(Data_bw, 'thicken');
    
    
    % Create pixel list for all cells
    Data_boundaries = bwboundaries(Data_bw);
    [~,temp] = sort(cellfun(@length, Data_boundaries));
    Data_boundaries = Data_boundaries(temp);
    temp = cellfun(@length, Data_boundaries);
    Data_boundaries(temp<10 | temp>220) = [];
    
    Data_bw = imfill(Data_bw, 'holes');
    
    %Create only Kiss files using a threshold
    Kiss_Gcamp_add = Kiss+Gcamp;
    Kiss_Gcamp_add = Kiss_Gcamp_add>100;
    Kiss_Gcamp_fuse = bwareaopen(Kiss_Gcamp_add,100);
    Kiss_Gcamp_fuse = bwmorph(Kiss_Gcamp_fuse,'thicken');
    
    Only_Kiss = immultiply(Kiss,Kiss_Gcamp_fuse);
    Kiss_pixels = find(Kiss_Gcamp_fuse==1);
    
    %Create pixel list for each boundary item and check if any of the
    %pixels are part of a Kiss region. Save these pixels
    count1 = 1;
    count2 = 1;
    pixel_list_kiss =[];
    pixel_list_nonkiss =[];
    for jj = 1:length(Data_boundaries)
        %Get pixels for the ROI
        temp_image = zeros(size(Data_bw));
        temp_boundaries = Data_boundaries{jj};
        temp_ind = sub2ind(size(temp_image),temp_boundaries(:,1), temp_boundaries(:,2));
        
        temp_image(temp_ind) = 1;
        temp_image = imfill(temp_image, 'holes');
        
        data_ind = find(temp_image==1);
        
        %Compare with Kiss. Save those ROIs
        if size(find(ismember(data_ind, Kiss_pixels)==1),1)>5
            pixel_list_kiss(count1).boundaries = data_ind;
            count1 = count1 +1;
        else
            pixel_list_nonkiss(count2).boundaries = data_ind;
            count2 = count2 +1;
        end
    end
    
    disp(['Number of overlapping ROIs with KISS...', int2str(count1-1)]);
    
    % Plot and save some images
    fs1 = figure(1);
    set(fs1, 'visible','off', 'color', 'white')
    
    subplot(1,3,1)
    imshowpair(Gcamp,Kiss+10, 'falsecolor','Scaling','joint');
    title('Representative Image Gcamp & Kiss');
    
    subplot(1,3,2)
    imshow(Only_Kiss)
    title('Only Kiss Pixels');
    
    subplot(1,3,3)
    imshow(imoverlay(Data, Kiss_Gcamp_fuse, [1,0,1]))
    title(['Data Stack ', int2str(ii), '& Kiss, ROIs selected:', int2str(count1-1)]);
    
    name_file = 'Registered Images with Kiss';
    if ii == 1 && exist([Result_Folder, name_file, '.pdf'], 'file')
        delete([Result_Folder, name_file, '.pdf'])
    end
    export_fig([Result_Folder, filesep, name_file], '-pdf', '-append');
    
    
    %Go through each time point and get intensity of the Kiss pixels.
    Time_Data_Folder = [Data_Folder, 'Z=', int2str(ii),'/'];
    
    for jj = 1:num_tim_data
        t_data = imread([Time_Data_Folder,'Registered_with_Rep_', Exp_name,'t', sprintf('%03.0f',jj),'z', int2str(actual_z), '.tif']);
        for kk = 1:length(pixel_list_kiss)
            t_ROI_data_kiss(kk,jj) = mean(t_data(pixel_list_kiss(kk).boundaries));
        end
        for kk = 1:length(pixel_list_nonkiss)
            t_ROI_data_nonkiss(kk,jj) = mean(t_data(pixel_list_nonkiss(kk).boundaries));
        end
    end
    
    
    for kk = 1:length(pixel_list_kiss)
        t_sm_ROI_data_kiss(kk,:) = smooth(t_ROI_data_kiss(kk,:),5);
        t_sm_ROI_data_kiss(kk,:) = t_sm_ROI_data_kiss(kk,:)./mean(t_sm_ROI_data_kiss(kk,6:40));
    end
    
    for kk = 1:length(pixel_list_nonkiss)
        t_sm_ROI_data_nonkiss(kk,:) = smooth(t_ROI_data_nonkiss(kk,:),5);
        t_sm_ROI_data_nonkiss(kk,:) = t_sm_ROI_data_nonkiss(kk,:)./mean(t_sm_ROI_data_nonkiss(kk,6:40));
    end
    
    
    %Only do the following steps if the arrays exist and there are kiss
    %cells
    
    % Kiss Cells
    if ~isempty(pixel_list_kiss)
        %Sort arrays by intensity
        [~, temp_sort] = sort(max(t_sm_ROI_data_kiss,[],2),'descend');
        t_sm_ROI_data_kiss = t_sm_ROI_data_kiss(temp_sort,:);
        
        %Plot some figures of the intensity between kiss cells and save
        close all
        fs1 = figure(1);
        set(fs1, 'visible','off', 'color', 'white')
        subplot(2,1,1)
        plot(mean(t_sm_ROI_data_kiss, 1));
        y = get(gca, 'YLim');
        plot_lines(y, num_tim_data) %Plot lines at stimulus on and off
        title(['Mean Kiss Response Stack', int2str(ii)])
        subplot(2,1,2)
        imagesc(t_sm_ROI_data_kiss, [0 5])
        colorbar;
        y = get(gca, 'YLim');
        plot_lines(y, num_tim_data)
        
        name_file = 'Kiss_NonKiss_ROI_Data';
        if ii == 1 && exist([Result_Folder, name_file, '.pdf'], 'file')
            delete([Result_Folder, name_file, '.pdf'])
        end
        export_fig([Result_Folder, filesep, name_file], '-pdf', '-append');
        
        %Save some variables
        name_file = ['Kiss_Cell_Info_Stack_', int2str(ii),'.mat'];
        save([Result_Folder, name_file], 't_ROI_data_kiss', 't_sm_ROI_data_kiss', 'count1');
    end
    
    % Non Kiss Cells
    if ~isempty(pixel_list_nonkiss)
        %Sort arrays by intensity
        [~, temp_sort] = sort(max(t_sm_ROI_data_nonkiss,[],2), 'descend');
        t_sm_ROI_data_nonkiss = t_sm_ROI_data_nonkiss(temp_sort,:);
        
        actual_z = actual_z-1;
        
        %Plot some figures of the intensity between non kiss cells and save
        close all
        fs1 = figure(1);
        set(fs1, 'visible','off', 'color', 'white')
        subplot(2,1,1)
        plot(mean(t_sm_ROI_data_nonkiss, 1));
        y = get(gca, 'YLim');
        plot_lines(y,num_tim_data)
        title(['Mean Non Kiss Response Stack', int2str(ii)])
        subplot(2,1,2)
        imagesc(t_sm_ROI_data_nonkiss, [0 5])
        colorbar;
        y = get(gca, 'YLim');
        plot_lines(y,num_tim_data)
        
        if ii == 1 && exist([Result_Folder, name_file, '.pdf'], 'file')
            delete([Result_Folder, name_file, '.pdf'])
        end
        name_file = 'Kiss_NonKiss_ROI_Data';
        export_fig([Result_Folder, filesep, name_file], '-pdf', '-append');
        
        %Save some variables
        name_file = ['NonKiss_Cell_Info_Stack_', int2str(ii),'.mat'];
        save([Result_Folder, name_file], 't_ROI_data_nonkiss', 't_sm_ROI_data_nonkiss', 'count2');
    end
    
end

end

function plot_lines(y, num_time_data)
Color = 'k';
box off
set(gca, 'TickDir', 'out')
xlim([0 num_time_data])
line([46 46], y, 'Color', Color,'LineWidth', 1, 'LineStyle', '-');
line([65 65], y, 'Color', Color,'LineWidth', 1, 'LineStyle', ':');
line([98 98], y, 'Color', Color,'LineWidth', 1, 'LineStyle', '-');
line([117 117], y, 'Color', Color,'LineWidth', 1, 'LineStyle', ':');
line([142 142], y, 'Color', Color,'LineWidth', 1, 'LineStyle', '-');
line([161 161], y, 'Color', Color,'LineWidth', 1, 'LineStyle', ':');
line([194 194], y, 'Color', Color,'LineWidth', 1, 'LineStyle', '-');
line([213 213], y, 'Color', Color,'LineWidth', 1, 'LineStyle', ':');
line([238 238], y, 'Color', 'k','LineWidth', 2, 'LineStyle', ':');
line([257 257], y, 'Color', 'k','LineWidth', 2, 'LineStyle', ':');
line([290 290], y, 'Color', 'k','LineWidth', 2, 'LineStyle', ':');
line([309 309], y, 'Color', 'k','LineWidth', 2, 'LineStyle', ':');
end

