# Contents

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
uiEdit = mic.ui.common.Edit('cLabel', 'Hello World');
uiToggle = mic.ui.common.Toggle();

% Add them to a figure
h = figure();
dUiWidth = 100;
dUiHeight = 30;
uiEdit.build(h, 10, 10, dUiWidth, dUiHeight);
uiToggle.build(h, 10, 50, dUiWidth, dUiHeight);
```

![mic.ui.device.GetSetNumber GIF](img/simple-example-a.jpg?raw=true)

Their values can be retreived with the `get()` method.

```
% Get {char} value of uiEdit
uiEdit.get()

% Get {logical} value of uiToggle
uiToggle.get()
``` 

![mic.ui.device.GetSetNumber GIF](img/simple-example-b.jpg?raw=true)

Their values can be set with the `set()` method

```
% Set {char} value of uiEdit (updates the display)
uiEdit.set('Hello');

% Set {logical} value of uiToggle (updates the display)
uiToggle.set(true);
```

![mic.ui.device.GetSetNumber GIF](img/simple-example-c.jpg?raw=true)

Several other `mic.ui.common.*` UI controls expose `set()` and `get()` methods.  The following table summarizes them along with their type:

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

### Events

All `mic.ui.common.*` classes notify events during user interaction.  The consumer can listen for them and take appropriate action.  

### Customization

Every property of every UI control in `mic.ui.*` can be set on instantiation with the MATLAB [varargin](https://www.mathworks.com/help/matlab/ref/varargin.html) syntax, enabling full customization. 

### Additional API

Each `mic.ui.common.*` UI control implements at least the `mic.interface.ui.common.Base` interface, which provides `hide()`, `show()`, `enable()`, and `disable()` methods.  See `mic.interface.ui.*` for more information.

### Code Examples and Tests

`tests/ui/common/*` contains working code examples for building each `mic.ui.common.*` class and responding to the events that they emit. 


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

![mic.ui.device.GetSetNumber GIF](img/mic.ui.device.GetSetNumber.gif?raw=true)

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

### Code Examples and Tests

- `tests/ui/device/*` contains working code examples for building each `mic.ui.device.*` class.  
- `examples/devices/*` shows you how to hook up an arbitrary vendor-provided device API to a `mic.ui.device.*` so you can control the device with a UI.  This process involves building a “translator“ that translates the vendor-provided API into the `mic.interface.device.GetSetNumber` interface, for example). Translator classes are named things like: `VendorDevice2GetSetNumber`.


# Guide and MATLAB App Designer

[Guide](https://www.mathworks.com/discovery/matlab-gui.html) and [MATLAB App Designer](https://www.mathworks.com/products/matlab/app-designer.html) can be used to create simple GUIs that manipulate data within MATLAB.  These two options make it possible to get something simple up and running quickly, but lack the organizational structure that large, complicated projects and instruments require. Moreover, they lack a well-defined interface for hooking into hardware. 

# Notes

Think of “device” as a property of an instruemnt that you can get or set; do not think of a device as an entire instrument.  For example, if you need to make a UI to control a Keithley Picoammeter, you would create a separate device for each property you want to set or get.  E.g., 

<table>
	<tr>
		<th>Property</th>
		<th>Device Interface</th>
		<th>UI</th>
	</tr>
	<tr>
		<td>Current</td>
		<td>mic.device.GetSetNumber</td>
		<td>mic.ui.device.GetSetNumber</td>
	</tr>
	<tr>
		<td>Integration Period</td>
		<td>mic.device.GetSetNumber</td>
		<td>mic.ui.device.GetSetNumber</td>
	</tr>
	<tr>
		<td>Auto Range On/Off</td>
		<td>mic.device.GetSetLogical</td>
		<td>mic.ui.device.GetSetLogical</td>
	</tr>
</table>

In this particualr example, you would most likely want to disable many of the optional features of `mic.ui.device.GetSetNumber`.  

# Using MIC to Control MATLAB Variables Instead of Hardware

Nothing says that you can’t use a `device` to set and get variables used in a MATLAB application and entirely forgo the notion of controlling hardware.  Remember: the only requirement of the `device` we pass into `mic.ui.device.*` UI controls is that it implements `mic.interface.device.*`. *How* it implents that interface is entirely up to you.  In fact, this is exactly what happens when all of the `mic.ui.device.*` UI controls are in virtual mode!


