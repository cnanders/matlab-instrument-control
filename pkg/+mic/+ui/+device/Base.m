classdef Base < mic.Base
    %BASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = protected)
        
        % {uint8 24x24} images for play/pause
        u8Play = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'play-24.png'));
        u8Pause = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'pause-24.png'));
        
        % {uint8 24x24} - images for the device real/virtual toggle
        u8ToggleOn = imread(fullfile(mic.Utils.pathImg(), 'toggle', 'horiz-1', 'toggle-horiz-24-true.png'));     
        u8ToggleOff = imread(fullfile(mic.Utils.pathImg(), 'toggle', 'horiz-1', 'toggle-horiz-24-false-yellow.png'));           
        
        % {uint8 24x24} - images for the initialize button/state UI
        u8InitTrue = imread(fullfile(mic.Utils.pathImg(), 'init', 'init-button-true.png'));
        u8InitFalse = imread(fullfile(mic.Utils.pathImg(), 'init', 'init-button-false-yellow.png'));
    end
    
    methods
    end
    
end

