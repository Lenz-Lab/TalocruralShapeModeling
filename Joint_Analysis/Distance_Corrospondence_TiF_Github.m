%% Corrospondence Points Distance Tibiofibular based on Tibia
% Created by: Rich Lisonbee
% Revised for Tibiofibular by: Andrew Peterson
% Created: 6.6.19
% Last Updated: 11.5.20

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
    clearvars -except subj subj_path trouble_shoot file_path subj_count
    close all
    Continue = [];
    
    %% Load Tolerance .mat File
    % These were created manually and updated using this script
    Distance = load('Joint_Space_Tolerances_TiF.mat');
    
    %% Identify Surfaces of Interest and Distance Data
    FileNameAll = strcat(subj,'_Tibia_Fibula_Talus.k');
    
    FileNameTibiofibularNodal = strcat(subj,'_Tibiofibular_Nodal.xplt');
    FileNameTibiofibularSpace = strcat(subj,'_Tibiofibular_Space.xplt');
    
    fprintf('Processing Subject %s \n',string((subj(subj_count))))
    
    %% Loading Tibiofibular Coverage and Joint Space
    tibiofibular_coverage = LoadDataFile(string(FileNameTibiofibularNodal(subj_count)));
    tibiofibular_space = LoadDataFile(string(FileNameTibiofibularSpace(subj_count)));
    
    %% Loading All Nodes
    nodes_all = LoadKFile(string(FileNameAll(subj_count)));
    
    %% Loading Tibia
    File_Tibia = strcat(subj(subj_count),'_Tibia.k');
    nodes_tibia = LoadKFile(char(strcat(File_Tibia)));
    
    %% Loading Fibula
    File_Fibula = strcat(subj(subj_count),'_Fibula.k');
    nodes_fibula = LoadKFile(char(strcat(File_Fibula)));
    
    %% Loading Tolerances
    TxTibfib = Distance.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.X;
    TyTibfib = Distance.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Y;
    TzTibfib = Distance.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Z;
    
    %% Cross Registration Between Individual Bones and All Bones
    tibia_start = find(nodes_all(:,:) == nodes_tibia(1,1));
    if sum(sum(nodes_all(:,:) == nodes_tibia(1,1),2)) > 1
        tibia_start = tibia_start(1,:);
    end
    
    tibia_end = find(nodes_all(:,:) == nodes_tibia(end,1));
    if sum(sum(nodes_all(:,:) == nodes_tibia(end,1),2)) > 1
        tibia_end = tibia_end(end,:);
    end
    
    fibula_start = find(nodes_all(:,:) == nodes_fibula(1,1));
    if sum(sum(nodes_all(:,:) == nodes_fibula(1,1),2)) > 1
        fibula_start = fibula_start(end,:);
    end
    
    fibula_end = find(nodes_all(:,:) == nodes_fibula(end,1));
    if sum(sum(nodes_all(:,:) == nodes_fibula(end,1),2)) > 1
        fibula_end = fibula_end(end,:);
    end
    
    tibia_nonzero_tibiofibular = nodes_tibia(find(tibiofibular_coverage(tibia_start:tibia_end,2) > 0),:);
    
    if trouble_shoot >= 2
        figure()
        plot3(nodes_all(tibia_start:tibia_end,1),nodes_all(tibia_start:tibia_end,2),nodes_all(tibia_start:tibia_end,3),'k.')
        hold on
        plot3(tibia_nonzero_tibiofibular(:,1),tibia_nonzero_tibiofibular(:,2),tibia_nonzero_tibiofibular(:,3),'g.')
        axis equal
    end
    
    %% Flip Lefts to Rights
    if subj_count <= 13
        nodes_all = nodes_all.*[-1,1,1];
        nodes_tibia = nodes_tibia.*[-1,1,1];
        tibia_nonzero_tibiofibular = tibia_nonzero_tibiofibular.*[-1,1,1];
    end
    %% Mid points of correspondance particles
    % This section finds the mid point of the correspondance particles in the
    % x, y, and z direction.
    
    cp = load('tibia.mean.pts'); % load in the correspondance particles
    
    x_cp = cp(:,1);
    max_x_cp = max(x_cp);
    min_x_cp = min(x_cp);
    mid_x_cp = (max_x_cp + min_x_cp)./2; % find the mid point of the cp is the x direction
    
    y_cp = cp(:,2);
    max_y_cp = max(y_cp);
    min_y_cp = min(y_cp);
    mid_y_cp = (max_y_cp + min_y_cp)./2; % find the mid point of the cp is the y direction
    
    z_cp = cp(:,3);
    max_z_cp = max(z_cp);
    min_z_cp = min(z_cp);
    mid_z_cp = (max_z_cp + min_z_cp)./2; % find the mid point of the cp is the z direction
    
    %% Mid points and shifting of nodal points
    % This section finds the midpoint of the nodal points and shifts it to
    % match the midpoint of the coorespondance particles in the x, y and z
    % direction.
    
    tibia_X = nodes_all(tibia_start:tibia_end,1);
    tibia_X_max = max(tibia_X);
    tibia_X_min = min(tibia_X);
    tibia_X_mid = (tibia_X_max + tibia_X_min)./2; % find the mid point of the nodal points in the x direction
    tibia_X_diff = mid_x_cp - tibia_X_mid; % how much you need to shift to get from starting place to cp
    tibia_X_shift = tibia_X + tibia_X_diff; % add the difference to shift to cp
    
    tibia_Y = nodes_all(tibia_start:tibia_end,2);
    tibia_Y_max = max(tibia_Y);
    tibia_Y_min = min(tibia_Y);
    tibia_Y_mid = (tibia_Y_max + tibia_Y_min)./2; % find the mid point of the nodal points in the y direction
    tibia_Y_diff = mid_y_cp - tibia_Y_mid; % how much you need to shift to get from starting place to cp
    tibia_Y_shift = tibia_Y + tibia_Y_diff; % add the difference to shift to cp
    
    tibia_Z = nodes_all(tibia_start:tibia_end,3);
    tibia_Z_max = max(tibia_Z);
    tibia_Z_min = min(tibia_Z);
    % tibia_Z_mid = (tibia_Z_max + tibia_Z_min)./2; % find the mid point of the nodal points in the z direction
    tibia_Z_diff = min_z_cp - tibia_Z_min; % how much you need to shift to get from starting place to cp
    tibia_Z_shift = tibia_Z + tibia_Z_diff; % add the difference to shift to cp
    
    tibia_translated = [tibia_X_shift, tibia_Y_shift, tibia_Z_shift]; % define new matrix based on the shifted nodes
    
    tibia_tibiofibular_translated = [tibia_nonzero_tibiofibular(:,1)+tibia_X_diff, tibia_nonzero_tibiofibular(:,2)+tibia_Y_diff, tibia_nonzero_tibiofibular(:,3)+tibia_Z_diff];
    
    nodes_all_translated = [nodes_all(:,1)+tibia_X_diff,nodes_all(:,2)+tibia_Y_diff,nodes_all(:,3)+tibia_Z_diff];
    nodes_tibia_translated = [nodes_tibia(:,1)+tibia_X_diff,nodes_tibia(:,2)+tibia_Y_diff,nodes_tibia(:,3)+tibia_Z_diff];
    
    if trouble_shoot >= 2
        figure()
        hold on
        plot3(tibia_translated(:,1), tibia_translated(:,2), tibia_translated(:,3), 'k.')
        hold on
        plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
        plot3(tibia_tibiofibular_translated(:,1),tibia_tibiofibular_translated(:,2),tibia_tibiofibular_translated(:,3),'b.')
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
            plot3(tibia_translated(:,1), tibia_translated(:,2), tibia_translated(:,3), 'k.')
            hold on
            plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
            xlabel('x')
            ylabel('y')
            zlabel('z')
            axis equal
            view(3), view([0,90])
        end
        l = 3;
        % u = axis_y1;
        u = nodes_tibia_translated(find(nodes_tibia_translated(:,l) == min(nodes_tibia_translated(:,l))),:);
        v = cp(find(cp(:,l) == min(cp(:,l))),:);
        
        CosTheta = dot(u,v)/(norm(u)*norm(v));
        
        if subj_count == 2 || subj_count == 6 || subj_count == 9 || subj_count == 13 || subj_count == 23
            if nodes_tibia_translated(find(nodes_tibia_translated(:,l) == min(nodes_tibia_translated(:,l))),1) < cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = -acosd(CosTheta);
            end
            
            if nodes_tibia_translated(find(nodes_tibia_translated(:,l) == min(nodes_tibia_translated(:,l))),1) > cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = acosd(CosTheta);
            end
        else
            if nodes_tibia_translated(find(nodes_tibia_translated(:,l) == min(nodes_tibia_translated(:,l))),1) < cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = acosd(CosTheta);
            end
            
            if nodes_tibia_translated(find(nodes_tibia_translated(:,l) == min(nodes_tibia_translated(:,l))),1) > cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = -acosd(CosTheta);
            end
        end
        
        Rz = [cosd(tz) -sind(tz) 0;sind(tz) cosd(tz) 0;0 0 1]; % rotate about Z axis
        
        
        nodes_tibia_translated_rot = (Rz*nodes_tibia_translated')';
        tibia_tibiofibular_translated = (Rz*tibia_tibiofibular_translated')';
        
        
        if trouble_shoot >= 2
            figure()
            plot3(nodes_tibia_translated_rot(:,1),nodes_tibia_translated_rot(:,2),nodes_tibia_translated_rot(:,3),'b.')
            hold on
            plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
            axis equal
            view(3), view([0,90])
        end
        
        %% Recenter 1
        nodes_tibia_translated_rot_X = nodes_tibia_translated_rot(:,1);
        nodes_tibia_translated_rot_X_max = max(nodes_tibia_translated_rot_X);
        nodes_tibia_translated_rot_min = min(nodes_tibia_translated_rot_X);
        nodes_tibia_translated_rot_X_mid = (nodes_tibia_translated_rot_X_max + nodes_tibia_translated_rot_min)./2; % find the mid point of the nodal points in the x direction
        nodes_tibia_translated_rot_X_diff = mid_x_cp - nodes_tibia_translated_rot_X_mid; % how much you need to shift to get from starting place to cp
        nodes_tibia_translated_rot_X_shift = nodes_tibia_translated_rot_X + nodes_tibia_translated_rot_X_diff; % add the difference to shift to cp
        
        nodes_tibia_translated_rot_Y = nodes_tibia_translated_rot(:,2);
        nodes_tibia_translated_rot_Y_max = max(nodes_tibia_translated_rot_Y);
        nodes_tibia_translated_rot_Y_min = min(nodes_tibia_translated_rot_Y);
        nodes_tibia_translated_rot_Y_mid = (nodes_tibia_translated_rot_Y_max + nodes_tibia_translated_rot_Y_min)./2; % find the mid point of the nodal points in the y direction
        nodes_tibia_translated_rot_Y_diff = mid_y_cp - nodes_tibia_translated_rot_Y_mid; % how much you need to shift to get from starting place to cp
        nodes_tibia_translated_rot_Y_shift = nodes_tibia_translated_rot_Y + nodes_tibia_translated_rot_Y_diff; % add the difference to shift to cp
        
        nodes_tibia_translated_rot = [nodes_tibia_translated_rot(:,1) + nodes_tibia_translated_rot_X_diff,nodes_tibia_translated_rot(:,2) + nodes_tibia_translated_rot_Y_diff,nodes_tibia_translated_rot(:,3)];
        tibia_tibiofibular_translated = [tibia_tibiofibular_translated(:,1) + nodes_tibia_translated_rot_X_diff,tibia_tibiofibular_translated(:,2) + nodes_tibia_translated_rot_Y_diff,tibia_tibiofibular_translated(:,3)];
        
        if trouble_shoot >= 2
            figure()
            plot3(nodes_tibia_translated_rot(:,1),nodes_tibia_translated_rot(:,2),nodes_tibia_translated_rot(:,3),'b.')
            hold on
            plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
            axis equal
            view(3), view([0,90])
        end
        
        %% Rotation 2
        if subj_count ~= 2 && subj_count ~= 7 && subj_count ~= 13 && subj_count ~= 23 && subj_count ~= 25
            u = nodes_tibia_translated_rot(find(nodes_tibia_translated_rot(:,l) == min(nodes_tibia_translated_rot(:,l))),:);
            v = cp(find(cp(:,l) == min(cp(:,l))),:);
            
            CosTheta = dot(u,v)/(norm(u)*norm(v));
            if nodes_tibia_translated_rot(find(nodes_tibia_translated_rot(:,l) == min(nodes_tibia_translated_rot(:,l))),1) < cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = acosd(CosTheta);
            end
            
            if nodes_tibia_translated_rot(find(nodes_tibia_translated_rot(:,l) == min(nodes_tibia_translated_rot(:,l))),1) > cp(find(cp(:,l) == min(cp(:,l))),1)
                tz = -acosd(CosTheta);
            end
            
            Rz = [cosd(tz) -sind(tz) 0;sind(tz) cosd(tz) 0;0 0 1]; % rotate about Z axis
            
            nodes_tibia_translated_rot = (Rz*nodes_tibia_translated_rot')';
            tibia_tibiofibular_translated = (Rz*tibia_tibiofibular_translated')';
            
            if trouble_shoot >= 2
                figure()
                plot3(nodes_tibia_translated_rot(:,1),nodes_tibia_translated_rot(:,2),nodes_tibia_translated_rot(:,3),'b.')
                hold on
                plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
                axis equal
                view(3), view([0,90])
            end
            
            %% Recenter 2
            nodes_tibia_translated_rot_X = nodes_tibia_translated_rot(:,1);
            nodes_tibia_translated_rot_X_max = max(nodes_tibia_translated_rot_X);
            nodes_tibia_translated_rot_min = min(nodes_tibia_translated_rot_X);
            nodes_tibia_translated_rot_X_mid = (nodes_tibia_translated_rot_X_max + nodes_tibia_translated_rot_min)./2; % find the mid point of the nodal points in the x direction
            nodes_tibia_translated_rot_X_diff = mid_x_cp - nodes_tibia_translated_rot_X_mid; % how much you need to shift to get from starting place to cp
            nodes_tibia_translated_rot_X_shift = nodes_tibia_translated_rot_X + nodes_tibia_translated_rot_X_diff; % add the difference to shift to cp
            
            nodes_tibia_translated_rot_Y = nodes_tibia_translated_rot(:,2);
            nodes_tibia_translated_rot_Y_max = max(nodes_tibia_translated_rot_Y);
            nodes_tibia_translated_rot_Y_min = min(nodes_tibia_translated_rot_Y);
            nodes_tibia_translated_rot_Y_mid = (nodes_tibia_translated_rot_Y_max + nodes_tibia_translated_rot_Y_min)./2; % find the mid point of the nodal points in the y direction
            nodes_tibia_translated_rot_Y_diff = mid_y_cp - nodes_tibia_translated_rot_Y_mid; % how much you need to shift to get from starting place to cp
            nodes_tibia_translated_rot_Y_shift = nodes_tibia_translated_rot_Y + nodes_tibia_translated_rot_Y_diff; % add the difference to shift to cp
            
            nodes_tibia_translated_rot = [nodes_tibia_translated_rot(:,1) + nodes_tibia_translated_rot_X_diff,nodes_tibia_translated_rot(:,2) + nodes_tibia_translated_rot_Y_diff,nodes_tibia_translated_rot(:,3)];
            tibia_tibiofibular_translated = [tibia_tibiofibular_translated(:,1) + nodes_tibia_translated_rot_X_diff,tibia_tibiofibular_translated(:,2) + nodes_tibia_translated_rot_Y_diff,tibia_tibiofibular_translated(:,3)];
            
            cp_plaf = cp(find(cp(:,1) < 1 & cp(:,1) > -1 & cp(:,2) < 1 & cp(:,2) > -1),3);
            temp_plaf = find(nodes_tibia_translated_rot(:,1) < 1 & nodes_tibia_translated_rot(:,1) > -1 & nodes_tibia_translated_rot(:,2) < 1 & nodes_tibia_translated_rot(:,2) > -1);
            
            nodes_tibia_translated_rot_plaf = min(nodes_tibia_translated_rot(temp_plaf,3));
            nodes_tibia_translated_rot_Z_diff = abs(cp_plaf) - abs(nodes_tibia_translated_rot_plaf);
            
            nodes_tibia_translated_rot = [nodes_tibia_translated_rot(:,1),nodes_tibia_translated_rot(:,2),nodes_tibia_translated_rot(:,3) + nodes_tibia_translated_rot_Z_diff];
            
            
            if trouble_shoot >= 2
                figure()
                plot3(nodes_tibia_translated_rot(:,1),nodes_tibia_translated_rot(:,2),nodes_tibia_translated_rot(:,3),'b.')
                hold on
                plot3(cp(:,1), cp(:,2), cp(:,3),'rx')
                hold on
                plot3(cp(68,1), cp(68,2), cp(68,3),'gx','linewidth',5)
                axis equal
                view(3), view([0,90])
            end
        end
        
        %% If Rotated
        nodes_tibia_translated = nodes_tibia_translated_rot;
        cp_min = cp(find(cp(:,1) <= 0),:);
        cp_max = cp(find(cp(:,1) >= 0),:);
        
    end
    
    % Did not need any rotation or centering
    if subj_count == 1
        cp_min = cp(find(cp(:,1) <= 0),:);
        cp_max = cp(find(cp(:,1) >= 0),:);
    end
    
    %% Selecting from the Correspondance Points
    % Flip Orientation to XY for FindROI and FindNear
    cp_xy(:,1) = cp(:,2);
    cp_xy(:,2) = cp(:,3);
    cp_xy(:,3) = cp(:,1);
    
    cp_min_xy(:,1) = cp_min(:,2);
    cp_min_xy(:,2) = cp_min(:,3);
    cp_min_xy(:,3) = cp_min(:,1);
    
    
    tibia_tibiofibular_translated_xy(:,1) = tibia_tibiofibular_translated(:,2);
    tibia_tibiofibular_translated_xy(:,2) = tibia_tibiofibular_translated(:,3);
    tibia_tibiofibular_translated_xy(:,3) = tibia_tibiofibular_translated(:,1);
    
    %% Tibiofibular FindROI
    ROItibiofibular_xy = FindROI(cp_xy,tibia_tibiofibular_translated_xy,'XY','max',TxTibfib,TyTibfib,TzTibfib,1);
    
    if trouble_shoot >= 2
        figure()
        hold on
        plot3(cp_min_xy(:,1),cp_min_xy(:,2),cp_min_xy(:,3),'kx')
        hold on
        plot3(tibia_tibiofibular_translated_xy(:,1),tibia_tibiofibular_translated_xy(:,2),tibia_tibiofibular_translated_xy(:,3),'b.')
        hold on
        plot3(ROItibiofibular_xy(:,1),ROItibiofibular_xy(:,2),ROItibiofibular_xy(:,3),'r*')
        axis equal
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
        title('tibiofibular')
        view(180,-90)
    end
    
    %% Tibiofibular FindNear
    if subj_count == 10 || subj_count == 13 || subj_count == 18 || subj_count == 19 || subj_count == 20 || subj_count == 21 || subj_count == 22 || subj_count == 23 || subj_count == 24 || subj_count == 25 || subj_count == 26 || subj_count == 27
        tol_near = 0.3;
    elseif subj_count == 11
        tol_near = 0.25;
    elseif subj_count == 14
        tol_near = 0.5;
    elseif subj_count == 16
        tol_near = 0.24;
    else
        tol_near = 1;
    end
    
    [tibiofibular_cp_xy ROItibiofibular_xy] = FindNear(ROItibiofibular_xy,tibia_tibiofibular_translated_xy,'XY',tol_near,1);
    
    if trouble_shoot >= 2
        figure()
        hold on
        plot3(tibiofibular_cp_xy(:,1),tibiofibular_cp_xy(:,2),tibiofibular_cp_xy(:,3),'r*')
        hold on
        plot3(tibia_tibiofibular_translated_xy(:,1),tibia_tibiofibular_translated_xy(:,2),tibia_tibiofibular_translated_xy(:,3),'b.')
        hold on
        plot3(ROItibiofibular_xy(:,1),ROItibiofibular_xy(:,2),ROItibiofibular_xy(:,3),'kx')
        axis equal
        xlabel('X')
        ylabel('Y')
        zlabel('Z')
    end
    
    %% Flip Orientation Back
    ROItibiofibular(:,2) = ROItibiofibular_xy(:,1);
    ROItibiofibular(:,3) = ROItibiofibular_xy(:,2);
    ROItibiofibular(:,1) = ROItibiofibular_xy(:,3);
    
    tibiofibular_cp(:,2) = tibiofibular_cp_xy(:,1);
    tibiofibular_cp(:,3) = tibiofibular_cp_xy(:,2);
    tibiofibular_cp(:,1) = tibiofibular_cp_xy(:,3);
    
    %%
    if trouble_shoot == 3
        Continue = menu('Would you like to continue?','Yes (no save)','Yes (save data)','No (no save)','No (save data)','Modify Tolerances (Repeat)');
        if Continue == 5
            MT = 1;
            while MT == 1
                xDirTibiofibular = sprintf('X-Direction, previous value (%s)',string(TxTibfib));
                yDirTibiofibular = sprintf('Y-Direction, previous value (%s)',string(TyTibfib));
                zDirTibiofibular = sprintf('Z-Direction, previous value (%s)',string(TzTibfib));
                
                TolTibiofibular = inputdlg({xDirTibiofibular,yDirTibiofibular,zDirTibiofibular},'Tibiofibular');
                Distance.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.X = str2double(TolTibiofibular(1));
                Distance.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Y = str2double(TolTibiofibular(2));
                Distance.Tolerances.(char(subj(subj_count))).Fibula.Tibiofibular.Z = str2double(TolTibiofibular(3));
                fprintf('Tibiofibular tolerances modified for subject %s \n',string(subj(subj_count)))
                
                MT = 2;
                
            end
            
            save('Joint_Space_Tolerances_TiF','-struct','Distance');
            
        end
    end
    
    %% Tibiofibular
    n = 1;
    while n <= length(tibiofibular_cp)
        temp = find(nodes_tibia_translated(:) == tibiofibular_cp(n,:));
        i_tibiofibular(n,:) =  temp(1,:);
        n = n + 1;
    end
    
    n = 1;
    while n <= length(ROItibiofibular)
        ii_tibiofibular(n,:) = find(cp(:,1) == ROItibiofibular(n,1) & cp(:,2) == ROItibiofibular(n,2) & cp(:,3) == ROItibiofibular(n,3));
        n = n + 1;
    end
    
    % find_tibiofibular = nodes_tibia_translated(i_tibiofibular,:);
    distance_tibiofibular = tibiofibular_space(i_tibiofibular+tibia_start-1,:);
    % distance_tibiofibular = tibiofibular_space(i_tibiofibular,:);
    
    %% Error Messages if FindROI and FindNear did not work
    if length(tibiofibular_cp) ~= length(ROItibiofibular)
        error('Tibiofibular matrix dimensions do not match')
    end
    
    
    errorPost = [];
    
    uTiFCPx = length(unique(tibiofibular_cp(:,1)));
    uTiFCPy = length(unique(tibiofibular_cp(:,2)));
    uTiFCPz = length(unique(tibiofibular_cp(:,3)));
    
    
    uRTiFx = length(unique(ROItibiofibular(:,1)));
    uRTiFy = length(unique(ROItibiofibular(:,2)));
    uRTiFz = length(unique(ROItibiofibular(:,3)));
    
    if uRTiFx ~= length(ROItibiofibular(:,1)) || uRTiFy ~= length(ROItibiofibular(:,2)) || uRTiFz ~= length(ROItibiofibular(:,3))
        fprintf('ROItibiofibular non-unique')
        errorPost = 1;
    end
    
    if uTiFCPx ~= length(tibiofibular_cp(:,1)) || uTiFCPy ~= length(tibiofibular_cp(:,2)) || uTiFCPz ~= length(tibiofibular_cp(:,3))
        fprintf('tibiofibular_cp non-unique')
        errorPost = 1;
    end
    
    if errorPost == 1;
        error('Non-unique matrix')
    end
    
     %% Save Distances and Nodes to Excel
    if trouble_shoot == 1 || Continue == 2 || Continue == 4
        excel_path = 'Nodal_Data_TiF_Github.xlsx';
        xlswrite(excel_path,{'Tibiofibular'},string(subj(subj_count)),'A1')
        xlswrite(excel_path,{'Node'},string(subj(subj_count)),'A2')
        xlswrite(excel_path,{'CP Node'},string(subj(subj_count)),'C2')
        xlswrite(excel_path,{'Distance'},string(subj(subj_count)),'B2')
        xlswrite(excel_path,distance_tibiofibular,string(subj(subj_count)),'A3')
        xlswrite(excel_path,ii_tibiofibular,string(subj(subj_count)),'C3')
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
