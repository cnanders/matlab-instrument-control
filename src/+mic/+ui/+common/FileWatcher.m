classdef FileWatcher < mic.ui.common.Base

   
    properties (Constant, Access = private)
    end
    

    properties

        
        % val is not a property because it can be several different types.
        % We use get() and set() methods that force the correct type
    end


    properties (Access = private)
    
        cTargetDirectory = ''
        clock
        dDelay = 1
        dHeight
        dWidth
        dLastDateNum = 0
        
        hPanel
       
        uiCheckBoxEnable
        uiEditDir
        uiButtonSelectDir
        
        uiImageAutoLoader
        
        hCallback = @()[]
        
        ceFileTypes = {'jpg', 'png', 'spe', 'bmp'}
        
    end


    properties (SetAccess = private)
        
       
    end

    events
    end

    %%
    methods
        
        %% constructor
        % cLabel, cType, lShowLabel, cHorizontalAlignment
        function this = FileWatcher(varargin)

            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            

            this.uiButtonSelectDir = mic.ui.common.Button(...
                'cText', 'Choose directory', 'hDirectCallback', @this.selectDir ...
            );
            
            this.uiEditDir = mic.ui.common.Edit('cLabel', 'Active Dir');
            
            this.uiCheckBoxEnable = mic.ui.common.Checkbox('cLabel', 'Enable');
            
            if ~isempty(this.clock)
                this.clock.add(@this.watch, this.id(), this.dDelay);
            end
        
        end
        
         function delete(this)

           % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task'); 
                this.clock.remove(this.id());
            end
          
         end
        
        
        
         
         

        %% Build
        function build(this, hParent, dLeft, dTop)

            % build panel:
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'FileWatcher',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [dLeft, dTop, 500, 50] ...
                );
            
  
            this.uiEditDir.build(this.hPanel, 10, 10, 250, 20);
            this.uiButtonSelectDir.build(this.hPanel, 270, 23, 100, 20);
            this.uiCheckBoxEnable.build(this.hPanel, 390, 23, 90, 20);
            
                       
        end

        
        function selectDir(this, src, evt)
            d = uigetdir();
            this.cTargetDirectory = d;
            this.uiEditDir.set(d);
        end
        
        
        function letMeIn(this)
           1; 
        end
        
        
        function watch(this)
            if ~this.uiCheckBoxEnable.get()
                return;
            end
            
            if isempty(this.cTargetDirectory)
                return
            end
            
            % get files in dir:
            fls = dir(this.cTargetDirectory);
            for k = length(fls):-1:1
                if length(fls(k).name) < 4
                    fls(k) = [];
                    continue;
                end
                if ~(any(strcmpi(fls(k).name(end-2:end), this.ceFileTypes)))
                    fls(k) = [];
                    continue;
                end
                
            end
            
            % find max dateNum:
            dTempDateNum = 0;
            dMaxIdx = 0;
            for k = 1:length(fls)
                if fls(k).datenum > dTempDateNum
                    dTempDateNum = fls(k).datenum;
                    dMaxIdx = k;
                end
            end
            
            if dTempDateNum > this.dLastDateNum
                this.dLastDateNum = dTempDateNum;
                this.hCallback(this, this.cTargetDirectory, fls(dMaxIdx).name);
            end
            
            
            
            
        end

    end

    methods (Access = protected)


        


    end
end