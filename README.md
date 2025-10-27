# Number Baseball WebView Shell

Flutter 껍데기에 WebView만 올려서 기존 React 기반 숫자 야구 서비스를 그대로 감싸는 초경량 앱입니다.

## 실행

```bash
cd mobile/number_baseball_webview
flutter pub get
flutter run \
  --dart-define=WEB_APP_URL=http://3.36.226.165:3000
```

`WEB_APP_URL`을 지정하지 않으면 기본값으로 `http://localhost:3000`이 사용됩니다.

## 주요 특징

- `webview_flutter` 공식 패키지 사용
- 풀스크린 WebView + 기본 새로고침, 로딩 인디케이터
- 안드로이드 뒤로가기 → WebView 히스토리를 우선 소비
- JavaScript 허용, 필요 시 `JavaScriptChannel` 추가 가능

## 플랫폼 메모

### Android
`android/app/src/main/AndroidManifest.xml`에 이미 있는 `<uses-permission android:name="android.permission.INTERNET" />`가 필요합니다 (기본 Flutter 템플릿에 포함). 별도 네트워크 보안 설정 없이 HTTP 접근 가능합니다.

### iOS
`ios/Runner/Info.plist`에 ATS 예외(HTTP 사용 시)나 HTTPS 도메인 인증을 넣어야 합니다. HTTP 그대로 쓰려면 아래 키를 추가하세요.

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

또는 배포 시 React 앱에 TLS를 붙이고 위 항목 없이 HTTPS 도메인을 사용하세요.
