# 1.0.0-beta.35

- `mic.Base` now supports new logging thpe `u8_MSG_TYPE_SCAN`


# 1.0.0-beta.34

- `ui.device.GetSetNumber` SET button now allows mapping from arbitrary value to new value instead of current value to new value.  
- `ui.device.GetSetNumber` has new method `setValToVal` which is a convenient way of defining a new software offset by passing in a calibrated value and the desired calibrated value.  

# 1.0.0-beta.33

- Adding virtual function callbacks.  See MIC notes for details

# 1.0.0-beta.32

- Added new functional programming constructs in `mic.Utils`

- Updated `mic.ui.device` elements to accept function callbacks


# 1.0.0-beta.31

- All instances of getReport(Exception) have been replaced by Exception.message


# 1.0.0-beta.30

- `mic.Base` now shows `msgbox` when `msg()` is called with a type of `u8_MSG_TYPE_ERROR`

# 1.0.0-beta.29
- Changes to the usability of `mic.ui.axes.ScalableAxes.m` to add some
  new centering functionality.

- Adding a logical value to `mic.ui.common.Edit` to allow disabling of callback when set method is programmatically called.

- Added a new colorscheme to `Utils` to represent an error state.

- Updates to `ScalableAxis` to make the slider position correct with respect to the main figure.


# 1.0.0-beta.28

- Updated `mic.ui.device.GetSetText` to use log typing

# 1.0.0-beta.27

### mic.ui.common.Edit/Button/Popup/PopupStruct/Checkbox

Updated `fhDirectCallback` to have two args: `(src, evt)` to match standard callback pattern in MATLAB.  

# 1.0.0-beta.26

### mic.ui.common.Edit

Updated mic.ui.common.Edit so it calls `fhDirectCallback()` any time it does `notify()`


- Adding accessor for u8Index in `Scan.m`

- Updating `mic.ui.axes.ScalableAxes.m` for bug fixes and customizable


- Fixed a bug in `mic.scan` causing it to fail to stop when stop() is called during a state change or an acquisition. Also fixing a bug causing raster scanning to fail in `mic.ui.common.ScanSetup`

- Generalizing scan axis and scan setup inputs

- Adding getter for `mic.ui.common.Popup` to access selected value of list item.

- Added options for changin colors in `mic.ui.common.ProgressBar`.

- General robustness and bug fixes in `PositionRecaller`

- Adding new classes `mic.ui.ScanAxisSetup` and `mic.ui.ScanSetup` as UI elements for setting up nested scan states of up to 3 dimensions.  

- Adding the UI element `mic.ui.common.Tabgroup` to expose MATLAB's tabgroup ui element to mic.  This allows for tabs to be created in groups to optimize the usable space in UIs.

# 1.0.0-beta.24

- Adding `DeferredActionScheduler`, a class for executing deferred actions subject to a trigger condition.  Useful for scheduling asynchronous actions that need to wait for certain states, such as waiting for a stage to home or move.

- Refactoring `SaveLoadList.m` into `PositionRecaller.m`, a UI class for saving and loading coupled-axis states into JSON.

- Adding syncDestination method to `mic.ui.device.GetSetNumber` to make edit box sync with actual read value.


# 1.0.0-beta.23

- Adding property `fhDirectCallback` to ui classes `ui.common.Edit`, `ui.common.Button`, `ui.common.Checkbox`, which allows a callback to be passed in directly to object instance. Existing callback framework was not modified to preserve backward-compatibility.

- Added utility classes `scalableAxis` for viewing images with various image processing modes, and `SaveLoadList` for providing a means for off-lining data associated with listboxes.

- Added a method `validateByConfigRange` to `ui.device.GetSetNumber` which will validate the input according to the corresponding config file boundaries.  A corresponding boolean `lValidateByConfigRange` can be passed in to use this validator.  By default, there is no destination validator.  Validation can be enabled by one of the following operations in order: 1) passing in `fhValidateDest`, 2) setting `lValidateByConfigRange` to true, or 3) overloading `validateDest` in an implementation instance.

