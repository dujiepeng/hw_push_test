_中文 | [English](./README.md)_

# hw_push_test

介绍使用华为推送的demo。

## 集成华为推送

1. 添加华为推送 sdk

```shell
flutter pub get huawei_push
```

2. 在 `android/app/` 中添加 `agconnect-services.json` 文件([获取agconnect-services.json](!https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-integrating-sdk-0000001050040084))。

3. 在 `android/app/src/main/AndroidManifest.xml` 中添加 华为的AppId

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

4. 在 `android/app/` 目录下添加 `xxx.jks` 签名文件([配置签名](!https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-integrating-sdk-0000001050040084#section9256185512327)

)， 并将 `signingConfigs` 信息添加到 `android/app/build.gradle` 中，并配置混淆文件([配置混淆文件](!https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-config-obfuscation-scripts-0000001050176973))。


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

5. 在华为推送后台上传 证书指纹([获取证书指纹](!https://developer.huawei.com/consumer/cn/doc/HMSCore-Guides/android-config-agc-0000001050170137))。

## 在 im sdk 设置

1. 集成 im sdk。

2. . 在环信后台上传 华为推送配置 [上传证书到im后台](!https://doc.easemob.com/document/android/push.html#%E4%B8%8A%E4%BC%A0%E5%88%B0%E8%AE%BE%E5%A4%87%E8%AF%81%E4%B9%A6%E5%88%B0%E7%8E%AF%E4%BF%A1%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF%E4%BA%91%E6%8E%A7%E5%88%B6%E5%8F%B0)。

3. 初始化时需要开起 HWPush。

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final options = ChatOptions(appKey: "Your Appkey");
  // 开启推送
  options.enableHWPush();
  EMClient.getInstance.init(options).then((value) => runApp(const MyApp()));
}
```

4. 获取华为推送token，并在im 登录后将华为推送token传给im sdk

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


