### MATLAB library for programmatically creating GUIs that control scientific instrumentation.  

# Documentation

## mic.ui.common.*

The core of the MIC library contains namespaced, object-oriented wrappers around all of MATLAB’s `uicontrol` elements: `edit`, `listbox`, `pushbutton`, etc.  These classes are located at `mic.ui.common.*`. 

Some `mic.ui.common.*` expose a value with a type determined by the UI element.  Examples:

<table>
	<tr>
		<th>Class</th>
		<th>Type of exposed value</th>
	</tr>
	<tr>
		<td>`mic.ui.common.Toggle`</td>
		<td>`logical`</td>
	</tr>
	<tr>
		<td>`mic.ui.common.Edit`</td>
		<td>`char`, `single`, `double`, `int*`, or `uint*` (configurable)</td>
	</tr>
</table>

Most `mic.ui.common.*` classes expose events the consumer can listen for.  This lets the consumer respond to the user interacting with the GUI, e.g., clicking a `mic.ui.common.Button` or editing the value of a `mic.ui.common.Edit`.  

## mic.ui.device.*

The next layer of the UI controls are `device` controls.  These are UIs designed to control hardware. 99% of the time we communicate with hardware we: 

- Ask for a value
- Tell it to go to a new value

 When we exchange data with hardware, the data always has a type.  Common user-facing data types are: 

- Numeric (`single`, `double`, `int*`, `uint*`)
	- Get the position of a stage
	- Set the position of a stage
- Boolean (`logical`)
	- Get or set the value of any binary switch
- String (`char`)
	- More rare, but it does come up

`mic.ui.device.*` contains a UI control for each data type; the data type dictates the features of the UI. 

### How `mic.ui.device.*` UI Controls Work

- Each `mic.ui.device.*` must be passed a `device`.  A `device` is something that implements the `mic.interface.device.*` interface. 
- The `mic.ui.device.*` provides a UI for invoking all available methods of the `device` (the methods defined in `mic.interface.device.*`).  
- The `device` is responsible for appropriately communicating with hardware when its methods are evoked by `mic.ui.device.*`

### `mic.ui.device.GetSetNumber`
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


### `mic.ui.device.GetSetLogical`
- A UI for invoking all methods of the provided `device`.
- `device` implements `mic.interface.device.GetSetLogical`.
- Use this for getting / setting boolean properties of hardware.

### `mic.ui.device.GetSetText`
- A UI for invoking all methods of the provided `device`.
- `device` implements `mic.interface.device.GetSetText`.
- Use this for getting / setting String properties of hardware.

### `mic.ui.device.GetNumber`
- A UI for invoking all methods of the provided `device`.  
- `device` implements `mic.interface.device.GetNumber`.  
- Use this for (only) getting numeric properties of hardware.

### `mic.ui.device.GetLogical`
- A UI for invoking all methods of the provided `device`.
- `device` implements `mic.interface.device.GetLogical`.  
- Use this for (only) getting boolean properties of hardware.

### `mic.ui.device.GetText`
- A UI for invoking all methods of the provided `device`.  
- `device` implements `mic.interface.device.GetText`.  
- Use this for (only) getting String properties of hardware.



# Motivation

[Guide](https://www.mathworks.com/discovery/matlab-gui.html) and [MATLAB App Designer](https://www.mathworks.com/products/matlab/app-designer.html) (released in 2015) can be used to create simple GUIs to manipulate data within MATLAB.  These two options make it possible to get something simple up and running quickly, but lack the organizational structure that large, complicated projects and instruments require. Moreover, if you want to use the GUI to control instrumentation, 

What is the job of a UI in MATLAB.  The majority of the time, it is to expose one or more variables that are used in a calculation. The UI makes it easy for the user to set these variables and see the result of the calculation without having to write any code. 

Inputs usually come in four data types: Boolean (toggles)


# Terminology

* “Boolean Device” - device that accepts and returns booleans
* “Text Device” - device that accepts and returns strings
* “Number Device” - device that accepts and returns numbers

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


