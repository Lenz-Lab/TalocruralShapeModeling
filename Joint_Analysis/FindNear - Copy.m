% function [ROI i_ROI] = FindNear(ROI_1,ROI_2,xyz,tolerance,Z)
% [ROI] = FindNear(ROI_1,ROI_2,xyz,tolerance)
% ROI_1 = Nodes selecting from
% ROI_2 = Nodal range limiting
% xyz = 'XY' or 'YZ' or 'XZ' plane
% tolerance = tolerance

%%
clc
ROI_1 = Data.(string(subj(subj_count))).Coverage.TalusTibiotalar;
ROI_2 = Data.(string(subj(subj_count))).Nodes.Tibia;
tolerance = 1.5;
Z = 2;
xyz = 'xy';

jk = 2;
m = 53; 
n = 2;

%%
if Z == 1
    ROI_1 = ROI_1;
    ROI_2 = ROI_2;
    xyz = xyz;
    tolerance = tolerance;
    [ROI i_ROI] = FindNear1(ROI_1,ROI_2,xyz,tolerance);
end

if Z == 2
    ROI_1 = ROI_1;
    ROI_2 = ROI_2;
    xyz = xyz;
    tolerance = tolerance;
    %[ROI] = FindNear2(ROI_1,ROI_2,xyz,tolerance);
end

%%
%     function [ROI i_ROI] = FindNear1(ROI_1,ROI_2,xyz,tolerance)
%         % XY-Plane
%         if xyz == 'xy' | xyz == 'XY' | xyz == 'yx' | xyz == 'YX' | xyz == 'xY' | xyz == 'Xy' | xyz == 'yX' | xyz == 'Yx'
%             x = 1;
%             y = 2;
%             z = 3;
%         end
%
%         % YZ-Plane
%         if xyz == 'zy' | xyz == 'ZY' | xyz == 'yz' | xyz == 'YZ' | xyz == 'zY' | xyz == 'Zy' | xyz == 'yZ' | xyz == 'Yz'
%             x = 3;
%             y = 1;
%             z = 2;
%         end
%
%         % XZ-Plane
%         if xyz == 'zx' | xyz == 'ZX' | xyz == 'xz' | xyz == 'XZ' | xyz == 'zX' | xyz == 'Zx' | xyz == 'xZ' | xyz == 'Xz'
%             x = 2;
%             y = 3;
%             z = 1;
%         end
%
%         n = 1;
%         jk = 1;
%         % ROI = [0 0 0];
%         while n <= length(ROI_1)
%             tolx = tolerance;
%             toly = tolerance;
%             tolz = tolerance;
%             m = 1;
%             q = 1;
%             tempFind = [];
%             while m <= 1000
%                 ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly);
%                 if isempty(ROI_temp(:,1)) == 0
%                     tempDistZ = pdist2(ROI_1(n,z),ROI_2(ROI_temp,z));
%                     tolz = min(tempDistZ) + 1;
%                     ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly & ROI_2(:,z) >= ROI_1(n,z) - tolz & ROI_2(:,z) <= ROI_1(n,z) + tolz);
%                 end
%                 if length(ROI_temp) > 1
%                     tolx = tolx - 0.001;
%                     toly = toly - 0.001;
%                     tolz = tolz - 0.001;
%                     ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly & ROI_2(:,z) >= ROI_1(n,z) - tolz & ROI_2(:,z) <= ROI_1(n,z) + tolz);
%                 end
%                 if isempty(ROI_temp) == 1 && q <= 10
%                     tolx = tolx + 0.0005;
%                     toly = toly + 0.0005;
%                     tolz = tolz + 0.0005;
%                     ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly & ROI_2(:,z) >= ROI_1(n,z) - tolz & ROI_2(:,z) <= ROI_1(n,z) + tolz);
%                     q = q + 1;
%                 end
%                 if length(ROI_temp) == 2 | length(ROI_temp) == 1  && q <= 10
%                     ii = find(ROI_2(ROI_temp,z) == max(ROI_2(ROI_temp,z)));
%                     ROI(jk,:) = ROI_2(ROI_temp(ii),:);
%                     i_ROI(jk,:) = ROI_1(n,:);
%                     %         if jk > 2 && length(ROI_temp) == 2
%                     %             tempFind = find(ROI((1:jk-1),:) == ROI(jk,:));
%                     %             if isempty(tempFind) == 0
%                     %                 i2 = find(ROI_2(ROI_temp,z) ~= max(ROI_2(ROI_temp,z)));
%                     %                 ROI(jk,:) = ROI_2(ROI_temp(i2),:);
%                     %             end
%                     %             if isempty(tempFind) == 1
%                     %                 clear tempFind
%                     %             end
%                     %         end
%                     jk = jk + 1;
%                     break
%                 end
%                 if q > 10
%                     break
%                 end
%                 m = m + 1;
%             end
%             n = n + 1;
%             clear ROI_temp
%         end
%
%         [unique1 IROI1 Iu1] = unique(ROI(:,1),'stable');
%         [unique2 IROI2 Iu2] = unique(ROI(:,2),'stable');
%         [unique3 IROI3 Iu3] = unique(ROI(:,3),'stable');
%
%         [unique4 IROI4 Iu4] = unique(i_ROI(:,1),'stable');
%
%         ROI = ROI(IROI1,:);
%         i_ROI = i_ROI(IROI4,:);
%     end


