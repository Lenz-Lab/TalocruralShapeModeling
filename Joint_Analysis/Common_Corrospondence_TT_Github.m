%% Common Corrospondence Particles
% Created by: Rich Lisonbee
% Revised for Tibiotalar by: Andrew Peterson
% Created: 6.14.19
% Last Updated: 11.3.20

% Run this script last, after SSM_Congruency and Common_Corrospondence

clear, clc, close all
trouble_shoot = 2; % % 1-off , 2-on (displays all plots)

TT = 3; % if TT = 3, then there has to be at least 3 individuals with the same cp to be included

%% Preparing Paths
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13','R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};
excel_path = 'Curvature_Data_TT_Github.xlsx';

%% Corrospondence Points from File
cp = load('talus.mean.pts'); % load in the correspondance particles

%% Load Tibiotalar Information from Excel
subj_count = 1;
while subj_count <= length(subj)
    excel_data = xlsread(excel_path,string(subj(subj_count)));
    Data.(string(subj(subj_count))).Tibiotalar = [excel_data(~isnan(excel_data(1:end,3)),3) excel_data(~isnan(excel_data(1:end,4)),4) excel_data(~isnan(excel_data(1:end,5)),5)];
    Data.(string(subj(subj_count))).Nodes.Tibiotalar = [excel_data(~isnan(excel_data(1:end,1)),1) excel_data(~isnan(excel_data(1:end,2)),2) excel_data(~isnan(excel_data(1:end,3)),3)];
    subj_count = subj_count + 1;
end

%% Compiling Data to Determine Common Points
% Takes all of the corrospondence points from each subject and compiles
% them into one matrix.
n = 0;
subj_count = 1;
while subj_count <= length(subj)
    Compiled_Tibiotalar_CP(n+1:length(Data.(string(subj(subj_count))).Tibiotalar(:,1))+n,:) = Data.(string(subj(subj_count))).Tibiotalar(:,1);
    n = length(Compiled_Tibiotalar_CP(:,1));
    subj_count = subj_count + 1;
end

% Extracts only the unique corrospondence points from the compiled matrix.
Compiled_Tibiotalar_CP_Unique = unique(Compiled_Tibiotalar_CP);

% Counts how many of each corrospondence point there is.
count_Tibiotalar = hist(Compiled_Tibiotalar_CP,Compiled_Tibiotalar_CP_Unique);

% Logical matrix that will find corrospondence points index with more than
% one subject having that specific point.
i_Repeat_Tibiotalar = (count_Tibiotalar~=1);

% Finds all repeated corrospondence points.
Repeat_Tibiotalar = Compiled_Tibiotalar_CP_Unique(i_Repeat_Tibiotalar);

% Counts the number of times a specific corrospondence point is common
% across all subjects.
Number_Tibiotalar = count_Tibiotalar(i_Repeat_Tibiotalar)';

%%
Repeat_TT = Repeat_Tibiotalar(find(Number_Tibiotalar >= TT),1);

%% Writing the Tibiotalar Common Points to Structure for Ease of Access
subj_count = 1;
while subj_count <= length(subj)
    n = 1;
    m = 1;
    while n <= length(Repeat_TT(:,1))
        temp = Data.(string(subj(subj_count))).Tibiotalar(find(Data.(string(subj(subj_count))).Tibiotalar(:,1) == Repeat_TT(n,:)),:);
        if isempty(temp) == 0
            Data.(string(subj(subj_count))).Common.Tibiotalar(m,:) = temp;
            m = m + 1;
        end
        n = n + 1;
    end
    subj_count = subj_count + 1;
end

%% Plotting the Common Points for Tibiotalar
if trouble_shoot >= 3
subj_count = 1;
while subj_count <= length(subj)
figure()
% ColorMapPlot3(cp(Data.(string(subj(subj_count))).Common.Tibiotalar(:,1),:),Data.(string(subj(subj_count))).Common.Tibiotalar(:,3));
ColorMapPlot3(cp(Data.(string(subj(subj_count))).Tibiotalar(:,1),:),Data.(string(subj(subj_count))).Tibiotalar(:,3));
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = strcat(string(subj(subj_count)),' Tibiotalar RMS');
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal

subj_count = subj_count + 1;
end
end

