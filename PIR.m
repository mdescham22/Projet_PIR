% rng("default")
% zipFile = matlab.internal.examples.downloadSupportFile("audio","ESC-10.zip");
filepath = 'E:\Documents\MATLAB\Examples\R2022b\supportfiles\audio'
%filepath = fileparts(zipFile);
%dataFolder = fullfile(filepath,"ESC-10");
dataFolder = fullfile(filepath,"Vowels");
%unzip(zipFile,dataFolder)
ads = audioDatastore(dataFolder,IncludeSubfolders=true,LabelSource="foldernames");
labelTable = countEachLabel(ads)

classes = labelTable.Label;
numClasses = size(labelTable,1);
[adsTrain,adsValidation] = splitEachLabel(ads,0.8,0.2);

fs = 44.1e3;
duration = 0.5;
N = duration*fs;

wNoise = 2*rand([N,1000]) - 1;
wLabels = repelem(categorical("white"),1000,1);

bNoise = filter(1,[1,-0.999],wNoise);
bNoise = bNoise./max(abs(bNoise),[],'all');
bLabels = repelem(categorical("brown"),1000,1);

pNoise = pinknoise([N,1000]);
pLabels = repelem(categorical("pink"),1000,1);


sound(wNoise(:,1),fs)
melSpectrogram(wNoise(:,1),fs)
title('White Noise')


sound(bNoise(:,1),fs)
melSpectrogram(bNoise(:,1),fs)
title('Brown Noise')


sound(pNoise(:,1),fs)
melSpectrogram(pNoise(:,1),fs)
title('Pink Noise')


audioTrain = [wNoise(:,1:800),bNoise(:,1:800),pNoise(:,1:800)];
labelsTrain = [wLabels(1:800);bLabels(1:800);pLabels(1:800)];

audioValidation = [wNoise(:,801:end),bNoise(:,801:end),pNoise(:,801:end)];
labelsValidation = [wLabels(801:end);bLabels(801:end);pLabels(801:end)];


aFE = audioFeatureExtractor("SampleRate",fs, ...
    "SpectralDescriptorInput","melSpectrum", ...
    "spectralCentroid",true, ...
    "spectralSlope",true);


featuresTrain = extract(aFE,audioTrain);
[numHopsPerSequence,numFeatures,numSignals] = size(featuresTrain)


featuresTrain = permute(featuresTrain,[2,1,3]);
featuresTrain = squeeze(num2cell(featuresTrain,[1,2]));

numSignals = numel(featuresTrain)
[numFeatures,numHopsPerSequence] = size(featuresTrain{1})

featuresValidation = extract(aFE,audioValidation);
featuresValidation = permute(featuresValidation,[2,1,3]);
featuresValidation = squeeze(num2cell(featuresValidation,[1,2]));


layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(50,"OutputMode","last")
    fullyConnectedLayer(numel(unique(labelsTrain)))
    softmaxLayer
    classificationLayer];

options = trainingOptions("adam", ...
    "Shuffle","every-epoch", ...
    "ValidationData",{featuresValidation,labelsValidation}, ...
    "Plots","training-progress", ...
    "Verbose",false);

net = trainNetwork(featuresTrain,labelsTrain,layers,options);


wNoiseTest = 2*rand([N,1]) - 1;
classify(net,extract(aFE,wNoiseTest)')

bNoiseTest = filter(1,[1,-0.999],wNoiseTest);
bNoiseTest= bNoiseTest./max(abs(bNoiseTest),[],'all');
classify(net,extract(aFE,bNoiseTest)')

pNoiseTest = pinknoise(N);
classify(net,extract(aFE,pNoiseTest)')

