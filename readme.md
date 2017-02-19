TuioPad is an open source TUIO tracker for iOS devices such as the iPad, iPhone and iPod touch, which allows  multi-touch remote control based on the [TUIO protocol](http://www.tuio.org/). This application is available free of charge on the App Store and can be used in conjunction with any TUIO enabled client application. Its source code is also available under the terms of the GPL and therefore can be freely used for the creation of open source TUIO enabled mobile 
applications. Apart from that the TuioPad is also a useful tool for the development and testing of TUIO 1.1 client implementations.

The application binary can be installed directly from the [iTunes App Store](http://itunes.apple.com/us/app/tuiopad/id412446962). If you are looking for a TUIO tracker on Android devices please check out [TUIOdroid](https://code.google.com/p/tuiodroid) instead.

[![TuioPad video](https://img.youtube.com/vi/8BGawz_It8Y/0.jpg)](https://www.youtube.com/watch?v=8BGawz_It8Y)

## Features and Configuration
TuioPad implements the TUIO 1.1 Cursor profile and is capable of sending multi-touch events to  TUIO clients on other devices via a WIFI or 3G network connection. Apart from the standard TUIO/UDP transport via port 3333 this application can also use alternative TUIO/TCP connections and alternative ports. The verbosity of the TUIO messages can be configured in order to improve the protocol robustness for unreliable network connections.

The binary provided on the App Store requires iOS 7.0 or later. In order to compile this application you will need a  working installation of OpenFrameworks 0.98 for iOS.

![TuioPad image](http://modin.yuri.at/extern/TuioPadActive.png)

## Acknowledgments
This application is based on [OpenFrameworks](http://www.openframeworks.cc) and has been created by [Mehmet Akten](http://www.memo.tv/) and [Martin Kaltenbrunner](http://modin.yuri.at). The included C++ TUIO reference implementation is using the [oscpack library](http://code.google.com/p/oscpack) by [Ross 
Bencina](http://www.audiomulch.com/~rossb/). Please note that the GPL demands the publication of the full source code of any derived work. If you are planning 
to develop a proprietary application based on this code, we may be able to provide an alternative commercial license 
option.