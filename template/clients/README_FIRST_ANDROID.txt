IMPORTANT!
==========

To use CFapi dynamically generated Android APP you must follow these instructions.
The generated Android APP uses Google Maps API, therefore, it is required to
load "Google Play Services Lib" into your Android workspace and add a reference
to it in the generated APP, in order to make it run properly. Otherwise
it will show a nullPointerException at runtime, because the map will not be
able to initialize. Just follow this step by step and there will be no trouble:

1) Copy folder "android" from "clients" directory to some temp directory of your choice.
2) Open Eclipse Android SDK and right-click "Package Explorer". Select "Import..."
3) Choose the "Existing Android Code into Workspace" option.
4) Click the "browse" button and point to "android" folder mentioned in step 1.
   Make sure that "Copy projects into workspace" options is checked. Click "finish".
5) Now you will have the dynamically generated app listed in "Package Explorer",
   without any errors. But do not run it yet. First you have to import Google Play Services Lib.
6) Unpack GooglePlayServicesLib.zip file from "clients" folder to some temp folder of your choice.
7) Import "Google-play-services_lib" project to your Android SDK workspace, as described in steps 2-4.
8) Now you will have the "Google-play-services_lib" project listed in "Package Explorer".
9) Next step is do add Google Play Services Lib to your generated APP.
10) Right-click on your APP project´s name and select "properties" option.
11) In the lower part of the window opened, at the "Library" section, click "Add" button.
12) Select "Google-play-services_lib" and click "Ok", then "Ok" again.
    Now, if you run your generated APP the map will show, but probably all grey.
    That is because you need two things: a Google Maps v2 API key, and to associate this key with your app.
13) Open your browser and point it to "https://console.developers.google.com". Log in.
14) Just next to "Google Developer Console" title, there´s a selection box. Select "Create a project...".
    Name it as you wish. Wait the process to end.
15) In the left menu, select "APIs", then "Google Maps Android API".
16) Click the "Activate API" button.
17) Now go to "Credentials" option on the left menu. Select "Add Credentials", then "API Key".
18) Select "Android Key", then name it as you wish and click "Create" button.
19) Google will show your API key now, for example: "AIzaSyB6H-y17gd6zIHsieaarDCq9nfG_azkYo". Copy this and click "ok".
20) Open your APP project´s AndroidManifest.xml file and change API_KEY value to your custom API key. Save file.
21) Select Eclipse menu "Project", option "Clean". Wait.
22) Compile and run your APP. The map will now show up with all the locations from your API displayed as red markers..  

This APP is just a base APP to help you start from something better than zero.
Good luck!


     
         


