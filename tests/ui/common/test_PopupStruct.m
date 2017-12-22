[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

u8Num = 8;
ceOptions = cell(1, u8Num);

fhDirect = @(src, evt) disp('cb Direct');

for n = 1 : u8Num
                
    stOption = struct( ...
        'cLabel', sprintf('Val %1.0f', n), ...
        'cVal', n ...
    );
    ceOptions{n} = stOption;

    fprintf('{\n');
    fprintf('"name": "%d",\n', n);
    fprintf('"raw": %d\n', n);
    fprintf('},\n');
  
end
            
h = figure();

ui = mic.ui.common.PopupStruct( ...
    'fhDirectCallback', fhDirect, ...
    'ceOptions', ceOptions ...
);

ui.build(h, 10, 10, 300, 30);

cb = @(src, evt) (fprintf('mic.ui.common.Popup eChange to item %1d\n', src.getSelectedIndex()));
addlistener(ui, 'eChange', cb);


u8Num = 3;
ceOptions2 = cell(1, u8Num);
for n = 1 : u8Num
                
    stOption = struct( ...
        'cLabel', sprintf('Val %1.0f', n), ...
        'cVal', n ...
    );
    ceOptions2{n} = stOption;

    fprintf('{\n');
    fprintf('"name": "%d",\n', n);
    fprintf('"raw": %d\n', n);
    fprintf('},\n');
  
end


