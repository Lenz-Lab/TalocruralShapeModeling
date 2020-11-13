function ColorMapPlot3(ROI,NodalData,CLimits)
% ColorMapPlot3(ROI,NodalData,CLimits)
% ROI = vertices (nodal locations)
% NodalData = values at those locations (indices must match ROI)
% CLimits - if left blank will give colormap from 0 to 1
%   - if length(CLimits) == 1 then will use min(NodalData) and max(NodalData)
%   for the colormap
%   - if length(Climits) == 2 then will use CLimits(1,1) and CLimits(1,2)
%   for the colormap


%%

k = 1;
a = (0:.01:1);
b = zeros(1,101);
c = 1-a;
ColorMap2 = colormap(jet);
close

ML = length(ColorMap2(:,1)); % Colormap Length (used to be ML, now is 256)

exist CLimits;
if ans == 0
    while k <= ML
        if k == 1
            S.BinRange(k,:) = [0 (1/ML)];
        end
        if k > 1 && k < ML
            S.BinRange(k,:) = [S.BinRange((k-1),2) S.BinRange((k-1),2)+(1/ML)];
        end
        if k == ML
            S.BinRange(k,:) = [S.BinRange((k-1),2) inf];
        end
        k = k + 1;
    end
end

exist CLimits;
if ans == 1
    if length(CLimits) == 1
        while k <= ML
            if k == 1
                S.BinRange(k,:) = [min(NodalData) min(NodalData)+(1/ML)*(max(NodalData)-min(NodalData))];
                
            end
            if k > 1 && k < ML
                S.BinRange(k,:) = [S.BinRange((k-1),2) S.BinRange((k-1),2)+((1/ML)*(max(NodalData)-min(NodalData)))];
                %         disp(S(k).BinRange)
            end
            if k == ML
                S.BinRange(k,:) = [S.BinRange((k-1),2) inf];
                %         disp(S(k).BinRange)
            end
            k = k + 1;
        end
    end
    
    if length(CLimits) > 1
        while k <= ML
            if k == 1
                S.BinRange(k,:) = [CLimits(1,1) CLimits(1,1)+(1/ML)*(CLimits(1,2)-CLimits(1,1))];
            end
            if k > 1 && k < ML
                S.BinRange(k,:) = [S.BinRange((k-1),2) S.BinRange((k-1),2)+((1/ML)*(CLimits(1,2)-CLimits(1,1)))];
                %         disp(S(k).BinRange)
            end
            if k == ML
                S.BinRange(k,:) = [S.BinRange((k-1),2) inf];
                %         disp(S(k).BinRange)
            end
            k = k + 1;
        end
    end
end

%%
n = 1;
while n <= length(NodalData(:,1))
    k = 1;
    while k <= ML
        if NodalData(n,1) >= S.BinRange(k,1) && NodalData(n,1) < S.BinRange(k,2)
            CMap(n,:) = ColorMap2(k,:);
        end
        k = k + 1;
    end
    n = n + 1;
end


%%
figure()
m = 1;
while m <= length(NodalData(:,1))
    scatter3(ROI(m,1),ROI(m,2),ROI(m,3),100,CMap(m,:),'filled');
    hold on
    m = m + 1;
end
hold on
C = colorbar;
exist CLimits;
if ans == 1
    if length(CLimits) > 1
        caxis([CLimits(1,1),CLimits(1,2)])
    end
    if length(CLimits) == 1
        caxis([min(NodalData) max(NodalData)]);
    end
end
if ans == 0
    caxis([0 1]);
end
colormap jet
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
end

%%
% figure()
% m = 1;
% while m <= length(NodalData(:,1))
%     scatter3(ROI(m,1),ROI(m,2),ROI(m,3),100,CMap(m,:),'filled')
%     hold on
%     m = m + 1;
% end
% hold on
% plot3(talus_nodes(:,1),talus_nodes(:,2),talus_nodes(:,3),'k.')
% colorbar
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% axis equal