- Reformatting `SaveLoadList`

# 1.0.0-beta.22

### mic.Base

Now msg always shows `u8_MSG_TYPE_ERROR` messages types

### mic.Clock

No longer re-throws errors when it tries to execute one of the function handles in its queue.  By not re-throwing, MATLAB displays the error and call stack in the console during runtime.  Rethrowing doesn't do this; it assumes you catch somewhere higher in the call stack.

# 1.0.0-beta.21

Fixed but with `ui.common.PopupStruct`, `ui.common.Text` and `ui.common.Toggle` that were sending hard-coded values through `msg()` instead of the new constants defined in `mic.Base`

# 1.0.0-beta.20

Fixed bug with several classes referencing property `u8_MSG_TYPE_DELETE` that should have been `u8_MSG_TYPE_CLASS_INIT_DELETE`

# 1.0.0-beta.19

### mic.Base

- Improved the messaging system.  Messages are now flagged with a `uint8` type.  Available types are stored as constants in `mic.Base` (`u8_MSG_TYPE_*`).  `mic.Base` now has a property `u8MsgType` that is a list of types that should be logged.  The `msg` function now requires that the type of the provided message is in the list of allowed types in order to display the message.  To change the message / logging style for the project, set `u8MsgType` to one of the defined `u8_MSG_TYPE_*` constants in the `mic.Base` constructor.


# 1.0.0-beta.18

### mic.ui.common.ListDir

- Implemented `save()` and `load()` method to persist the state across sessions

# 1.0.0-beta.17

### mic.ui.common.Button

- Added `fhOnClick` property, a `function_handle` that is called whenever the button is clicked. If the button requires confirmation during click, `fhOnClick` is only clicked if there is a successful confirmation.

# 1.0.0-beta.16

### mic.ui.common.ListDir

- Fixed bug in `updateUiTextDir()`. It now properly returns if `uiTextDir` has not been defined

# 1.0.0-beta.15

### mic.ui.common.ListDir

- Extendion of mic.ui.common.List that is designed to show the contents of a directory
- Has an optional button that allows the user to change the directory that is being listed
- `getDir()` method can be used to retrieve the directory the user is viewing

# 1.0.0-beta.14

### mic.ui.common.ButtonList

- Now setting tooltip when cLayout === cLAYOUT_BLOCK 
- Made all private properties protected so subclasses can access them
- Added setButtonColorBackground


### mic.ui.common.Button

- Added setColorText method
- Added setColorBackground method

# 1.0.0-beta.13

### mic.ui.common.ButtonList

- New UI Control that is a list of `mic.ui.common.Button`s in a panel.  Buttons can be displayed inline or block.  A `cell` of button definition `struct`s is passed in with the `varargin` syntax to configure the buttons.  Each “button definition“ has three properties, as shown below.

```matlab
% @typedef {struct 1x1} ButtonDefinition
% @property {char 1xm} cLabel - label of the button
% @property {function_handle 1x1} fhOnClick - function that is called when button is clicked.  Must return logical to indicate if the action was successfull or not
% @property {char 1xm} cTooltip - tooltip of the button
```
# 1.0.0-beta.12

### mic.ui.device.*

- Moved common properties and methods to `mic.ui.device.Base`.  These include:
  - properties (Protected)
    - uitDevice
    - uibInit
    - uiilInitState
    - cLabelDevice
    - cLabelInit
    - cLabelInitState
    - lIsInitializing
    - uitxLabelDevice
    - uitxLabelInit
    - uitxLabelInitState
  - methods (Public)
    - turnOn()
    - turnOff()
    - initialize()
  - methods (Protected)
    - onInitChange()
    - onDeviceChange()
- uitDevice is now disabled until setDevice() is called
- turnOn() now shows a warning dialog and returns if setDevice() has not been called
- internal property lDeviceIsSet used to track if setDevice() has been called

### mic.ui.device.Base

- turnOn() no longer kills the deviceVirtual instance

# 1.0.0-beta.11
 
