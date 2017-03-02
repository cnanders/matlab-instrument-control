
# `mic.ui.device.*`

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