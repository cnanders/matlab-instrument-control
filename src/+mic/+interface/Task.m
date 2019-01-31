classdef Task < mic.Base

    methods (Abstract)
        
        % executes
        execute(this)
        
        % aborts
        abort(this)
       
        % returns true when executing
        % @return {logical 1x1}
        l = isExecuting(this)
       
        % returns true when goal of task is satisfied
        % @return {logical 1x1} 
        l = isDone(this)
        
        % returns the message to dispaly to the user for this state
        % @return {char 1xm}
        c = getMessage(this)
        
        
        
        
    end
    
end
        
