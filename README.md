## Overview

* For kintone developers, provide an example of developing mobile application using kintone-ios-sdk.
* With kintone-ios-sdk, you can develop iOS-specific apps for kintone.
* Specifically, you can view records, add record, edit record, delete record, write record's comment, etc. of the kintone app.

## Requirements

* Xcode 9 or newer
* Supported Devices: iPhone 6 or newer
* iOS 11.4 or newer

## Usage

1. Create a kintone App

* Create kintone App and Form with fileds as below.
  
    * Form Design \
     ![overview image](./Screenshots/FormSetting.png?raw=true)

    * Field Settings 
    
        |Name|Field Code| 
        | :- | :- |
        | Summary| Summary| 
        | Notes| Notes| 
        | Photo| Photo| 
        | Status | Status| 
        | Creator | Creator| 
        | Create Date Time|CreateDateTime| 

2. Get source code

```bashshell
$ git clone https://github.com/kintone/SAMPLE-kintone-ios-sdk-mobile-app.git
```

3. Recheck the Podfile

        target 'SpaceSoldierApp' do
            pod 'kintone-ios-sdk'
            pod 'CryptoSwift'
            pod 'PromisesSwift', '~> 1.2.7'	
        end

* Install those dependency packages

        pod install

4. Open the workspace of application

* In Xcode, select File > Open. Then choose cloned SAMPLE-kintone-ios-sdk-mobile-app. 

![xcode settings](./Screenshots/XcodeSettings.png?raw=true)

5. Run The App

* In Xcode, click run icon to start app in simulator. 

![overview image](./Screenshots/XcodeView.png?raw=true)

## Features
 * Using Password Authentication to connect with kintone
 * Be able to import client certificate file to authenticate.
 * View all records.
 * Create a new record.
 * View/Edit/Delete specific record.
 * Take photo and Upload images from mobile application to kintone.
 * Comment/Reply or Delete a comment belong to a record.
 
## Description

* About The App Pages 

    * Login Page \
     ![overview image](./Screenshots/LoginView.png?raw=true)
    * Record List Page \
     ![overview image](./Screenshots/RecordList.png?raw=true)
    * Record Detail Page \
     ![overview image](./Screenshots/RecordDetail.png?raw=true)
    * Record Comment Page \
     ![overview image](./Screenshots/RecordComment.png?raw=true)
    * Edit Record Page \
     ![overview image](./Screenshots/RecordEdit.png?raw=true)
    * Add Record Page \
     ![overview image](./Screenshots/RecordAdd.png?raw=true)

## Libraries used and their documentation

* kintone-ios-sdk v0.2.0  [Docs](https://kintone.github.io/kintone-ios-sdk/)
* PromisesSwift [Docs](https://github.com/google/promises/blob/master/g3doc/index.md)
* CryptoSwift [Docs](https://cryptoswift.io/)

## License

&emsp;&ensp;MIT

## Copyright

&emsp;&ensp;Copyright(c) Cybozu, Inc.

