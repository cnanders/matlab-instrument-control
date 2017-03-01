MATLAB library for programmatically creating GUIs that control scientific instrumentation.  

# Documentation

- [mic.ui.common.*](#mic.ui.common)
- [mic.ui.device.*](#mic.ui.device)
	- [How `mic.ui.device.*` UI Controls Work](#how-devices-work)
	- [mic.ui.device.GetSetNumber](#mic.ui.device.GetSetNumber)
	- [mic.ui.device.GetSetLogical](#mic.ui.device.GetSetLogical)
 	- [mic.ui.device.GetSetText](#mic.ui.device.GetSetText)
	- [mic.ui.device.GetNumber](#mic.ui.device.GetNumber)
	- [mic.ui.device.GetLogical](#mic.ui.device.GetLogical)
	- [mic.ui.device.GetText](#mic.ui.device.GetText)


Docs are a work in progress.

<a name="mic.ui.common"></a>
# `mic.ui.common.*`

The MIC library is based on namespaced, object-oriented wrappers around MATLAB’s `uicontrol` elements, e.g., `edit`, `toggle`, and `popup`.  They are located at `mic.ui.common.*`. 

### Example

The following code can be used to create “MIC” versions of `edit` and `toggle` uicontrols. 

```
uiEdit = mic.ui.common.Edit();
uiToggle = mic.ui.common.Toggle();

% Add them to a figure
h = figure();
dUiWidth = 100;
dUiHeight = 30;
uiEdit.build(h, 10, 10, dUiWidth, dUiHeight);
uiToggle.build(h, 10, 50, dUiWidth, dUiHeight);
```

![mic.ui.device.GetSetNumber GIF](img-docs/simple-example-a.jpg?raw=true)

Their values can be retreived with

```
% Get {char} value of uiEdit
uiEdit.get()

% Get {logical} value of uiToggle
uiToggle.get()
``` 

![mic.ui.device.GetSetNumber GIF](img-docs/simple-example-b.jpg?raw=true)

Their values can be set with 

```
% Set {char} value of uiEdit (updates the display)
uiEdit.set('Test');

% Set {logical} value of uiToggle (updates the display)
uiToggle.set(true);
```

![mic.ui.device.GetSetNumber GIF](img-docs/simple-example-c.jpg?raw=true)


Every property of every class in `mic.ui.*` can be set on instantiation with the MATLAB [varargin](https://www.mathworks.com/help/matlab/ref/varargin.html) syntax, enabling full customization. 

All `mic.ui.common.*` UI controls implement the `mic.interface.ui.common.Base` interface (at minimum), which requires the following methods:

```
% Build the UI on a figure or uipanel. 
% mic.ui.common.* elements can be built in multiple places
build(this, hParent, dLeft, dTop, dWidth, dHeight)

% Remove a visible UI
hide(this)

% Show a hidden UI
show(this)

% Set the tooltip for mouse hover
% @param {char 1xm}
setTooltip(this, cTooltip)

% Disable user interaction
enable(this)

% Enable user interaction
disable(this)
```

Several `mic.ui.common.*` UI controls expose `set()` and `get()` methods.  The following table summarizes them along with their type:

<table>
	<tr>
		<th>Class</th>
		<th>Type used by set() and get()</th>
	</tr>
	<tr>
		<td>mic.ui.common.Toggle</td>
		<td>logical</td>
	</tr>
	<tr>
		<td>mic.ui.common.ButtonToggle</td>
		<td>logical</td>
	</tr>
	<tr>
		<td>mic.ui.common.Checkbox</td>
		<td>logical</td>
	</tr>
	<tr>
		<td>mic.ui.common.Edit</td>
		<td>char, single, double, int*, or uint* (configurable)</td>
	</tr>
	<tr>
		<td>mic.ui.common.Text</td>
		<td>char</td>
	</tr>
</table>

The interfaces of all UI controls are located at `mic.interface.ui.*` 

Most `mic.ui.common.*` classes expose events the consumer can listen for.  This lets the consumer respond to the user interacting with the GUI, e.g., clicking a `mic.ui.common.Button` or editing the value of a `mic.ui.common.Edit`.  

<a name="mic.ui.device"></a>
# `mic.ui.device.*`

The next layer of the UI controls are `device` controls.  These are UIs designed to control hardware. 99% of the time we communicate with hardware we: 

- Ask for a value
- Tell it to go to a new value

When we exchange data with hardware, the data always has a type.  Common user-facing data types are: 

<table>
	<tr>
		<th>Type</th>
		<th>MATLAB Class</th>
		<th>Example Use Case</th>
	</tr>
	<tr>
		<td>Numeric</td>
		<td>single, double, int*, uint*</td>
		<td>Get or set the position of a stage</td>
	</tr>
	<tr>
		<td>Boolean</td>
		<td>logical</td>
		<td>Get or set a binary switch</td>
	</tr>
	<tr>
		<td>String</td>
		<td>char</td>
		<td>More rare, but it does come up</td>
	</tr>
</table>

`mic.ui.device.*` contains a UI control for each common user-facing data type. 

<a name="how-devices-work"></a>
## How `mic.ui.device.*` UI Controls Connect To Hardware

- Each `mic.ui.device.*` must be passed a `device`.  A `device` is something that implements the `mic.interface.device.*` interface. 
- The `mic.ui.device.*` provides a UI for invoking all available methods of the `device` (the methods required by the `mic.interface.device.*` interface).  
- The `device` is responsible for appropriately communicating with hardware when its methods are evoked by `mic.ui.device.*`

<a name="mic.ui.device.GetSetNumber"></a>



### `mic.ui.device.GetSetNumber`

![mic.ui.device.GetSetNumber GIF](img-docs/mic.ui.device.GetSetNumber.gif?raw=true)

- A UI for invoking all methods of the provided `device`
- `device` implements `mic.interface.device.GetSetNumber`.
- Use this for getting / setting numeric properties of hardware. 
- UI options (all fully configurable):
	- Text label
	- Live updating value
		- Calls `device.get()` on timer
	- Edit box for setting a new value
		- Calls `device.set()` on change
    - Go/Pause button 
		- Calls `device.set()` or `device.stop()` depending on state when pressed
	- Jog buttons
		- These update the Edit box incrementally and trigger calls to `device.set()`
		- Configurable with `mic.config.GetSetNumber`
	- Selectable stored values
		- These update the Edit box and trigger a call to `device.set()`
		- Configurable with `mic.config.GetSetNumber`
	- Selectable units
	 	- units let you convert display values into a different unit than the hardware `device` provides
		- can configure as many units as you want but only linear conversions are supported
		- Configurable with `mic.config.GetSetNumber`
	- Initialization button
		- Calls `device.initialize()` on click
    - “Set Val“ button that allows the user to re-definine a new calibrated value of the current position
		- Behind the scenes this is storing an offset in `device` units so it is unit independent
	- “Abs/Raw” Toggle toggles the display values between using and not using the offset stored during the last “Set Val” (see previous item)
	- Range display shows the allowed range of the `device`.  Updates when units change
		- Configurable with `mic.config.GetSetNumber`
	- “Device” toggle that allows channeling all device calls through a “virtual” `device`.  This is useful during the development phase before harware is available. 
		- The “virtual” `device`, which `mic.ui.device.GetSetNumber` creates automatically, is an instance of `mic.device.GetSetNumber`.  It implements `mic.interface.device.GetSetNumber` and behaves like real hardware; e.g., it takes time to get to a target value.

<a name="mic.ui.device.GetSetLogical"></a>
### `mic.ui.device.GetSetLogical`
- A UI for invoking all methods of the provided `device`.
- `device` implements `mic.interface.device.GetSetLogical`.
- Use this for getting / setting boolean properties of hardware.

<a name="mic.ui.device.GetSetText"></a>
### `mic.ui.device.GetSetText`
- A UI for invoking all methods of the provided `device`.
- `device` implements `mic.interface.device.GetSetText`.
- Use this for getting / setting String properties of hardware.

<a name="mic.ui.device.GetNumber"></a>
### `mic.ui.device.GetNumber`
- A UI for invoking all methods of the provided `device`.  
- `device` implements `mic.interface.device.GetNumber`.  
- Use this for (only) getting numeric properties of hardware.

<a name="mic.ui.device.GetLogical"></a>
### `mic.ui.device.GetLogical`
- A UI for invoking all methods of the provided `device`.
- `device` implements `mic.interface.device.GetLogical`.  
- Use this for (only) getting boolean properties of hardware.

<a name="mic.ui.device.GetText"></a>
### `mic.ui.device.GetText`
- A UI for invoking all methods of the provided `device`.  
- `device` implements `mic.interface.device.GetText`.  
- Use this for (only) getting String properties of hardware.



# Motivation

[Guide](https://www.mathworks.com/discovery/matlab-gui.html) and [MATLAB App Designer](https://www.mathworks.com/products/matlab/app-designer.html) (released in 2015) can be used to create simple GUIs to manipulate data within MATLAB.  These two options make it possible to get something simple up and running quickly, but lack the organizational structure that large, complicated projects and instruments require. Moreover, if you want to use the GUI to control instrumentation, 

What is the job of a UI in MATLAB.  The majority of the time, it is to expose one or more variables that are used in a calculation. The UI makes it easy for the user to set these variables and see the result of the calculation without having to write any code. 

Inputs usually come in four data types: Boolean (toggles)


# Notes

Think of “device” as a property of an instruemnt that you can get or set; do not think of a device as an entire instrument.  For example, if you need to make a UI to control a Keithley Picoammeter, you would create a separate device for each property you want to set or get.  E.g., 

<table>
	<tr>
		<th>Property</th>
		<th>Device Type</th>
	</tr>
	<tr>
		<td>Current</td>
		<td>Number Device</td>
	</tr>
	<tr>
		<td>Integration Period</td>
		<td>Number Device</td>
	</tr>
	<tr>
		<td>Auto Range On/Off</td>
		<td>Boolean Device</td>
	</tr>
</table>




 the We build `mic.translator.*` classes to expose the interface the UI requires (`mic.interface.device.*`) from the  API of the instrument (which is typically provided by the vendor).  


