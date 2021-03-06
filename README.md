MATLAB Instrument Control (MIC) is a namespaced, object-oriented MATLAB library for programmatically creating GUIs that control scientific instrumentation.  

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
	- [API](#device-api)
	- [Code Examples](#device-code)
	- [mic.ui.device.*](#mic.ui.device.*)
- [Controlling Local Variables Instead of Hardware](#control-matlab-variables)

<a name="common"></a>
# Standard UI Controls (Toggle, Edit, Button, etc.)

<a name="common-overview"></a>
## Overview

The MIC library provides namespaced, object-oriented wrappers around most of MATLAB’s `uicontrol` elements.  They are located at `mic.ui.common.*`.  The following code can be used to create “MIC” versions of `edit` and `toggle` uicontrols, for example. 

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

![mic.ui.device.GetSetNumber GIF](docs/img/simple-example-a.jpg?raw=true)

Their values can be retreived with the `get()` method.

```matlab
% Get {char} value of uiEdit
uiEdit.get()

% Get {logical} value of uiToggle
uiToggle.get()
``` 

![mic.ui.device.GetSetNumber GIF](docs/img/simple-example-b.jpg?raw=true)

Their values can be set with the `set()` method

```matlab
% Set {char} value of uiEdit (updates the display)
uiEdit.set('Hello');

% Set {logical} value of uiToggle (updates the display)
uiToggle.set(true);
```

![mic.ui.device.GetSetNumber GIF](docs/img/simple-example-c.jpg?raw=true)

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

`tests/ui/common/*` contains working code examples for building each `mic.ui.common.*` class and responding to its events. 


<a name="device"></a>
# Device UI Controls

<a name="device-overview"></a>
## Overview
THe MIC library provdes namespaced, object-oriented UI components that control devices (hardware). They are located at `mic.ui.device.*`. Device UI controls come in three varieties, based on common user-facing data types:

### `mic.ui.device.GetSetNumber`
![mic.ui.device.GetSetNumber GIF](docs/img/mic.ui.device.GetSetNumber.gif?raw=true)

`mic.ui.device.GetSetNumber` is a UI control designed to control a numeric (`single`, `double`, `int*`, `uint*`) property of a device.  The standard use case is controlling the position of a motorized stage. As the above .gif shows, the UI supports all of the functionality you would expect, including units.

### `mic.ui.device.GetSetLogical`
![mic.ui.device.GetSetLogical GIF](docs/img/mic.ui.device.GetSetLogical-2.gif?raw=true)

`mic.ui.device.GetSetLogical` is a UI control designed to control a `logical` property of a device.  The standard use case is controlling a binary switch. 


### `mic.ui.device.GetSetText`
![mic.ui.device.GetSetText GIF](docs/img/mic.ui.device.GetSetText.gif?raw=true)

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

Each `mic.ui.device.*` UI control must be provided with a `device`.  The `device` can be passed during instantiation of the UI control or set with the `setDevice()` method later on.  The provided `device` must implement the device interface that matches the UI control. Examples:
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

All device UI controls have a “Device” toggle.  When the “Device” toggle is set to `false` (the default), `device` calls, e.g., `device.get()`,  are routed to a “virtual” `device`.  This is useful during the development phase before hardware is available. 

All `mic.ui.device.*` UI controls automatically create their own “virtual” `device` on instantiation; virtualization of hardware is supported by default. Examples:

- `mic.ui.device.GetSetNumber` UI controls instantiate a `mic.device.GetSetNumber`, which is a `device` that implements `mic.interface.device.GetSetNumber`
- `mic.ui.device.GetSetLogical` UI controls instantiate a `mic.device.GetSetLogical`, which is a `device` that implements `mic.interface.device.GetSetLogical`

All `mic.device.*` “virtual” `devices` mock real hardware; e.g., they take time to get to a target value.

## API

All `mic.ui.device.*` UI controls expose a full-featured API that allows them to be accessed and controlled programatically.  See `mic.interface.ui.device.*` for more information.

## Code Examples

### Tests
`tests/ui/device/*` contains working code examples for building each `mic.ui.device.*` class. 

### Application
`examples/app/*` is an application that builds a UI for a made-up instrument.  The made-up instrument has two motorized stages (x, and y), an internal text setting, and a binary switch.  It is assumed that the vendor provided a device API that lets MATLAB talk to the instrument from the command line.  Our job is to build a UI.  

This example demonstrates how to hook up an arbitrary vendor-provided API to `mic.ui.device.*` UI controls.  This process involves building “translators“ that translate the vendor-provided API into the `mic.interface.device.*` interfaces that the UI controls require.  It also demonstrates how consume data from the UI controls using their internal API. 

<a name="control-local-variables"></a>
# Controlling Local Variables Instead of Hardware

The only requirement of the `device` provided to `mic.ui.device.*` UI controls is that it implements `mic.interface.device.*`. *How* it implents that interface is entirely up to you.  If you want to implement a `device` to set and get local data that a MATLAB application can consume, go for it.  In fact, the work is already done for you as this is precisely what happens when `mic.ui.device.*` UI controls are in “virtual” mode.  See `examples/app` for a working code example that consumes user-controled local data with a MATLAB application.

# Why MATLAB?

MATLAB is ubiquitous in science.  

# Why Not Guide and MATLAB App Designer?

[Guide](https://www.mathworks.com/discovery/matlab-gui.html) and [MATLAB App Designer](https://www.mathworks.com/products/matlab/app-designer.html) can be used to create UIs for simple applications that require user control of local data.  Unfortunately, the cookie-cutter .m file that these tools output lacks the organizational structure that large, complicated projects require. Moreover, there is no well-defined interface for hooking into hardware. 

# Hungarian Notation

This repo uses [MATLAB Hungarian notation](https://github.com/cnanders/matlab-hungarian) for variable names.  

# Notes on Discussion of MIC 2.0 Refactor With Ryan

Ryan and I considered a direct-callback-based refactor.  `GetSetNumber` would have the following properties

- fhSet
- fhGet
- fhIsReady
- fhStop
- fhInitialize (possibly not?)
- fhIsInitialized (possibly not?)

- fhSet2
- fhGet2
- fhIsReady2
- fhStop2
- fhInitialize2
- fhIsInitialized2

- fhUseRoute2

`fhUseRoute2`, if not provided, defaults to a function that returns `false`.  

- When `fhUseRoute2` returns `false`, `get()`, `set()`, etc are routed to the vanilla `fhGet`, `fhSet`, methods, respectively.  
- When `fhUseRoute2` returns `true`, `get()`, `set()`, etc are routed to the vanilla `fhGet2`, `fhSet2`, methods, respectively.
- In principle, there could be an array of `fhGet*()` methods and `fhUseRoute2` could be `fhGetRouteIndex` which would tell the UI which collection of get, set, ... methods to use.

- `fhSet`, `fhGet`, `fhIsReady`, `fhStop`, `fhInitialize`, `fhIsInitialized`, if not provided would have defaults.  The `mic.ui.device.GetSetNumber` would instantiate its own `mic.device.GetSetNumber` to a privae property named `device` and 
  - `fhGet` = @device.get
  - `fhSet` = @device.set
  - and so on


The idea is that the UI works by default in "internal Matlab mode" (virtual).  If the developer wants to code the UI to call different get, set, etc. methods, the developer needs to program that.

For the case where there are two routes, one that is virtual and one that controls real hardware, `fhUseRoute2` would be mapped to the the `get()` method of a `GetSetLogical` instance, which is a connect button. 

Example UI Module

```matlab

class StageTest < mic.Base
  properties
    uiX
  end

  properties (Access = private)
    comm
    clock
  end

  methods
    function this = StageTest(comm, clock)
      this.comm = comm
      this.clock = clock
    end


    function init(this)

      this.uiConnect = mic.ui.device.GetSetLogical(...
        'clock', this.clock ...
      )
      this.uiX = mic.ui.device.GetSetNumber(...
        'fhGet2', @this.comm.getPosition, ...
        'fhSet2', @this.comm.setPosition, ...
        'fhIsReady2', @this.comm.isStopped, ...
        'fhStop2', @this.comm.stopAxis, ...
        'fhInitialize2', @()[], ...
        'fhIsInitialized2', @()[], ...
        'fhUseRoute2', @this.uiConnect.get ...
        'clock', this.clock
      )

    end

    function build(this)

      // Build code here

    end

  end


```

- It is also probably worth thinking if this should be Matlab.  
- Also think about the clock.  Do UI components need a clock?  What if instead they had a render() method that told them to redraw?.  Calling ui.get() would always fetch a new value but render() could be called on demand.



<!--
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

-->
<!--
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
-->