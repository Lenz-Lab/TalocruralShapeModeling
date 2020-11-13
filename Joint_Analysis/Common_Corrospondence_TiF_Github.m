%% Common Corrospondence Particles for Tibiofibular Joint
% Created by: Rich Lisonbee
% Revised for Tibiofibular by: Andrew Peterson
% Created: 6.14.19
% Last Updated: 2.11.20

% Run this script third, after Distance_Corrospondence and SSM_Congruency

clear, clc, close all
trouble_shoot = 2; % % 1-off , 2-on (displays all plots)

TiF = 3; %if TiF = 3, then there has to be at least 3 individuals with the same cp to be included

%% Preparing Paths
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13','R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};
excel_path = 'Curvature_Data_TiF_Github.xlsx';

%% Corrospondence Points from File
cp = load('tibia.mean.pts'); % load in the correspondance particles

%% Load Tibiofibular Information from Excel
subj_count = 1;
while subj_count <= length(subj)
    excel_data = xlsread(excel_path,string(subj(subj_count)));
    Data.(string(subj(subj_count))).Tibiofibular = [excel_data(~isnan(excel_data(1:end,3)),3) excel_data(~isnan(excel_data(1:end,4)),4) excel_data(~isnan(excel_data(1:end,5)),5)];
    Data.(string(subj(subj_count))).Nodes.Tibiofibular = [excel_data(~isnan(excel_data(1:end,1)),1) excel_data(~isnan(excel_data(1:end,2)),2) excel_data(~isnan(excel_data(1:end,3)),3)];
    subj_count = subj_count + 1;
end

%% Compiling Data to Determine Common Points
% Takes all of the corrospondence points from each subject and compiles
% them into one matrix.
n = 0;
subj_count = 1;
while subj_count <= length(subj)
    Compiled_Tibiofibular_CP(n+1:length(Data.(string(subj(subj_count))).Tibiofibular(:,1))+n,:) = Data.(string(subj(subj_count))).Tibiofibular(:,1);
    n = length(Compiled_Tibiofibular_CP(:,1));
    subj_count = subj_count + 1;
end

% Extracts only the unique corrospondence points from the compiled matrix.
Compiled_Tibiofibular_CP_Unique = unique(Compiled_Tibiofibular_CP);

% Counts how many of each corrospondence point there is.
count_Tibiofibular = hist(Compiled_Tibiofibular_CP,Compiled_Tibiofibular_CP_Unique);

% Logical matrix that will find corrospondence points index with more than
% one subject having that specific point.
i_Repeat_Tibiofibular = (count_Tibiofibular~=1);

% Finds all repeated corrospondence points.
Repeat_Tibiofibular = Compiled_Tibiofibular_CP_Unique(i_Repeat_Tibiofibular);

% Counts the number of times a specific corrospondence point is common
% across all subjects.
Number_Tibiofibular = count_Tibiofibular(i_Repeat_Tibiofibular)';

%%
Repeat_TiF = Repeat_Tibiofibular(find(Number_Tibiofibular >= TiF),1);

%% Writing the Tibiofibular Common Points to Structure for Ease of Access
subj_count = 1;
while subj_count <= length(subj)
    n = 1;
    m = 1;
    while n <= length(Repeat_TiF(:,1))
        temp = Data.(string(subj(subj_count))).Tibiofibular(find(Data.(string(subj(subj_count))).Tibiofibular(:,1) == Repeat_TiF(n,:)),:);
        if length(temp) == 1
            if isempty(temp) == 0
                Data.(string(subj(subj_count))).Common.Tibiofibular(m,:) = temp;
                m = m + 1;
            end
        else
            if isempty(temp) == 0
                Data.(string(subj(subj_count))).Common.Tibiofibular(m,:) = temp(end,:);
                m = m + 1;
            end
        end
        
        n = n + 1;
    end
    subj_count = subj_count + 1;