%function [ROI] = FindNear2(ROI_1,ROI_2,xyz,tolerance)
% XY-Plane
if xyz == 'xy' | xyz == 'XY' | xyz == 'yx' | xyz == 'YX' | xyz == 'xY' | xyz == 'Xy' | xyz == 'yX' | xyz == 'Yx'
    x = 1;
    y = 2;
    z = 3;
end

% YZ-Plane
if xyz == 'zy' | xyz == 'ZY' | xyz == 'yz' | xyz == 'YZ' | xyz == 'zY' | xyz == 'Zy' | xyz == 'yZ' | xyz == 'Yz'
    x = 3;
    y = 1;
    z = 2;
end

% XZ-Plane
if xyz == 'zx' | xyz == 'ZX' | xyz == 'xz' | xyz == 'XZ' | xyz == 'zX' | xyz == 'Zx' | xyz == 'xZ' | xyz == 'Xz'
    x = 2;
    y = 3;
    z = 1;
end

% n = 1;
% jk = 1;
% while n <= length(ROI_1)
    tol = tolerance;
     m = 1;
%     while m <= 150
        if m == 1
            ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol);
            tempZ = pdist2(ROI_1(n,z),ROI_2(ROI_temp,z));
            tolz = min(tempZ) + 1;
            ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol & ROI_2(:,z) <= ROI_1(n,z) + tolz & ROI_2(:,z) >= ROI_1(n,z) - tolz);
        end
        if length(ROI_temp(:,1)) > 1
            tol = tol - 0.01;
            ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol & ROI_2(:,z) <= ROI_1(n,z) + tolz & ROI_2(:,z) >= ROI_1(n,z) - tolz);
        end
        if isempty(ROI_temp) == 1
            tol = tol + 0.005;
            ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol & ROI_2(:,z) <= ROI_1(n,z) + tolz & ROI_2(:,z) >= ROI_1(n,z) - tolz);
        end
        if length(ROI_temp) <= 2 && length(ROI_temp) > 0
            tempD = pdist2(ROI_1(n,z),ROI_2(ROI_temp,z));
            ROI_temp = ROI_temp(find(tempD == min(tempD)));
            if length(ROI_temp) > 1
                ROI_temp = ROI_temp(1);
            end 
            ROI(jk,:) = ROI_2(ROI_temp,:);
        end
        if jk > 2 && length(ROI_temp) == 2
            tempFind = find(ROI((1:jk-1),:) == ROI(jk,:));
            if isempty(tempFind) == 0
                i2 = find(ROI_2(ROI_temp,z) ~= max(ROI_2(ROI_temp,z)));
                if ROI_2(ROI_temp,z)
                    ROI(jk,:) = ROI_2(ROI_temp(i2),:);
                end
                if isempty(tempFind) == 1
%                     clear tempFind tempD
                end
            end
%             break
        end
        m = m + 1;
%     end

