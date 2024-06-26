classdef PClockTask < mic.Base

    %{
        A clock task that can be added to a PClock
    %}
    
    
    %% Properties
	properties
        cName % name ('identifier') of the Clock
        dLastExecutionTime = -1
        dPeriod = 0.1
        lActive = true
        lPersistent = false % task does not deactivate when deactivated by source
        lOneShot = false
        cSource = 'none'
        hFn = @()[]
    end
    
    
    methods
    %% Methods
        function this = PClockTask(cName, varargin)
            this.cName = cName;
            for k = 1:2:length(varargin)
                switch varargin{k}
                    case 'dPeriod'
                        this.dPeriod = varargin{k + 1};
                    case 'lActive'
                        this.lActive = varargin{k + 1};
                    case 'lPersistent'
                        this.lPersistent = varargin{k + 1};
                    case 'cSource'
                        this.cSource = varargin{k + 1};
                    case 'hFn'
                        this.hFn = varargin{k + 1};
                    case 'lOneShot'
                        this.lOneShot = varargin{k + 1};
                    otherwise
                        error('Unknown parameter name: %s', varargin{k});
                end
            end
        end

        % Make inactive all non-persistent tasks from this source
        function deactivateBySource(this, cSource)
            if strcmp(this.cSource, cSource)
                this.lActive = false;
            end
        end

        % Make active all tasks from this source
        function activateBySource(this, cSource)
            if strcmp(this.cSource, cSource)
                this.lActive = true;
            end
        end
        
    end
end