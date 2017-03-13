classdef GetSetNumber < mic.interface.device.GetSetNumber

    % deviceVirtual

    properties (Access = private)
        clock                      % Clock
        dPeriod = 200/1000;
        lIsInitialized = false;
        
        % {uint8 1x1} number of clock periods to move through path
        u8PathCycles = 10; 
        
        % {uint8 1x1} current path cycle (resets after move complete)
        u8PathCycle = 1; 

        % {double 1xu8PathCycles} values from current to dest during a move
        dPath
        
        % {double 1x1} current value [returned by get()]
        dVal = 0
        
        % {double 1x1} goal value. 
        dDest = 0
        
    end


    properties

        cName;
         

    end

            
    methods
        
        function this = GetSetNumber(varargin)

            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end       

        end

        function dReturn = get(this)
            dReturn = this.dVal;
        end


        function lIsReady = isReady(this)
            lIsReady = this.dVal == this.dDest;
        end
        
        
        function set(this, dDest)

            % Reset dPath and u8PathCycle and make sure the clock is calling
            % onClock().  onClock() advances u8PathCycle, updating
            % dDest as dPath(u8PathCycle).
            
            if isempty(this.clock)
                this.dVal = dDest;
                return;
            end
            
            
            this.dDest = dDest;
            this.dPath = linspace(this.dVal, this.dDest, this.u8PathCycles);
            this.u8PathCycle = 1;

            % 2013.07.08 CNA
            % Adding support for Clock

            % this.msg(sprintf('%s.moveAbsolute() calling this.c1.add()', this.id()));

            if ~this.clock.has(this.id())
                this.clock.add(@this.onClock, this.id(), this.dPeriod);
            else
                this.msg(sprintf('set() not adding %s', this.id()), 5);
            end

            % stop(this.t);
            % start(this.t);

        end 

        function stop(this)
            % stop(this.t);

            % Set destination to current position so subsequent calls to
            % isReady() returns true
            this.dDest = this.dVal;
            
            if ~isempty(this.clock)
                this.clock.remove(this.id());
            end
        end

       
        function delete(this)

            this.msg('delete()', 5);

            % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end


        end
        
        
        
        function initialize(this)
            this.lIsInitialized = true;
        end
        
        function l = isInitialized(this)
            l = this.lIsInitialized;
        end
        
        

    end %methods
    
    methods (Access = protected)
        
        
        function onClock(this)

            try


                % Update pos
                this.dVal = this.dPath(this.u8PathCycle);
                
                this.msg(sprintf('onClock() updating dVal to %1.3f', this.dVal), 5);

                % Do we need to stop the timer?
                if (this.dVal == this.dDest)
                    this.clock.remove(this.id());                
                end

            catch err
                this.msg(getReport(err), 2);
            end

            % Update counter
            if this.u8PathCycle < this.u8PathCycles
                this.u8PathCycle = this.u8PathCycle + 1;
            end

        end
    end
    
end %class
    

            
            
            
        