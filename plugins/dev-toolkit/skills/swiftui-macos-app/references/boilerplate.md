# ボイラープレート（コピペ用コード全文）

SKILL.md の方針に対応する、そのまま貼れるコード。必要な節だけ読むこと。
すべて macOS 14 以上・SwiftUI 前提。

## 目次
- [App エントリポイント](#app-エントリポイント)
- [メニューコマンド & ショートカット](#メニューコマンド--ショートカット)
- [共有設定オブジェクト（フォント等）](#共有設定オブジェクト)
- [フォント設定画面](#フォント設定画面)
- [アプリ全体へのフォント反映](#アプリ全体へのフォント反映)
- [外部サービスのログイン起点フロー](#外部サービスのログイン起点フロー)

---

## App エントリポイント

```swift
import SwiftUI

@main
struct MyApp: App {
    // アプリ全体で共有する設定（フォント・認証状態など）
    @State private var settings = AppSettings()
    @State private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .environment(auth)
                .appFont(settings)          // ← フォント反映（下記 modifier）
        }
        .commands { AppCommands() }

        Settings {
            SettingsView()
                .environment(settings)
                .appFont(settings)
        }
    }
}
```

---

## メニューコマンド & ショートカット

```swift
struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("新規作成") { NotificationCenter.default.post(name: .newItem, object: nil) }
                .keyboardShortcut("n", modifiers: .command)
        }
        CommandMenu("操作") {
            Button("更新") { NotificationCenter.default.post(name: .refresh, object: nil) }
                .keyboardShortcut("r", modifiers: .command)
            Divider()
            Button("検索") { /* … */ }
                .keyboardShortcut("f", modifiers: .command)
        }
    }
}

extension Notification.Name {
    static let newItem = Notification.Name("app.newItem")
    static let refresh = Notification.Name("app.refresh")
}
```

`⌘,`（設定）は `Settings` scene が自動で割り当てるため、ここには**書かない**。

---

## 共有設定オブジェクト

`@Observable` + `@AppStorage` 相当の永続化。フォント名・サイズを保持する。

```swift
import SwiftUI
import Observation

@Observable
final class AppSettings {
    // 読みやすさのための下限。極端に小さいサイズは許可しない。
    static let minFontSize: Double = 11
    static let maxFontSize: Double = 28
    static let systemFontName = "システムデフォルト"

    var fontName: String {
        didSet { UserDefaults.standard.set(fontName, forKey: "fontName") }
    }
    var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "fontSize") }
    }

    init() {
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? Self.systemFontName
        let saved = UserDefaults.standard.double(forKey: "fontSize")
        self.fontSize = saved == 0 ? 13 : saved   // 0 は未設定
    }

    /// 設定を SwiftUI の Font に変換。未選択時はシステムフォント。
    /// relativeTo: でアクセシビリティのサイズ変更に追従させ、可読性を保つ。
    var resolvedFont: Font {
        if fontName == Self.systemFontName {
            return .system(size: fontSize)
        }
        return .custom(fontName, size: fontSize, relativeTo: .body)
    }
}
```

---

## フォント設定画面

`NSFontManager` から利用可能なフォント一覧を取得し、Picker に流す。プレビュー付き。

```swift
import SwiftUI
import AppKit

struct AppearanceSettingsView: View {
    @Environment(AppSettings.self) private var settings

    private var families: [String] {
        [AppSettings.systemFontName] + NSFontManager.shared.availableFontFamilies
    }

    var body: some View {
        @Bindable var settings = settings
        Form {
            Picker("フォント", selection: $settings.fontName) {
                ForEach(families, id: \.self) { Text($0).tag($0) }
            }

            VStack(alignment: .leading) {
                Text("サイズ：\(Int(settings.fontSize))pt")
                Slider(value: $settings.fontSize,
                       in: AppSettings.minFontSize...AppSettings.maxFontSize,
                       step: 1)
            }

            // その場で結果を確認できるプレビュー（日本語＋英数字）
            GroupBox("プレビュー") {
                Text("あア亜 The quick brown fox 0123")
                    .font(settings.resolvedFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
        }
        .padding()
    }
}
```

---

## アプリ全体へのフォント反映

ルートに付けるだけで全子ビューへ伝播する ViewModifier。

```swift
extension View {
    func appFont(_ settings: AppSettings) -> some View {
        self.environment(\.font, settings.resolvedFont)
    }
}
```

個別に上書きしたいビュー（見出しなど）は、その場で `.font(.title)` を付ければ優先される。

---

## 外部サービスのログイン起点フロー

未認証ならログイン画面、認証済みなら本体。分岐は認証状態オブジェクトで行う。

```swift
import SwiftUI
import AuthenticationServices

@Observable
final class AuthStore {
    enum State { case unknown, loggedOut, loggedIn }
    var state: State = .loggedOut   // 起動時に Keychain を見て復元する

    // トークンは UserDefaults ではなく Keychain に保存する（平文保存禁止）
    // ここでは省略：KeychainWrapper 等でアクセストークン/リフレッシュトークンを扱う
}

struct RootView: View {
    @Environment(AuthStore.self) private var auth

    var body: some View {
        switch auth.state {
        case .unknown:
            ProgressView("確認中…")
        case .loggedOut:
            LoginView()          // ← 未認証は必ずここが起点
        case .loggedIn:
            MainView()           // ← 認証後に作成/操作フローへ
        }
    }
}

struct LoginView: View {
    @Environment(AuthStore.self) private var auth
    @Environment(\.webAuthenticationSession) private var webAuth

    var body: some View {
        VStack(spacing: 16) {
            Text("Notion と連携")
                .font(.title2).bold()
            Text("ページの作成・更新に使います。ログインすると連携が始まります。")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Notion でログイン") {
                Task { await login() }
            }
            .keyboardShortcut(.defaultAction)   // Return で実行
        }
        .padding(40)
        .frame(minWidth: 360)
    }

    private func login() async {
        // ASWebAuthenticationSession（SwiftUI の webAuthenticationSession 環境値）で
        // OAuth 2.0 のフローを開始し、コールバックURLから code を受け取る。
        // 取得したトークンは検証のうえ Keychain に保存し、auth.state = .loggedIn にする。
        // client ID / secret はハードコードしない（環境変数・設定ファイル・Keychain 経由）。
    }
}
```

> `webAuthenticationSession` 環境値は macOS 14+ で利用可能。Google連携も同様に、
> スコープ・リダイレクトURIを設定したうえで同じ骨組みで実装する。
> **client secret や token を握ったら、コミット前に `code-reviewer` でレビューすること。**
