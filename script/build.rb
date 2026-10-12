#!/usr/bin/env ruby
# frozen_string_literal: true

# main.rb から require をたどり、ブラウザで読み込む 1 ファイル（dist/game.rb）にまとめる。
#
# PicoRuby.wasm では、ゲームのファイルを require できない（仮想ファイルシステムが空）。
# また <script type="text/ruby"> をファイルごとに並べても代わりにならない。それぞれが別タスクとして
# 同時に動き出すので、前のファイルの Image.load の await を待たずに次のファイルが始まってしまう。
# そこで、Ruby の require と同じ順序になるよう、require の行をそのファイルの中身で
# 置き換えて 1 本のスクリプトにする。原作のファイル構成と require はそのまま残せる。
# PicoDX は index.html で CDN から別に読み込む（クラスを定義するだけで await しないので問題ない）。
#
#   ruby script/build.rb    # dist/game.rb を生成する
module GameBuild
  ROOT   = File.expand_path('..', __dir__)
  ENTRY  = 'main.rb'
  OUTPUT = File.join(ROOT, 'dist', 'game.rb')

  # ブラウザでは読み込まないライブラリ
  SKIPPED = {
    'dxruby' => 'PicoDX を先に読み込むので不要',
  }.freeze

  # PicoRuby にない標準ライブラリを、このゲームで使う分だけ実装したファイルに置き換える
  COMPAT = {
    'set' => 'compat/set.rb',
  }.freeze

  REQUIRE_RE = /\A(\s*)require(_relative)?\s*\(?\s*(["'])([^"']+)\3\s*\)?\s*(#.*)?\z/

  module_function

  def build
    loaded = []
    body = expand(File.join(ROOT, ENTRY), loaded)
    header = "# このファイルは script/build.rb が生成したものです。直接編集しないでください。\n" \
             "# 元のファイル: #{loaded.map { |f| relative(f) }.join(', ')}\n"
    header + body
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

      # './xxx.rb' や require_relative 以外は、ゲームのファイルではなくライブラリの require。
      # 実行時の require に任せる（PicoRuby にあれば読み込まれ、なければ LoadError になる）
      unless rel || name.start_with?('./', '../', '/')
        out << line
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
