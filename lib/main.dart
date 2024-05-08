import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:huawei_push/huawei_push.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final options = ChatOptions(appKey: "easemob#easeim", autoLogin: false);
  options.enableHWPush();
  ChatClient.getInstance.init(options).then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _token = '';
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _onNotificationOpenedApp(dynamic initialNotification) {
    if (initialNotification != null) {
      showResult('onNotificationOpenedApp', initialNotification.toString());
    }
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    // If you want auto init enabled, after getting user agreement call this method.
    await Push.setAutoInitEnabled(true);

    Push.getTokenStream.listen(
      _onTokenEvent,
      onError: _onTokenError,
    );
    Push.getIntentStream.listen(
      _onNewIntent,
      onError: _onIntentError,
    );
    Push.onNotificationOpenedApp.listen(
      _onNotificationOpenedApp,
    );

    final dynamic initialNotification = await Push.getInitialNotification();
    _onNotificationOpenedApp(initialNotification);

    final String? intent = await Push.getInitialIntent();
    _onNewIntent(intent);

    Push.onMessageReceivedStream.listen(
      _onMessageReceived,
      onError: _onMessageReceiveError,
    );
    Push.getRemoteMsgSendStatusStream.listen(
      _onRemoteMessageSendStatus,
      onError: _onRemoteMessageSendError,
    );

    bool backgroundMessageHandler = await Push.registerBackgroundMessageHandler(
      backgroundMessageCallback,
    );
    debugPrint(
      'backgroundMessageHandler registered: $backgroundMessageHandler',
    );
  }

  void _onTokenEvent(String event) async {
    _token = event;
    try {
      await ChatClient.getInstance.pushManager.updateHMSPushToken(_token);
    } catch (e) {
      debugPrint('bind token error: $e');
    }
    showResult('TokenEvent', _token);
  }

  void _onTokenError(Object error) {
    PlatformException e = error as PlatformException;
    showResult('TokenErrorEvent', e.message!);
  }

  void _onRemoteMessageSendStatus(String event) {
    showResult('RemoteMessageSendStatus', 'Status: $event');
  }

  void _onMessageReceived(RemoteMessage remoteMessage) {
    String? data = remoteMessage.data;
    if (data != null) {
      Push.localNotification(
        <String, String>{
          HMSLocalNotificationAttr.TITLE: 'DataMessage Received',
          HMSLocalNotificationAttr.MESSAGE: data,
        },
      );
      showResult('onMessageReceived', 'Data: $data');
    } else {
      showResult('onMessageReceived', 'No data is present.');
    }
  }

  void _onMessageReceiveError(Object error) {
    showResult('onMessageReceiveError', error.toString());
  }

  void _onRemoteMessageSendError(Object error) {
    PlatformException e = error as PlatformException;
    showResult('RemoteMessageSendError', 'Error: $e');
  }

  void _onNewIntent(String? intentString) {
    // For navigating to the custom intent page (deep link) the custom
    // intent that sent from the push kit console is:
    // app://app2
    intentString = intentString ?? '';
    if (intentString != '') {
      showResult('CustomIntentEvent: ', intentString);
      List<String> parsedString = intentString.split('://');
      if (parsedString[1] == 'app2') {
        SchedulerBinding.instance.addPostFrameCallback(
          (Duration timeStamp) {
            Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => const CustomIntentPage(),
              ),
            );
          },
        );
      }
    }
  }

  void _onIntentError(Object err) {
    PlatformException e = err as PlatformException;
    debugPrint('Error on intent stream: $e');
  }

  void showResult(
    String name, [
    String? msg = 'Button pressed.',
  ]) {
    msg ??= '';
    debugPrint('[$name]: $msg');
    Push.showToast('[$name]: $msg');
  }

  static void backgroundMessageCallback(RemoteMessage remoteMessage) async {
    String? data = remoteMessage.data;

    Push.localNotification(
        {HMSLocalNotificationAttr.TITLE: '[Headless] DataMessage Received', HMSLocalNotificationAttr.MESSAGE: data});

    Push.showToast('[Headless] DataMessage Received: $data');
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
                onPressed: () => {
                      ChatClient.getInstance
                          .login('du013', '1')
                          .then((value) => debugPrint('loginSuccess'))
                          .catchError((error) => debugPrint(error))
                    },
                child: const Text("Login")),
            TextButton(
                onPressed: () async {
                  Push.getToken('HCM');
                },
                child: const Text("bind hms token")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomIntentPage extends StatefulWidget {
  const CustomIntentPage({super.key});

  @override
  State<CustomIntentPage> createState() => _CustomIntentPageState();
}

class _CustomIntentPageState extends State<CustomIntentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Intent Page'),
      ),
      body: const Center(
        child: Text('Custom Intent Page'),
      ),
    );
  }
}
