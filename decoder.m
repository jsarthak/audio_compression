% 
% Author : Sarthak Jain
% Version : 10.0
% Filename : quantizer.m
% Last Updated : December 23 2017 19:00
% Description : New dequantizer script that performs the following functions :
%			

% Clear the workspace and command window
clear all;
close all; 
clc;

% Start the timing 
tic;

% Initialize the progress meter
dispstat('', 'init');

% Load the previous workspace.
filename = input('Enter the filename in quotes : ');
dispstat(sprintf('Loading workspace...'),'keepthis','timestamp');
workspaceName = '';
for i = 1:(numel(filename)-4)
    workspaceName(i) = filename(i);
end
load(workspaceName);


dequantizeDctDataVector = udecode(uint8(decodedText),8);

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
audiowrite(strcat(workspaceName,'_decoded.wav'),decompressedData,Fs);

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