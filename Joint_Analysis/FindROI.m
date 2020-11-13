function [ROI] = FindROI(ROI_1,ROI_2,xyz,limits,tolx,toly,tolz,Z)
% [ROI] = FindROI(ROI_1,ROI_2,xyz,limits,tolx,toly,tolz)
% ROI_1 = Nodes that are selected (e.g. correspondance points)
% ROI_2 = Nodes of interest (e.g. articulating surface)
% xyz = 'XY' or 'YZ' or 'XZ' plane
% limits = 'max' or 'min'
% tolx = tolerance in 1st-direction
% toly = tolerance in 2nd-direction
% tolz = tolerance in 3rd-direction (into plane)
%
% This function selects nodes from ROI_1 that are within the boundaries of
% ROI_2 projected in the plane selected.
% The tolerances allow for narrowing or broadening how the limits of how it
% will select in the different directions.

%%
if Z == 1
    [ROI] = FindROI1(ROI_1,ROI_2,xyz,limits,tolx,toly,tolz,Z);
end

if Z == 2
    [ROI] = FindROI2(ROI_1,ROI_2,xyz,limits,tolx,toly,tolz,Z);
end

    function [ROI] = FindROI1(ROI_1,ROI_2,xyz,limits,tolx,toly,tolz,Z)
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
            x = 1;
            y = 3;
            z = 2;
        end
        
        n = 0;
        temp = [];
        ROI = [];
        tempX = [];
        tempXold = [];
        
        % ROI Moving in X-Direction
        move_count_x = min(ROI_2(:,x)); % starting place in x-direction
        move_x = (abs(max(ROI_2(:,x))) + abs(min(ROI_2(:,x))))/20; % increment in x-direction
        
        while move_count_x <= max(ROI_2(:,x))
            if isempty(tempX) == 0
                tempXold = tempX;
            end
            tempX = ROI_2(find(ROI_2(:,x) >= move_count_x & ROI_2(:,x) <= move_count_x + move_x),:);
            move_count_x = move_count_x + move_x;
            move_count_y = min(tempX(:,y));
            move_y = (abs(max(tempX(:,y))) + abs(min(tempX(:,y))))/20;
            while move_count_y <= max(tempX(:,y))
                tempY = tempX(find(tempX(:,y) >= move_count_y & tempX(:,y) <= move_count_y + move_y),:);
                if isempty(tempY) == 0
                    if isempty(tempXold) == 0
                        if limits == 'max'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                        end
                        if limits == 'min'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                        end
                    end
                    if isempty(tempXold) == 1
                        if limits == 'max'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz),:);
                            end
                        end
                        if limits == 'min'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz),:);
                            end
                        end
                    end
                end
                move_count_y = move_count_y + move_y;
                
                if isempty(temp) == 0
                    m = 1;
                    while m <= length(temp(:,1))
                        ROI(n+m,:) = temp(m,:);
                        m = m + 1;
                    end
                    m = m - 1;
                    n = n + m;
                end
            end
        end
        
        [unique1 IROI1 Iu1] = unique(ROI(:,1),'stable');
        [unique2 IROI2 Iu2] = unique(ROI(:,2),'stable');
        [unique3 IROI3 Iu3] = unique(ROI(:,3),'stable');
        
        ROI = ROI(IROI1,:);
        
    end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [ROI] = FindROI2(ROI_1,ROI_2,xyz,limits,tolx,toly,tolz,Z)
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
            x = 1;
            y = 3;
            z = 2;
        end
        
        n = 0;
        temp = [];
        ROI = [];
        tempX = [];
        tempXold = [];
        
        % ROI Moving in X-Direction
        move_count_x = min(ROI_2(:,x)); % starting place in x-direction
        move_x = (abs(max(ROI_2(:,x))) + abs(min(ROI_2(:,x))))/20; % increment in x-direction
        
        while move_count_x <= max(ROI_2(:,x))
            if isempty(tempX) == 0
                tempXold = tempX;
            end
            tempX = ROI_2(find(ROI_2(:,x) >= move_count_x & ROI_2(:,x) <= move_count_x + move_x),:);
            move_count_x = move_count_x + move_x;
            move_count_y = min(tempX(:,y));
            move_y = (abs(max(tempX(:,y))) + abs(min(tempX(:,y))))/20;
            while move_count_y <= max(tempX(:,y))
                tempY = tempX(find(tempX(:,y) >= move_count_y & tempX(:,y) <= move_count_y + move_y),:);
                if isempty(tempY) == 0
                    if isempty(tempXold) == 0
                        if limits == 'max'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                        end
                        if limits == 'min'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - move_y*tolz & ROI_1(:,y) <= max(tempXold(:,y)) & ROI_1(:,y) >= min(tempXold(:,y))),:);
                            end
                        end
                    end
                    if isempty(tempXold) == 1
                        if limits == 'max'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) <= max(tempY(:,z)) + tolz),:);
                            end
                        end
                        if limits == 'min'
                            % At starting point, X and Y
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % Moving through first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % At end of first line
                            if move_count_x <= min(ROI_1(:,x)) + move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % At start of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % Middle of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % At end of middle section
                            if move_count_x > min(ROI_1(:,x)) + move_x && move_count_x < max(ROI_1(:,x)) - move_x + move_x && move_count_y >= max(tempX(:,x)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) + move_y*tolx & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % At start of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y <= min(tempX(:,y)) + move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % Moving through last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y > min(tempX(:,y)) + move_y && move_count_y < max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) + move_y*toly & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                            % At end of last line
                            if move_count_x >= max(ROI_1(:,x)) - move_x && move_count_y >= max(tempX(:,y)) - move_y
                                temp = ROI_1(find(ROI_1(:,x) >= min(tempY(:,x)) - move_y*tolx & ROI_1(:,x) <= max(tempY(:,x)) & ROI_1(:,y) >= min(tempY(:,y)) - move_y*toly & ROI_1(:,y) <= max(tempY(:,y)) & ROI_1(:,z) >= min(tempY(:,z)) - tolz),:);
                            end
                        end
                    end
                end
                move_count_y = move_count_y + move_y;
                
                if isempty(temp) == 0
                    m = 1;
                    while m <= length(temp(:,1))
                        ROI(n+m,:) = temp(m,:);
                        m = m + 1;
                    end
                    m = m - 1;
                    n = n + m;
                end
            end
        end
        
        [unique1 IROI1 Iu1] = unique(ROI(:,1),'stable');
        [unique2 IROI2 Iu2] = unique(ROI(:,2),'stable');
        [unique3 IROI3 Iu3] = unique(ROI(:,3),'stable');
        
        ROI = ROI(IROI1,:);
    end
end
