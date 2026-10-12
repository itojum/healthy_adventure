# 移植メモ：DXRuby 版から PicoRuby.wasm + PicoDX 版へ

Ruby合宿2024春 Team5 のゲーム（[rc2024sp_team5](https://github.com/itojum/rc2024sp_team5) @ `f5b8055`）を、
[PicoDX](https://github.com/itojum/picodx) を使ってブラウザだけで動くようにしたときの記録です。
発表資料の素材にするため、原作から変えた点と、その理由をすべて残します。

## 進め方

まず PicoDX だけが動く最小構成（`port/00-base`）を用意し、そこに原作を無変更のまま載せました（#12）。
原作を載せた時点では動かないので、その上に、動かない原因を 1 つずつ直すブランチをスタック PR として積みました。
各 PR は「直す前に何が起きていたか」と「直した後どうなったか」を、ブラウザで実際に動かして確かめています。

| PR | ブランチ | 直す前に起きていたこと | 直したこと | 原作の変更 |
| --- | --- | --- | --- | --- |
| ─ | `port/00-base` | ─ | PicoDX の最小構成（矢印キーで四角が動く） | ─ |
| #12 | `port/original` | ─ | 原作を無変更のまま載せる（`require 'dxruby'` で止まる） | ─ |
| #2 | `port/01-require` | `require 'dxruby'` で `LoadError` | `require` をたどって 1 ファイルにまとめるビルド | なし |
| #3 | `port/02-set` | `require 'set'` で `LoadError` | ゲームで使う分だけの `Set` を用意 | なし |
| #4 | `port/03-ranking` | `require 'net/http'` で `LoadError` | ランキングを一旦外す | `page/goal.rb` |
| #5 | `port/04-image-path` | 背景画像が 404（`image%08ackground1.png`） | 画像パスの `\` を `/` に | `main.rb` ほか 3 ファイル |
| #6 | `port/05-rand-range` | プレイ画面で `rand(0..10)` が `TypeError` | `rand` が `Range` を受け付けるように | なし |
| #7 | `port/06-collision-nearby` | プレイ画面が約 3fps | 衝突判定を近くのブロックだけに絞る | `page/gameplay.rb` |
| #8 | `port/07-skip-offscreen-blocks` | （約 31〜39fps） | 画面の右外のブロックを描かない | `page/gameplay.rb` |
| #9 | `port/08-fast-rand` | （約 30〜50fps） | `rand` を Ruby の xorshift に置き換え | なし |
| #10 | `port/09-docs` | ─ | この移植メモと README | なし |

#12 の差分が原作そのものです。原作のコードからの変更は `git diff port/original port/09-docs -- main.rb page class init` で見られます。

## 結果

- タイトル → キャラ選択 → プレイ → ゲームオーバー / ゴール → タイトル、の一周がブラウザで動く
- プレイ画面は約 56〜60fps（ゲーム処理は 1 フレームあたり中央値 8ms、95% で 14ms）
- 原作のゲームのコードで書き換えたのは **4 ファイル・追加 15 行／削除 12 行**（コメントを含む）。
  ほかは新規ファイル（`init/block_grid.rb`）、互換レイヤー（`compat/`）、ビルドで吸収した

計測はヘッドレス Chromium（クラウドの開発環境）で行った。実機の値は別に測る必要がある。

## 動かなかった原因と直し方

### 1. `require` が使えない（#2）

- **起きたこと**：`main.rb` の 1 行目 `require 'dxruby'` で `LoadError`
- **原因**：PicoRuby.wasm では、ゲームのファイルを `require` できない（仮想ファイルシステムが空）。
  `<script type="text/ruby">` をファイルごとに並べても、それぞれが**別タスクとして同時に動く**ので代わりにならない
  （前のファイルの `Image.load` の `await` を待たずに次のファイルが始まる）
- **直し方**：`script/build.rb` で `main.rb` から `require` をたどり、`require` の行をそのファイルの中身で置き換えて、
  PicoDX と合わせた 1 ファイル（`dist/game.rb`）にする。原作のファイル構成と `require` はそのまま残せる

### 2. `Set` がない（#3）

- **起きたこと**：`require 'set'` で `LoadError`
- **原因**：PicoRuby には標準ライブラリの `Set` がない
- **直し方**：原作が使う `add` / `delete` / `each` / `select` / `to_a` だけを `compat/set.rb` に実装し、
  ビルドで `require 'set'` をこのファイルに置き換える。`each` の途中で `delete` しても読み飛ばさない点も CRuby に合わせた

### 3. ランキングが外部サーバーに依存している（#4）

- **起きたこと**：`require 'net/http'` で `LoadError`
- **原因**：ランキングは `net/http` で外部サーバー（Replit）にスコアを送り、返ってきた文字列を `eval` している
- **直し方**：一旦なしにする判断をした。`page/goal.rb` から読み込みと呼び出しを外し、`ranking.rb` は原作のまま残す

### 4. Windows のパス区切り（#5）

- **起きたこと**：`image%08ackground1.png` を読みに行って 404
- **原因**：`'image\background1.png'` が JS の文字列に埋め込まれ、`\b` がバックスペースとして解釈された
- **直し方**：4 か所のパスを `/` に直した

### 5. `rand` が `Range` を受け付けない（#6）

- **起きたこと**：プレイ画面に入った瞬間に `TypeError: Range cannot be converted to Float`
- **原因**：PicoRuby の `rand` は `Range` を受け付けない
- **直し方**：`compat/kernel.rb` で `rand` を包み、整数の `Range` を受け付けるようにした。ビルドがゲーム本体より前に読み込む

### 6. 遅い（#7〜#9）

エラーはなくなったが、プレイ画面が約 3fps だった。

| 段階 | プレイ画面の fps | 残ったボトルネック |
| --- | --- | --- |
| #6 まで（エラーなし） | 約 3 | 全ブロックとの `Sprite#===`（約 3 万回 / フレーム） |
| #7 衝突判定を近くに絞る | 約 31〜39 | `rand` と、画面外ブロックの描画予約 |
| #8 画面外のブロックを描かない | 約 30〜50（ばらつき大） | `rand`（1 フレーム約 14ms） |
| #9 `rand` を xorshift に | 約 56〜60 | ─ |

- **衝突判定（#7）**：PicoRuby.wasm では `Sprite#===` が 1 回 10〜20µs かかる。DXRuby では C 実装なので気にならなかった。
  ブロックを x 座標の列ごとに振り分け、近くの列だけを判定する。全ブロックとの判定結果と照合し、約 650 万回で取りこぼし 0 件
- **画面外の描画（#8）**：描画の予約だけでも 1 回十数 µs かかる。効果は計測のばらつきに埋もれる程度だった
- **乱数（#9）**：PicoRuby.wasm の `rand` は **1 回 130〜150µs** と、`Sprite#===` の 10 倍以上遅い。
  Ruby で書いた xorshift32 にすると 1 回 3〜5µs になる。これが 60fps に届いた決め手

## 移植で分かった PicoRuby.wasm の特徴（発表のネタ）

- **`require` が使えない**ので、ビルド時に 1 ファイルへ結合する。`<script>` を分けると別タスクとして並行に動くので、分けるだけでは代わりにならない
- **標準ライブラリの一部がない**（`Set`、`net/http` など）。必要な分だけ Ruby で書けば足りる
- **組み込みメソッドの速さに大きな差がある**。`rand` は Ruby で書いた乱数の 30 倍以上遅い。
  DXRuby（C 実装）では気にならなかった処理が、そのまま 1 フレームの予算（16.7ms）を食いつぶす
- **Ruby のコード自体も CRuby よりかなり遅い**。総当たりの衝突判定は、近くだけを調べる工夫が必要になる
- 逆に、**PicoDX の互換性が高いので、ゲームのロジックはほぼそのまま動く**。原作の変更は 4 ファイル・追加 15 行／削除 12 行で済んだ

## 移植のための土台（`port/00-base` と #2 で追加。原作には関係しないもの）

| ファイル | 内容 |
| --- | --- |
| `index.html` | 1024x700 の canvas を、画面サイズに合わせて縦横比を保ったまま拡大・縮小する |
| `vendor/picodx.rb` | PicoDX（itojum/picodx@`7b230b8` のビルド）。会場でネットワークに頼らないよう同梱 |
| `vendor/picoruby/` | PicoRuby.wasm 4.0.2（`@picoruby/wasm-wasi`）。同上 |
| `script/server` | Ruby の標準ライブラリだけで動くサーバー（ポート 3001）。`dist/game.rb` へのアクセスのたびにビルドし直す。IPv4 と IPv6 の両方で待ち受け、ポートが使われていたら止まる |
| `script/build.rb` | `require` をたどって `dist/game.rb` にまとめるビルド |

## PicoDX 側で見つかった問題（PicoDX のリポジトリには未反映）

- **1 フレームより短い入力を取りこぼす**：キーやマウスを 16ms 未満で押して離すと、`key_down?` / `key_push?` / `mouse_push?` が一度も真にならない。タッチパッドのタップで起きる可能性がある
- **`Image.load` / `Sound.new` がパスを JS の文字列にそのまま埋め込む**：`\` や `'` を含むパスで壊れる（#5 の原因）。エスケープすれば原作のパスのままでも読める

## 未対応・未確認

- **BGM**：`page/bgm/selectBGM.wav` は 23MB あり、原作の `Bgm.new` が同じファイルを 3 回読み込む。Web に公開するなら圧縮形式への変換か、読み込みを 1 回にする対応が必要。実機での再生は未確認
- **BGM の利用条件**：MusMus の素材ファイルをリポジトリで配布してよいかは要確認（原作のリポジトリにも含まれている）
- **フォント**：原作の「HGP創英角ﾎﾟｯﾌﾟ体」などは Windows 専用のため、ブラウザの標準フォントで表示される
- **ゴール画面**：毎フレーム `Image.load` で大きな背景画像を複製しているため約 30fps。静止画面なので実害はない
- **ランキング**：一旦なし
