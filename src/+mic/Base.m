classdef Base < handle
%Base is an overloaded handle class that implements useful functions
%   Among these functions are the ability to recursively save and load
%   an instance of a child class.

    % 2014.05.08 CNA
    % I thought it would be a good idea to make cName a protected property,
    % but I realized most of the classes don't have a cName property. It is
    % realy only HardwareIO, HardwareO classes that need them.  We will
    % make them public properties to the msg() method can access them
    
    %{
    properties (Access = protected)
        cName   = 'Unnamed';
    end
    %}
    
    properties (Access = protected)
        u8verbosity = 5;
    end
    
    
    methods


    end 
    
    % 2013-11-20 AW added method overloads to remove 'handle' class
    % for the listed methods of the class.
    % This is better for cod pretty-print and autocompletion
    % http://stackoverflow.com/questions/6621850/is-it-possible-to-hide-the-methods-inherited-from-the-handle-class-in-matlab
    methods(Hidden)
        
        
        function msg(this, cMsg, u8verbosity_level)
        % Outputs a message in the command window
        %   Base.msg('Hello World')
        %     similar to disp() except that channeling every fprintf or
        %     disp through this method lets us easily eliminate all print
        %     or only show certain ones.  I've found it really helpful in
        %     other projects to do something like this.  Especially
        %     event-based projects.  Also, if you make the message prefixed
        %     with the class name, you can put logic in here to only echo
        
        % 0 : always shows
        % 1 : show by default
        % 2 : show errors
        % 3 : something is sent
        % 4 : something is received
        % 5 : something is activated/deactivated
        % 6 : event addition or clock
        % 7 : something loaded/saved (parameters)
        % 8 : something is instantiated/deleted
        % 9 : show everything
            
            % April 2016 (AW) addition of verbosity parameteres
            
            cTimestamp = datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local');
            
            try
                if nargin<3
                    u8verbosity_level = 0;
                end
                
                
                if u8verbosity_level<=this.u8verbosity
                    fprintf('%s: %s %s\n', cTimestamp, this.id(), cMsg);
                end
                
            catch
                fprintf('%s: %s %s\n', cTimestamp, this.id(), cMsg);
            end
        end
        

        function cID = id(this)
        %ID Gives the Class of which this object is an instance
        %   cID = Base.id()
            if this.hasProp( 'cName')
                cID =  sprintf('%s-%s', class(this), this.cName);
            % elseif this.hasProp( 'cLabel')
                % cID =  sprintf('%s-%s', class(this), this.cLabel);
            else
                cID = class(this);
            end
        end
        
        
        %%
        % @param {char 1xm} c - name of property
        % @return {logical 1x1} - true if class has property
        
        function l = hasProp(this, c)
            l = false;
            if length(findprop(this, c)) > 0
                l = true;
            end
        end
        
        
        
        
        
        
        
        
    end
    
end %classdef
        
        
