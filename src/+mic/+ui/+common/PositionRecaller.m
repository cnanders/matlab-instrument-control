% A UI class desgined for saving and loading coupled-axis states to JSON.
% Will build test class soon

classdef PositionRecaller < mic.ui.common.Base

    properties

        hGetCallback
        hSetCallback
        cConfigPath = ''
        
    end


    properties (Access = private)
    
        % Array of structures that stores key-value pairs [{key: ...,
        % value: ...}, {key, ... ]
        
        cName = '' % Need a name for this to keep JSON unique
        
        stPositionsArray = struct([])
        
        cJsonPath
        
        uiList
        uibSave
        uibLoad
        
        lDisableSave = false
        
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
        function this = PositionRecaller(varargin)
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end
            
            if isempty(this.cConfigPath)
                error('PositionRecaller: Must specify a configuration path: cConfigPath');
            end
            if isempty(this.cName)
                error('PositionRecaller: Must specify a unique name for storing JSON');
            end
            
           
            this.uiList = mic.ui.common.List('cLabel', this.cName, 'lShowRefresh', false, ...
                        'fhDirectCallback', @this.syncAndSave);
            
            % Try loading corresponding JSON

            this.cJsonPath = fullfile(this.cConfigPath, [this.cName '-recall.json']);
            fid = fopen(this.cJsonPath, 'r');
            if (fid ~= -1)
                cTxt = fread(fid, inf, 'uint8=>char');
                this.stPositionsArray = jsondecode(cTxt);
                fclose(fid);
            end
            
            
            if ~isempty(this.stPositionsArray)
                this.uiList.setOptions(this.makeOptionsfromPositions());
            end
            
            
            this.uibSave = mic.ui.common.Button(...
                'cText', 'Save position', 'fhDirectCallback', @this.savePosition ...
            );
            this.uibLoad = mic.ui.common.Button(...
                'cText', 'Load position', 'fhDirectCallback', @this.loadPosition ...
            );
        

            this.uiePosName = mic.ui.common.Edit('cLabel', 'Positon label', 'cType', 'c');

        
        end

        % Build
        function build(this, hParent, dLeft, dTop, dWidth, dHeight)

            % build panel:
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [dLeft, dTop, dWidth, dHeight] ...
                );
            
            this.uiList.build(this.hPanel, 10, 7, dWidth/2 + 25, dHeight - 57);
            this.uibLoad.build(this.hPanel,  dWidth/2 + 50, 40, 110, 20);
            
            if ~this.lDisableSave
                this.uibSave.build(this.hPanel,  dWidth/2 + 50, 110, 110, 20);

                this.uiePosName.build(this.hPanel,  dWidth/2 + 50, 70, 110, 20);
                this.uiePosName.set('New_position');
            end
        end

        function syncAndSave(this)
            ceListOptions = this.uiList.getOptions();
            
            if (~isempty(ceListOptions))
                for k = 1:length(ceListOptions)
                    stNewOptionsArray(k) = struct('key', ceListOptions{k}); %#ok<AGROW>
                end
            else
                stNewOptionsArray = struct([]);
            end
            
            % For each new option, loop through old options and transfer
            
            for k = 1:length(stNewOptionsArray)
                cKey = stNewOptionsArray(k).key;
                
                for m = 1:length(this.stPositionsArray)
                    if strcmp(cKey, this.stPositionsArray(m).key) % then transfer value
                        stNewOptionsArray(k).value = this.stPositionsArray(m).value; %#ok<AGROW>
                    end
                end
            end

            this.stPositionsArray = stNewOptionsArray;
            
            % save back to file:
            cJsonEncodedOptions = jsonencode(this.stPositionsArray);
            fid = fopen(this.cJsonPath, 'w+');
            fprintf(fid, cJsonEncodedOptions);
            fclose(fid);
            
        end
        
        function programmaticSave(this, cStoreName)
            this.uiePosName.set(cStoreName);
            this.savePosition();
        end
        
        function savePosition(this, ~, ~)
            cPosName = this.uiePosName.get();
            
            % load options
            listOptions = this.uiList.getOptions();
            
            % check if this name already exists:
            for k = 1:length(listOptions)
                if strcmpi(cPosName, listOptions{k})
                    error('Already a position with this name');
                end
            end
            
            
            listOptions{end+1} = cPosName;
            this.uiList.setOptions(listOptions);
            
            % make structure:
            st = struct();
            st.key = cPosName;
            st.value = this.hGetCallback();
                        
            % need to do this to avoid subscript dimension mismatches:
            if (isempty(this.stPositionsArray))
                 this.stPositionsArray = st;
            else
                this.stPositionsArray(end + 1) = st;
            end
            
            this.syncAndSave();
        end
        
        function loadPosition(this, ~, ~)
            % get selected option:
            cSelectedVal = this.uiList.get();
            
            % find this entry in our options list:
            val = [];
            for k = 1:length(this.stPositionsArray)
                if strcmpi(this.stPositionsArray(k).key, cSelectedVal)
                    val = this.stPositionsArray(k).value;
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

        function ceOptions = makeOptionsfromPositions(this)
            ceOptions = {};
            for k = 1:length(this.stPositionsArray)
                ceOptions{k} = this.stPositionsArray(k).key;
            end
        end
        


    end
end