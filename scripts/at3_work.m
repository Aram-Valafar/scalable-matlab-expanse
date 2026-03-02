% AT3: Write small checkpoint files to node-local scratch only
workdir = getenv('WORKDIR');
if isempty(workdir)
    error('WORKDIR environment variable not set');
end

for i = 1:5
    fname = fullfile(workdir, sprintf('checkpoint_%d.mat', i));
    data = struct('task', i, 'value', rand(10,10));
    save(fname, 'data');
    fprintf('Wrote checkpoint_%d.mat to local scratch\n', i);
end
fprintf('AT3: all checkpoints written to local scratch\n');
