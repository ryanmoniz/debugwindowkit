**DebugWindow**

Since DebugWindow is primarily a debugging library and should never be included in production, the steps below will outline how to install DebugWindow in a way that keeps it out of production builds. There is also a guide below explaining how to verify which builds have DebugWindow and which ones do not.

**CocoaPods**

TBD

**Carthage**

To install through Carthage add github "ryanmoniz/debugwindow" to your cartfile. Then run carthage update. Drag and drop the created frameworks into your Xcode project. **Important Make sure that DebugWindow and any of it's frameworks are not included as embedded frameworks (Settings should be available in General project settings).**

Once you ensure that DebugWindow is not included in the embedded frameworks change the status of the DebugWindow frameworks under "Linked Frameworks and Libraries" section to optional. At this point your project settings should look something like this.

Xcode->Build Phases

Embedded Binaries: empty
Linked Frameworks and Libraries: DebugWindow.framework

Next hop on over to the build phases section and add a custom run script. Make sure it is inserted right above the "Linked Frameworks and Libraries" build phase. Make this your custom run script:

#Add the configurations you want to include DebugWindow in below.
`if [ "$CONFIGURATION" == "Debug" ]; then 
    /usr/local/bin/carthage copy-frameworks
fi`

Next you are going to want to add each DebugWindow framework path to the "Input Files" section of your build script. Your build script should look something like this: 

Xcode->Build Phases

Run Script: (Create a new one)
Shell: /bin/sh
add the previous code to the script field
Show Environment variables in build log: true
Run script only when installing : false

Input Files:
$(SRCROOT)/Carthage/Build/iOS/DebugWindow.framework

Output Files:
$(BUILD\_PRODUCTS\_DIR)/$(FRAMEWORKS\_FOLDER\_PATH)/DebugWindow.framework

**Build Settings**
Specificy in Xcode->Build Settings the value for Framework Search Paths as the path to the input:
$(SRCROOT)/Carthage/Build/iOS/

**Verifying A Build Does Not Include DebugWindow**
Note: This only works if you are using DebugWindow Frameworks. If you are using Cocoapods ensure that you have specified "use_frameworks!".

**Opening the IPA**

Right click your IPA file and open it with Archive Utility. This should unzip your IPA.
Inside the unzipped IPA there should be an Application file. Depending on how the IPA was built it might be in a Payload folder. Once found, right click the Application file and select "Show Package Contents".
Inside the package there should be a folder called "Frameworks". Ensure that DebugWindow and it's plugins are not included in that folder. If DebugWindow is in that folder then that means DebugWindow is included in that build.
As an extra step you can ensure that your apps executable is not attempting to load DebugWindow. Inside your app package find your app's executable (It should be a unix executable in the root of the package). Run this:

`otool -L {Unix Executable Path Here}`

Verify the output does not contain any references to DebugWindow.

**While Running The App**

Ensure that none of the DebugWindow triggers (shake, etc.) you have set activate DebugWindow.
If attached to the debugger you can pause the process and run:

`image list -b`

This will show all of the shared libraries that are currently loaded in the app. Make sure that DebugWindow and it's frameworks are not listed.


