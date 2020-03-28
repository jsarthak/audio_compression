%   LZW decoder
%   Author : Sarthak Jain
%   Version    : 2.1
%   Last updated on : December 23, 2017

% Read oldCode
% output oldCode
% CHARACTER = oldCode
% WHILE there are still input characters DO
%     Read NEW_CODE
%     IF NEW_CODE is not in the translation table THEN
%         STRING = get translation of oldCode
%         STRING = STRING+CHARACTER
%     ELSE
%         STRING = get translation of NEW_CODE
%     END of IF
%     output STRING
%     CHARACTER = first character in STRING
%     add translation of oldCode + CHARACTER to the translation table
%     oldCode = NEW_CODE
% END of WHILE

tic;

clc;
clear all;
close all;

% Load the previous workspace.
filename = input('Enter the filename in quotes : ');
dispstat(sprintf('Loading workspace...'),'keepthis','timestamp');
workspaceName = '';
for i = 1:(numel(filename)-4)
    workspaceName(i) = filename(i);
end
load(workspaceName);
dispstat('', 'init');
dispstat(sprintf('Begining the LZW Decompression process...'),'keepthis','timestamp');

fileID = fopen(strcat(workspaceName,'.dat'),'r');
readBytes = fread(fileID)';
fclose(fileId);


lzwIndexes = getArrayFromByteStream(uint8(readBytes));

table = cell(1,256);
for i = 1:256
    table{i} = char(i);
end

lengthTable = length(table);

oldCode = lzwIndexes(1);

character = table{oldCode};
output = character;
for i = 2:length(lzwIndexes)
    if (lzwIndexes(i)~=0)
        new_code = lzwIndexes(i);
        if (lengthTable<(new_code))
            string = table{oldCode};
            string = strcat(string, character);
        else
            string = table{new_code};
        end
        
        character = string(1);
        output = strcat(output,string);
        lengthTable = lengthTable+1;
        table{lengthTable} = strcat(table{oldCode}, character);
        oldCode = new_code;
        dispstat(sprintf('Processed %d samples of %d samples.', i, length(lzwIndexes)));
    end
end

decodedText = output;

dispstat(sprintf('Saving the Workspace...'),'keepthis','timestamp');
% Save the current workspace
workspaceName = '';
for i = 1:(numel(filename)-4)
    workspaceName(i) = filename(i);
end

save(workspaceName);
dispstat(sprintf('Done.'),'keepthis','timestamp');
toc;
