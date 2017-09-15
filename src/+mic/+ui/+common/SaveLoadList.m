classdef SaveLoadList < mic.ui.common.Base

    properties

        hGetCallback
        hSetCallback
        cConfigPath = ''
        
        
        % val is not a property because it can be several different types.
        % We use get() and set() methods that force the correct type
    end


    properties (Access = private)
    
        
        cePositions
  
        uiList
        uibSave
        uibLoad
        uibSync
        
        uiePosName
        
        hPanel
        
        
    end


    properties (SetAccess = private)
        
       
    end

    events
    end

    %%
    methods
        
        % constructor
        % cLabel, cType, lShowLabel, cHorizontalAlignment
        function this = SaveLoadList(varargin)
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end
            
           
            this.uiList = mic.ui.common.List('cLabel', 'Saved Locations', 'lShowRefresh', false);
            
            % load options:
            load([this.cConfigPath, '/saveLoad.mat']);
            if exist('options', 'var') ~= 1
                options = {};
            end
            
            if length(options(:)) > 0
                this.uiList.setOptions(options(:,1));
            end
            
            this.cePositions = options;
            
            this.uibSave = mic.ui.common.Button(...
                'cText', 'Save position', 'fhDirectCallback', @this.savePosition ...
            );
            this.uibLoad = mic.ui.common.Button(...
                'cText', 'Load position', 'fhDirectCallback', @this.loadPosition ...
            );
        
            this.uibSync = mic.ui.common.Button(...
                'cText', 'Sync', 'fhDirectCallback', @this.syncPositionLists ...
            );
        
        
        
            this.uiePosName = mic.ui.common.Edit('cLabel', 'Positon label', 'cType', 'c');

        
        end

        % Build
        function build(this, hParent, dLeft, dTop)

            % build panel:
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [dLeft, dTop, 500, 270] ...
                );
            
            this.uiList.build(this.hPanel, 10, 20, 280, 200);
            this.uibLoad.build(this.hPanel, 320, 30, 80, 20);
            this.uibSave.build(this.hPanel, 320, 110, 80, 20);
            this.uibSync.build(this.hPanel, 320, 150, 80, 20);
            
            this.uiePosName.build(this.hPanel, 320, 70, 150, 20);
            this.uiePosName.set('New position');
        end


        function syncPositionLists(this, src)
            listOptions = this.uiList.getOptions();
            
            % Create new list:
            newPositions = {};
            for k = 1:length(listOptions)
                newPositions{k,1} = listOptions{k};
                for m = 1:length(this.cePositions(:,1));
                    if strcmp(newPositions{k,1}, this.cePositions{m,1})
                        newPositions{k,2} = this.cePositions{m,2};
                    end
                end
            end
            
            this.cePositions = newPositions;
            
            % save back to file:
            options = this.cePositions;
            save([this.cConfigPath, '/saveLoad.mat'], 'options');
            
        end
        
        function savePosition(this, src)
            cPosName = this.uiePosName.get();
            
            % load options
            listOptions = this.uiList.getOptions();
            
            % check if this name already exists:
            for k = 1:size(this.cePositions, 1)
                if strcmpi(cPosName, this.cePositions{k,1})
                    error('Already a position with this name');
                end
            end
            for k = 1:length(listOptions)
                if strcmpi(cPosName, listOptions{k})
                    error('Already a position with this name');
                end
            end
            
            
            listOptions{end+1} = cPosName;
            this.uiList.setOptions(listOptions);
            
            idx = size(this.cePositions, 1) + 1;
            this.cePositions{idx, 1} = cPosName;
            this.cePositions{idx, 2} = this.hGetCallback();
            
            this.syncPositionLists();
        end
        
        function loadPosition(this, src)
            % get selected option:
            cSelectedVal = this.uiList.get();
            
            % find this entry in our options list:
            val = [];
            for k = 1:size(this.cePositions, 1)
                if strcmpi(this.cePositions{k,1}, cSelectedVal)
                    val = this.cePositions{k,2};
                    break;
                end
            end
            if isempty(val)
                error ('no matching value found');
            end
            
            this.hSetCallback(val);
        end
        
   
        
        function letMeIn(this)
           1; 
        end
        
  
        

    end

    methods (Access = protected)


        


    end
end