#!/usr/bin/env ruby
# frozen_string_literal: true

# main.rb から require をたどり、ブラウザで読み込む 1 ファイル（dist/game.rb）にまとめる。
#
# PicoRuby.wasm では require が使えない（仮想ファイルシステムが空）うえ、
# <script type="text/ruby"> を複数並べると、それぞれが別タスクとして同時に動き出す
# （前のファイルの Image.load の await を待たずに次のファイルが始まる）。
# そこで、Ruby の require と同じ順序になるよう、require の行をそのファイルの中身で
# 置き換えて 1 本のスクリプトにする。原作のファイル構成と require はそのまま残せる。

module GameBuild
  ROOT  = File.expand_path('..', __dir__)
  ENTRY = 'main.rb'
  OUTPUT = File.join(ROOT, 'dist', 'game.rb')

  # ブラウザでは読み込まない（または読み込めない）ライブラリ
  SKIPPED = {
    'dxruby' => 'PicoDX を先に読み込むので不要',
  }.freeze

  # PicoRuby にない標準ライブラリを、このゲームで使う分だけ実装したファイルに置き換える
  COMPAT = {
    'set' => 'compat/set.rb',
  }.freeze

  # 標準ライブラリとの違いを埋めるため、ゲーム本体より前に必ず読み込むファイル
  PRELUDE = %w[compat/kernel.rb].freeze

  REQUIRE_RE = /\A(\s*)require(_relative)?\s*\(?\s*(["'])([^"']+)\3\s*\)?\s*(#.*)?\z/

  module_function

  # PicoDX 本体（ライブラリ）。これも同じファイルに入れる。別の <script> にすると
  # 別タスクになり、PicoDX のクラス定義が終わる前にゲームが動き出すおそれがある
  PICODX = File.join(ROOT, 'vendor', 'picodx.rb')

  def build
    loaded = []
    prelude = PRELUDE.map { |f| expand(File.join(ROOT, f), loaded) }.join
    body = prelude + expand(File.join(ROOT, ENTRY), loaded)
    header = "# このファイルは script/build が生成したものです。直接編集しないでください。\n" \
             "# 元のファイル: vendor/picodx.rb, #{loaded.map { |f| relative(f) }.join(', ')}\n"
    picodx = "# ==== vendor/picodx.rb ====\n" + File.read(PICODX, encoding: 'UTF-8')
    picodx << "\n" unless picodx.end_with?("\n")
    # Ruby のコードが動き始めたら「読み込み中」の表示を消す
    loading = "JS.eval(\"document.getElementById('loading')?.remove()\")\n"
    header + picodx + loading + body
  end

  def write
    code = build
    Dir.mkdir(File.dirname(OUTPUT)) unless Dir.exist?(File.dirname(OUTPUT))
    File.write(OUTPUT, code)
    OUTPUT
  end

  def expand(path, loaded)
    return '' if loaded.include?(path) # 2 回目以降の require は何もしない（Ruby と同じ）

    loaded << path
    out = +"# ==== #{relative(path)} ====\n"
    File.read(path, encoding: 'UTF-8').each_line do |line|
      m = REQUIRE_RE.match(line.chomp)
      unless m
        out << line
        next
      end

      indent, rel, name = m[1], m[2], m[4]
      if SKIPPED.key?(name)
        out << "#{indent}# [build] require '#{name}' を除去: #{SKIPPED[name]}\n"
        next
      end

      if COMPAT.key?(name)
        out << expand(File.join(ROOT, COMPAT[name]), loaded)
        out << "# ==== (#{relative(path)} に戻る) ====\n"
        next
      end

      base = rel ? File.dirname(path) : ROOT
      target = File.expand_path(name, base)
      target += '.rb' unless target.end_with?('.rb')
      raise "#{relative(path)}: require '#{name}' のファイルが見つかりません" unless File.exist?(target)

      out << expand(target, loaded)
      out << "# ==== (#{relative(path)} に戻る) ====\n"
    end
    out << "\n" unless out.end_with?("\n")
    out
  end

  def relative(path)
    path.delete_prefix("#{ROOT}/")
  end
end

if $PROGRAM_NAME == __FILE__
  out = GameBuild.write
  puts "Built #{GameBuild.relative(out)}"
end