end
    
    %% Plotting the Common Points for Tibiofibular
    if trouble_shoot >= 3
        subj_count = 1;
        while subj_count <= length(subj)
            figure()
            % ColorMapPlot3(cp(Data.(string(subj(subj_count))).Common.Talofibular(:,1),:),Data.(string(subj(subj_count))).Common.Talofibular(:,3));
            ColorMapPlot3(cp(Data.(string(subj(subj_count))).Tibiofibular(:,1),:),Data.(string(subj(subj_count))).Tibiofibular(:,3));
            hold on
            plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
            colorbar
            nameTitle = strcat(string(subj(subj_count)),' Tibiofibular RMS');
            title(nameTitle)
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            axis equal
            
            subj_count = subj_count + 1;
        end
    end
    
    %% Troubleshooting That Corrospondence Points Are Correct
    % subj_count = 8;
    %
    % figure()
    % plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
    % hold on
    % plot3(cp(584,1),cp(584,2),cp(584,3),'r*','linewidth',5)
    % axis equal
    %
    % figure()
    % ColorMapPlot3(cp(Data.(string(subj(subj_count))).Talofibular(:,1),:),Data.(string(subj(subj_count))).Talofibular(:,3));
    % hold on
    % plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
    % hold on
    % plot3(cp(584,1),cp(584,2),cp(584,3),'k*','linewidth',3)
    % axis equal
    
    %% Tibiofibular Mean RMS
    n = 1;
    while n <= length(Compiled_Tibiofibular_CP_Unique(:,1))
        subj_count = 1;
        while subj_count <= length(subj)
            temp = find(Data.(string(subj(subj_count))).Tibiofibular(:,1) == Compiled_Tibiofibular_CP_Unique(n));
            if isempty(temp) == 0
                temporary = Data.(string(subj(subj_count))).Tibiofibular(temp,3);
                Repeat.Node.(strcat('CP_',string(Compiled_Tibiofibular_CP_Unique(n))))(subj_count,:) = temporary(end,:);
            end
            if isempty(temp) == 1
                Repeat.Node.(strcat('CP_',string(Compiled_Tibiofibular_CP_Unique(n))))(subj_count,:) = NaN;
            end
            subj_count = subj_count + 1;
        end
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Compiled_Tibiofibular_CP_Unique(:,1))
        MeanRMSTibiofibular(n,:) = [Compiled_Tibiofibular_CP_Unique(n,1) mean(Repeat.Node.(strcat('CP_',string(Compiled_Tibiofibular_CP_Unique(n))))(~isnan(Repeat.Node.(strcat('CP_',string(Compiled_Tibiofibular_CP_Unique(n)))))))];
        n = n + 1;
    end
    
    if trouble_shoot >= 2
        figure()
        ColorMapPlot3(cp(MeanRMSTibiofibular(:,1),:),MeanRMSTibiofibular(:,2));
        hold on
        plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
        colorbar
        nameTitle = 'Mean Tibiotalar RMS';
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MEAN RMS (95%)
    %% Tibiofibular Mean RMS
    n = 1;
    while n <= length(Repeat_TiF(:,1))
        subj_count = 1;
        while subj_count <= length(subj)
            temp = find(Data.(string(subj(subj_count))).Tibiofibular(:,1) == Repeat_TiF(n));
            if isempty(temp) == 0
                temporary = Data.(string(subj(subj_count))).Tibiofibular(temp,3);
                Repeat.Node.(strcat('CP_',string(Repeat_TiF(n))))(subj_count,:) = temporary(end,:);
            end
            if isempty(temp) == 1
                Repeat.Node.(strcat('CP_',string(Repeat_TiF(n))))(subj_count,:) = NaN;
            end
            subj_count = subj_count + 1;
        end
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Repeat_TiF(:,1))
        MeanRMSTibiofibular_95(n,:) = [Repeat_TiF(n,1) mean(Repeat.Node.(strcat('CP_',string(Repeat_TiF(n))))(~isnan(Repeat.Node.(strcat('CP_',string(Repeat_TiF(n)))))))];
        n = n + 1;
    end
    
    if trouble_shoot >= 2
        figure()
        ColorMapPlot3(cp(MeanRMSTibiofibular_95(:,1),:),MeanRMSTibiofibular_95(:,2));
        hold on
        plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
        colorbar
        nameTitle = 'Mean Tibiofibular RMS (Common)';
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
    end
    
    %% MEAN DISTANCE (95%)
    %% Tibiofibular Mean Distance
    n = 1;
    while n <= length(Repeat_TiF(:,1))
        subj_count = 1;
        while subj_count <= length(subj)
            temp = find(Data.(string(subj(subj_count))).Tibiofibular(:,1) == Repeat_TiF(n));
            if isempty(temp) == 0
                temporary = Data.(string(subj(subj_count))).Tibiofibular(temp,2);
                Repeat.Distance.(strcat('CP_',string(Repeat_TiF(n))))(subj_count,:) = temporary(end,:);
            end
            if isempty(temp) == 1
                Repeat.Distance.(strcat('CP_',string(Repeat_TiF(n))))(subj_count,:) = NaN;
            end
            subj_count = subj_count + 1;
        end
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Repeat_TiF(:,1))
        MeanDistTibiofibular_95(n,:) = [Repeat_TiF(n,1) mean(Repeat.Distance.(strcat('CP_',string(Repeat_TiF(n))))(~isnan(Repeat.Distance.(strcat('CP_',string(Repeat_TiF(n)))))))];
        n = n + 1;
    end
    
    if trouble_shoot >= 2
        figure()
        ColorMapPlot3(cp(MeanDistTibiofibular_95(:,1),:),MeanDistTibiofibular_95(:,2),1);
        hold on
        plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
        colorbar
        nameTitle = 'Mean Tibiofibular Distance (Common)';
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
    end
    
    %% COMBINED RMS and Distance
    MeanRMS_95 = [MeanRMSTibiofibular_95(:,:)];
    
    if trouble_shoot >= 2
        figure()
        ColorMapPlot3(cp(MeanRMS_95(:,1),:),MeanRMS_95(:,2));
        hold on
        plot3(cp(:,1),cp(:,2),cp(:,3),'k.')
        colorbar
        nameTitle = 'Mean RMS (Common)';
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        set(gca,'xtick',[],'ytick',[],'ztick',[],'xcolor','none','ycolor','none','zcolor','none')
    end
    
    MeanDist_95 = [MeanDistTibiofibular_95(:,:)];
    
    if trouble_shoot >= 2
        figure()
        ColorMapPlot3(cp(MeanDist_95(:,1),:),MeanDist_95(:,2),2);
        hold on
        plot3(cp(:,1),cp(:,2),cp(:,3),'k.')
        colorbar
        nameTitle = 'Mean Distance (Common)';
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        set(gca,'xtick',[],'ytick',[],'ztick',[],'xcolor','none','ycolor','none','zcolor','none')
    end