### mic.ui.commmon.List 
- Created properties for the label, width, and height of the move up, move down, delete, and refresh buttons that can be set with the `varargin` syntax

# 1.0.0-beta.10


### mic.ui.common.Checkbox
- Removed hLabel property since it has been moved out to `mic.ui.common.Base`

### mic.ui.Scan

- New UI to control a `mic.Scan` and display the scan progress.
- Contains start, pause/resume, and abort buttons.

### mic.Scan

- Refactored elapsed time so elapsed time is no longer incremented while paused and the time complete and time remaining predictions are correct when a scan is paused / resumed many times.


# 1.0.0-beta.9

### mic.StateScan -> mic.Scan
- New method `getStatus()` returns a `struct` with elapsed time, time remaining, etc that is useful for presenting scan information to the user
- Renamed to Scan

# 1.0.0-beta.8


### mic.StateScan
- Added documentation for the “contract” pattern that is useful in classes that utilize a `mic.StateScan`

### mic.ui.common.Text
- Now has an optional label.  Set `lShowLabel` to `true` to use the label.  The default value of `lShowLabel` is `false` 
- Now extends `mic.ui.common.Base`

### mic.ui.common.Base
- added `hLabel` property
- `disable()` and `enable()` now apply the style to the label in addition to the main UI element

# 1.0.0-beta.7

### mic.ui.device.GetSetNumber

- When `lDisableSet` is true, default virtual device is now an instance of `mic.device.GetNumber` instead of `mic.device.GetSetNumber`

### mic.ui.axes.ZoomPanAxes

- Now notifies `eZoom` event on zoom

### mic.StateScan

- Now passes `stValue` into `fhAcquire()`

# 1.0.0-beta.6

### mic.StateScan

- Added function templates for all functions that this class evokes. They can be copy/pasted into any class that uses `mic.StateScan`
- Now pass `stValue` into `fhIsAcquired()`

### mic.ui.device.GetSetNumber

- `u8UnitIndex` is now properly cast as `uint8`

### mic.ui.device.Base

- `setDevice()` now checks that the passed `device` extends the correct `mic.interface.device.*` device interface
- added `isActive()` method to programatically check if the UI is routing `device` calls to the “virtual” `device`

### mic.ui.common.List

- Added `refresh()` method that was accidentally removed in 1.0.0-beta.5
- `setSelectedIndexes()` now shows a warning message if the provided index(es) are not cast as `uint8`

### mic.ui.common.Popup*
- `setSelectedIndex()` now shows a warning message if the provided index is not cast as `uint8`


# 1.0.0-beta.5

Implemented `save()` and `load()` methods for classes with a state that can persist across sessions:

- mic.ui.common.ButtonToggle
- mic.ui.common.Toggle
- mic.ui.common.Popup
- mic.ui.common.PopupStruct
- mic.ui.common.List
- mic.ui.common.Edit
- mic.ui.common.Checkbox
- mic.ui.device.GetSetNumber
- mic.ui.device.GetSetText

Deleted most of mic.Base since it no longer has `loadClassInstance` and `saveClassInstance` methods which were the bulk of this class.  

- The `save()` method returns a structure with the UI state that should be saved.  
- The `load()` method receives a structure and sets the UI elements to match. 
- _Neither of these methods write to disk or load from disk_.  
- Each UI component in the application should implement its own `save()` and `load()` methods with identical interfaces.  
- To persist UI state across sessions, the highest-level UI component should implement `saveToDisk()` and `loadFromDisk()` methods that save (to disk) the structure returned by `save()` and load it and then pass it to `load()`.

### examples/app/src/+app/App.m
Added `save()` and `load()` methods and `saveToDisk()` and `loadFromDisk()` methods that persist UI state across sessions

### mic.ui.common.List

- Got rid of setters
- Added `get()`, `getOptions()`, `getSelectedIndexes()`, `setOptions()` and `setSelectedIndexes()` methods
- Fixed bug with `onMoveDown()` method when more than one item was selected while performing the action

