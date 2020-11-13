%% Statitistical Shape Modeling Congruency for Tibiotalar Joint
% Created by: Rich Lisonbee
% Revised for Tibiotalar by: Andrew Peterson
% Last Updated: 11.2.20

% Run this script second, after Distance_Corrospondence and before Common_Corrospondence

clear, clc, close all
subj_count = 1;
trouble_shoot = 1; % 1-off , 2-on (displays all plots), 3- loop to adjust tolerances (displays all plots)

%% Preparing Paths
% Cell array with each subject for accessing structures
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13','R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};
% Network location for loading excel data
excel_path = 'Nodal_Data_TT_Github.xlsx';
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
    Data.(string(subj(subj_count))).Excel.Tibiotalar = [excel_data(~isnan(excel_data(1:end,1)),1) excel_data(~isnan(excel_data(1:end,2)),2) excel_data(~isnan(excel_data(1:end,3)),3)];
    
    % Loads coordinates of the tibia, talus, and calcaneus in one large matrix
    Data.(string(subj(subj_count))).Nodes.All = LoadDataFile(string(strcat(subj(subj_count),'_Tibia_Talus_Calcaneus.k')));
    
    % Loads coordinates of each bone individually
    nodes_talus = LoadDataFile(string(strcat(subj(subj_count),'_Talus.k')));
    talus_start = find(Data.(string(subj(subj_count))).Nodes.All(:,1) == nodes_talus(1,1) & Data.(string(subj(subj_count))).Nodes.All(:,2) == nodes_talus(1,2) & Data.(string(subj(subj_count))).Nodes.All(:,3) == nodes_talus(1,3));
    talus_end = find(Data.(string(subj(subj_count))).Nodes.All(:,1) == nodes_talus(end,1));
    if length(talus_end) > 1
        talus_end = talus_end(end);
    end
    
    Data.(string(subj(subj_count))).Nodes.Talus = Data.(string(subj(subj_count))).Nodes.All(talus_start:talus_end,:);
    
    Data.(string(subj(subj_count))).Nodes.Tibia = LoadDataFile(string(strcat(subj(subj_count),'_Tibia.k')));
    
    %% Nodal Locations of the Talus Articulating Surfaces
    % Pulls the nodal locations for the talar dome from the matrix with all of the bone nodes
    Data.(string(subj(subj_count))).Nodes.TalusTibiotalar = Data.(string(subj(subj_count))).Nodes.All(Data.(string(subj(subj_count))).Excel.Tibiotalar(:,1),:);
    
    % Finds the index number for each node in the talus tibiotalar facet
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,1))
        Data.(string(subj(subj_count))).Index.TalusTibiotalar(n,:) = find(Data.(string(subj(subj_count))).Nodes.Talus(:,1) == Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(n,1) & Data.(string(subj(subj_count))).Nodes.Talus(:,2) == Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(n,2));
        n = n + 1;
    end

    %% Extracting Specific Node Data For Talus
    % Mean and Gaussian Curvature data from PostView
    Talus_MeanCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Talus_MeanCurvature.xplt')));
    Talus_GaussianCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Talus_GaussianCurvature.xplt')));
    
    Tibia_MeanCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Tibia_MeanCurvature.xplt')));
    Tibia_GaussianCurvature = LoadDataFile(char(strcat(subj(subj_count),'_Tibia_GaussianCurvature.xplt')));
    
    % Saves the extracted data to a structure
    Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar = [Data.(string(subj(subj_count))).Index.TalusTibiotalar Talus_MeanCurvature(Data.(string(subj(subj_count))).Index.TalusTibiotalar,2)];
    Data.(string(subj(subj_count))).Curvature.GaussianTalusTibiotalar = [Data.(string(subj(subj_count))).Index.TalusTibiotalar Talus_GaussianCurvature(Data.(string(subj(subj_count))).Index.TalusTibiotalar,2)];
    
    %% Load Tolerance .mat File
    Congruency = load('Congruency_Tolerances_TT.mat');
    
    %% Loading Tolerances
    % Load tolerances from Distance_Correspondence Script (these were saved in
    % a different .mat file so that they could not be changed from that script
    % anymore)
    
    TxTT = Congruency.Tolerances.(char(subj(subj_count))).Talus.Tibiotalar.X;
    TyTT = Congruency.Tolerances.(char(subj(subj_count))).Talus.Tibiotalar.Y;
    TzTT = max(Data.(string(subj(subj_count))).Excel.Tibiotalar(:,2));
    
    %% Locate Nodes from Tibia in Coverage of Articulating Surfaces
    % Determine talar nodes that are within the coverage of the tibial plafond
    Data.(string(subj(subj_count))).Coverage.TalusTibiotalar = FindROI(Data.(string(subj(subj_count))).Nodes.TalusTibiotalar,Data.(string(subj(subj_count))).Nodes.Tibia,'xy','max',TxTT,TyTT,TzTT,2);
    
    if trouble_shoot >= 2
        % Red nodes are within the coverage and green are outside of the bounds
        figure()
        plot3(Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,1),Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,2),Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,3),'g*')
        hold on
        plot3(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,1),Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,2),Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,3),'rx','linewidth',5)
        hold on
        plot3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),'k.')
        title('Talus Tibiotalar Coverage')
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        view([0 90])
    end
    
    %% Modifying Tolerances to Increase or Decrease the Coverage Capture Regions
    % This section will only be ran if troubleshooting the tolerances
    % Used to change the scope of the coverage between the talus and the
    % tibia
    
    % The loop will repeat until the user selects 'Done'
    if trouble_shoot == 3
        MT = 1;
        while MT == 1
            ModTol = menu('Do you want to modify the tibiotalar tolerances?','Yes','No');
            
            if ModTol == 1
                xDirTT = sprintf('X-Direction, previous value (%s)',string(TxTT));
                yDirTT = sprintf('Y-Direction, previous value (%s)',string(TyTT));
                
                TolTT = inputdlg({xDirTT,yDirTT},'Tibiotalar');
                Congruency.Tolerances.(char(subj(subj_count))).Talus.Tibiotalar.X = str2double(TolTT(1));
                Congruency.Tolerances.(char(subj(subj_count))).Talus.Tibiotalar.Y = str2double(TolTT(2));
                fprintf('Tibiotalar tolerances modified for subject %s \n',string(subj(subj_count)))
            end
            
            TxTT = Congruency.Tolerances.(char(subj(subj_count))).Talus.Tibiotalar.X;
            TyTT = Congruency.Tolerances.(char(subj(subj_count))).Talus.Tibiotalar.Y;
            TzTT = max(Data.(string(subj(subj_count))).Excel.Tibiotalar(:,2));
            
            if ModTol ~= 1
                close all
            end
            
            % Clears current coverage to be replaced with new coverage
            Data.(string(subj(subj_count))).Coverage.TalusTibiotalar = [];
            
            % Determines new coverage of the tibial plafond with updated tolerances
            Data.(string(subj(subj_count))).Coverage.TalusTibiotalar = FindROI(Data.(string(subj(subj_count))).Nodes.TalusTibiotalar,Data.(string(subj(subj_count))).Nodes.Tibia,'xy','max',TxTT,TyTT,TzTT,2);
            
            figure()
            plot3(Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,1),Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,2),Data.(string(subj(subj_count))).Nodes.TalusTibiotalar(:,3),'g*')
            hold on
            plot3(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,1),Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,2),Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,3),'rx','linewidth',5)
            hold on
            plot3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),'k.')
            title('Talus Tibiotalar Coverage')
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            axis equal
            view([0 90])
            
            
            if ModTol == 2
                MT = 2;
                save('Congruency_Tolerances_TT.mat','-struct','Congruency');
            end
        end
    end
    
    
    %% Select Tibia Nodes Matched with Talus
    Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar = FindNear(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar,Data.(string(subj(subj_count))).Nodes.Tibia,'XY',1,2);
    
    figure()
    plot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,1),Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,2),Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,3),'y*','linewidth',5)
    hold on
    plot3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),'k.')
    hold on
    plot3(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,1),Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,2),Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,3),'rx','linewidth',5)
    title('Tibia')
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
    
    % This was used a test so that the user could see if the number of Talar
    % nodes for each surface matched with number of Calcaneus nodes
    % Not very important for end user but was beneficial when troubleshooting
    fprintf('Talus Tibiotalar Nodes within range %.0f \n',length(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,1)))
    fprintf('Tibia Tibiotalar Nodes selected %.0f \n \n',length(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,1)))
    
    %% Load Tibia Curvature Data
    % Locate the tibia indices within the coverage of the articulating surfaces
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,1))
        Data.(string(subj(subj_count))).Index.TibiaTibiotalar(n,:) = find(Data.(string(subj(subj_count))).Nodes.Tibia(:,1) == Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(n,1) & Data.(string(subj(subj_count))).Nodes.Tibia(:,2) == Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(n,2));
        n = n + 1;
    end
    
    % Separates the curvature data from the postview nodal data
    Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar = [Data.(string(subj(subj_count))).Index.TibiaTibiotalar Tibia_MeanCurvature(Data.(string(subj(subj_count))).Index.TibiaTibiotalar,2)];
    Data.(string(subj(subj_count))).Curvature.GaussianTibiaTibiotalar = [Data.(string(subj(subj_count))).Index.TibiaTibiotalar Tibia_GaussianCurvature(Data.(string(subj(subj_count))).Index.TibiaTibiotalar,2)];
    
    %% Principal Curvatures - Tibiotalar
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,1))
        Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar(n,2) - sqrt(Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTalusTibiotalar(n,2));
        Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar(n,2) + sqrt(Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTalusTibiotalar(n,2));
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,1))
        Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar(n,2) - sqrt(Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTibiaTibiotalar(n,2));
        Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar(n,2) + sqrt(Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar(n,2)^2 - Data.(string(subj(subj_count))).Curvature.GaussianTibiaTibiotalar(n,2));
        n = n + 1;
    end
    
    if isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMinimum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMaximum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMinimum) == 0 || isreal(Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMaximum) == 0
        error('The curvature surfaces are incorrect. Please export them again.')
    end
    
    %% Curvature Differences
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMinimum(:,1))
        Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(n,:) = Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMinimum(n,1) - Data.(string(subj(subj_count))).PrincipalCurvatures.TalusTibiotalarMaximum(n,1);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMinimum(:,1))
        Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiotalar(n,:) = Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMinimum(n,1) - Data.(string(subj(subj_count))).PrincipalCurvatures.TibiaTibiotalarMaximum(n,1);
        n = n + 1;
    end
    
    %% Relative Principal Curvatures
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(:,1))
        Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiotalarMinimum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar(n,2) + Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar(n,2) - 0.5*sqrt(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(n,1)^2 + Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiotalar(n,1)^2 + 2*Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(n,1)*Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiotalar(n,1)*1);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(:,1))
        Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiotalarMaximum(n,:) = Data.(string(subj(subj_count))).Curvature.MeanTalusTibiotalar(n,2) + Data.(string(subj(subj_count))).Curvature.MeanTibiaTibiotalar(n,2) + 0.5*sqrt(Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(n,1)^2 + Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiotalar(n,1)^2 + 2*Data.(string(subj(subj_count))).DifferenceCurvatures.TalusTibiotalar(n,1)*Data.(string(subj(subj_count))).DifferenceCurvatures.TibiaTibiotalar(n,1)*1);
        n = n + 1;
    end
    
    %% Overall Congruency Index at a Contact
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiotalarMinimum(:,1))
        Data.(string(subj(subj_count))).RMS.Tibiotalar(n,:) = sqrt((Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiotalarMinimum(n,1)^2 + Data.(string(subj(subj_count))).RelativePrincipalCurvatures.TibiotalarMaximum(n,1)^2)/2);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(:,1))
        Data.(string(subj(subj_count))).Index.TalusTibiotalarNew(n,:) = find(Data.(string(subj(subj_count))).Nodes.Talus(:,1) == Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(n,1) & Data.(string(subj(subj_count))).Nodes.Talus(:,2) == Data.(string(subj(subj_count))).Coverage.TalusTibiotalar(n,2));
        n = n + 1;
    end
    
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(:,1))
        Data.(string(subj(subj_count))).Index.TibiaTibiotalarNew(n,:) = find(Data.(string(subj(subj_count))).Nodes.Tibia(:,1) == Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(n,1) & Data.(string(subj(subj_count))).Nodes.Tibia(:,2) == Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar(n,2));
        n = n + 1;
    end
    
    %% Match CP Data from Excel
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Index.TalusTibiotalarNew(:,1))
        Data.(string(subj(subj_count))).CP.TalusTibiotalar(n,:) = Data.(string(subj(subj_count))).Excel.Tibiotalar(find(Data.(string(subj(subj_count))).Excel.Tibiotalar(:,1) == Data.(string(subj(subj_count))).Index.TalusTibiotalarNew(n,1)+talus_start-1),3);
        n = n + 1;
    end
    
    %% Match Distance Data from Excel
    n = 1;
    while n <= length(Data.(string(subj(subj_count))).Index.TalusTibiotalarNew(:,1))
        Data.(string(subj(subj_count))).Distance.TalusTibiotalar(n,:) = Data.(string(subj(subj_count))).Excel.Tibiotalar(find(Data.(string(subj(subj_count))).Excel.Tibiotalar(:,1) == Data.(string(subj(subj_count))).Index.TalusTibiotalarNew(n,1)+talus_start-1),2);
        n = n + 1;
    end
    
    %% Figures
    if trouble_shoot >= 2
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar,Data.(string(subj(subj_count))).RMS.Tibiotalar)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Talus(:,1),Data.(string(subj(subj_count))).Nodes.Talus(:,2),Data.(string(subj(subj_count))).Nodes.Talus(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Talus Tibiotalar RMS');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar,Data.(string(subj(subj_count))).RMS.Tibiotalar)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Tibia Tibiotalar RMS');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TalusTibiotalar,Data.(string(subj(subj_count))).Distance.TalusTibiotalar,1)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Talus(:,1),Data.(string(subj(subj_count))).Nodes.Talus(:,2),Data.(string(subj(subj_count))).Nodes.Talus(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Talus Tibiotalar Distance');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
        
        figure()
        ColorMapPlot3(Data.(string(subj(subj_count))).Coverage.TibiaTibiotalar,Data.(string(subj(subj_count))).Distance.TalusTibiotalar,1)
        hold on
        scatter3(Data.(string(subj(subj_count))).Nodes.Tibia(:,1),Data.(string(subj(subj_count))).Nodes.Tibia(:,2),Data.(string(subj(subj_count))).Nodes.Tibia(:,3),10,[0.5 0.5 0.5],'filled')
        colorbar
        nameTitle = strcat(string(subj(subj_count)),' Tibia Tibiotalar Distance');
        title(nameTitle)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        axis equal
    end

    %% Min/Max/Mean check
    fprintf('Tibiotalar RMS \n')
    fprintf('Minimum RMS: %.4f \n',min(Data.(string(subj(subj_count))).RMS.Tibiotalar))
    fprintf('Maximum RMS: %.4f \n',max(Data.(string(subj(subj_count))).RMS.Tibiotalar))
    fprintf('Mean RMS:    %.4f \n',mean(Data.(string(subj(subj_count))).RMS.Tibiotalar))
    fprintf('\n')
    
    %% Save RMS Data
    if trouble_shoot >= 2
        passorgo = menu('Would you like to continue?','Yes (no save)','Yes (save data)','No (no save)','No (save data)','Repeat (no save');
    end
    
    if trouble_shoot == 1 || passorgo == 2 || passorgo == 4
        excel_path2 = 'Curvature_Data_TT_Github.xlsx';
        xlswrite(excel_path2,{'Tibiotalar'},string(subj(subj_count)),'A1')
        xlswrite(excel_path2,{'Tibia Node'},string(subj(subj_count)),'A2')
        xlswrite(excel_path2,{'Talus Node'},string(subj(subj_count)),'B2')
        xlswrite(excel_path2,{'Talus CP'},string(subj(subj_count)),'C2')
        xlswrite(excel_path2,{'Distance'},string(subj(subj_count)),'D2')
        xlswrite(excel_path2,{'RMS'},string(subj(subj_count)),'E2')
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Index.TibiaTibiotalarNew,string(subj(subj_count)),'A3') % Calcaneus Medial Facet Indices
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Index.TalusTibiotalarNew,string(subj(subj_count)),'B3') % Talus Medial Facet Indices
        xlswrite(excel_path2,Data.(string(subj(subj_count))).CP.TalusTibiotalar,string(subj(subj_count)),'C3') % Talus Medial Facet Correspondence Points
        xlswrite(excel_path2,Data.(string(subj(subj_count))).Distance.TalusTibiotalar,string(subj(subj_count)),'D3') % Talus Medial Facet Distances
        xlswrite(excel_path2,Data.(string(subj(subj_count))).RMS.Tibiotalar,string(subj(subj_count)),'E3') % Talus Medial RMS
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





