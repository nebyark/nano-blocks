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

![](https://i.imgur.com/ldm9UeW.jpg)

## Running the project
The project should build out-of-box to a simulator. You'll have to modify the team signing settings (don't commit these changes) to get the project to build to a device.

## Contributing
Feel free to contribute. [There's a #dev channel in the Nano Blocks Discord](https://discord.gg/n76DkEt). There's plenty to do, including refactoring most views that use .xibs to have their layouts programmatically generated (I started on a few using `SnapKit`).

## About Nano Blocks
Nano Blocks started in December 2017 when, at the time, no mobile light wallets for Nano existed yet. More on that on [here](https://medium.com/@benkray).
