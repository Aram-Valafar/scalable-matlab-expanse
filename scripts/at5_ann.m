% AT5: Non-CNN ANN (MLP) for regression — CPU and GPU compatible
% Demonstrates broader ANN support beyond CNN/RNN

rng(42);
numObs      = 500;
numFeatures = 20;

% Synthetic regression data
X = rand(numObs, numFeatures);
Y = sum(X(:, 1:5), 2) + 0.1 * randn(numObs, 1);

% MLP architecture (non-CNN, non-RNN)
layers = [
    featureInputLayer(numFeatures)
    fullyConnectedLayer(128)
    reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(1)
    regressionLayer
];

% Detect execution environment
if gpuDeviceCount > 0
    execEnv = 'gpu';
    g = gpuDevice(1);
    fprintf('AT5: GPU detected — %s\n', g.Name);
    fprintf('AT5: GPU available memory: %.2f GB\n', g.AvailableMemory / 1e9);
else
    execEnv = 'cpu';
    fprintf('AT5: No GPU detected, running on CPU\n');
end

opts = trainingOptions('adam', ...
    'MaxEpochs',           20,      ...
    'MiniBatchSize',       64,      ...
    'ExecutionEnvironment', execEnv, ...
    'Verbose',             true,    ...
    'Plots',               'none');

fprintf('AT5: Training MLP (%s)...\n', execEnv);
net = trainNetwork(X, Y, layers, opts);
fprintf('AT5: Training complete\n');

% Save model
outdir = getenv('WORKDIR');
if isempty(outdir)
    outdir = getenv('HOME');
end
outfile = fullfile(outdir, 'at5_model.mat');
save(outfile, 'net');
fprintf('AT5: Model saved to %s\n', outfile);
