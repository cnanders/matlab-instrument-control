[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirMic));
purge

cPathConfig = fullfile(...
    mic.Utils.pathConfig(), ...
    'get-set-number', ...
    'config-default-inverse.json' ...
);
        
tic
config = mic.config.GetSetNumber('cPath', cPathConfig);
toc



