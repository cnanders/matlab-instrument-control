# About

MATLAB library for programmatically creating GUIs that control scientific instrumentation.  

# Motivation

[Guide](https://www.mathworks.com/discovery/matlab-gui.html) and [MATLAB App Designer](https://www.mathworks.com/products/matlab/app-designer.html) (released in 2015) can be used to create simple GUIs to manipulate data within MATLAB. 

These two options make it possible to get something simple up and running quickly, but they lack the organizational structure and interfaces that large, complicated projects and instruments require.  Also, if you to control instrumentation, these two fall short.  

# Terminology

* “Boolean Device” - device that accepts and returns booleans
* “Text Device” - device that accepts and returns strings
* “Number Device” - device that accepts and returns numbers

Think of “device” as any single property of an instruemnt (or variable in MATLAB) that you can get or set; do not think of a device as an entire instrument.  For example, if you need to make a UI to control a Keithley Picoammeter, you would create a separate device for each property you want to set or get.  E.g., 

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

## mic.ui.device.GetSetLogical
A UI for calling get() and set() methods of a provided logical device.  The provided device must implement `mic.interface.device.GetSetLogical`

## mic.ui.device.GetSetNumber
A UI for calling get() and set() methods of a supplied numeric device.   The supplied device must implement `mic.interface.device.GetSetNumber`

## mic.ui.device.GetSetText
A UI for calling get() and set() methods of a supplied text device.   The supplied device must implement `mic.interface.device.GetSetText`


 the We build `mic.translator.*` classes to expose the interface the UI requires (`mic.interface.device.*`) from the  API of the instrument (which is typically provided by the vendor).  


