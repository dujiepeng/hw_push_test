_English | [中文](./README_zh.md)_

# hw_push_test

This is a demo on how to use Huawei Push.

## Integrating Huawei Push

1. Add Huawei Push sdk

```shell
flutter pub get huawei_push
```

2. Add `agconnect-services.json` file in `android/app/` ([Get agconnect-services.json](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-integrating-sdk-0000001050040084)).

3. Add Huawei's AppId in `android/app/src/main/AndroidManifest.xml`

```xml
<application>
    ...
    <meta-data
        android:name="com.huawei.hms.client.appid"
        android:value="Your huawei appid">
    </meta-data>
    ...
</application>
```

4. Add `xxx.jks` signature file in `android/app/` directory ([Configure signature](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-integrating-sdk-0000001050040084#section9256185512327)

), and add `signingConfigs` information to `android/app/build.gradle`, and configure obfuscation file ([Configure obfuscation file](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-config-obfuscation-scripts-0000001050176973)).


```gradle
android{
    ...
    signingConfigs {
        config {
            keyAlias 'xxxx'
            keyPassword 'xxxx'
            storeFile file('huawei_push_flutter.jks')
            storePassword 'xxxx'
            v1SigningEnabled true
            v2SigningEnabled true
        }
    }

    buildTypes {
        debug {
            signingConfig signingConfigs.config
        }
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
            signingConfig signingConfigs.debug
        }
    }
    ...
}
```

5. Upload the certificate fingerprint to Huawei Push backend ([Get certificate fingerprint](https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-config-agc-0000001050170137)).

## Setting up in im sdk

1. Integrate im sdk.

2. Upload Huawei Push configuration to Easemob backend [Upload certificate to im backend](https://doc.easemob.com/document/android/push.html#%E4%B8%8A%E4%BC%A0%E5%88%B0%E8%AE%BE%E5%A4%87%E8%AF%81%E4%B9%A6%E5%88%B0%E7%8E%AF%E4%BF%A1%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF%E4%BA%91%E6%8E%A7%E5%88%B6%E5%8F%B0).

3. Need to start HWPush during initialization.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final options = ChatOptions(appKey: "Your Appkey");
  // Enable push
  options.enableHWPush();
  EMClient.getInstance.init(options).then((value) => runApp(const MyApp()));
}
```

4. Get Huawei Push token, and pass the Huawei Push token to im sdk after im login

```dart
Push.getTokenStream.listen(
    (event) async {
    _token = event;
    try {
        await ChatClient.getInstance.pushManager.updateHMSPushToken(_token);
    } catch (e) {
        debugPrint('bind token error: $e');
    }
    showResult('TokenEvent', _token);
    },
    onError: (e) {
    debugPrint('get token error: $e');
    },
);
```