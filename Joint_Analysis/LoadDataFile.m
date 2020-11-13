function FileData = LoadDataFile(FileName)
% This function takes an inputed .xplt or .k file and loads it as variable
% 'FileData'.

FileSplit = split(FileName,".");

FileType = string(FileSplit(2,1));

if FileType == 'xplt';
fid = fopen(FileName);
temp = fgets(fid); % ignores "ASCII EXPORT"
temp = fgets(fid); % ignores "STATE 1"
temp = fgets(fid); % ignores "TIME_VALUE"
temp = fgets(fid); % ignores "NODAL_DATA"
Data = textscan(fid,'%f %f', 'Delimiter',','); % fixes the spacing that happens when you ignore the first two lines and makes a matrix with jus the (x,y,z) coordinates
fclose(fid);
FileData = [Data{1,1}, Data{1,2}]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end

if FileType == 'k'
fid = fopen(FileName);
temp = fgets(fid); % ignores "keyword"
temp = fgets(fid); % ignores "node"
allfiledata = textscan(fid,'%d %f %f %f', 'Delimiter', '\n');
fclose(fid);
FileData = [allfiledata{1,2}, allfiledata{1,3}, allfiledata{1,4}]; % pulls the (x,y,z) coordinates for the nodes into a new matrix
end

%%
end