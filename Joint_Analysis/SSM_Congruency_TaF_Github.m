%% Statitistical Shape Modeling Congruency for Talofibular Joint
% Created by: Rich Lisonbee
% Revised for Talofibular by: Andrew Peterson
% Last Updated: 11.5.20

% Run this script second, between Distance_Corrospondence and Common_Corrospondence
   
clear, clc, close all
subj_count = 1;
trouble_shoot = 1; % 1-off , 2-on (displays all plots), 3- loop to adjust tolerances (displays all plots)

%% Preparing Paths
% Cell array with each subject for accessing structures
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13','R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};
% Network location for loading excel data
excel_path = 'Nodal_Data_TaF_Github.xlsx';
%% Loop through for each subject
while subj_count <= length(subj)
    %% Loading Data
    clearvars -except subj subj_path excel_path subj_count trouble_shoot Data
    close all
    fprintf('Processing Subject %s \n',string((subj(subj_count))))

    % Loading excel data of specific subject's sheet
    excel_data = xlsread(excel_path,string(subj(subj_count)));
    
    % Save data in the structure via:
    % Data.(Side & Subject Number).Excel._____ = [Node Index #, Distance Value, CP Matched Index];
    Data.(string(subj(subj_count))).Excel.Talofibular = [excel_data(~isnan(excel_data(1:end,1)),1) excel_data(~isnan(excel_data(1:end,2)),2) excel_data(~isnan(excel_data(1:end,3)),3)];
    
    % Loads coordinates of the tibia, talus, and calcaneus in one large matrix
    Data.(string(subj(subj_count))).Nodes.All = LoadDataFile(string(strcat(subj(subj_count),'_Tibia_Fibula_Talus.k')));
    
    % Loads coordinates of each bone individually
    nodes_talus = LoadDataFile(string(strcat(subj(subj_count),'_Talus.k')));
    talus_start = find(Data.(string(subj(subj_count))).Nodes.All(:,1) == nodes_talus(1,1) & Data.(string(subj(subj_count))).Nodes.All(:,2) == nodes_talus(1,2) & Data.(string(subj(subj_count))).Nodes.All(:,3) == nodes_talus(1,3));
    talus_end = find(Data.(string(subj(subj_count))).Nodes.All(:,1) == nodes_talus(end,1));
    if length(talus_end) > 1
        talus_end = talus_end(end);
    end
    
    Data.(string(subj(subj_count))).Nodes.Talus = Data.(string(subj(subj_count))).Nodes.All(talus_start:talus_end,:);
    
    Data.(string(subj(subj_count))).Nodes.Fibula = LoadDataFile(string(strcat(subj(subj_count),'_Fibula.k')));
    
    %% Nodal Locations of the Talus Articulating Surfaces
    % Pulls the nodal locations for the talus from the matrix with all of the bone nodes
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular = Data.(string(subj(subj_count))).Nodes.All(Data.(string(subj(subj_count))).Excel.Talofibular(:,1),:);
    
    % Finds the index number for each node in the talus tibiotalar facet
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,1))
        Data.(string(subj(subj_count))).Index.TalusTalofibular(n,:) = find(Data.(string(subj(subj_count))).Nodes.Talus(:,1) == Data.(string(subj(subj_count))).Nodes.TalusTalofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Talus(:,2) == Data.(string(subj(subj_count))).Nodes.TalusTalofibular(n,2));
        n = n + 1;
    end

    %% Extracting Specific Node Data For Talus
    % Mean and Gaussian Curvature data from PostView
    Talus_MeanCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Talus_MeanCurvature.xplt')));
    Talus_GaussianCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Talus_GaussianCurvature.xplt')));
    
    Fibula_MeanCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Fibula_MeanCurvature.xplt')));
    Fibula_GaussianCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Fibula_GaussianCurvature.xplt')));
    
    % Saves the extracted data to a structure
    Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular = [Data.(string(subj(subj_count))).Index.TalusTalofibular Talus_MeanCurvature(Data.(string(subj(subj_count))).Index.TalusTalofibular,2)];
    Data.(string(subj(subj_count))).Curvature.GaussianTalusTalofibular = [Data.(string(subj(subj_count))).Index.TalusTalofibular Talus_GaussianCurvature(Data.(string(subj(subj_count))).Index.TalusTalofibular,2)];
    
    %% Load Tolerance .mat File
    Congruency = load('Congruency_Tolerances_TaF.mat');
    
    %% Loading Tolerances
    % Load tolerances from Distance_Correspondence Script (these were saved in
    % a different .mat file so that they could not be changed from that script
    % anymore)
    
    TxTaF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.X;
    TyTaF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Y;
    TzTaF = max(Data.(string(subj(subj_count))).Excel.Talofibular(:,2));
    
    %% Flip Orientation to XY for FindROI and FindNear
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,1) = Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,2);
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,2) = Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,3);
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,3) = Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,1);
    
    Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1) = Data.(string(subj(subj_count))).Nodes.Fibula(:,2);
    Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2) = Data.(string(subj(subj_count))).Nodes.Fibula(:,3);
    Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3) = Data.(string(subj(subj_count))).Nodes.Fibula(:,1);
    
    %% Locate Nodes from Fibula in Coverage of Articulating Surfaces
    % Determine talar nodes that are within the coverage of the fibula
    Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy = FindROI(Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy,Data.(string(subj(subj_count))).Nodes.Fibula_xy,'xy','max',TxTaF,TyTaF,TzTaF,1);
    
    if trouble_shoot >= 2
        % Red nodes are within the coverage and green are outside of the bounds
        figure()
        plot3(Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,1),Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,2),Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,3),'g*')
        hold on
        plot3(Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,3),'rx','linewidth',5)
        hold on
        plot3(Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3),'k.')
        title('Talus Talofibular Coverage')
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        view([0 90])
    end
    
    %% Modifying Tolerances to Increase or Decrease the Coverage Capture Regions
    % This section will only be ran if troubleshooting the tolerances
    % Used to change the scope of the coverage between the talus and the
    % fibula
    
    % The loop will repeat until the user selects 'Done'
    if trouble_shoot == 3
        MT = 1;
        while MT == 1
            ModTol = menu('Do you want to modify the talofibular tolerances?','Yes','No');
            
            if ModTol == 1
                xDirTaF = sprintf('X-Direction, previous value (%s)',string(TxTaF));
                yDirTaF = sprintf('Y-Direction, previous value (%s)',string(TyTaF));
                
                TolTaF = inputdlg({xDirTaF,yDirTaF},'Talofibular');
                Congruency.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.X = str2double(TolTaF(1));
                Congruency.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Y = str2double(TolTaF(2));
                fprintf('Talofibular tolerances modified for subject %s \n',string(subj(subj_count)))
            end
            
            TxTaF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.X;
            TyTaF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Y;
            TzTaF = max(Data.(string(subj(subj_count))).Excel.Talofibular(:,2));
            
            if ModTol ~= 1
                close all
            end
            
            % Clears current coverage to be replaced with new coverage
            Data.(string(subj(subj_count))).Coverage.TalusTalofibular = [];
            
            % Determines new coverage of the fibula with updated tolerances
            Data.(string(subj(subj_count))).Coverage.TalusTalofibular = FindROI(Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy,Data.(string(subj(subj_count))).Nodes.Fibula_xy,'xy','max',TxTaF,TyTaF,TzTaF,2);
            
            figure()
            plot3(Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,1),Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,2),Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,3),'g*')
            hold on
            plot3(Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,3),'rx','linewidth',5)
            hold on
            plot3(Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3),'k.')
            title('Talus Talofibular Coverage')
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            axis equal
            view([0 90])
            
            
            if ModTol == 2
                MT = 2;
                save('Congruency_Tolerances_TaF_new.mat','-struct','Congruency');
            end
        end
    end
    
    
    %% Select Fibula Nodes Matched with Talus
    Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy = FindNear(Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy,Data.(string(subj(subj_count))).Nodes.Fibula_xy,'XY',1.5,2);
    
    figure()
    plot3(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,3),'y*','linewidth',5)
    hold on
    plot3(Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3),'k.')
    hold on
    plot3(Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,3),'rx','linewidth',5)
    title('Fibula')
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
    
    % This was used a test so that the user could see if the number of Talar
    % nodes for each surface matched with number of Fibular nodes
    % Not very important for end user but was beneficial when troubleshooting
    fprintf('Talus Talofibular Nodes within range %.0f \n',length(Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,1)))
    fprintf('Fibula Talofibular Nodes selected %.0f \n \n',length(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,1)))
    
    %% Flip Orientation Back
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,2) = Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,1);
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,3) = Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,2);
    Data.(string(subj(subj_count))).Nodes.TalusTalofibular(:,1) = Data.(string(subj(subj_count))).Nodes.TalusTalofibular_xy(:,3);
    
    Data.(string(subj(subj_count))).Nodes.Fibula(:,2) = Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1);
    Data.(string(subj(subj_count))).Nodes.Fibula(:,3) = Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2);
    Data.(string(subj(subj_count))).Nodes.Fibula(:,1) = Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3);
    
    Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(:,2) = Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,1);
    Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(:,3) = Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,2);
    Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(:,1) = Data.(string(subj(subj_count))).Coverage.FibulaTalofibular_xy(:,3);
    
    Data.(string(subj(subj_count))).Coverage.TalusTalofibular(:,2) = Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,1);
    Data.(string(subj(subj_count))).Coverage.TalusTalofibular(:,3) = Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,2);
    Data.(string(subj(subj_count))).Coverage.TalusTalofibular(:,1) = Data.(string(subj(subj_count))).Coverage.TalusTalofibular_xy(:,3);

    %% Load Fibula Curvature Data
    % Locate the fibula indices within the coverage of the articulating surfaces
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(:,1))
        Data.(string(subj(subj_count))).Index.FibulaTalofibular(n,:) = find(Data.(string(subj(subj_count))).Nodes.Fibula(:,1) == Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Fibula(:,2) == Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(n,2));
        n = n + 1;
    end
    
    % Separates the curvature data from the postview nodal data
    Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular = [Data.(string(subj(subj_count))).Index.FibulaTalofibular Fibula_MeanCurvature(Data.(string(subj(subj_count))).Index.FibulaTalofibular,2)];
    Data.(string(subj(subj_count))).Curvature.GaussianFibularTalofibular = [Data.(string(subj(subj_count))).Index.FibulaTalofibular Fibula_GaussianCurvature(Data.(string(subj(subj_count))).Index.FibulaTalofibular,2)];
    
    %% Principal Curvatures - Talofibular
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TalusTalofibular(:,1))
        Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular(n,2) - sqrt(Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTalusTalofibular(n,2));
        Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular(n,2) + sqrt(Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTalusTalofibular(n,2));
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(:,1))
        Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular(n,2) - sqrt(Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianFibularTalofibular(n,2));
        Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular(n,2) + sqrt(Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianFibularTalofibular(n,2));
        n = n + 1;
    end
    
    if isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMinimum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMaximum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMinimum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMaximum) == 0
        error('The curvature surfaces are incorrect. Please export them again.')
    end
    
    %% Curvature Differences
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMinimum(:,1))
        Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(n,:) = Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMinimum(n,1) - Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTalofibularMaximum(n,1);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMinimum(:,1))
        Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTalofibular(n,:) = Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMinimum(n,1) - Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTalofibularMaximum(n,1);
        n = n + 1;
    end
    
    %% Relative Principal Curvatures
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(:,1))
        Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TalofibularMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular(n,2) + Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular(n,2) - 0.5*sqrt(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(n,1)^2 + Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTalofibular(n,1)^2 + 2*Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(n,1)*Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTalofibular(n,1)*1);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(:,1))
        Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TalofibularMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTalofibular(n,2) + Data.(string(subj(subj_count))).Curvature.MeanFibulaTalofibular(n,2) + 0.5*sqrt(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(n,1)^2 + Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTalofibular(n,1)^2 + 2*Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTalofibular(n,1)*Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTalofibular(n,1)*1);
        n = n + 1;
    end
    
    %% Overall Congruency Index at a Contact
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TalofibularMinimum(:,1))
        Data.(string(subj(subj_count))).RMS.Talofibular(n,:) = sqrt((Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TalofibularMinimum(n,1)^2 + Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TalofibularMaximum(n,1)^2)/2);
        n = n + 1;
    end
    
    %%
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TalusTalofibular(:,1))
        Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,:) = find(Data.(string(subj(subj_count))).Nodes.Talus(:,1) == Data.(string(subj(subj_count))).Coverage.TalusTalofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Talus(:,2) == Data.(string(subj(subj_count))).Coverage.TalusTalofibular(n,2));
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(:,1))
        Data.(string(subj(subj_count))).Index.FibulaTalofibularNew(n,:) = find(Data.(string(subj(subj_count))).Nodes.Fibula(:,1) == Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Fibula(:,2) == Data.(string(subj(subj_count))).Coverage.FibulaTalofibular(n,2));
        n = n + 1;
    end
    
    %% Match CP Data from Excel
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Index.TalusTalofibularNew(:,1))
        if length(Data.(string(subj(subj_count))).Excel.Talofibular(find(Data.(string(subj(subj_count))).Excel.Talofibular(:,1) == Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,1)+talus_start-1),3)) == 1
            Data.(string(subj(subj_count))).CP.TalusTalofibular(n,:) = Data.(string(subj(subj_count))).Excel.Talofibular(find(Data.(string(subj(subj_count))).Excel.Talofibular(:,1) == Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,1)+talus_start-1),3);
        else
            temp = Data.(string(subj(subj_count))).Excel.Talofibular(find(Data.(string(subj(subj_count))).Excel.Talofibular(:,1) == Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,1)+talus_start-1),3);
            Data.(string(subj(subj_count))).CP.TalusTalofibular(n,:) = temp(end,:);
        end
        
        n = n + 1;
    end
    
    %% Match Distance Data from Excel
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Index.TalusTalofibularNew(:,1))
        if length(Data.(string(subj(subj_count))).Excel.Talofibular(find(Data.(string(subj(subj_count))).Excel.Talofibular(:,1) == Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,1)+talus_start-1),3)) == 1
            Data.(string(subj(subj_count))).Distance.TalusTalofibular(n,:) = Data.(string(subj(subj_count))).Excel.Talofibular(find(Data.(string(subj(subj_count))).Excel.Talofibular(:,1) == Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,1)+talus_start-1),2);
        else
            temp = Data.(string(subj(subj_count))).Excel.Talofibular(find(Data.(string(subj(subj_count))).Excel.Talofibular(:,1) == Data.(string(subj(subj_count))).Index.TalusTalofibularNew(n,1)+talus_start-1),2);
            Data.(string(subj(subj_count))).Distance.TalusTalofibular(n,:) = temp(end,:);
        end
        
        n = n + 1;
    end
    
    %% Figures
    if trouble_shoot >= 2
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TalusTalofibular,Data.(string(subj(subj_count))).RMS.Talofibular)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Talus(:,1),Data.(string(subj(subj_count))).Nodes.Talus(:,2),Data.(string(subj(subj_count))).Nodes.Talus(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Talus Talofibular RMS');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular,Data.(string(subj(subj_count))).RMS.Talofibular)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Fibula(:,1),Data.(string(subj(subj_count))).Nodes.Fibula(:,2),Data.(string(subj(subj_count))).Nodes.Fibula(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Fibula Talofibular RMS');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TalusTalofibular,Data.(string(subj(subj_count))).Distance.TalusTalofibular,1)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Talus(:,1),Data.(string(subj(subj_count))).Nodes.Talus(:,2),Data.(string(subj(subj_count))).Nodes.Talus(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Talus Talofibular Distance');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.FibulaTalofibular,Data.(string(subj(subj_count))).Distance.TalusTalofibular,1)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Fibula(:,1),Data.(string(subj(subj_count))).Nodes.Fibula(:,2),Data.(string(subj(subj_count))).Nodes.Fibula(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Fibula Talofibular Distance');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
    end
    
    %% Min/Max/Mean check
    fprintf('Tibiotalar RMS \n')
    fprintf('Minimum RMS: %.4f \n',min(Data.(string(subj(subj_count))).RMS.Talofibular))
    fprintf('Maximum RMS: %.4f \n',max(Data.(string(subj(subj_count))).RMS.Talofibular))
    fprintf('Mean RMS:    %.4f \n',mean(Data.(string(subj(subj_count))).RMS.Talofibular))
    fprintf('\n')
    
    %% Save RMS Data
    if trouble_shoot >= 2
        passorgo = menu('Would you like to continue?','Yes (no save)','Yes (save data)','No (no save)','No (save data)','Repeat (no save');
    end
    
    if trouble_shoot == 1 || passorgo == 2 || passorgo == 4
        excel_path2 = 'Curvature_Data_TaF_Github.xlsx';
        xlswrite(excel_path2,{'Talofibular'},string(subj(subj_count)),'A1')
        xlswrite(excel_path2,{'Fibula Node'},string(subj(subj_count)),'A2')
        xlswrite(excel_path2,{'Talus Node'},string(subj(subj_count)),'B2')
        xlswrite(excel_path2,{'Talus CP'},string(subj(subj_count)),'C2')
        xlswrite(excel_path2,{'Distance'},string(subj(subj_count)),'D2')
        xlswrite(excel_path2,{'RMS'},string(subj(subj_count)),'E2')
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Index.FibulaTalofibularNew,string(subj(subj_count)),'A3') % Fibula Medial Facet Indices
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Index.TalusTalofibularNew,string(subj(subj_count)),'B3') % Talus Medial Facet Indices
        xlswrite(excel_path2,Data.(string(subj(subj_count))).CP.TalusTalofibular,string(subj(subj_count)),'C3') % Talus Medial Facet Correspondence Points
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Distance.TalusTalofibular,string(subj(subj_count)),'D3') % Talus Medial Facet Distances
        xlswrite(excel_path2,Data.(string(subj(subj_count))).RMS.Talofibular,string(subj(subj_count)),'E3') % Talus Medial RMS
    end
    
    %%
    if trouble_shoot == 1
        subj_count = subj_count + 1;
        close all
    end
    if trouble_shoot >= 2
        if passorgo == 1 || passorgo == 2
            subj_count = subj_count + 1;
            close all
        end
        if passorgo == 3 || passorgo == 4
            break
        end
        if passorgo == 5
            subj_count = subj_count;
        end
    end
end
fprintf('Congruency Calculations Complete! \n')





