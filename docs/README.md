# Contents

- [Standard UI Controls (Toggle, Edit, Button, etc.)](#common)
	- [Overview](#common-overview)
	- [Events](#common-events)
	- [Customization](#common-customization)
	- [API](#common-api)
	- [Code Examples](#common-code)
- [Device UI Controls](#device)
	- [Overview](#device-overview)
	- [How Device UI Controls Connect To Hardware](#device-connect)
		- [Definition of `device`](#device-definition)
		- [Providing a `device` to a Device UI Control](#device-require)
		- [Device UI Controls Evoke Methods of Their `device`](#device-wiring-up)
		- [`device` Implementation Handles Hardware Communication](#device-implementation)
	- [“Virtual” `device`](#device-virtual)
	- [Code Examples](#device-code)
	- [mic.ui.device.*](#mic.ui.device.*)

Docs are a work in progress.

<a name="common"></a>
# Standard UI Controls (Toggle, Edit, Button, etc.)

<a name="common-overview"></a>
## Overview

The MIC library provides namespaced, object-oriented wrappers around most of MATLAB’s `uicontrol` elements.  They are located at `mic.ui.common.*`. 

The following code can be used to create “MIC” versions of `edit` and `toggle` uicontrols. 

```matlab
% Instantiation
uiEdit = mic.ui.common.Edit('cLabel', 'Hello World');
uiToggle = mic.ui.common.Toggle();

% Build a figure
h = figure();

% Add UI controls to the figure
% .build(fig_handle, offset_left, offset_top, width, height)
uiEdit.build(h, 10, 10, 100, 30);
uiToggle.build(h, 10, 50, 100, 30);
```

![mic.ui.device.GetSetNumber GIF](img/simple-example-a.jpg?raw=true)

Their values can be retreived with the `get()` method.

```matlab
% Get {char} value of uiEdit
uiEdit.get()

% Get {logical} value of uiToggle
uiToggle.get()
``` 

![mic.ui.device.GetSetNumber GIF](img/simple-example-b.jpg?raw=true)

Their values can be set with the `set()` method

```matlab
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

<a name="common-events"></a>
## Events

All `mic.ui.common.*` classes notify events during user interaction.  The consumer can listen for them and take appropriate action.  

<a name="common-customization"></a>
## Customization

Every property of every UI control in `mic.ui.*` can be set on instantiation with the MATLAB [varargin](https://www.mathworks.com/help/matlab/ref/varargin.html) syntax, enabling full customization. 

<a name="common-api"></a>
## API

Each `mic.ui.common.*` UI control implements at least the `mic.interface.ui.common.Base` interface, which provides `hide()`, `show()`, `enable()`, and `disable()` methods.  See `mic.interface.ui.common.*` for more information.

<a name="common-code"></a>
## Code Examples

`tests/ui/common/*` contains working code examples for building each `mic.ui.common.*` class and responding to the events that they emit. 


<a name="device"></a>
# Device UI Controls

<a name="device-overview"></a>
## Overview
THe MIC library provdes namespaced, object-oriented UI components that control devices (hardware). They are located at `mic.ui.device.*`. Device UI controls come in three varieties, based on common user-facing data types:

### `mic.ui.device.GetSetNumber`
![mic.ui.device.GetSetNumber GIF](img/mic.ui.device.GetSetNumber.gif?raw=true)

`mic.ui.device.GetSetNumber` is a UI control designed to control a numeric (`single`, `double`, `int*`, `uint*`) property of a device.  The standard use case is controlling the position of a motorized stage. As the above .gif shows, the UI supports all of the functionality you would expect, including units.

### `mic.ui.device.GetSetLogical`
![mic.ui.device.GetSetLogical GIF](img/mic.ui.device.GetSetLogical-2.gif?raw=true)

`mic.ui.device.GetSetLogical` is a UI control designed to control a `logical` property of a device.  The standard use case is controlling a binary switch. 


### `mic.ui.device.GetSetText`
![mic.ui.device.GetSetText GIF](img/mic.ui.device.GetSetText.gif?raw=true)

`mic.ui.device.GetSetText` is a UI control designed to control a `char` property of a device.  The standard use case is controlling instrument configuration values.

There are also “get only” versions of each device UI control that omit set functionality.  
- `mic.ui.device.GetNumber`
- `mic.ui.device.GetLogical`
- `mic.ui.device.GetText`


<a name="device-connect"></a>
## How Device UI Controls Connect To Hardware

<a name="device-definition"></a>
### Definition of `device`

In MIC, a `device` is defined as anything that implements a device interface (`mic.interface.device.*`). Below is the `mic.interface.device.GetSetNumber` interface, for example.

```matlab
% Get the value
% @return {double 1x1} - the numeric value
d = get(this)

% Set a new value and go to it
% @param {double 1x1} dVal - new value
set(this, dVal) 

% @return {logical 1x1} - true when stopped or at its target
l = isReady(this) 

% Stop motion to destination 
stop(this)

% Take care of required initialization
initialize(this)

% Ask if required initialization is finished
% @return {logical 1x1} 
l = isInitialized(this)

```
<a name="device-required"></a>
### Providing a `device` to a Device UI Control

Each `mic.ui.device.*` must be provided with a `device`.  The `device` can be passed during instantiation of the UI control or set with the `setDevice()` method later on.  The provided `device` must implement the device interface that matches the UI control. Examples:
- `mic.ui.device.GetSetNumber` UI controls require a `device` that implements `mic.interface.device.GetSetNumber`
- `mic.ui.device.GetSetLogical` UI controls require a `device` that implements `mic.interface.device.GetSetLogical` 

<a name="device-wiring-up"></a>
### UI Controls Evoke Methods of Their `device`

When users interact with the UI, methods of the passed `device` are evoked. Examples:

- Clicking the “Go” button calls `device.set()`, passing the commanded value.
- Clicking the “Init” button calls `device.initialize()`

The UI control also passively calls methods of the passed `device`.  Examples:

- The display value is regularly updated by calling `device.get()` on a timer. 
- The state of the “Init” button (yellow vs. green) is regularly updated by calling `device.isInitialized()` on a timer.

<a name="device-implementation"></a>
### `device` Implementation Handles Hardware Communication

The `device` implementation is responsible for communicating with hardware when its methods are evoked by `mic.ui.device.*`.  

<a name="device-virtual"></a>
## “Virtual” `devices`

All device UI controls have a “Device” toggle.  When the “Device” toggle is set to `false` (the default), `device` calls, e.g., `device.get()`,  are routed to a “virtual” `device`.  This is useful during the development phase before harware is available. 

All `mic.ui.device.*` UI controls automatically create their own “virtual” `device` on instantiation; virtualization of hardware is supported by default without any configuration. Examples:

- `mic.ui.device.GetSetNumber` UI controls instantiate a `mic.device.GetSetNumber`, a `device` that implements `mic.interface.device.GetSetNumber`
- `mic.ui.device.GetSetLogical` UI controls instantiate a `mic.device.GetSetLogical`, a `device` that implements `mic.interface.device.GetSetLogical`

All `mic.device.*` “virtual” `devices` mock real hardware; e.g., they take time to get to a target value.

## Code Examples

- `tests/ui/device/*` contains working code examples for building each `mic.ui.device.*` class.  
- `examples/devices/*` shows you how to hook up an arbitrary vendor-provided device API to a `mic.ui.device.*` so you can control the device with a UI.  This process involves building a “translator“ that translates the vendor-provided API into the `mic.interface.device.GetSetNumber` interface.


## `mic.ui.device.*`

<a name="mic.ui.device.GetSetNumber"></a>
### `mic.ui.device.GetSetNumber`

![mic.ui.device.GetSetNumber GIF](img/mic.ui.device.GetSetNumber.gif?raw=true)

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

- `device` implements `mic.interface.device.GetSetLogical`.
- Use this for getting / setting boolean properties of hardware.

<a name="mic.ui.device.GetSetText"></a>
### `mic.ui.device.GetSetText`

- `device` implements `mic.interface.device.GetSetText`.
- Use this for getting / setting String properties of hardware.

<a name="mic.ui.device.GetNumber"></a>
### `mic.ui.device.GetNumber`
  
- `device` implements `mic.interface.device.GetNumber`.  
- Use this for (only) getting numeric properties of hardware.

<a name="mic.ui.device.GetLogical"></a>
### `mic.ui.device.GetLogical`

- `device` implements `mic.interface.device.GetLogical`.  
- Use this for (only) getting boolean properties of hardware.

<a name="mic.ui.device.GetText"></a>
### `mic.ui.device.GetText`
  
- `device` implements `mic.interface.device.GetText`.  
- Use this for (only) getting String properties of hardware.




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

The only requirement of the `device` we pass into `mic.ui.device.*` UI controls is that it implements `mic.interface.device.*`. *How* it implents that interface is entirely up to you.  If you want to implement a `device` to set and get variables of a MATLAB application and entirely forgo the notion of controlling hardware, go for it.  This is,  in fact, exactly what happens when all of the `mic.ui.device.*` UI controls are in virtual mode.

# Extra

99% of the time we communicate with hardware we: 

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
