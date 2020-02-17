# ASMvvm

This project is inspired by [https://github.com/duyduong/DTMvvm](https://github.com/duyduong/DTMvvm) 

[![CI Status](https://img.shields.io/travis/toandk/DTMvvm.svg?style=flat)](https://travis-ci.org/toandk/DTMvvm)
[![Version](https://img.shields.io/cocoapods/v/DTMvvm.svg?style=flat)](https://cocoapods.org/pods/DTMvvm)
[![License](https://img.shields.io/cocoapods/l/DTMvvm.svg?style=flat)](https://cocoapods.org/pods/DTMvvm)
[![Platform](https://img.shields.io/cocoapods/p/DTMvvm.svg?style=flat)](https://cocoapods.org/pods/DTMvvm)

ASMvvm is a library for who wants to start writing iOS application using MVVM (Model-View-ViewModel), written in Swift.

- [Features](#features)
- [Requirements](#requirements)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Example](#example)
- [Usage](#usage)

## Features

- [x] Base classes for ASViewController, ASView, ASCellNode and ASCollectionNode
- [x] Base classes for ViewModel, ListViewModel and CellViewModel
- [x] Services injection

## Requirements
- iOS 10.0+
- Xcode 11.0+
- Swift 5.0+

## Dependencies
The library heavily depends on [RxSwift](https://github.com/ReactiveX/RxSwift) for data-binding and events. For who does not familiar with Reactive Programming, I suggest to start reading about it first. Beside that, here are the list of dependencies:
- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [TextureGroup](https://github.com/TextureGroup/Texture)
- [RxCocoa-Texture](https://github.com/RxSwiftCommunity/RxCocoa-Texture)
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)
- [RxASDataSources](https://github.com/RxSwiftCommunity/RxASDataSources)

## Installation
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ASMvvm into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ASMvvm'
end
```

Then, run the following command:

```bash
$ pod install
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

To be updated

## License

ASMvvm is available under the MIT license. See the LICENSE file for more info.
