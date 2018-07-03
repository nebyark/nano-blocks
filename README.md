# Nano Blocks
An iOS light wallet for the [Nano cryptocurrency](https://nano.org/en), written from the ground up, purely in Swift. Nano Blocks uses the [Canoe backend](https://github.com/getcanoe/canoed) for all key network requests including proof-of-work generation and block processing.

All designs are from my brother, Tim. Here's his other [stuff](http://www.timkray.com/).

## Features
* send and receive Nano
* change representative
* multiple account address support
* client-side address book
* QR generation and scanning
* biometrics
* export seed to encrypted zip (note: the baked-in macOS unzip utility won't unzip it)
* in-app block viewer
* multiple languages including English, Japanese, French, German, Spanish, and Swedish. [Contribute here.](https://poeditor.com/join/project/jmtLv86PbQ)


## Running the project
The project should build to a device out-of-the-box. However, if you wish to run on sim, you'll have to create a new `Sodium.framework` build [off of my swift-sodium fork](https://github.com/nebyark/swift-sodium) that includes sim architectures. 

## Contributing
Feel free to contribute. [There's a #dev channel in the Nano Blocks Discord](https://discord.gg/n76DkEt). There's plenty to do, including refactoring most views that use .xibs to have their layouts programmatically generated (I started on a few using `SnapKit`).
