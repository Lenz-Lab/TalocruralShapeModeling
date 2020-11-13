%% Corrospondence Points Distance Talofibular Joint based on Talus
% Created by: Rich Lisonbee
% Revised for Talofibular by: Andrew Peterson
% Created: 6.6.19
% Last Updated: 11.4.20

% Run this script first, before SSM_Congruency and Common_Corrospondence

clear,clc, close all

trouble_shoot = 1; % 1-off, 2-on (displays plots), 3- loop to adjust tolerances (displays plots)
subj_count = 1;

%% Preparing paths
% Subject side and number
subj = {'L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11','L12','L13',...
    'R01','R02','R03','R04','R05','R06','R07','R08','R09','R10','R11','R12','R13','R14'};

%% Start of Loops
while subj_count <= length(subj)
    % clear variables that are repeatedly used for each iteration   
    clearvars -except subj subj_path trouble_shoot file_path subj_count
    close all
    Continue = [];
    
    %% Load Tolerance .mat File
    % These were create manually and upadated using this script
    Distance = load('Joint_Space_Tolerances.mat');
    
    %% Identify Surfaces of Interest and Distance Data
    FileNameAll = strcat(subj,'_Tibia_Fibula_Talus.k');
    
    FileNameTalofibularNodal = strcat(subj,'_Talofibular_Nodal.xplt');
    FileNameTalofibularSpace = strcat(subj,'_Talofibular_Space.xplt');
    
    fprintf('Processing Subject %s \n',string((subj(subj_count))))
    
    %% Loading Talofibular Coverage and Joint Space
    talofibular_coverage = LoadDataFile(string(FileNameTalofibularNodal(subj_count)));
    talofibular_space = LoadDataFile(string(FileNameTalofibularSpace(subj_count)));
    
    %% Loading All Nodes
    nodes_all = LoadKFile(string(FileNameAll(subj_count)));
    
    %% Loading Talus
    File_Talus = strcat(subj(subj_count),'_Talus.k');
    nodes_talus = LoadKFile(char(strcat(File_Talus)));
    
    %% Loading Fibula
    File_Fibula = strcat(subj(subj_count),'_Fibula.k');
    nodes_fibula = LoadKFile(char(strcat(File_Fibula)));
    
    %% Loading Tolerances
    TxTalfib = Distance.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.X;
    TyTalfib = Distance.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Y;
    TzTalfib = Distance.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Z;
    
    %% Cross Registration Between Individual Bones and All Bones
    
    talus_start = find(nodes_all(:,:) == nodes_talus(1,1));
    if sum(sum(nodes_all(:,:) == nodes_talus(1,1),2)) > 1
        talus_start = talus_start(end,:);
    end
    
    talus_end = find(nodes_all(:,:) == nodes_talus(end,1));
    if sum(sum(nodes_all(:,:) == nodes_talus(end,1),2)) > 1
        talus_end = talus_end(end,:);
    end
    
    fibula_start = find(nodes_all(:,:) == nodes_fibula(1,1));
    if sum(sum(nodes_all(:,:) == nodes_fibula(1,1),2)) > 1
        fibula_start = fibula_start(end,:);
    end
    
    fibula_end = find(nodes_all(:,:) == nodes_fibula(end,1));
    if sum(sum(nodes_all(:,:) == nodes_fibula(end,1),2)) > 1
        fibula_end = fibula_end(end,:);
    end
    
    talus_nonzero_talofibular = nodes_talus(find(talofibular_coverage(talus_start:talus_end,2) > 0),:);
    
    if trouble_shoot >= 2
        figure()
        plot3(talus_nonzero_talofibular(:,1),talus_nonzero_talofibular(:,2),talus_nonzero_talofibular(:,3),'g.')
        hold on
        plot3(nodes_all(talus_start:talus_end,1),nodes_all(talus_start:talus_end,2),nodes_all(talus_start:talus_end,3),'k.')
        axis equal
    end
    
    %% Flip Lefts to Rights
    if subj_count <= 13
        nodes_all = nodes_all.*[-1,1,1];
        nodes_talus = nodes_talus.*[-1,1,1];
        talus_nonzero_talofibular = talus_nonzero_talofibular.*[-1,1,1];
    end
    %% Mid points of correspondance particles
    % This section finds the mid point of the correspondance particles in the
    % x, y, and z direction.
    
    cp = load('talus.mean.pts'); % load in the correspondance particles
    
    x_cp = cp(:,1);
    max_x_cp = max(x_cp);
    min_x_cp = min(x_cp);
    mid_x_cp = (max_x_cp + min_x_cp)./2; % find the mid point of the cp is the x direction
    
    y_cp = cp(:,2);
    max_y_cp = max(y_cp);
    min_y_cp = min(y_cp);
    mid_y_cp = (max_y_cp + min_y_cp)./2; % find the mid point of the cp is the x direction
    
    z_cp = cp(:,3);
    max_z_cp = max(z_cp);
    min_z_cp = min(z_cp);
    mid_z_cp = (max_z_cp + min_z_cp)./2; % find the mid point of the cp is the x direction
    
    %% Mid points and shifting of nodal points
    % This section finds the midpoint of the nodal points and shifts it to
    % match the midpoint of the coorespondance particles in the x, y and z
    % direction.
    
    talus_X = nodes_all(talus_start:talus_end,1);
    talus_X_max = max(talus_X);
    talus_X_min = min(talus_X);
    talus_X_mid = (talus_X_max + talus_X_min)./2; % find the mid point of the nodal points in the x direction
    talus_X_diff = mid_x_cp - talus_X_mid; % how much you need to shift to get from starting place to cp
    talus_X_shift = talus_X + talus_X_diff; % add the difference to shift to cp
    
    talus_Y = nodes_all(talus_start:talus_end,2);
    talus_Y_max = max(talus_Y);
    talus_Y_min = min(talus_Y);
    talus_Y_mid = (talus_Y_max + talus_Y_min)./2; % find the mid point of the nodal points in the y direction
    talus_Y_diff = mid_y_cp - talus_Y_mid; % how much you need to shift to get from starting place to cp
    talus_Y_shift = talus_Y + talus_Y_diff; % add the difference to shift to cp
    
    talus_Z = nodes_all(talus_start:talus_end,3);
    talus_Z_max = max(talus_Z);
    talus_Z_min = min(talus_Z);
    talus_Z_mid = (talus_Z_max + talus_Z_min)./2; % find the mid point of the nodal points in the x direction
    talus_Z_diff = mid_z_cp - talus_Z_mid; % how much you need to shift to get from starting place to cp
    talus_Z_shift = talus_Z + talus_Z_diff; % add the difference to shift to cp
    
    talus_translated = [talus_X_shift, talus_Y_shift, talus_Z_shift]; % define new matrix based on the shifted nodes
    
    talus_talofibular_translated = [talus_nonzero_talofibular(:,1)+talus_X_diff, talus_nonzero_talofibular(:,2)+talus_Y_diff, talus_nonzero_talofibular(:,3)+talus_Z_diff];
    
    nodes_all_translated = [nodes_all(:,1)+talus_X_diff,nodes_all(:,2)+talus_Y_diff,nodes_all(:,3)+talus_Z_diff];
    nodes_talus_translated = [nodes_talus(:,1)+talus_X_diff,nodes_talus(:,2)+talus_Y_diff,nodes_talus(:,3)+talus_Z_diff];
    
    if trouble_shoot >= 2
        figure()
        hold on
        plot3(talus_translated(:,1), talus_translated(:,2), talus_translated(:,3), 'k.')
        hold on
        plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
        plot3(talus_talofibular_translated(:,1),talus_talofibular_translated(:,2),talus_talofibular_translated(:,3),'b.')
        hold on
        plot3(nodes_all_translated(:,1),nodes_all_translated(:,2),nodes_all_translated(:,3),'k.')
        xlabel('x')
        ylabel('y')
        zlabel('z')
        axis equal
    end
    
    %% Align the Individual Nodes with the Correspondence Particles
    % Not all individuals needed to be rotated and recentered the same
    % amount.
    if subj_count ~= 1
        %% Rotation 1
        if trouble_shoot >= 2
            figure()
            hold on
            plot3(talus_translated(:,1), talus_translated(:,2), talus_translated(:,3), 'k.')
            hold on
            plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
            xlabel('x')
            ylabel('y')
            zlabel('z')
            axis equal
            view(3), view([0,90])
        end
        l = 3;
        u = nodes_talus_translated(find(nodes_talus_translated(:,l) == min(nodes_talus_translated(:,l))),:);
        v = cp(find(cp(:,l) == min(cp(:,l))),:);
        
        CosTheta = dot(u,v)/(norm(u)*norm(v));
        
        if subj_count == 9 || subj_count == 13 || subj_count == 22
            if nodes_talus_translated(find(nodes_talus_translated(:,l) == min(nodes_talus_translated(:,l))),1) < cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = -acosd(CosTheta);
            end
            
            if nodes_talus_translated(find(nodes_talus_translated(:,l) == min(nodes_talus_translated(:,l))),1) > cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = acosd(CosTheta);
            end
        else
            if nodes_talus_translated(find(nodes_talus_translated(:,l) == min(nodes_talus_translated(:,l))),1) < cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = acosd(CosTheta);
            end
            
            if nodes_talus_translated(find(nodes_talus_translated(:,l) == min(nodes_talus_translated(:,l))),1) > cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = -acosd(CosTheta);
            end
        end
        
        Rz = [cosd(tz) -sind(tz) 0;sind(tz) cosd(tz) 0;0 0 1]; % rotate about Z axis
        
        
        nodes_talus_translated_rot = (Rz*nodes_talus_translated')';
        talus_talofibular_translated = (Rz*talus_talofibular_translated')';
        
        
        if trouble_shoot >= 2
            figure()
            plot3(nodes_talus_translated_rot(:,1),nodes_talus_translated_rot(:,2),nodes_talus_translated_rot(:,3),'b.')
            hold on
            plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
            axis equal
            view(3), view([0,90])
        end
        
        %% Recenter 1
        nodes_talus_translated_rot_X = nodes_talus_translated_rot(:,1);
        nodes_talus_translated_rot_X_max = max(nodes_talus_translated_rot_X);
        nodes_talus_translated_rot_min = min(nodes_talus_translated_rot_X);
        nodes_talus_translated_rot_X_mid = (nodes_talus_translated_rot_X_max + nodes_talus_translated_rot_min)./2; % find the mid point of the nodal points in the x direction
        nodes_talus_translated_rot_X_diff = mid_x_cp - nodes_talus_translated_rot_X_mid; % how much you need to shift to get from starting place to cp
        nodes_talus_translated_rot_X_shift = nodes_talus_translated_rot_X + nodes_talus_translated_rot_X_diff; % add the difference to shift to cp
        
        nodes_talus_translated_rot_Y = nodes_talus_translated_rot(:,2);
        nodes_talus_translated_rot_Y_max = max(nodes_talus_translated_rot_Y);
        nodes_talus_translated_rot_Y_min = min(nodes_talus_translated_rot_Y);
        nodes_talus_translated_rot_Y_mid = (nodes_talus_translated_rot_Y_max + nodes_talus_translated_rot_Y_min)./2; % find the mid point of the nodal points in the y direction
        nodes_talus_translated_rot_Y_diff = mid_y_cp - nodes_talus_translated_rot_Y_mid; % how much you need to shift to get from starting place to cp
        nodes_talus_translated_rot_Y_shift = nodes_talus_translated_rot_Y + nodes_talus_translated_rot_Y_diff; % add the difference to shift to cp
        
        nodes_talus_translated_rot = [nodes_talus_translated_rot(:,1) + nodes_talus_translated_rot_X_diff,nodes_talus_translated_rot(:,2) + nodes_talus_translated_rot_Y_diff,nodes_talus_translated_rot(:,3)];
        talus_talofibular_translated = [talus_talofibular_translated(:,1) + nodes_talus_translated_rot_X_diff,talus_talofibular_translated(:,2) + nodes_talus_translated_rot_Y_diff,talus_talofibular_translated(:,3)];
        
        if trouble_shoot >= 2
            figure()
            plot3(nodes_talus_translated_rot(:,1),nodes_talus_translated_rot(:,2),nodes_talus_translated_rot(:,3),'b.')
            hold on
            plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
            axis equal
            view(3), view([0,90])
        end
        
        %% Rotation 2
        if subj_count ~= 4 && subj_count ~= 6 && subj_count ~= 9 && subj_count ~= 11 && subj_count ~= 15 && subj_count ~= 19 && subj_count ~= 23 && subj_count ~= 24 && subj_count ~= 25 && subj_count ~= 27
            u = nodes_talus_translated_rot(find(nodes_talus_translated_rot(:,l) == min(nodes_talus_translated_rot(:,l))),:);
            v = cp(find(cp(:,l) == min(cp(:,l))),:);
            
            CosTheta = dot(u,v)/(norm(u)*norm(v));
            if nodes_talus_translated_rot(find(nodes_talus_translated_rot(:,l) == min(nodes_talus_translated_rot(:,l))),1) < cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = acosd(CosTheta);
            end
            
            if nodes_talus_translated_rot(find(nodes_talus_translated_rot(:,l) == min(nodes_talus_translated_rot(:,l))),1) > cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = -acosd(CosTheta);
            end
            
            Rz = [cosd(tz) -sind(tz) 0;sind(tz) cosd(tz) 0;0 0 1]; % rotate about Z axis
            
            nodes_talus_translated_rot = (Rz*nodes_talus_translated_rot')';
            talus_talofibular_translated = (Rz*talus_talofibular_translated')';
            
            if trouble_shoot >= 2
                figure()
                plot3(nodes_talus_translated_rot(:,1),nodes_talus_translated_rot(:,2),nodes_talus_translated_rot(:,3),'b.')
                hold on
                plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
                axis equal
                view(3), view([0,90])
            end
            
            %% Recenter 2
            nodes_talus_translated_rot_X = nodes_talus_translated_rot(:,1);
            nodes_talus_translated_rot_X_max = max(nodes_talus_translated_rot_X);
            nodes_talus_translated_rot_min = min(nodes_talus_translated_rot_X);
            nodes_talus_translated_rot_X_mid = (nodes_talus_translated_rot_X_max + nodes_talus_translated_rot_min)./2; % find the mid point of the nodal points in the x direction
            nodes_talus_translated_rot_X_diff = mid_x_cp - nodes_talus_translated_rot_X_mid; % how much you need to shift to get from starting place to cp
            nodes_talus_translated_rot_X_shift = nodes_talus_translated_rot_X + nodes_talus_translated_rot_X_diff; % add the difference to shift to cp
            
            nodes_talus_translated_rot_Y = nodes_talus_translated_rot(:,2);
            nodes_talus_translated_rot_Y_max = max(nodes_talus_translated_rot_Y);
            nodes_talus_translated_rot_Y_min = min(nodes_talus_translated_rot_Y);
            nodes_talus_translated_rot_Y_mid = (nodes_talus_translated_rot_Y_max + nodes_talus_translated_rot_Y_min)./2; % find the mid point of the nodal points in the y direction
            nodes_talus_translated_rot_Y_diff = mid_y_cp - nodes_talus_translated_rot_Y_mid; % how much you need to shift to get from starting place to cp
            nodes_talus_translated_rot_Y_shift = nodes_talus_translated_rot_Y + nodes_talus_translated_rot_Y_diff; % add the difference to shift to cp
            
            nodes_talus_translated_rot = [nodes_talus_translated_rot(:,1) + nodes_talus_translated_rot_X_diff,nodes_talus_translated_rot(:,2) + nodes_talus_translated_rot_Y_diff,nodes_talus_translated_rot(:,3)];
            talus_talofibular_translated = [talus_talofibular_translated(:,1) + nodes_talus_translated_rot_X_diff,talus_talofibular_translated(:,2) + nodes_talus_translated_rot_Y_diff,talus_talofibular_translated(:,3)];
            
            if trouble_shoot >= 2
                figure()
                plot3(nodes_talus_translated_rot(:,1),nodes_talus_translated_rot(:,2),nodes_talus_translated_rot(:,3),'b.')
                hold on
                plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
                hold on
                plot3(cp(68,1), cp(68,2), cp(68,3),'gx','linewidth',5)
                axis equal
                view(3), view([0,90])
            end
        end
        
        %% If Rotated
        nodes_talus_translated = nodes_talus_translated_rot;
        cp_min = cp(find(cp(:,3) <= 0),:);
        cp_max = cp(find(cp(:,3) >= 0),:);
        
    end
    
    % Did not need any rotation or centering
    if subj_count == 1
        cp_min = cp(find(cp(:,3) <= 0),:);
        cp_max = cp(find(cp(:,3) >= 0),:);
    end
    
    %% Selecting from the Correspondance Points
    % Flip Orientation to XY for FindROI and FindNear
    cp_xy(:,1) = cp(:,2);
    cp_xy(:,2) = cp(:,3);
    cp_xy(:,3) = cp(:,1);
    
    cp_min_xy(:,1) = cp_min(:,2);
    cp_min_xy(:,2) = cp_min(:,3);
    cp_min_xy(:,3) = cp_min(:,1);
    
    talus_talofibular_translated_xy(:,1) = talus_talofibular_translated(:,2);
    talus_talofibular_translated_xy(:,2) = talus_talofibular_translated(:,3);
    talus_talofibular_translated_xy(:,3) = talus_talofibular_translated(:,1);
    
    %% Talofibular
    ROItalofibular_xy = FindROI(cp_xy,talus_talofibular_translated_xy,'XY','max',TxTalfib,TyTalfib,TzTalfib,1);
    
    if trouble_shoot >= 2
        figure()
        hold on
        plot3(cp_min_xy(:,1),cp_min_xy(:,2),cp_min_xy(:,3),'kx')
        hold on
        plot3(talus_talofibular_translated_xy(:,1),talus_talofibular_translated_xy(:,2),talus_talofibular_translated_xy(:,3),'b.')
        hold on
        plot3(ROItalofibular_xy(:,1),ROItalofibular_xy(:,2),ROItalofibular_xy(:,3),'r*')
        axis equal
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        title('Talofibular')
        view(180,-90)
        %         set(gcf, 'Position', get(0, 'Screensize'))
    end
    
    %% Talofibular
    [talofibular_cp_xy ROItalofibular_xy] = FindNear(ROItalofibular_xy,talus_talofibular_translated_xy,'XY',.5,1);
    
    if trouble_shoot >= 2
        figure()
        hold on
        plot3(talofibular_cp_xy(:,1),talofibular_cp_xy(:,2),talofibular_cp_xy(:,3),'r*')
        hold on
        plot3(talus_talofibular_translated_xy(:,1),talus_talofibular_translated_xy(:,2),talus_talofibular_translated_xy(:,3),'b.')
        hold on
        plot3(ROItalofibular_xy(:,1),ROItalofibular_xy(:,2),ROItalofibular_xy(:,3),'kx')
        axis equal
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
    end
    
    %% Flip Orientation Back
    ROItalofibular(:,2) = ROItalofibular_xy(:,1);
    ROItalofibular(:,3) = ROItalofibular_xy(:,2);
    ROItalofibular(:,1) = ROItalofibular_xy(:,3);
    
    talofibular_cp(:,2) = talofibular_cp_xy(:,1);
    talofibular_cp(:,3) = talofibular_cp_xy(:,2);
    talofibular_cp(:,1) = talofibular_cp_xy(:,3);
    
    %%
    if trouble_shoot == 3
        Continue = menu('Would you like to continue?','Yes (no save)','Yes (save data)','No (no save)','No (save data)','Modify Tolerances (Repeat)');
        if Continue == 5
            MT = 1;
            while MT == 1
                xDirTalofibular = sprintf('X-Direction, previous value (%s)',string(TxTalfib));
                yDirTalofibular = sprintf('Y-Direction, previous value (%s)',string(TyTalfib));
                zDirTalofibular = sprintf('Z-Direction, previous value (%s)',string(TzTalfib));
                
                TolTalofibular = inputdlg({xDirTalofibular,yDirTalofibular,zDirTalofibular},'Talofibular');
                Distance.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.X = str2double(TolTalofibular(1));
                Distance.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Y = str2double(TolTalofibular(2));
                Distance.Tolerances.(char(subj(subj_count))).Fibula.Talofibular.Z = str2double(TolTalofibular(3));
                fprintf('Talofibular tolerances modified for subject %s \n',string(subj(subj_count)))
                
                MT = 2;
                
            end
            
            save('Joint_Space_Tolerances','-struct','Distance');
            
        end
    end
    
    %% Talofibular
    n = 1;
    while n <= length(talofibular_cp)
        temp = find(nodes_talus_translated(:) == talofibular_cp(n,:));
        i_talofibular(n,:) =  temp(1,:);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(ROItalofibular)
        ii_talofibular(n,:) = find(cp(:,1) == ROItalofibular(n,1) & cp(:,2) == ROItalofibular(n,2) & cp(:,3) == ROItalofibular(n,3));
        n = n + 1;
    end
    
    distance_talofibular = talofibular_space(i_talofibular+talus_start-1,:);
    
    %% Error Messages if FindROI and FindNear did not work
    if length(talofibular_cp) ~= length(ROItalofibular)
        error('Talofibular matrix dimensions do not match')
    end
    
    
    errorPost = [];
    
    uTaFCPx = length(unique(talofibular_cp(:,1)));
    uTaFCPy = length(unique(talofibular_cp(:,2)));
    uTaFCPz = length(unique(talofibular_cp(:,3)));
    
    
    uRTaFx = length(unique(ROItalofibular(:,1)));
    uRTaFy = length(unique(ROItalofibular(:,2)));
    uRTaFz = length(unique(ROItalofibular(:,3)));
    
    if uRTaFx ~= length(ROItalofibular(:,1)) || uRTaFy ~= length(ROItalofibular(:,2)) || uRTaFz ~= length(ROItalofibular(:,3))
        fprintf('ROItalofibular non-unique')
        errorPost = 1;
    end
    
    if uTaFCPx ~= length(talofibular_cp(:,1)) || uTaFCPy ~= length(talofibular_cp(:,2)) || uTaFCPz ~= length(talofibular_cp(:,3))
        fprintf('talofibular_cp non-unique')
        errorPost = 1;
    end
    
    if errorPost == 1;
        error('Non-unique matrix')
    end
    
    %% Save Distances and Nodes to Excel
    if trouble_shoot == 1 || Continue == 2 || Continue == 4
        excel_path = 'Nodal_Data_TaF_Github.xlsx';
        xlswrite(excel_path,{'Talofibular'},string(subj(subj_count)),'A1')
        xlswrite(excel_path,{'Node'},string(subj(subj_count)),'A2')
        xlswrite(excel_path,{'CP Node'},string(subj(subj_count)),'C2')
        xlswrite(excel_path,{'Distance'},string(subj(subj_count)),'B2')
        xlswrite(excel_path,distance_talofibular,string(subj(subj_count)),'A3')
        xlswrite(excel_path,ii_talofibular,string(subj(subj_count)),'C3')
    end
    
    if trouble_shoot == 3
        if Continue == 1 || Continue == 2
            subj_count = subj_count + 1;
            close all
        end
        if Continue == 3 || Continue == 4
            break
        end
        if Continue == 5
            subj_count = subj_count;
            close all
        end
    end
    if trouble_shoot == 1 || trouble_shoot == 2
        subj_count = subj_count + 1;
    end
    fprintf('\n')
end

fprintf('Node Distance Values Complete!\n')