%     n = n + 1;
%     jk = jk + 1;
%     clear ROI_temp tempZ tolZ
%end
% end
% end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% n = 1;
% jk = 1;
% while n <= length(ROI_1)
%     tol = tolerance;
%     m = 1;
%     q = 1;
%     while m <= 2000
%         ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol);
%         if m == 1
%             tempZmax = max(ROI_2(ROI_temp,3));
%         end
%         if length(ROI_temp(:,1)) > 1
%             tol = tol - 0.01;
%             ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol & ROI_2(:,z) >= tempZmax - tol);
%         end
%         if isempty(ROI_temp) == 1
%             tol = tol + 0.005;
%             ROI_temp = find(ROI_2(:,x) >= ROI_1(n,x) - tol & ROI_2(:,x) <= ROI_1(n,x) + tol & ROI_2(:,y) >= ROI_1(n,y) - tol & ROI_2(:,y) <= ROI_1(n,y) + tol & ROI_2(:,z) >= tempZmax - tol);
%         end
%         if length(ROI_temp) <= 2 && length(ROI_temp) > 0
%             ii = find(ROI_2(ROI_temp,z) == max(ROI_2(ROI_temp,z)));
%             ROI(jk,:) = ROI_2(ROI_temp(ii),:);
%         if jk > 2 && length(ROI_temp) == 2
%             tempFind = find(ROI((1:jk-1),:) == ROI(jk,:));
%             if isempty(tempFind) == 0
%                 i2 = find(ROI_2(ROI_temp,z) ~= max(ROI_2(ROI_temp,z)));
%                 ROI(jk,:) = ROI_2(ROI_temp(i2),:);
%             end
%             if isempty(tempFind) == 1
%                 clear tempFind tempZmax
%             end
%         end
%         jk = jk + 1;
%         break
%     end
%     if q > 5
%         break
%     end
%         m = m + 1;
%     end
%     n = n + 1;
%     clear ROI_temp
% end
% end
%
% end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% if Z == 2
% n = 1;
% jk = 1;
% while n <= length(ROI_1)
%     tolx = tolerance;
%     toly = tolerance;
%     tolz = tolerance*5;
%     m = 1;
%     q = 1;
%     tempFind = [];
%     while m <= 2000
%     ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly & ROI_2(:,z) >= ROI_1(n,z) - tolz);
%     if length(ROI_temp) > 1
%         tolx = tolx - 0.001;
%         toly = toly - 0.001;
%         ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly & ROI_2(:,z) >= ROI_1(n,z) - tolz);
%     end
%     if isempty(ROI_temp) == 1 && q <= 10
%         tolx = tolx + 0.0005;
%         toly = toly + 0.0005;
%         ROI_temp = find(ROI_2(:,x) <= ROI_1(n,x) + tolx & ROI_2(:,x) >= ROI_1(n,x) - tolx & ROI_2(:,y) <= ROI_1(n,y) + toly & ROI_2(:,y) >= ROI_1(n,y) - toly & ROI_2(:,z) >= ROI_1(n,z) - tolz);
%         q = q + 1;
%     end
%     if length(ROI_temp) == 2 | length(ROI_temp) == 1  && q <= 10
%         ii = find(ROI_2(ROI_temp,z) == max(ROI_2(ROI_temp,z)));
%         ROI(jk,:) = ROI_2(ROI_temp(ii),:);
%         if jk > 2 && length(ROI_temp) == 2
%             tempFind = find(ROI((1:jk-1),:) == ROI(jk,:));
%             if isempty(tempFind) == 1
%                 i2 = find(ROI_2(ROI_temp,z) ~= max(ROI_2(ROI_temp,z)));
%                 ROI(jk,:) = ROI_2(ROI_temp(i2),:);
%             end
%             if isempty(tempFind) == 0
%                 clear tempFind
%             end
%         end
%         jk = jk + 1;
%         break
%     end
%     if q > 5
%         break
%     end
%         m = m + 1;
%     end
%     n = n + 1;
%     clear ROI_temp
% end
% end

% end


%% Plotting
% figure()
% plot3(ROI_1(:,1),ROI_1(:,2),ROI_1(:,3),'kx')
% hold on
% % plot3(ROI_1(n,1),ROI_1(n,2),ROI_1(n,3),'yx','linewidth',5)
% hold on
% plot3(ROI_2(:,1),ROI_2(:,2),ROI_2(:,3),'b.')
% hold on
% % plot3(ROI_temp(:,1),ROI_temp(:,2),ROI_temp(:,3),'r*')
% hold on
% plot3(ROI(:,1),ROI(:,2),ROI(:,3),'r*')
% axis equal
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
%
% length(ROI(:,1))
% length(ROI_1(:,1))