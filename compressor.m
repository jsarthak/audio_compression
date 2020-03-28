%   LZW encoder
%   Author : Sarthak Jain
%   Version    : 3.5
%   Last updated on : December 23, 2017
%
% How it encodes:
%
% STRING = get input character
% WHILE there are still input characters DO
%     CHARACTER = get input character
%     IF STRING+CHARACTER is in the string table then
%         STRING = STRING+character
%     ELSE
%         output the code for STRING
%         add STRING+CHARACTER to the string table
%         STRING = CHARACTER
%     END of IF
% END of WHILE
% output the code for STRING

% Start the timing 
tic;

% Initialize the progress meter
dispstat('', 'init');
dispstat(sprintf('Begining the LZW Compression process...'),'keepthis','timestamp');

%   Dictionary to be used is 256 ASCII characters
lzwBaseDictionary = cell(1,256);
lengthBaseDictionary = length(lzwBaseDictionary);
for i = 1:lengthBaseDictionary
    lzwBaseDictionary{i} = char(i);
end

lzwDictionary = {};

%   get the input character
STRING = encodedText(1);
lengthText = length(encodedText);

%   iterate till the end of text
for i = 2:lengthText
    %   get next input character
    nextChar = encodedText(i);
    %   combine first and next character
    nextStr = strcat(STRING, nextChar);
    %   check if nextstr is in the dictionary
    if any(strcmp(lzwBaseDictionary, nextStr))
        STRING = nextStr;
    else
        %   get the code for the string
        j = 0;
        for k = 1:length(lzwBaseDictionary)
            if (strcmp(lzwBaseDictionary{k}, STRING))
                j = k;
                break;
            end
        end
        % transmit the code
        lzwDictionary{length(lzwDictionary)+1} = j;
        if (j~=0)
            %   add the string in the dictionary
            lzwBaseDictionary{length(lzwBaseDictionary)+1} = nextStr;
            %   move to next character
            STRING = nextChar;
        end
        
    end
    %   display progress
    dispstat(sprintf('Processed %d samples of %d samples.', i, lengthText));
end
%   get the code for the string
j = 0;
for k = 1:length(lzwBaseDictionary)
    if (strcmp(lzwBaseDictionary{k}, STRING))
        j = k;
        break;
    end
end
% transmit the code
lzwDictionary{length(lzwDictionary)+1} = j;
if (j~=0)
    STRING = nextChar;
end

lzwDictionaryEncodedAsBytes = getByteStreamFromArray(cell2mat(lzwDictionary));

% Save the workspace
dispstat(sprintf('Saving the workspace...'),'keepthis','timestamp');
workspaceName = '';
for i = 1:length(filename)-4
	workspaceName(i) = filename(i);
end
save(workspaceName);

% Save the file
dispstat(sprintf('Generating file...'),'keepthis','timestamp');
workspaceName = strcat(workspaceName,'.dat');
fileID = fopen(workspaceName, 'w');
fwrite(fileID,lzwDictionaryEncodedAsBytes);
fclose(fileID);

dispstat(sprintf('Done.'),'keepthis','timestamp');


