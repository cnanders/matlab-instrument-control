classdef   GetSetNumber < mic.interface.ui.device.Base
    
    %GETSETNUMBER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
                
        d = getDestCal(this, cUnit)
        %DESTCAL Get the abs destination in a calibrated unit.  
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in. We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale.
        %   @return {double} - the calibrated value
        %   see also DESTCALDISPLAY
        
        d = getDestCalDisplay(this)
        %DESTCALDISPLAY Get the destinatino as shown in the UI with the active
        %display unit and abs/rel state 
        
        d = getDestRaw(this)
        %DESTRAW Get the abs dest value in raw units. Raw value can never
        %changed with the UI configuration so this returns the same thing
        %regardless of UI configuration.
        
        setDestCal(this, dCalAbs, cUnit)
        % SETDESTCALABS Update the destination inside the mic.ui.common.Edit based on
        % an absolute value in a particular unit.
        %   @param {double} dCal - desired destination in an abs calibrated
        %       unit (regardless of the UI's "abs/rel" state).
        %   @param {char} [cUnit = this.getUnit().name] - the name of the 
        %       unit you are passing in. If this is not set, it will be
        %       assumed that the unit is unit the UI is showing.
        %   EXAMPLE: If the UI was put into "rel" mode when the value was
        %       5 mm and you want the destination to be +1 mm (relative
        %       change), dCalAbs should be 6 and cUnit should be "mm".  
        %       See also SETDESTCAL, SETDESTRAW
        
        setDestCalDisplay(this, dCal, cUnit)
        %SETDESTCAL Update the destination (cal) inside the dest mic.ui.common.Edit.
        %   @param {double} dCal - desired destination in a calibrated
        %       unit that can be either "abs" or "rel" (should match UI state)
        %       If the UI is in "abs" mode, it is assumed
        %       the value passed in is an "abs" value; if the UI is in "rel"
        %       mode, it is assumed the value passed in is a "rel" value
        %       (relative to a stored zero).  If you need to set the
        %       destination with an "abs" value even when the UI is displaying
        %       a "rel" value, use setDestCalAbs.  
        %   @param {char} [cUnit = this.getUnit().name] - the name of the 
        %       unit you are passing in. If this is not set, it will be
        %       assumed that the unit is unit the UI is showing.
        %   EXAMPLE: If the UI was put into "rel" mode when the value
        %       was 5 mm and you want the absolute destination to be 6 mm,
        %       dCal should be 1 and cUnit should be "mm".  Alternatively,
        %       you could use setDestCalAbs(6, "mm")
        %   See also SETDESTCALABS, SETDESTRAW
        
        setDestRaw(this, dRaw)
        %SETDESTRAW Update the destination inside the dest mic.ui.common.Edit from a
        %raw value.  The raw value is converted to the unit and abs/rel
        %settings of the UI
        
        moveToDest(this)
        %MOVETODEST Converts the destination from the display units to raw 
        % units and calls .set() on the active device, passing the raw
        % target value 
        
        stop(this)
        %Aborts the current motion.  Calls stop() on active device
        
        d = getValCal(this, cUnit)
        %VALCAL Get the abs value (not relative to a stored zero) in a calibrated unit.
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in.  We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale. 
        %   @returns {double} - the calibrated value
        %
        %   If you want the value showed in the display (with the active
        %   display unit and abs/rel state use getValCalDisplay()
        
        d = getValCalDisplay(this)
        %VALCALDISPLAY Get the value as shown in the UI with the active
        %display unit and abs/rel state
        
        d = getValRaw(this)
        %VALRAW Get the value in  raw units. 
        
        % @return { struct 1x1 }
        st = getUnit(this)
        
        setUnit(this, cUnit)
        %SETUNIT set the active display unit by name
        %   @param {char} cUnit - the name of the unit, i.e., "mm", "m"
        
        stepNeg(this)
        %STEPPOS Increment dest by -jog step and move to dest.  Units don't
        %come into play here because the dest and the step are in the same
        %unit.  Identical to the user clicking the "-jog" button
        
        stepPos(this)
        %STEPPOS Increment dest by +jog step and move to dest.  Units don't
        %come into play here because the dest and the step are in the same
        %unit.  Identical to the user clicking the "+jog" button
        
        
  
    end
    
end

