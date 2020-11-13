%% Common Corrospondence Particles
% Created by: Rich Lisonbee
% Revised for Talofibular by: Andrew Peterson
% Last Updated: 11.5.20

% Run this script last, after SSM_Congruency and Common_Corrospondence

clear, clc, close all
trouble_shoot = 2; % % 1-off , 2-on (displays all plots)

TaF = 3; % if TT = 3, then there has to be at least 3 individuals with the same cp to be included

%% Preparing Paths
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13','R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};
excel_path = 'Curvature_Data_TaF_Github.xlsx';

%% Corrospondence Points from File
cp = load('talus.mean.pts'); % load in the correspondance particles

%% Load Talofibular Information from Excel
subj_count = 1;
while subj_count <= length(subj)
    excel_data = xlsread(excel_path,string(subj(subj_count)));
    Data.(string(subj(subj_count))).Talofibular = [excel_data(~isnan(excel_data(1:end,3)),3) excel_data(~isnan(excel_data(1:end,4)),4) excel_data(~isnan(excel_data(1:end,5)),5)];
    Data.(string(subj(subj_count))).Nodes.Talofibular = [excel_data(~isnan(excel_data(1:end,1)),1) excel_data(~isnan(excel_data(1:end,2)),2) excel_data(~isnan(excel_data(1:end,3)),3)];
    subj_count = subj_count + 1;
end

%% Compiling Data to Determine Common Points
% Takes all of the corrospondence points from each subject and compiles
% them into one matrix.
n = 0;
subj_count = 1;
while subj_count <= length(subj)
    Compiled_Talofibular_CP(n+1:length(Data.(string(subj(subj_count))).Talofibular(:,1))+n,:) = Data.(string(subj(subj_count))).Talofibular(:,1);
    n = length(Compiled_Talofibular_CP(:,1));
    subj_count = subj_count + 1;
end

% Extracts only the unique corrospondence points from the compiled matrix.
Compiled_Talofibular_CP_Unique = unique(Compiled_Talofibular_CP);

% Counts how many of each corrospondence point there is.
count_Talofibular = hist(Compiled_Talofibular_CP,Compiled_Talofibular_CP_Unique);

% Logical matrix that will find corrospondence points index with more than
% one subject having that specific point.
i_Repeat_Talofibular = (count_Talofibular~=1);

% Finds all repeated corrospondence points.
Repeat_Talofibular = Compiled_Talofibular_CP_Unique(i_Repeat_Talofibular);

% Counts the number of times a specific corrospondence point is common
% across all subjects.
Number_Talofibular = count_Talofibular(i_Repeat_Talofibular)';

%%
Repeat_TaF = Repeat_Talofibular(find(Number_Talofibular >= TaF),1);

%% Writing the Talofibular Common Points to Structure for Ease of Access
subj_count = 1;
while subj_count <= length(subj)
    n = 1;
    m = 1;
    while n <= length(Repeat_TaF(:,1))
        temp = Data.(string(subj(subj_count))).Talofibular(find(Data.(string(subj(subj_count))).Talofibular(:,1) == Repeat_TaF(n,:)),:);
        if isempty(temp) == 0
            Data.(string(subj(subj_count))).Common.Talofibular(m,:) = temp;
            m = m + 1;
        end
        n = n + 1;
    end
    subj_count = subj_count + 1;
end

%% Plotting the Common Points for Talofibular
if trouble_shoot >= 3
subj_count = 1;
while subj_count <= length(subj)
figure()
% ColorMapPlot3(cp(Data.(string(subj(subj_count))).Common.Talofibular(:,1),:),Data.(string(subj(subj_count))).Common.Talofibular(:,3));
ColorMapPlot3(cp(Data.(string(subj(subj_count))).Talofibular(:,1),:),Data.(string(subj(subj_count))).Talofibular(:,3));
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = strcat(string(subj(subj_count)),' Talofibular RMS');
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal

subj_count = subj_count + 1;
end
end