### mic.ui.common.Popup*

- Got rid of setters
- Added  `get()`, `getOptions()`, `getSelectedIndex()`, `setOptions()` and `setSelectedIndex()` methods

# 1.0.0-beta.4

### mic.ui.device.GetSetNumber

- Added [`dValDeviceDefault` = 0] prop that is now used to set the `dVal` prop of the `mic.device.GetSetNumber` “virtual” device on instantiation.

# 1.0.0-beta.3

### mic.config.GetSetNumber

- Added support for “invert” property in config files.  Unit structures now have a `invert` property of type `logical` that defaults to false if the “invert” field is not provided in the config .json file. 

### mic.ui.device.GetSetNumber

- Updated `cal2raw()` and `raw2cal()` methods to support inverse units.
- Updated `updateRange()` to support inverse units.  This includes a special case when the non-inverted calibrated range spans zero.  In this scenario, the inverted range looks like [-inf -X] [Y +inf].


# 1.0.0-beta.2

### mic.ui.axes.ZoomPanAxes
- When zooming, the scene coordinate under the mouse now stays fixed like in Google Maps.  This required adjusting pan x and pan y during zoom.
- Now supports click to pan.  Children graphical objects, e.g., `patch` with `HitTest` set to `on` (the default) will absorb/block the click from reaching to the low-level `hggroup`.  Anything you want to be able to “click to pan”, must have its `HitTest` property set to `off`.

### mic.ui.device.GetSetNumber
- Adding clock task inside init() instead of build()

### mic.ui.device.GetSetText
- Adding clock task inside init() instead of build()

# 1.0.0-beta.2

- Renamed /pkg to /src

# 1.0.0-beta.1

- Namespaced the library (massive restructuring)
- Using the term “device” throughout instead of “api”
- HardwareIO\* -> mic.ui.device.GetSet\*
- HardwareO* -> mic.ui.device.Get\*
- Removed instrumentation libraries.  They no longer belong in this framework.

