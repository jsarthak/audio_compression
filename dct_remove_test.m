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
    X = dctDataBlocks{i};
    X = X(:);
    [XX,ind] = sort(abs(X),'descend');
    j = 1;
    while norm(X(ind(1:j)))/norm(X) < 0.99
       j = j + 1;
    end
    needed = j;
    X(ind(needed+1:end)) = 0;
    dctDataBlocks{i} = X;
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

dequantizeDctDataVector = udecode(uint8(encodedText),8);
iblocks = {};
for i = 1:numberBlocks-1
    iblocks{i} = idct(reshape(dequantizeDctDataVector(64*(i-1)+1:64*i),8,8));
end
for i = 1:numberBlocks-1
    iblocks{i} = reshape(iblocks{i}, [],1);
end
% TODO : Fix the code for the last block
idctDataVector = cell2mat(iblocks);
decompressedData = reshape(idctDataVector, [], dataColumns);
audiowrite(strcat(filename,'_decoded.wav'),decompressedData,Fs);

dispstat(sprintf('Performing SNR calculations...'),'keepthis','timestamp');
%power of original signal
Ps = sum(data(:).*data(:)/2);

%power of noise
for i = 1:length(decompressedData)
    noise(i) = data(i) - decompressedData(i);
end
Pn = sum(noise.*noise/2);

%signal to noise ratio
SNR = 10*log(Ps/Pn)