%% Talofibular Mean RMS
n = 1;
while n <= length(Compiled_Talofibular_CP_Unique(:,1))
    subj_count = 1;
    while subj_count <= length(subj)
        temp = find(Data.(string(subj(subj_count))).Talofibular(:,1) == Compiled_Talofibular_CP_Unique(n));
        if isempty(temp) == 0
            Repeat.Node.(strcat('CP_',string(Compiled_Talofibular_CP_Unique(n))))(subj_count,:) = Data.(string(subj(subj_count))).Talofibular(temp,3);
        end
        if isempty(temp) == 1
            Repeat.Node.(strcat('CP_',string(Compiled_Talofibular_CP_Unique(n))))(subj_count,:) = NaN;
        end            
        subj_count = subj_count + 1;
    end
    n = n + 1;
end

n = 1;
while n <= length(Compiled_Talofibular_CP_Unique(:,1))
    MeanRMSTalofibular(n,:) = [Compiled_Talofibular_CP_Unique(n,1) mean(Repeat.Node.(strcat('CP_',string(Compiled_Talofibular_CP_Unique(n))))(~isnan(Repeat.Node.(strcat('CP_',string(Compiled_Talofibular_CP_Unique(n)))))))];
    n = n + 1;
end

if trouble_shoot >= 2
figure()
ColorMapPlot3(cp(MeanRMSTalofibular(:,1),:),MeanRMSTalofibular(:,2));
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = 'Mean Talofibular RMS';
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
end

%% MEAN RMS (95%)
n = 1;
while n <= length(Repeat_TaF(:,1))
    subj_count = 1;
    while subj_count <= length(subj)
        temp = find(Data.(string(subj(subj_count))).Talofibular(:,1) == Repeat_TaF(n));
        if isempty(temp) == 0
            Repeat.Node.(strcat('CP_',string(Repeat_TaF(n))))(subj_count,:) = Data.(string(subj(subj_count))).Talofibular(temp,3);
        end
        if isempty(temp) == 1
            Repeat.Node.(strcat('CP_',string(Repeat_TaF(n))))(subj_count,:) = NaN;
        end            
        subj_count = subj_count + 1;
    end
    n = n + 1;
end

n = 1;
while n <= length(Repeat_TaF(:,1))
    MeanRMSTalofibular_95(n,:) = [Repeat_TaF(n,1) mean(Repeat.Node.(strcat('CP_',string(Repeat_TaF(n))))(~isnan(Repeat.Node.(strcat('CP_',string(Repeat_TaF(n)))))))];
    n = n + 1;
end

if trouble_shoot >= 2
figure()
ColorMapPlot3(cp(MeanRMSTalofibular_95(:,1),:),MeanRMSTalofibular_95(:,2));
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = 'Mean Talofibular RMS (Common)';
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
end

%% MEAN DISTANCE (95%)
n = 1;
while n <= length(Repeat_TaF(:,1))
    subj_count = 1;
    while subj_count <= length(subj)
        temp = find(Data.(string(subj(subj_count))).Talofibular(:,1) == Repeat_TaF(n));
        if isempty(temp) == 0
            Repeat.Distance.(strcat('CP_',string(Repeat_TaF(n))))(subj_count,:) = Data.(string(subj(subj_count))).Talofibular(temp,2);
        end
        if isempty(temp) == 1
            Repeat.Distance.(strcat('CP_',string(Repeat_TaF(n))))(subj_count,:) = NaN;
        end            
        subj_count = subj_count + 1;
    end
    n = n + 1;
end

n = 1;
while n <= length(Repeat_TaF(:,1))
    MeanDistTalofibular_95(n,:) = [Repeat_TaF(n,1) mean(Repeat.Distance.(strcat('CP_',string(Repeat_TaF(n))))(~isnan(Repeat.Distance.(strcat('CP_',string(Repeat_TaF(n)))))))];
    n = n + 1;
end

if trouble_shoot >= 2
figure()
ColorMapPlot3(cp(MeanDistTalofibular_95(:,1),:),MeanDistTalofibular_95(:,2),1);
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = 'Mean Talofibular Distance (Common)';
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
end

%% COMBINED RMS and Distance
MeanRMS_95 = [MeanRMSTalofibular_95(:,:)];

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

MeanDist_95 = [MeanDistTalofibular_95(:,:)];

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
