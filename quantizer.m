% 
% Author : Sarthak Jain
% Version : 10.0
% Filename : quantizer.m
% Last Updated : December 23 2017 18:00
% Description : New quantizer script that performs the following functions :
%			1. Read the audio file for samples and sampling frequency
%			2. Convert the audio samples to 8X8 blocks
%			3. Perform the Discrete Cosine Transform on each blocks
%			4. Convert the DCT samples back to origin array
% 			5. Quantize the DCT array using inbuilt uencode function
% 			6. Convert the encoded data into ASCII characters using dictionary
% Next step will be to perform the compression of the ASCII characters using 
% the LZW compression Algorithm

% Clear the workspace and command window
clear all;
close all; 
clc;

% Start the timing 
tic;

% Initialize the progress meter
dispstat('', 'init');

% Get the audio file as path
filename = input('Enter the filename in quotes : ');

% Store the samples in data variable and sampling frequency in Fs
[data,Fs] = audioread(filename);

% Roll the intro
dispstat(sprintf('Begining the compression process...'),'keepthis','timestamp');

% Count the total number of samples
numberSamples = numel(data);

% Count the number of rows and columns in the data
dataRows = size(data,1);
dataColumns = size(data,2);

% Convert the data matrix into vector
dataVector = data(:);

% find the number of blocks
numberBlocks = ceil(numberSamples/64);
lastBlockSize = rem(numberSamples,64);

dispstat(sprintf('Converting the data...'),'keepthis','timestamp');
% Convert the data into 8x8 blocks except the last block
dataBlocks = {};
for i = 1:numberBlocks-1
	dataBlocks{i} = reshape(dataVector(64*(i-1)+1:64*i),8,8);
end

% Convert the last block into x8 matrix
lastDataBlock = reshape(dataVector(64*(numberBlocks-1)+1:numberSamples), 8, []);

% the final data block
dataBlocks{numberBlocks} = lastDataBlock;

% Perfom DCT on each data block
dispstat(sprintf('Transforming data...'),'keepthis','timestamp');
dctDataBlocks = {};
for i = 1:numberBlocks
	dctDataBlocks{i} = dct(dataBlocks{i});
end

% Convert the DCT blocks back to vector
for i = 1:numberBlocks
	dctDataBlocks{i} = reshape(dctDataBlocks{i}, [], 1);
end
dctDataVector = cell2mat(dctDataBlocks(1:numberBlocks-1));
reshape(dctDataVector,[],1);
% append the last block
dctDataVector = [dctDataVector(:); dctDataBlocks{numberBlocks}(:)];

% Quantize the DCT data as 8-bit
dispstat(sprintf('Quantizing and encoding data...'),'keepthis','timestamp');
quantizedDctDataVector = uencode(dctDataVector,8);

% Determine all the quantum levels obtained as result of quantization
quantumLevels = unique(quantizedDctDataVector);
numberQuantumLevels = numel(quantumLevels);

% Encode the Quantum levels to ASCII 
encodedText = char(quantizedDctDataVector);

% Write the encoded data to a file
% (for testing only,remove this in the final version)
% Save the workspace
dispstat(sprintf('Saving the workspace...'),'keepthis','timestamp');
workspaceName = '';
for i = 1:length(filename)-4
	workspaceName(i) = filename(i);
end
save(workspaceName);
% Write the encoded data to a file
% (for testing only,remove this in the final version)
workspaceName = strcat(workspaceName,'.txt');
fileId = fopen(workspaceName,'w');
fprintf(fileId,'%s',encodedText);
fclose(fileId);

dispstat(sprintf('Done.'),'keepthis','timestamp');
toc;
