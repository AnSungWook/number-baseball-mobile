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

## Android 출시 준비

1. 릴리스 키 생성  
   ```bash
   cd mobile/number_baseball_webview/android
   keytool -genkey -v \
     -keystore numberbaseball-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias numberbaseball
   ```
2. `key.properties.example`을 복사해 `key.properties`로 이름을 바꾸고 실제 비밀번호·경로를 입력합니다. 생성한 keystore 파일은 `android/` 바깥(예: `mobile/number_baseball_webview/numberbaseball-release.jks`)에 두고 Git에는 올리지 마세요.
3. 프로젝트 루트에서 릴리스 번들을 빌드합니다.  
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle \
     --dart-define=WEB_APP_URL=https://nagarago.com
   ```
   필요하다면 `flutter build apk --split-per-abi ...` 명령으로 테스트용 APK도 함께 만듭니다.
4. 산출물 확인  
   - `build/app/outputs/bundle/release/app-release.aab` → Google Play Console에 업로드  
   - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` 등 → 실제 기기에서 서명 정상 여부 점검
5. Google Play Console 작업  
   - 앱을 생성한 뒤 `앱 무결성` 메뉴에서 Play App Signing을 활성화합니다.  
   - 스토어 등록 정보(아이콘, 스크린샷, 소개 문구, 개인정보처리방침 URL)를 모두 입력합니다.  
   - `내부 테스트` 트랙에 먼저 올려 팀원과 검증한 뒤, `생산` 트랙 릴리스를 만듭니다.  
   - 검수에서 보완 요청이 오면 내용을 반영해 다시 제출합니다.