1.0.0-alpha.\* releases are located at [cnanders/mic](https://github.com/cnanders/mic]), which has been superseded by this repository.  The CHANGELOG.md file from [cnanders/mic](https://github.com/cnanders/mic]) repository is included below, for referece.

# 1.0.0-alpha.42

### UIButton

Added setText() method

# 1.0.0-alpha.41

### HardwareIOPlus
- Now saves and loads: unit selection (UiPulldown), abs/rel mode (UiToggle), and dZeroRaw

### UIText
- new method setBackgroundColor()

### MicUtils
- gained some new utility methods

# 1.0.0-alpha.40

### HardwareIOPlus
- SetZero button now allows the user to set the current raw position to any desired calibrated value.  Prior to this change, the SetZero button set the current raw position to a calibrated value of 0.  This change adds more utility.  Internally, this button still sets dRawZero, but there is additional math required to figure out the dRawZero required to make it work.
- In handleClock(), the call to updateDisplayVal() no comes after lReady is checked/set so the text color immediately displays correct color and doesn't have to wait for next clock cycle.

# 1.0.0-alpha.39

### HandlePlus
- saveClassInstance() now does not save properties unless they have SetAccess = 'public'
- loadClassInstance() now when it identifies a field that is a structure, instead of assuming it reference a class instance that extends HandlePlus, it checks that this.field is an object and that this.field has a method named 'loadClassInstance()' if both of these additional criteria are satisfied, it proceeds with recursively calling, i.e., this.field.loadClassInstance(stSave.field)

### Keithley6482
- Improved configurability by assigning some label and padding values to class properties


# 1.0.0-alpha.38

### UIEdit
- New private property lNotify used to wrap all calls to notify to allow temporary disabling of notify on setVal() [see below]
- New method setValWithoutNotify() equivalent to setVal() but does not notify 'eChange' event

### HardwareIOPlus
- Added dWidthPad* properties to allow padding any of each configurable UI component
- New properties lAskOnApiClick and lAskOnInitClick allow configuring if it shows confirmation dialog when these buttons are clicked.
- Now dispatches 'eTurnOff' on turnOff() and 'eTurnOn' on turnOn()

### Keithley6482 
- New property lAskOnApiClick allows configuring if it shows confirmation dialog when the 
API button is clicked.


# 1.0.0-alpha.37

### ConfigHardwareIOPlus
- Now supports optional 'step' property which is the step in raw units.
- If not provided in config.json, defaults to 0.1
- Now supports optional 'min' and 'max' values (raw unit).  When not provided, defaults to +/-maxreal()

### HardwareIOPlus
- Now sets uieStep.get() to config.step on load
- Now has option lShowRange.  When true, displays the range [config.min, config.max]
- Now changes value color during moves


### Keithley6482
- Added dTimeout property to set the timeout
- Now supports setting the baud rate of serial communication
- Refactored the device API wrappers.  Now have HardwareIOPlusFromKeithley, HardwareIOTextFromKeithley, HardwareOPlusFromKeithley.  
- Deleted all previous API wrappers
- Now when lShowSettings = true and lShowRange = false, draws settings at correct height
- delete() method now calls disconnect() method and calls delete({serial})


### Keithley6517a
- All wrappers of ApiKeithley6517a that implement InterfaceHardwareIOPlus now implement initialize() and isInitialized() methods to they satisfy the  requirements of the updates to InterfaceHardwareIOPlus Abstract class that were added in v1.0.0-alpha.35


# 1.0.0-alpha.36

### Keithley6482
- Now supports varargin
- Added cPort property 
- Renamed terminator property to cTerminator to follow Hungarian

### HardwareIOPlus
- In turnOn() call this.setDestCalDisplay(this.valCalDisplay()) to update goal to device value.

# 1.0.0-alpha.35

### UIImageLogical
- New component that has two image states to display the value of a logical
- This will most likely break other code.  I will need to fix.

### InterfaceHardwareIOPlus
- Modified the Interface to add initialize() and isInitialized() methods which all of Carl's Axis classes need.  

### HardwareIOPlus
- Added Init button to send initialize() gommand to API.
- Added InitState UIImageLogical to show the state of isInitialized()
- handleClock now polls getApi().isInitialized() along with getApi().get()
- Both of these UI elements are configurable in varagrin with [lShowInitButton = true] and [lShowInitState = true]
- Updated image assets for the API toggle

### Keithley6482
- Updated image assets for the API toggle


# 1.0.0-alpha.34

- Added .mat to .gitignore
- Removed all .mat files from the repository

### HandlePlus
- Added setVarargin() method since many components are now varargin.  Built a unified way to set properties.
- It turns out that this doesn’t work because the base class cannot access protected / private methods in the child class. 

# 1.0.0-alpha.33

### HardwareIOPlus, HardwareIOText
- Removed setter for apiv property and added method setApiv()
- Moved documentation from above the constructor to the property names in the class definition

### Keithley6517a, Keithley6482
- Added setApiv() method that calls setApiv() on all of the HioText and Hio instances so they use the wrappers around ApivKeithley* that implement the correct interface for the UI components.
- call to setApiv() now at the end of init() since it relies on having all of the Hardware* instances available
- delete() method now properly calls delete() on all children
- delete() now deletes the apiv at the end (after all Hardware* classes have been deleted) since they rely on the api/apiv being available for timer callbacks

### Unanswered Question
What class is responsible for deleting api and apiv instances? Need to think about this.  Often times, Hardware* classes have an api that is an interface wrapper around a larger API. It should be OK for Hardware* classes to delete their api refernce in this scenario. 

# 1.0.0-alpha.32

### Keithley6482
- Added lShowRange and lShowSettings to allow disabling the range and settings UI.  Made changes robust enough that if there is ever a version of this instrument with separate settings for each channel, a few lines of code can make this work. 

### Keithley6517a
- Bug fixes from 1.0.0-alpha.31 in setApi() and turnOff() methods

# 1.0.0-alpha.31

### Keithley6517a
- Added lShowRange and lShowSettings to allow disabling the range and settings UI

### ApiKeithley6517a
- Now supports serial and GPIB communication protocols.  Both are synchronous right now.  Communication isn't the bottleneck; it is the time the device takes to fill buffer with answer.
- Full synchronous read takes between 50 ms - 60 ms
	- 3 ms to send the command
	- 45 ms for the instrument to fill its buffer
	- 1 ms for reading the result 
- Commented tic/toc that was used while debugging serial vs. gpib speed

# 1.0.0-alpha.30.5

### NOT STABLE RELEASE

### UIEdit
Figured out how to make it notify 'eEnter' on clicking enter and have the val() function report the value in the edit box.  get(src, 'String') doesn't return the value the user has typed until the callback is evoked. The callback is evoked by pressing enter or by clicking another component but in the callback there is no way to know if it was evoked from enter or not.  I used KeyPress event to store the last key press and check it in the callback.  This was a 



# 1.0.0-alpha.30.3

### NOT STABLE RELEASE

In the process of making backwards compatible with 2009b.  And eventually want to try going back to 2008a, where OOP was first introduced.  isprop() functions differently in 2009b then in 2013a, which is the last place it was tested.

# 1.0.0-alpha.30.2

### NOT STABLE RELEASE

### KEITHLEY6517A
- Build new API that asynchronously polls the device and stores recent values so when a consumer needs them, it can get them immediately.  Not fully tested.

# 1.0.0-alpha.30.1

### NOT STABLE RELEASE

### Keithley6517A
- Fixed bug referncing this.terminator instead of this.cTerminator

### Clock
- Added second optional paramater in constrictor to set the period

# 1.0.0-alpha.30
- Renamed components/HardwareIOPlus/InterfaceHardwareIO to InterfaceHardwareIOPlus to fix namespace conflict with components/HardwareIO/InterfaceHardwareIO
- In devices folder, all APIs that implemented InterfaceHardwareIO were switched to HardwareIOPlus


# 1.0.0-alpha.29

### Keithley6517A
- Major changes to visual appearance

### HardwareIOToggle
- Minor changes 

# 1.0.0-alpha.28

### HardwareIOPlus, HardwareIOText, HardwareOPlus
Fixing case errors in class names due to git case insensivity that occurred in 1.0.0-alpha.26 release


# 1.0.0-alpha.27

### Keithley6482, Keithley6517A
Fixing case errors in class names due to git case insensivity that occurred in 1.0.0-alpha.26 release

# 1.0.0-alpha.26

### Keithley6482, Keithley6517A
- Disambiguated names of API wrappers.  In general, it is good practice to have verbose names for API wrappers.  I'm using ApiKeithley6482AutoRangeState, for exampele, for the API that implements InterfaceHardwareIOText.

# 1.0.0-alpha.25

- HardwareIOPlus, HardwareIOText, HardwareOPlus, Keithley6482, Keithley6517A all migrating away from upper-case acronyms in class names and method names.   For example APIHIOTXAutoRangeState became ApiHiotxAutoRangeState for easier readibility.  

# 1.0.0-alpha.24

### Config
- Deprecated and it became ConfigHardwareIOPlus for more verbosity

### HardwareIOPlus, Keithley6517A, Keithley6482
- Updated to use ConfigHardwareIOPlus instead of deprecated Config

# 1.0.0-alpha.23

- Moved tests into component and devide folders so they are easier to find.  Now a component or device folder contains its tests.


# 1.0.0-alpha.22

### Keithley6482
- Updates to appearance.  Made it more closely resemble the display on the physical unit

# 1.0.0-alpha.21

### UIEdit
- Temporarily disabling KeyReleaseFcn callback and channeling the handler through KeyPressFcn which works in earlier versions of MATLAB.
- Update to HardwarePlus.checkDir() for better type checking (forces === 7 check) and it now displays a message whenever it creates a directory.


# 1.0.0-alpha.20

### Keithley6482
- Realized that ADC period, average filter, and median filter apply globally to both channels.  Updated UI to reflect this.
- Changed API to implement READ? SPCI command instead of MEASure?.  MEASure calls another function which sets auto range to on on both channels.  Not what we want.

# 1.0.0-alpha.19

### Keithley6482
- Rebuilt the UI as a 2-channel version of Keithley 6517A

# 1.0.0-alpha.18

### Keithley6517A
- Added tests from DCT codebase.

# 1.0.0-alpha.17

### Keithley6517A
- Added this device from DCT codebase.  The API uses the MATLAB Instrument Control Toolbox and talks to the device using SCPI (Standard Commands for Programmable Instruments).

# 1.0.0-alpha.16

### HardwareOPlus
- Fixed bug in constructor.  Now works with varargin.  Since HardwareOPlus is a HardwareIOPlus with limited functionality, since changing HardwareIOPlus to varargin input HardwareOPlus was not working correctly. 

### HardwareOPlus, IOPlus, IOText
- Now have settable properties for the values of each label

# 1.0.0-alpha.15

### UIEdit
- Now nofies event eEnter when user releases the Enter key while the UI has focus (onKeyRelease)

### HardwareIOPlus
- Now calls moveToDest() when the user releases the Enter key when the destination has focus

# 1.0.0-alpha.14

### HardwareIOPlus
- Updated APIInterface with return values on get and isReady

### HardwareIOText
- Updated APIInterface with return value on get
- Fixed bug that called depricated setValRaw method in turnOn method

### Keithley6482
- Finalized APIInterface
- Built API
- Built APIV
- improved tests to call several methods of the class

# 1.0.0-alpha.13

### HardwareIOPlus, HardwareIOText,
- Now notify {event} eChange only when the value changes

# 1.0.0-alpha.12

###HardwareIOPlus, HardwareIOText,
- Now notify {event} eChange when the destination changes


#1.0.0-alpha.11

### HardwareIOPlus, HardwareIOText, UIButtonToggle
- enable, disable methods now supported to dis/enable UI programatically

# 1.0.0-alpha.10

### HardwareIOPlus, HardwareIOText
- Improved formatting on Windows
- @param {logical 1x1} lActive now defaults to false
- Moved all of the constant width, height props to protected properties so they are settable with varargin syntax.
- @param {char 1xm} cLabelStores now settable with varargin to control label over stores PopUp.

# 1.0.0-alpha.9

### HardwareIOPlus
- New @prop {logical 1x1} [lShowUnit = true] allows hiding the unit dropdown
- New @prop {char 1x1 | 1xm} [cConversion = 'f'] allows setting the string conversion of the value.  'f' for floating point and 'e' for exponential are currently supported
- To set either of these new properties, assignn them in the constructor with varargin syntax.


# 1.0.0-alpha.8

### HardwareIOText
- New component HardwareIOText similar to HardwareIOPlus except that it is unitless, therefore has no cal / raw, and sets values using char, not double.

# 1.0.0-alpha.7

Unknown changes

# 1.0.0-alpha.6

### UiPopupStruct
- now uses varargin

### Keithley6482
- support for new UIPopupStruct constructor

### HardwareIOPlus
- support for new UIPopupStruct constructor



# 1.0.0-alpha.5

### HardwareIOPlus 
- now uses varargin for constructor
- valCal, valCalDisplay, and valRaw now force a call to api.get() instead of using dValRaw that is updated with the clock
- clock task added in build() and only if clock is not empty [ ]

### APIVHardwareIOPlus
- if clock is empty [ ], directly goes to the destination instead of marching a linear path in time to the destination. 

### Documentation
- Added CONVENTIONS.md to describe Hungarian notation, loop counters, and other conventions used throughout the MIC library
- Added NOTES.md


# 1.0.0-alpha.4

Updated README.md with instructions for checking out a specific tag

# 1.0.0-alpha.3

Updated README.md with proposed project structure and other information

# 1.0.0-alpha.2

Added CHANGELOG.md

# 1.0.0-alpha.1

Initial commit
