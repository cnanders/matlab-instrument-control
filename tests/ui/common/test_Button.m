% Add mic
try
    purge
    
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

addpath(genpath(cDirMic));

cPathImg = fullfile(mic.Utils.pathImg(), 'zero', 'axis-zero-24-2.png');

u8Zero = imread(cPathImg);
% u8Zero = imread(cPathImg);

%{
cPathImg = fullfile(mic.Utils.pathImg(), 'loading-24px.gif');
[X,map] = imread(cPathImg, 'GIF');
imshow(X,map)
%}

fhDirect = @(src, evt) disp('cb Direct\n');

uiButton = mic.ui.common.Button( ...
    'cText', 'Zero', ...
    'lImg', true, ...
    'u8Img', u8Zero, ...
    'fhOnPress', @(src, evt) disp('pressed'), ...
    'fhOnRelease', @(src, evt) disp('released'), ...
    'fhDirectCallback', fhDirect ...
);

h = figure;
uiButton.build(h, 10, 10, 24, 24);
% uiButton.disable();

cb = @(src, evt) (fprintf('mic.ui.common.Button press\n'));
addlistener(uiButton, 'ePress', cb);

