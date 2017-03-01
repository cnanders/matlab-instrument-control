# About

This example shows you how to hook up an arbitrary vendor-provided device API to a `mic.ui.device.*` so you can control the device with a ui

# /vendor

Provides a fake device API that mimics something a vendor might provide.  The vendor-provided device API does not match the `mic.interface.device.*` interface that the `mic.ui.device.*` UI classes need

# /translators

“Translators” are something that translate one interface into another