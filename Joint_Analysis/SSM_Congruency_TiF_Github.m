%% Statitistical Shape Modeling Congruency for Tibiofibular Joint
% Created by: Rich Lisonbee
% Revised for Tibiofibular by: Andrew Peterson
% Last Updated: 11.5.20

% Run this script second, between Distance_Corrospondence and Common_Corrospondence
   
clear, clc, close all
subj_count = 1;
trouble_shoot = 1; % 1-off , 2-on (displays all plots), 3- loop to adjust tolerances (displays all plots)

%% Preparing Paths
% Cell array with each subject for accessing structures
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13','R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};
% Network location for loading excel data
excel_path = 'Nodal_Data_TiF_Github.xlsx';
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
    Data.(string(subj(subj_count))).Excel.Tibiofibular = [excel_data(~isnan(excel_data(1:end,1)),1) excel_data(~isnan(excel_data(1:end,2)),2) excel_data(~isnan(excel_data(1:end,3)),3)];
    
    % Loads coordinates of the tibia, talus, and calcaneus in one large matrix
    Data.(string(subj(subj_count))).Nodes.All = LoadDataFile(string(strcat(subj(subj_count),'_Tibia_Fibula_Talus.k')));
    
    % Loads coordinates of each bone individually
    nodes_tibia = LoadDataFile(string(strcat(subj(subj_count),'_Tibia.k')));
    tibia_start = find(Data.(string(subj(subj_count))).Nodes.All(:,1) == nodes_tibia(1,1) & Data.(string(subj(subj_count))).Nodes.All(:,2) == nodes_tibia(1,2) & Data.(string(subj(subj_count))).Nodes.All(:,3) == nodes_tibia(1,3));
    tibia_end = find(Data.(string(subj(subj_count))).Nodes.All(:,1) == nodes_tibia(end,1));
    if length(tibia_end) > 1
        tibia_end = tibia_end(end);
    end
    
    Data.(string(subj(subj_count))).Nodes.Tibia = Data.(string(subj(subj_count))).Nodes.All(tibia_start:tibia_end,:);
    
    Data.(string(subj(subj_count))).Nodes.Fibula = LoadDataFile(string(strcat(subj(subj_count),'_Fibula.k')));
    
    %% Nodal Locations of the Tibia Articulating Surfaces
    % Pulls the nodal locations for the tibia from the matrix with all of the bone nodes
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular = Data.(string(subj(subj_count))).Nodes.All(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1),:);
    
    % Finds the index number for each node in the tibia tibiofibular facet
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,1))
        Data.(string(subj(subj_count))).Index.TibiaTibiofibular(n,:) = find(Data.(string(subj(subj_count))).Nodes.Tibia(:,1) == Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Tibia(:,2) == Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(n,2));
        n = n + 1;
    end

    %% Extracting Specific Node Data For Tibia  
    % Mean and Gaussian Curvature data from PostView
    Tibia_MeanCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Tibia_MeanCurvature.xplt')));
    Tibia_GaussianCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Tibia_GaussianCurvature.xplt')));
    
    Fibula_MeanCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Fibula_MeanCurvature.xplt')));
    Fibula_GaussianCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Fibula_GaussianCurvature.xplt')));
    
    % Saves the extracted data to a structure
    Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular = [Data.(string(subj(subj_count))).Index.TibiaTibiofibular Tibia_MeanCurvature(Data.(string(subj(subj_count))).Index.TibiaTibiofibular,2)];
    Data.(string(subj(subj_count))).Curvature.GaussianTibiaTibiofibular = [Data.(string(subj(subj_count))).Index.TibiaTibiofibular Tibia_GaussianCurvature(Data.(string(subj(subj_count))).Index.TibiaTibiofibular,2)];
    
    %% Load Tolerance .mat File
    Congruency = load('Congruency_Tolerances_TiF.mat');
    
    %% Loading Tolerances
    % Load tolerances from Distance_Correspondence Script (these were saved in
    % a different .mat file so that they could not be changed from that script
    % anymore)
    
    TxTiF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.X;
    TyTiF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Y;
    TzTiF = max(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,2));
    
    %% Flip Orientation to XY for FindROI and FindNear
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,1) = Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,2);
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,2) = Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,3);
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,3) = Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,1);
    
    Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1) = Data.(string(subj(subj_count))).Nodes.Fibula(:,2);
    Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2) = Data.(string(subj(subj_count))).Nodes.Fibula(:,3);
    Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3) = Data.(string(subj(subj_count))).Nodes.Fibula(:,1);
    
    %% Locate Nodes from Fibula in Coverage of Articulating Surfaces
    % Determine talar nodes that are within the coverage of the fibula
    Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy = FindROI(Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy,Data.(string(subj(subj_count))).Nodes.Fibula_xy,'xy','max',TxTiF,TyTiF,TzTiF,1);
    
    if trouble_shoot >= 2
        % Red nodes are within the coverage and green are outside of the bounds
        figure()
        plot3(Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,1),Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,2),Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,3),'g*')
        hold on
        plot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,3),'rx','linewidth',5)
        hold on
        plot3(Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3),'k.')
        title('Tibia Tibiofibular Coverage')
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        view([0 90])
    end
    
    %% Modifying Tolerances to Increase or Decrease the Coverage Capture Regions
    % This section will only be ran if troubleshooting the tolerances
    % Used to change the scope of the coverage between the tibia and the fibula
    
    % The loop will repeat until the user selects 'Done'
    if trouble_shoot == 3
        MT = 1;
        while MT == 1
            ModTol = menu('Do you want to modify the tibiofibular tolerances?','Yes','No');
            
            if ModTol == 1
                xDirTiF = sprintf('X-Direction, previous value (%s)',string(TxTiF));
                yDirTiF = sprintf('Y-Direction, previous value (%s)',string(TyTiF));
                
                TolTiF = inputdlg({xDirTiF,yDirTiF},'Tibiofibular');
                Congruency.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.X = str2double(TolTiF(1));
                Congruency.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Y = str2double(TolTiF(2));
                fprintf('Tibiofibular tolerances modified for subject %s \n',string(subj(subj_count)))
            end
            
            TxTiF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.X;
            TyTiF = Congruency.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Y;
            TzTiF = max(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,2));
            
            if ModTol ~= 1
                close all
            end
            
            % Clears current coverage to be replaced with new coverage
            Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular = [];
            
            % Determines new coverage of the fibula with updated tolerances
            Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular = FindROI(Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy,Data.(string(subj(subj_count))).Nodes.Fibula_xy,'xy','max',TxTiF,TyTiF,TzTiF,2);
            
            figure()
            plot3(Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,1),Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,2),Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,3),'g*')
            hold on
            plot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,3),'rx','linewidth',5)
            hold on
            plot3(Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3),'k.')
            title('Tibia Tibiofibular Coverage')
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            axis equal
            view([0 90])
            
            
            if ModTol == 2
                MT = 2;
                save('Congruency_Tolerances_TiF.mat','-struct','Congruency');
            end
        end
    end
    
    
    %% Select Fibula Nodes Matched with Tibia
    Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy = FindNear(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy,Data.(string(subj(subj_count))).Nodes.Fibula_xy,'XY',1.5,2);
    
    figure()
    plot3(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,3),'y*','linewidth',5)
    hold on
    plot3(Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2),Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3),'k.')
    hold on
    plot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,1),Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,2),Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,3),'rx','linewidth',5)
    title('Fibula')
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
    
    % This was used a test so that the user could see if the number of Talar
    % nodes for each surface matched with number of Fibular nodes
    % Not very important for end user but was beneficial when troubleshooting
    fprintf('Tibia Tibiofibular Nodes within range %.0f \n',length(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,1)))
    fprintf('Fibula Tibiofibular Nodes selected %.0f \n \n',length(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,1)))
    
    %% Flip Orientation Back
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,2) = Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,1);
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,3) = Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,2);
    Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular(:,1) = Data.(string(subj(subj_count))).Nodes.TibiaTibiofibular_xy(:,3);
    
    Data.(string(subj(subj_count))).Nodes.Fibula(:,2) = Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,1);
    Data.(string(subj(subj_count))).Nodes.Fibula(:,3) = Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,2);
    Data.(string(subj(subj_count))).Nodes.Fibula(:,1) = Data.(string(subj(subj_count))).Nodes.Fibula_xy(:,3);
    
    Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(:,2) = Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,1);
    Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(:,3) = Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,2);
    Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(:,1) = Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular_xy(:,3);
    
    Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(:,2) = Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,1);
    Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(:,3) = Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,2);
    Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(:,1) = Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular_xy(:,3);

    %% Load Fibula Curvature Data
    % Locate the fibula indices within the coverage of the articulating surfaces
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(:,1))
        Data.(string(subj(subj_count))).Index.FibulaTibiofibular(n,:) = find(Data.(string(subj(subj_count))).Nodes.Fibula(:,1) == Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Fibula(:,2) == Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(n,2));
        n = n + 1;
    end
    
    % Separates the curvature data from the postview nodal data
    Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular = [Data.(string(subj(subj_count))).Index.FibulaTibiofibular Fibula_MeanCurvature(Data.(string(subj(subj_count))).Index.FibulaTibiofibular,2)];
    Data.(string(subj(subj_count))).Curvature.GaussianFibularTibiofibular = [Data.(string(subj(subj_count))).Index.FibulaTibiofibular Fibula_GaussianCurvature(Data.(string(subj(subj_count))).Index.FibulaTibiofibular,2)];
    
    %% Principal Curvatures - Tibiofibular
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(:,1))
        Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular(n,2) - sqrt(Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTibiaTibiofibular(n,2));
        Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular(n,2) + sqrt(Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTibiaTibiofibular(n,2));
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(:,1))
        Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular(n,2) - sqrt(Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianFibularTibiofibular(n,2));
        Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular(n,2) + sqrt(Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianFibularTibiofibular(n,2));
        n = n + 1;
    end
    
    if isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMinimum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMaximum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMinimum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMaximum) == 0
        error('The curvature surfaces are incorrect. Please export them again.')
    end
    
    %% Curvature Differences
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMinimum(:,1))
        Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(n,:) = Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMinimum(n,1) - Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiofibularMaximum(n,1);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMinimum(:,1))
        Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTibiofibular(n,:) = Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMinimum(n,1) - Data.(string(subj(subj_count))).PrincipalCurvatures.FibulaTibiofibularMaximum(n,1);
        n = n + 1;
    end
    
    %% Relative Principal Curvatures
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(:,1))
        Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiofibularMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular(n,2) + Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular(n,2) - 0.5*sqrt(Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(n,1)^2 + Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTibiofibular(n,1)^2 + 2*Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(n,1)*Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTibiofibular(n,1)*1);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(:,1))
        Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiofibularMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiofibular(n,2) + Data.(string(subj(subj_count))).Curvature.MeanFibulaTibiofibular(n,2) + 0.5*sqrt(Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(n,1)^2 + Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTibiofibular(n,1)^2 + 2*Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiofibular(n,1)*Data.(string(subj(subj_count))).DifferenceCurvatures.FibulaTibiofibular(n,1)*1);
        n = n + 1;
    end
    
    %% Overall Congruency Index at a Contact
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiofibularMinimum(:,1))
        Data.(string(subj(subj_count))).RMS.Tibiofibular(n,:) = sqrt((Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiofibularMinimum(n,1)^2 + Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiofibularMaximum(n,1)^2)/2);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(:,1))
        Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,:) = find(Data.(string(subj(subj_count))).Nodes.Tibia(:,1) == Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Tibia(:,2) == Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular(n,2));
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(:,1))
        Data.(string(subj(subj_count))).Index.FibulaTibiofibularNew(n,:) = find(Data.(string(subj(subj_count))).Nodes.Fibula(:,1) == Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(n,1) & Data.(string(subj(subj_count))).Nodes.Fibula(:,2) == Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular(n,2));
        n = n + 1;
    end
    
    %% Match CP Data from Excel
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(:,1))
        if length(Data.(string(subj(subj_count))).Excel.Tibiofibular(find(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1) == Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,1)+tibia_start-1),3)) == 1
            Data.(string(subj(subj_count))).CP.TibiaTibiofibular(n,:) = Data.(string(subj(subj_count))).Excel.Tibiofibular(find(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1) == Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,1)+tibia_start-1),3);
        else
            temp = Data.(string(subj(subj_count))).Excel.Tibiofibular(find(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1) == Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,1)+tibia_start-1),3);
            Data.(string(subj(subj_count))).CP.TibiaTibiofibular(n,:) = temp(end,:);
        end
        
        n = n + 1;
    end
    
    %% Match Distance Data from Excel
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(:,1))
        if length(Data.(string(subj(subj_count))).Excel.Tibiofibular(find(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1) == Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,1)+tibia_start-1),3)) == 1
            Data.(string(subj(subj_count))).Distance.TibiaTibiofibular(n,:) = Data.(string(subj(subj_count))).Excel.Tibiofibular(find(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1) == Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,1)+tibia_start-1),2);
        else
            temp = Data.(string(subj(subj_count))).Excel.Tibiofibular(find(Data.(string(subj(subj_count))).Excel.Tibiofibular(:,1) == Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew(n,1)+tibia_start-1),2);
            Data.(string(subj(subj_count))).Distance.TibiaTibiofibular(n,:) = temp(end,:);
        end
        
        n = n + 1;
    end
    
    
    %% Figures
    if trouble_shoot >= 2
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular,Data.(string(subj(subj_count))).RMS.Tibiofibular)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Tibia Tibiofibular RMS');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular,Data.(string(subj(subj_count))).RMS.Tibiofibular)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Fibula(:,1),Data.(string(subj(subj_count))).Nodes.Fibula(:,2),Data.(string(subj(subj_count))).Nodes.Fibula(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Fibula Tibiofibular RMS');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiofibular,Data.(string(subj(subj_count))).Distance.TibiaTibiofibular,1)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Tibia Tibiofibular Distance');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.FibulaTibiofibular,Data.(string(subj(subj_count))).Distance.TibiaTibiofibular,1)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Fibula(:,1),Data.(string(subj(subj_count))).Nodes.Fibula(:,2),Data.(string(subj(subj_count))).Nodes.Fibula(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Fibula Tibiofibular Distance');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
    end
    
      %% Min/Max/Mean check
    fprintf('Tibiofibular RMS \n')
    fprintf('Minimum RMS: %.4f \n',min(Data.(string(subj(subj_count))).RMS.Tibiofibular))
    fprintf('Maximum RMS: %.4f \n',max(Data.(string(subj(subj_count))).RMS.Tibiofibular))
    fprintf('Mean RMS:    %.4f \n',mean(Data.(string(subj(subj_count))).RMS.Tibiofibular))
    fprintf('\n')
    
    %% Save RMS Data
    if trouble_shoot >= 2
        passorgo = menu('Would you like to continue?','Yes (no save)','Yes (save data)','No (no save)','No (save data)','Repeat (no save');
    end
    
    if trouble_shoot == 1 || passorgo == 2 || passorgo == 4
        excel_path2 = 'Curvature_Data_TiF_Github.xlsx';
        xlswrite(excel_path2,{'Tibiofibular'},string(subj(subj_count)),'A1')
        xlswrite(excel_path2,{'Fibula Node'},string(subj(subj_count)),'A2')
        xlswrite(excel_path2,{'Tibia Node'},string(subj(subj_count)),'B2')
        xlswrite(excel_path2,{'Tibia CP'},string(subj(subj_count)),'C2')
        xlswrite(excel_path2,{'Distance'},string(subj(subj_count)),'D2')
        xlswrite(excel_path2,{'RMS'},string(subj(subj_count)),'E2')
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Index.FibulaTibiofibularNew,string(subj(subj_count)),'A3') % Fibula Tibiofibular Indices
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Index.TibiaTibiofibularNew,string(subj(subj_count)),'B3') % Tibia Tibiofibular Indices
        xlswrite(excel_path2,Data.(string(subj(subj_count))).CP.TibiaTibiofibular,string(subj(subj_count)),'C3') % Tibia Tibiofibular Correspondence Points
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Distance.TibiaTibiofibular,string(subj(subj_count)),'D3') % Tibia Tibiofibular Distances
        xlswrite(excel_path2,Data.(string(subj(subj_count))).RMS.Tibiofibular,string(subj(subj_count)),'E3') % Tibia Tibiofibular RMS
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