%% Tibiotalar Mean RMS
n = 1;
while n <= length(Compiled_Tibiotalar_CP_Unique(:,1))
    subj_count = 1;
    while subj_count <= length(subj)
        temp = find(Data.(string(subj(subj_count))).Tibiotalar(:,1) == Compiled_Tibiotalar_CP_Unique(n));
        if isempty(temp) == 0
            Repeat.Node.(strcat('CP_',string(Compiled_Tibiotalar_CP_Unique(n))))(subj_count,:) = Data.(string(subj(subj_count))).Tibiotalar(temp,3);
        end
        if isempty(temp) == 1
            Repeat.Node.(strcat('CP_',string(Compiled_Tibiotalar_CP_Unique(n))))(subj_count,:) = NaN;
        end            
        subj_count = subj_count + 1;
    end
    n = n + 1;
end

n = 1;
while n <= length(Compiled_Tibiotalar_CP_Unique(:,1))
    MeanRMSTibiotalar(n,:) = [Compiled_Tibiotalar_CP_Unique(n,1) mean(Repeat.Node.(strcat('CP_',string(Compiled_Tibiotalar_CP_Unique(n))))(~isnan(Repeat.Node.(strcat('CP_',string(Compiled_Tibiotalar_CP_Unique(n)))))))];
    n = n + 1;
end

if trouble_shoot >= 2
figure()
ColorMapPlot3(cp(MeanRMSTibiotalar(:,1),:),MeanRMSTibiotalar(:,2));
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

%% MEAN RMS (95%)
n = 1;
while n <= length(Repeat_TT(:,1))
    subj_count = 1;
    while subj_count <= length(subj)
        temp = find(Data.(string(subj(subj_count))).Tibiotalar(:,1) == Repeat_TT(n));
        if isempty(temp) == 0
            Repeat.Node.(strcat('CP_',string(Repeat_TT(n))))(subj_count,:) = Data.(string(subj(subj_count))).Tibiotalar(temp,3);
        end
        if isempty(temp) == 1
            Repeat.Node.(strcat('CP_',string(Repeat_TT(n))))(subj_count,:) = NaN;
        end            
        subj_count = subj_count + 1;
    end
    n = n + 1;
end

n = 1;
while n <= length(Repeat_TT(:,1))
    MeanRMSTibiotalar_95(n,:) = [Repeat_TT(n,1) mean(Repeat.Node.(strcat('CP_',string(Repeat_TT(n))))(~isnan(Repeat.Node.(strcat('CP_',string(Repeat_TT(n)))))))];
    n = n + 1;
end

if trouble_shoot >= 2
figure()
ColorMapPlot3(cp(MeanRMSTibiotalar_95(:,1),:),MeanRMSTibiotalar_95(:,2));
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = 'Mean Tibiotalar RMS (Common)';
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
end

%% MEAN DISTANCE (95%)
n = 1;
while n <= length(Repeat_TT(:,1))
    subj_count = 1;
    while subj_count <= length(subj)
        temp = find(Data.(string(subj(subj_count))).Tibiotalar(:,1) == Repeat_TT(n));
        if isempty(temp) == 0
            Repeat.Distance.(strcat('CP_',string(Repeat_TT(n))))(subj_count,:) = Data.(string(subj(subj_count))).Tibiotalar(temp,2);
        end
        if isempty(temp) == 1
            Repeat.Distance.(strcat('CP_',string(Repeat_TT(n))))(subj_count,:) = NaN;
        end            
        subj_count = subj_count + 1;
    end
    n = n + 1;
end

n = 1;
while n <= length(Repeat_TT(:,1))
    MeanDistTibiotalar_95(n,:) = [Repeat_TT(n,1) mean(Repeat.Distance.(strcat('CP_',string(Repeat_TT(n))))(~isnan(Repeat.Distance.(strcat('CP_',string(Repeat_TT(n)))))))];
    n = n + 1;
end

if trouble_shoot >= 2
figure()
ColorMapPlot3(cp(MeanDistTibiotalar_95(:,1),:),MeanDistTibiotalar_95(:,2),1);
hold on
plot3(cp(:,1),cp(:,2),cp(:,3),'kx')
colorbar
nameTitle = 'Mean Tibiotalar Distance (Common)';
title(nameTitle)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
end

%% COMBINED RMS and Distance
MeanRMS_95 = [MeanRMSTibiotalar_95(:,:)];

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

MeanDist_95 = [MeanDistTibiotalar_95(:,:)];

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
