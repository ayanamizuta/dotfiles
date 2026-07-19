# mac-mini

Mac mini (M4) の再起動時セットアップ。

## claude remote-control の自動起動

`LaunchAgents/` の plist は、以下の各ディレクトリで `claude remote-control` を
ログイン時に自動起動し、`--continue` で直前のセッションを再開する
(再開できない場合は `--spawn worktree --sandbox` で新規起動)。

| plist | ディレクトリ |
|---|---|
| `com.mizuta.claude-rc.incubate` | `~/work/products/incubate` |
| `com.mizuta.claude-rc.talksmith` | `~/work/loov/Talksmith` |
| `com.mizuta.claude-rc.umigame` | `~/work/products/umigame` |
| `com.mizuta.claude-rc.wedraft-flows` | `~/work/wedraft/flows` |
| `com.mizuta.claude-rc.kanken` | `~/work/products/kanken` |
| `com.mizuta.claude-rc.dotfiles` | `~/work/dotfiles` |

## セットアップ

```sh
cd mac-mini
./bootstrap.sh
```

## 注意

- `--continue` は Claude Code **v2.1.200 以上**が必要(それ未満は unknown argument で
  フォールバック側が起動する)
- `--continue` は「そのディレクトリで最後に使った Remote Control セッション」を1つ
  再開する仕様。`--spawn` との併用は不可
- 再起動後に自動で走らせるには、macOS の自動ログインが有効である必要がある
  (ログイン画面のままでは LaunchAgent は起動しない)
- 対象ディレクトリを増減する場合は `LaunchAgents/` に plist を追加/削除して
  `bootstrap.sh` を再実行
