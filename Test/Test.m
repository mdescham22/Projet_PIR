%%création de ma base de données labellisée
trainTable = readtable('trainLabels.csv');

oralSegments = {}; % initialisation du vecteur pour stocker les segments oraux
nasalSegments = {}; % initialisation du vecteur pour stocker les segments nasaux
oralSTFTs = {};
nasalSTFTs = {};

for i = 1:size(trainTable, 1)
    [audioData, sampleRate] = audioread(trainTable{i, 1}{1});
    startTime = 0;
    
    % calculer la durée totale du fichier audio
    audioDuration = length(audioData) / sampleRate;
    
    % calculer le temps de fin en fonction de la durée du fichier et du temps de début
    endTime = startTime + audioDuration;
    
    vowelType = trainTable{i, 2};
    
    % extraire le segment à partir des temps de début et de fin calculés
    startIdx = round(startTime * sampleRate) + 1;
    endIdx = round(endTime * sampleRate);
    segment = audioData(startIdx:endIdx);
    
    % ajouter le segment au vecteur correspondant en fonction de son type de voyelle
    if (vowelType== 1)
        oralSegments{end+1} = segment;
    elseif (vowelType== 2)
        nasalSegments{end+1} = segment;
    end

    
end

oralFeatures = [];
nasalFeatures = [];
% Définir les paramètres pour le calcul des spectrogrammes
windowSize = round(0.02 * sampleRate); % taille de la fenêtre en nombre d'échantillons (20 ms)
hopSize = round(0.01 * sampleRate); % taille du pas de la fenêtre en nombre d'échantillons (10 ms)
nfft = 2^nextpow2(windowSize); % nombre de points de la FFT (power of 2 for faster computation)

% Calculer les spectrogrammes pour les segments oraux
oralSTFTs = {};
for i = 1:length(oralSegments)
    if (size(oralSegments{i},1)==1) 
        oralSegments{i}=transpose(oralSegments{i});
    end
    [S, F, T] = spectrogram(oralSegments{i}, windowSize, hopSize, nfft, sampleRate);
    oralSTFTs{i} = abs(S);
    % Calculez les caractéristiques acoustiques pour chaque segment oral
        f0 = pitch(oralSegments{i}, sampleRate);
        rmsValue = rms(oralSegments{i});
        spectralcentroid = spectralCentroid(oralSegments{i}, sampleRate);
        %spectralrolloff = spectralRolloff(oralSegments{i}, sampleRate, 0.85);
        % Stocker les caractéristiques dans une matrice "oralFeatures"
        features = [transpose(f0), rmsValue, transpose(spectralcentroid)];
        oralFeatures = [oralFeatures; transpose(features)];
end

% Calculer les spectrogrammes pour les segments nasaux
nasalSTFTs = {};
for i = 1:length(nasalSegments)
    if (size(nasalSegments{i},1)==1) 
        nasalSegments{i}=transpose(nasalSegments{i});
    end
    [S, F, T] = spectrogram(nasalSegments{i}, windowSize, hopSize, nfft, sampleRate);
    nasalSTFTs{i} = abs(S);
     % Calculez les caractéristiques acoustiques pour chaque segment nasal
        f0 = pitch(nasalSegments{i}, sampleRate);
        rmsValue = rms(nasalSegments{i});
        spectralcentroid = spectralCentroid(nasalSegments{i}, sampleRate);
        %spectralrolloff = spectralRolloff(nasalSegments{i}{j}, sampleRate, 0.85);
        % Stocker les caractéristiques dans une matrice "nasalFeatures"
        features = [transpose(f0), rmsValue, transpose(spectralcentroid)];
        nasalFeatures = [nasalFeatures; transpose(features)];
end

oralData = [];
nasalData = [];

for i = 1:length(oralFeatures)
    % Concaténez les caractéristiques acoustiques et la STFT pour chaque segment oral
    oralData = vertcat(transpose(oralData), [oralFeatures(i, :), oralSTFTs{i}(:)']);
end

for i = 1:length(nasalFeatures)
    % Concaténez les caractéristiques acoustiques et la STFT pour chaque segment nasal
    nasalData = vertcat(nasalData, [nasalFeatures(i, :), nasalSTFTs{i}(:)']);
end

oralLabels = repmat({'oral'}, size(oralData, 1), 1);
nasalLabels = repmat({'nasal'}, size(nasalData, 1), 1);

data = horzcat(oralData, nasalData);
labels = vertcat(oralLabels, nasalLabels);

save('myDataset.mat', 'data', 'labels');




