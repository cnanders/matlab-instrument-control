

classdef test_PositionRecaller < mic.Base
    

    
    properties (Access = protected)
        
        % A unique name
        cName = 'test_positionRecaller';
        
        % Path to the folder where you will store the position data
        cConfigPath = fileparts(fullfile(mfilename('fullpath')))

        % Save load list for scan parameters
        uiprTest
        
        % Some edit boxes in your app
        uieParam1
        uieParam2

    end
    
    
    
    methods
        
        function this = test_PositionRecaller()
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

            cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

            % Add mic
            addpath(genpath(cDirMic));

            this.initAndBuild()
            
        end
        
        function initAndBuild(this)
            
            hFigure = figure();
            this.uiprTest = mic.ui.common.PositionRecaller(...
                'cConfigPath', this.cConfigPath, ... 
                'cName', this.cName, ...
                'cTitleOfPanel', 'Test Stores', ...
                'lShowLabelOfList', false, ...
                'hGetCallback', @this.fhGet, ...
                'hSetCallback', @this.fhSet);
            
            this.uieParam1       = mic.ui.common.Edit('cLabel', 'param1', 'cType', 'd');
            this.uieParam2       = mic.ui.common.Edit('cLabel', 'param2', 'cType', 'd');
            this.uieParam1.set(430);
            this.uieParam2.set(10.1234);
            
            
            this.uiprTest.build(hFigure, 20, 100, 380, 200);
            this.uieParam1.build(hFigure, 10, 50, 80, 20);
            this.uieParam2.build(hFigure, 150, 50, 80, 20);   
            
        end
        
        % Grab values from your app and store into dPositions
        function dPositions = fhGet(this)
            dPositions = [this.uieParam1.get(), this.uieParam2.get()];
        end
        
        % Recall values from store and do something with them:
        function fhSet(this, dPositions)
            this.uieParam1.set(dPositions(1));
            this.uieParam2.set(dPositions(2));
        end

        
        
    end
    
    
end