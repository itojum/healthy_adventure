require 'js'

module PicoDX
  # 色配列を CSS の色文字列に変換する唯一の窓口。
  # 4 要素は DXRuby と同じ [A, R, G, B]、3 要素は [R, G, B]（不透明）。
  def self._css_color(color)
    if color.length == 4
      a, r, g, b = color
      "rgba(#{r},#{g},#{b},#{a.to_f / 255})"
    else
      r, g, b = color
      "rgb(#{r},#{g},#{b})"
    end
  end

  module Drawable
    # -------------------------------------------------------------------------
    # Queue-aware public draw methods
    # Each method pushes a descriptor onto @draw_queue when available
    # (Window), or falls through to the immediate _render_* variant
    # (RenderTarget, which has no queue).
    #
    # z は DXRuby と同じく末尾の位置引数で受け取る（例: draw(x, y, image, z)）。
    # 互換のため z: キーワードも受け付け、両方あれば位置引数を優先する。
    # -------------------------------------------------------------------------

    def draw(x, y, image, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw, z: z, x: x, y: y, image: image }
      else
        _render_draw(x, y, image)
      end
    end

    def draw_box(x1, y1, x2, y2, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_box, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_box(x1, y1, x2, y2, color)
      end
    end

    def draw_box_fill(x1, y1, x2, y2, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_box_fill, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_box_fill(x1, y1, x2, y2, color)
      end
    end

    def draw_font(x, y, str, font_or_color, color_or_size = nil)
      z = 0
      if font_or_color.is_a?(Font)
        opts = color_or_size.is_a?(Hash) ? color_or_size : {}
        z = opts[:z] || 0
      end
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_font, z: z, x: x, y: y, str: str,
                         font_or_color: font_or_color, color_or_size: color_or_size }
      else
        _render_draw_font(x, y, str, font_or_color, color_or_size)
      end
    end

    def draw_font_ex(x, y, str, font_or_color, options_or_size = nil)
      z = 0
      if font_or_color.is_a?(Font)
        opts = options_or_size.is_a?(Hash) ? options_or_size : {}
        z = opts[:z] || 0
      end
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_font_ex, z: z, x: x, y: y, str: str,
                         font_or_color: font_or_color, options_or_size: options_or_size }
      else
        _render_draw_font_ex(x, y, str, font_or_color, options_or_size)
      end
    end

    def draw_line(x1, y1, x2, y2, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_line, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_line(x1, y1, x2, y2, color)
      end
    end

    def draw_pixel(x, y, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_pixel, z: z, x: x, y: y, color: color }
      else
        _render_draw_pixel(x, y, color)
      end
    end

    def draw_circle(x, y, r, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_circle, z: z, x: x, y: y, r: r, color: color }
      else
        _render_draw_circle(x, y, r, color)
      end
    end

    def draw_circle_fill(x, y, r, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_circle_fill, z: z, x: x, y: y, r: r, color: color }
      else
        _render_draw_circle_fill(x, y, r, color)
      end
    end

    def draw_scale(x, y, image, scale_x, scale_y, cx = nil, cy = nil, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_scale, z: z, x: x, y: y, image: image,
                         scale_x: scale_x, scale_y: scale_y, cx: cx, cy: cy }
      else
        _render_draw_scale(x, y, image, scale_x, scale_y, cx, cy)
      end
    end

    def draw_rot(x, y, image, angle, cx = nil, cy = nil, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_rot, z: z, x: x, y: y, image: image,
                         angle: angle, cx: cx, cy: cy }
      else
        _render_draw_rot(x, y, image, angle, cx, cy)
      end
    end

    def draw_alpha(x, y, image, alpha, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_alpha, z: z, x: x, y: y, image: image, alpha: alpha }
      else
        _render_draw_alpha(x, y, image, alpha)
      end
    end

    def draw_ex(x, y, image, options = {})
      z = options[:z] || 0
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_ex, z: z, x: x, y: y, image: image, options: options }
      else
        _render_draw_ex(x, y, image, options)
      end
    end

    def draw_add(x, y, image, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_add, z: z, x: x, y: y, image: image }
      else
        _render_draw_add(x, y, image)
      end
    end

    def draw_sub(x, y, image, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_sub, z: z, x: x, y: y, image: image }
      else
        _render_draw_sub(x, y, image)
      end
    end

    # draw_morph: 2画像間の線形補間（rate: 0.0=image1のみ, 1.0=image2のみ）
    # DXRubyの4コーナー変換とは異なり、Canvas 2D でのアルファブレンドで近似する
    def draw_morph(x, y, image1, image2, rate, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_morph, z: z, x: x, y: y, image1: image1, image2: image2, rate: rate }
      else
        _render_draw_morph(x, y, image1, image2, rate)
      end
    end

    def draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_tile, z: z, x: x, y: y, map: map, chips: chips,
                         offset_x: offset_x, offset_y: offset_y,
                         count_x: count_x, count_y: count_y }
      else
        _render_draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y)
      end
    end

    # -------------------------------------------------------------------------
    # Queue flush — called by Window._tick_with after the user block
    # -------------------------------------------------------------------------

    def _flush_draw_queue
      return unless @draw_queue && !@draw_queue.empty?
      sorted = _stable_sort_by_z(@draw_queue)
      sorted.each { |cmd| _dispatch_render(cmd) }
      @draw_queue = []
    end

    private

    def _has_queue?
      defined?(@draw_queue) && !@draw_queue.nil?
    end

    # 描画先の準備が必要なら行うフック。Window は未接続なら canvas に自動接続する。
    def _ensure_ready
    end

    # Stable insertion sort (ascending z)
    def _stable_sort_by_z(queue)
      sorted = []
      queue.each { |cmd| sorted << cmd }
      n = sorted.length
      i = 1
      while i < n
        key = sorted[i]
        key_z = key[:z] || 0
        j = i - 1
        while j >= 0 && (sorted[j][:z] || 0) > key_z
          sorted[j + 1] = sorted[j]
          j -= 1
        end
        sorted[j + 1] = key
        i += 1
      end
      sorted
    end

    def _dispatch_render(cmd)
      case cmd[:type]
      when :draw
        _render_draw(cmd[:x], cmd[:y], cmd[:image])
      when :draw_box
        _render_draw_box(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2], cmd[:color])
      when :draw_box_fill
        _render_draw_box_fill(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2], cmd[:color])
      when :draw_font
        _render_draw_font(cmd[:x], cmd[:y], cmd[:str], cmd[:font_or_color], cmd[:color_or_size])
      when :draw_font_ex
        _render_draw_font_ex(cmd[:x], cmd[:y], cmd[:str], cmd[:font_or_color], cmd[:options_or_size])
      when :draw_line
        _render_draw_line(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2], cmd[:color])
      when :draw_pixel
        _render_draw_pixel(cmd[:x], cmd[:y], cmd[:color])
      when :draw_circle
        _render_draw_circle(cmd[:x], cmd[:y], cmd[:r], cmd[:color])
      when :draw_circle_fill
        _render_draw_circle_fill(cmd[:x], cmd[:y], cmd[:r], cmd[:color])
      when :draw_scale
        _render_draw_scale(cmd[:x], cmd[:y], cmd[:image], cmd[:scale_x], cmd[:scale_y], cmd[:cx], cmd[:cy])
      when :draw_rot
        _render_draw_rot(cmd[:x], cmd[:y], cmd[:image], cmd[:angle], cmd[:cx], cmd[:cy])
      when :draw_alpha
        _render_draw_alpha(cmd[:x], cmd[:y], cmd[:image], cmd[:alpha])
      when :draw_ex
        _render_draw_ex(cmd[:x], cmd[:y], cmd[:image], cmd[:options])
      when :draw_add
        _render_draw_add(cmd[:x], cmd[:y], cmd[:image])
      when :draw_sub
        _render_draw_sub(cmd[:x], cmd[:y], cmd[:image])
      when :draw_morph
        _render_draw_morph(cmd[:x], cmd[:y], cmd[:image1], cmd[:image2], cmd[:rate])
      when :draw_tile
        _render_draw_tile(cmd[:x], cmd[:y], cmd[:map], cmd[:chips],
                          cmd[:offset_x], cmd[:offset_y], cmd[:count_x], cmd[:count_y])
      end
    end

    # -------------------------------------------------------------------------
    # Immediate rendering primitives (used by _dispatch_render and RenderTarget)
    # -------------------------------------------------------------------------

    def _render_draw(x, y, image)
      @ctx.drawImage(image._canvas, x, y)
    end

    def _render_draw_box(x1, y1, x2, y2, color)
      @ctx[:strokeStyle] = _css(color)
      @ctx.strokeRect(x1, y1, x2 - x1, y2 - y1)
    end

    def _render_draw_box_fill(x1, y1, x2, y2, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
    end

    def _render_draw_font(x, y, str, font_or_color, color_or_size = nil)
      if font_or_color.is_a?(Font)
        font  = font_or_color
        color = color_or_size.is_a?(Hash) ? (color_or_size[:color] || [255, 255, 255]) : (color_or_size || [255, 255, 255])
        @ctx.save
        @ctx[:fillStyle] = _css(color)
        @ctx[:font]         = font._css_font
        @ctx[:textBaseline] = 'top'
        @ctx.fillText(str, x, y)
        @ctx.restore
      else
        color = font_or_color
        size  = color_or_size || 16
        @ctx.save
        @ctx[:fillStyle]    = _css(color)
        @ctx[:font]         = "#{size}px monospace"
        @ctx[:textBaseline] = 'top'
        @ctx.fillText(str, x, y)
        @ctx.restore
      end
    end

    def _render_draw_font_ex(x, y, str, font_or_color, options_or_size = nil)
      if font_or_color.is_a?(Font)
        font         = font_or_color
        options      = options_or_size.is_a?(Hash) ? options_or_size : {}
        color        = options[:color]        || [255, 255, 255]
        edge_color   = options[:edge_color]
        edge_width   = options[:edge_width]   || 2
        shadow       = options[:shadow]       || false
        shadow_color = options[:shadow_color] || [0, 0, 0]
        shadow_x     = options[:shadow_x]     || 1
        shadow_y     = options[:shadow_y]     || 1
        css_font     = font._css_font
      else
        color        = font_or_color
        size         = options_or_size.is_a?(Integer) ? options_or_size : 16
        edge_color   = nil
        edge_width   = 2
        shadow       = false
        shadow_color = [0, 0, 0]
        shadow_x     = 1
        shadow_y     = 1
        css_font     = "#{size}px monospace"
      end

      @ctx.save
      @ctx[:font]         = css_font
      @ctx[:textBaseline] = 'top'

      if shadow
        @ctx[:shadowColor]   = _css(shadow_color)
        @ctx[:shadowOffsetX] = shadow_x
        @ctx[:shadowOffsetY] = shadow_y
      end

      if edge_color
        @ctx[:strokeStyle] = _css(edge_color)
        @ctx[:lineWidth]   = edge_width * 2
        @ctx[:lineJoin]    = 'round'
        @ctx.strokeText(str, x, y)
      end

      @ctx[:fillStyle] = _css(color)
      @ctx.fillText(str, x, y)
      @ctx.restore
    end

    def _render_draw_line(x1, y1, x2, y2, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1, y1)
      @ctx.lineTo(x2, y2)
      @ctx.stroke
    end

    def _render_draw_pixel(x, y, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x, y, 1, 1)
    end

    def _render_draw_circle(x, y, r, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.stroke
    end

    def _render_draw_circle_fill(x, y, r, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.fill
    end

    # DXRuby の座標系: (x, y) は変形前の画像の左上、(cx, cy) は画像内の
    # 拡縮・回転の中心（既定は画像中央）。
    def _render_draw_scale(x, y, image, scale_x, scale_y, cx = nil, cy = nil)
      cx = image.width  / 2 if cx.nil?
      cy = image.height / 2 if cy.nil?
      @ctx.save
      @ctx.translate(x + cx, y + cy)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image._canvas, -cx, -cy)
      @ctx.restore
    end

    def _render_draw_rot(x, y, image, angle, cx = nil, cy = nil)
      cx = image.width  / 2 if cx.nil?
      cy = image.height / 2 if cy.nil?
      rad = angle * Math::PI / 180.0
      @ctx.save
      @ctx.translate(x + cx, y + cy)
      @ctx.rotate(rad)
      @ctx.drawImage(image._canvas, -cx, -cy)
      @ctx.restore
    end

    def _render_draw_alpha(x, y, image, alpha)
      @ctx.save
      @ctx[:globalAlpha] = alpha.to_f / 255
      @ctx.drawImage(image._canvas, x, y)
      @ctx.restore
    end

    def _render_draw_ex(x, y, image, options = {})
      angle   = options[:angle]   || 0
      scale_x = options[:scale_x] || 1.0
      scale_y = options[:scale_y] || 1.0
      alpha   = options[:alpha]
      blend   = options[:blend]
      return if alpha && alpha <= 0
      w = image.width
      h = image.height

      if angle == 0 && scale_x == 1 && scale_y == 1
        return unless _on_screen?(x, y, x + w, y + h)
        # 変形・半透明・合成なしなら save / restore を省いて drawImage 1 回で描く
        if (alpha.nil? || alpha >= 255) && (blend.nil? || blend == :alpha)
          @ctx.drawImage(image._canvas, x, y)
          return
        end
      end

      cx = options[:cx] || w / 2
      cy = options[:cy] || h / 2
      rad = angle * Math::PI / 180.0
      if angle == 0 && scale_x == 1 && scale_y == 1
        bounds = blend == :sub ? [x, y, x + w, y + h] : nil
      else
        bounds = _transformed_bounds(x + cx, y + cy, -cx * scale_x, -cy * scale_y,
                                     (w - cx) * scale_x, (h - cy) * scale_y, rad)
        return unless _on_screen?(bounds[0], bounds[1], bounds[2], bounds[3])
      end

      # 減算は「反転 → 加算 → 反転」で表す（_invert_rect のコメント参照）
      _invert_rect(bounds) if blend == :sub
      @ctx.save
      @ctx[:globalCompositeOperation] = _blend_op(blend) if blend
      @ctx[:globalAlpha] = alpha.to_f / 255 if alpha
      @ctx.translate(x + cx, y + cy)
      @ctx.rotate(rad)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image._canvas, -cx, -cy)
      @ctx.restore
      _invert_rect(bounds) if blend == :sub
    end

    def _render_draw_add(x, y, image)
      @ctx.save
      @ctx[:globalCompositeOperation] = "lighter"
      @ctx.drawImage(image._canvas, x, y)
      @ctx.restore
    end

    def _render_draw_sub(x, y, image)
      bounds = [x, y, x + image.width, y + image.height]
      _invert_rect(bounds)
      @ctx.save
      @ctx[:globalCompositeOperation] = "lighter"
      @ctx.drawImage(image._canvas, x, y)
      @ctx.restore
      _invert_rect(bounds)
    end

    # Canvas 2D には減算合成がないので、描画範囲を反転してから加算し、もう一度反転する。
    #   1 - min(1, (1 - dst) + src) = max(0, dst - src)
    # 反転は白の difference 合成（|1 - dst| = 1 - dst）で行う。範囲は描画先のピクセル境界
    # （平行移動を足した座標）で整数に広げて、端のピクセルが半端に反転されないようにする
    # （ox / oy が小数でもずれない）。範囲内の描画先は不透明になる。
    def _invert_rect(bounds)
      vx = _view_ox
      vy = _view_oy
      x1 = (bounds[0] + vx).floor - vx
      y1 = (bounds[1] + vy).floor - vy
      x2 = (bounds[2] + vx).ceil  - vx
      y2 = (bounds[3] + vy).ceil  - vy
      @ctx.save
      @ctx[:globalCompositeOperation] = "difference"
      @ctx[:fillStyle] = "#fff"
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
      @ctx.restore
    end

    def _render_draw_morph(x, y, image1, image2, rate)
      r = rate.to_f
      w = [image1.width,  image2.width ].max
      h = [image1.height, image2.height].max
      if @_morph_canvas.nil? || @_morph_canvas[:width].to_i != w || @_morph_canvas[:height].to_i != h
        @_morph_canvas = JS.eval("new OffscreenCanvas(#{w}, #{h})")
        @_morph_ctx    = @_morph_canvas.getContext('2d')
      end
      @_morph_ctx.clearRect(0, 0, w, h)
      @_morph_ctx[:globalCompositeOperation] = "source-over"
      @_morph_ctx[:globalAlpha] = 1.0 - r
      @_morph_ctx.drawImage(image1._canvas, 0, 0)
      @_morph_ctx[:globalCompositeOperation] = "lighter"
      @_morph_ctx[:globalAlpha] = r
      @_morph_ctx.drawImage(image2._canvas, 0, 0)
      @_morph_ctx[:globalCompositeOperation] = "source-over"
      @_morph_ctx[:globalAlpha] = 1.0
      @ctx.drawImage(@_morph_canvas, x, y)
    end

    def _render_draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y)
      flat = chips.flatten
      return if flat.empty?
      tw    = flat[0].width
      th    = flat[0].height
      t_ox  = offset_x / tw
      t_oy  = offset_y / th
      px_ox = offset_x % tw
      px_oy = offset_y % th
      (count_y + 1).times do |row|
        map_row = t_oy + row
        next if map_row < 0 || map_row >= map.length
        (count_x + 1).times do |col|
          map_col = t_ox + col
          next if map_col < 0 || map_col >= map[map_row].length
          idx = map[map_row][map_col]
          next if idx.nil?
          chip = flat[idx]
          next if chip.nil?
          @ctx.drawImage(chip._canvas, x + col * tw - px_ox, y + row * th - px_oy)
        end
      end
    end

    # 描画範囲 (x1, y1)-(x2, y2) が描画先に少しでも掛かるか（画面外の描画を省くため）
    def _on_screen?(x1, y1, x2, y2)
      w = @width
      h = @height
      return true if w.nil? || h.nil?
      ox = _view_ox
      oy = _view_oy
      x2 + ox > 0 && x1 + ox < w && y2 + oy > 0 && y1 + oy < h
    end

    # 中心 (px, py) まわりに拡縮済みの矩形 (ax1, ay1)-(ax2, ay2) を rad だけ回転したときの
    # 外接矩形 [x1, y1, x2, y2]
    def _transformed_bounds(px, py, ax1, ay1, ax2, ay2, rad)
      c = Math.cos(rad)
      s = Math.sin(rad)
      x_a = ax1 * c; x_b = ax2 * c; y_a = ay1 * s; y_b = ay2 * s
      min_x = (x_a < x_b ? x_a : x_b) - (y_a > y_b ? y_a : y_b)
      max_x = (x_a > x_b ? x_a : x_b) - (y_a < y_b ? y_a : y_b)
      x_a = ax1 * s; x_b = ax2 * s; y_a = ay1 * c; y_b = ay2 * c
      min_y = (x_a < x_b ? x_a : x_b) + (y_a < y_b ? y_a : y_b)
      max_y = (x_a > x_b ? x_a : x_b) + (y_a > y_b ? y_a : y_b)
      [px + min_x, py + min_y, px + max_x, py + max_y]
    end

    # 描画時に掛かっている平行移動量。Window はループ内で (ox, oy) だけずらして描く
    def _view_ox
      0
    end

    def _view_oy
      0
    end

    def _css(color)
      PicoDX._css_color(color)
    end

    def _blend_op(blend)
      case blend
      when :add then "lighter"
      when :sub then "lighter"  # 前後で描画範囲を反転して減算にする（_invert_rect）
      else "source-over"
      end
    end
  end
end

module PicoDX
  class Font
    class << self
      def default
        @default ||= new(16)
      end

      def default=(font)
        @default = font
      end

      def install(filename, name = nil)
        family = name || filename.to_s.split('/').last.split('.').first
        JS.global[:__picodx_font_name] = family
        JS.global[:__picodx_font_url]  = filename.to_s
        JS.eval(
          "new FontFace(window.__picodx_font_name," \
          " 'url(' + window.__picodx_font_url + ')')" \
          ".load().then(font => { document.fonts.add(font); return font; });"
        ).await
        [family]
      end
    end

    attr_reader :size, :fontname, :italic, :weight

    def initialize(size, name = "", options = {})
      @size     = size
      @fontname = name.to_s
      @italic   = options[:italic] || false
      @weight   = options[:weight].nil? ? 400 : options[:weight]
    end

    alias name fontname

    def get_width(str)
      @measure_ctx ||= JS.eval("new OffscreenCanvas(1, 1)").getContext('2d')
      @measure_ctx[:font] = _css_font
      @measure_ctx.measureText(str)[:width].to_i
    end

    def _css_font
      style  = @italic ? "italic " : ""
      family = @fontname.empty? ? "monospace" : "#{@fontname}, monospace"
      "#{style}#{@weight} #{@size}px #{family}"
    end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed || false
    end

    def info(str)
      @measure_ctx ||= JS.eval("new OffscreenCanvas(1, 1)").getContext('2d')
      @measure_ctx[:font] = _css_font
      m  = @measure_ctx.measureText(str)
      {
        width:       m[:width].to_i,
        height:      (m[:actualBoundingBoxAscent].to_f + m[:actualBoundingBoxDescent].to_f).to_i,
        left_offset: m[:actualBoundingBoxLeft].to_i,
        top_offset:  m[:actualBoundingBoxAscent].to_i
      }
    end
  end
end

module PicoDX
  class Image
    attr_reader :width, :height

    def _ctx
      @ctx
    end

    # 描画元として渡す canvas（_ctx[:canvas] と同じだが JS 呼び出しを省ける）
    def _canvas
      @canvas
    end

    def initialize(width, height, color = [0, 0, 0])
      @width  = width
      @height = height
      @color  = color
      @canvas = JS.eval("new OffscreenCanvas(#{width}, #{height})")
      @ctx    = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(0, 0, width, height)
    end

    @@cache = {}

    def self.load(filename)
      cached = @@cache[filename]
      return cached.dup if cached

      promise = JS.eval("new Promise((res,rej)=>{const i=new Image();i.onload=()=>res(i);i.onerror=()=>rej(new Error('load error'));i.src='#{filename}';})")
      html_img = promise.await
      w = html_img[:naturalWidth].to_i
      h = html_img[:naturalHeight].to_i
      img = Image.new(w, h, [0, 0, 0, 0])
      img._copy_all_from(html_img)
      @@cache[filename] = img
      img.dup
    end

    def self.load_tiles(filename, x_count, y_count)
      load(filename).slice_tiles(x_count, y_count)
    end

    def fill(color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(0, 0, @width, @height)
    end

    def clear
      @ctx.clearRect(0, 0, @width, @height)
    end

    def line(x1, y1, x2, y2, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1 + 0.5, y1 + 0.5)
      @ctx.lineTo(x2 + 0.5, y2 + 0.5)
      @ctx.stroke
    end

    def box(x1, y1, x2, y2, color)
      @ctx[:strokeStyle] = _css(color)
      @ctx.strokeRect(x1 + 0.5, y1 + 0.5, x2 - x1, y2 - y1)
    end

    def box_fill(x1, y1, x2, y2, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
    end

    def circle(x, y, r, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.stroke
    end

    def circle_fill(x, y, r, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.fill
    end

    def triangle(x1, y1, x2, y2, x3, y3, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1 + 0.5, y1 + 0.5)
      @ctx.lineTo(x2 + 0.5, y2 + 0.5)
      @ctx.lineTo(x3 + 0.5, y3 + 0.5)
      @ctx.closePath
      @ctx.stroke
    end

    def triangle_fill(x1, y1, x2, y2, x3, y3, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.moveTo(x1, y1)
      @ctx.lineTo(x2, y2)
      @ctx.lineTo(x3, y3)
      @ctx.closePath
      @ctx.fill
    end

    def draw(x, y, other_image)
      @ctx.drawImage(other_image._canvas, x, y)
    end

    def draw_font(x, y, str, font, color = [255, 255, 255])
      @ctx.save
      @ctx[:fillStyle]    = _css(color)
      @ctx[:font]         = font._css_font
      @ctx[:textBaseline] = 'top'
      @ctx.fillText(str, x, y)
      @ctx.restore
    end

    def draw_font_ex(x, y, str, font, options = {})
      color        = options[:color]        || [255, 255, 255]
      edge_color   = options[:edge_color]
      edge_width   = options[:edge_width]   || 2
      shadow       = options[:shadow]       || false
      shadow_color = options[:shadow_color] || [0, 0, 0]
      shadow_x     = options[:shadow_x]     || 1
      shadow_y     = options[:shadow_y]     || 1

      @ctx.save
      @ctx[:font]         = font._css_font
      @ctx[:textBaseline] = 'top'

      if shadow
        @ctx[:shadowColor]   = _css(shadow_color)
        @ctx[:shadowOffsetX] = shadow_x
        @ctx[:shadowOffsetY] = shadow_y
      end

      if edge_color
        @ctx[:strokeStyle] = _css(edge_color)
        @ctx[:lineWidth]   = edge_width * 2
        @ctx[:lineJoin]    = 'round'
        @ctx.strokeText(str, x, y)
      end

      @ctx[:fillStyle] = _css(color)
      @ctx.fillText(str, x, y)
      @ctx.restore
    end

    def to_a
      data = @ctx.getImageData(0, 0, @width, @height)[:data]
      result = []
      n = @width * @height
      i = 0
      while i < n
        j = i * 4
        result << [data[j+3].to_i, data[j].to_i, data[j+1].to_i, data[j+2].to_i]
        i += 1
      end
      result
    end
    def compare(x, y, other, ox, oy, w, h)
      data1 = @ctx.getImageData(x, y, w, h)[:data]
      data2 = other._ctx.getImageData(ox, oy, w, h)[:data]
      diff = 0
      n = w * h
      i = 0
      while i < n
        j = i * 4
        if data1[j].to_i   != data2[j].to_i   ||
           data1[j+1].to_i != data2[j+1].to_i ||
           data1[j+2].to_i != data2[j+2].to_i ||
           data1[j+3].to_i != data2[j+3].to_i
          diff += 1
        end
        i += 1
      end
      diff
    end

    def change_hls(hue = 0, luminance = 0, saturation = 0)
      hue_shift        = hue.to_f
      luminance_delta  = luminance.to_f / 100.0
      saturation_delta = saturation.to_f / 100.0
      return dup if hue_shift.zero? && luminance_delta.zero? && saturation_delta.zero?

      # 色相も輝度・彩度と同じく HLS 色空間で回す（DXRuby と同じ結果になるよう、
      # CSS の hue-rotate() の近似は使わない）
      new_img = Image.new(@width, @height, [0, 0, 0, 0])
      src_data = @ctx.getImageData(0, 0, @width, @height)[:data]
      dst_img  = new_img._ctx.createImageData(@width, @height)
      dst_data = dst_img[:data]
      n = @width * @height
      i = 0
      while i < n
        j = i * 4
        r = src_data[j].to_f / 255
        g = src_data[j + 1].to_f / 255
        b = src_data[j + 2].to_f / 255
        a = src_data[j + 3].to_i

        h, l, s = _rgb_to_hls(r, g, b)
        h = (h + hue_shift) % 360.0
        l = _clamp01(l + luminance_delta)
        s = _clamp01(s + saturation_delta)
        nr, ng, nb = _hls_to_rgb(h, l, s)

        dst_data[j]     = (nr * 255).round
        dst_data[j + 1] = (ng * 255).round
        dst_data[j + 2] = (nb * 255).round
        dst_data[j + 3] = a
        i += 1
      end
      new_img._ctx.putImageData(dst_img, 0, 0)
      new_img
    end

    def [](x, y)
      data = @ctx.getImageData(x, y, 1, 1)[:data]
      [data[3].to_i, data[0].to_i, data[1].to_i, data[2].to_i]
    end

    def []=(x, y, color)
      @ctx.clearRect(x, y, 1, 1)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x, y, 1, 1)
    end

    def slice(x, y, w, h)
      new_img = Image.new(w, h, [0, 0, 0, 0])
      new_img._copy_from(@canvas, x, y, w, h)
      new_img
    end

    def dup
      new_img = Image.new(@width, @height, [0, 0, 0, 0])
      new_img._copy_all_from(@canvas)
      new_img
    end

    alias clone dup

    # 左上から右へ、行が終わったら次の行へ並べた 1 次元配列を返す（DXRuby 互換）
    def slice_tiles(x_count, y_count)
      tw = @width  / x_count
      th = @height / y_count
      result = []
      y_count.times do |row|
        x_count.times do |col|
          result << slice(col * tw, row * th, tw, th)
        end
      end
      result
    end

    def set_color_key(color)
      r_key, g_key, b_key = color.length == 4 ? [color[1], color[2], color[3]] : [color[0], color[1], color[2]]
      data = @ctx.getImageData(0, 0, @width, @height)
      pixels = data[:data]
      n = @width * @height
      i = 0
      while i < n
        j = i * 4
        if pixels[j].to_i == r_key && pixels[j+1].to_i == g_key && pixels[j+2].to_i == b_key
          pixels[j+3] = 0
        end
        i += 1
      end
      @ctx.putImageData(data, 0, 0)
      self
    end

    def save(filename = nil)
      fname = filename || "image.png"
      blob = @canvas.convertToBlob(JS.eval("({type:'image/png'})")).await
      url  = JS.global.URL.createObjectURL(blob)
      a    = JS.document.createElement("a")
      a[:href]     = url
      a[:download] = fname
      a.click
      JS.global.URL.revokeObjectURL(url)
    end

    def flush; end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed || false
    end

    def _copy_from(src, sx, sy, sw, sh)
      @ctx.clearRect(0, 0, @width, @height)
      @ctx.drawImage(src, sx, sy, sw, sh, 0, 0, sw, sh)
    end

    def _copy_all_from(src)
      @ctx.clearRect(0, 0, @width, @height)
      @ctx.drawImage(src, 0, 0)
    end

    private

    def _css(color)
      PicoDX._css_color(color)
    end

    def _clamp01(value)
      return 0.0 if value < 0.0
      return 1.0 if value > 1.0
      value
    end

    def _rgb_to_hls(r, g, b)
      max = [r, g, b].max
      min = [r, g, b].min
      l = (max + min) / 2.0
      return [0.0, l, 0.0] if max == min

      d = max - min
      s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
      h = case max
          when r then ((g - b) / d) + (g < b ? 6.0 : 0.0)
          when g then ((b - r) / d) + 2.0
          else         ((r - g) / d) + 4.0
          end
      [(h * 60.0) % 360.0, l, s]
    end

    def _hls_to_rgb(h, l, s)
      return [l, l, l] if s == 0.0

      q = l < 0.5 ? l * (1.0 + s) : l + s - (l * s)
      p = 2.0 * l - q
      hk = h / 360.0
      [
        _hue_to_rgb(p, q, hk + (1.0 / 3.0)),
        _hue_to_rgb(p, q, hk),
        _hue_to_rgb(p, q, hk - (1.0 / 3.0))
      ]
    end

    def _hue_to_rgb(p, q, t)
      t += 1.0 if t < 0.0
      t -= 1.0 if t > 1.0
      return p + (q - p) * 6.0 * t if t < (1.0 / 6.0)
      return q if t < 0.5
      return p + (q - p) * ((2.0 / 3.0) - t) * 6.0 if t < (2.0 / 3.0)
      p
    end
  end
end

module PicoDX
  class Input
    @keys_down       = {}
    @keys_prev       = {}
    @keys_pushed     = {}
    @keys_released   = {}
    @key_hold_frames = {}
    @repeat_initial  = 0
    @repeat_interval = 0
    @key_repeat      = {}
    @mouse_x         = 0
    @mouse_y         = 0
    @mouse_down      = {}
    @mouse_prev      = {}
    @mouse_pushed    = {}
    @mouse_released  = {}
    @mouse_wheel_pos = 0
    @pad_buttons_down    = {}
    @pad_buttons_prev    = {}
    @pad_buttons_pushed  = {}
    @pad_buttons_released= {}
    @pad_hold_frames     = {}
    @pad_repeat_initial  = 0
    @pad_repeat_interval = 0
    @connected_pads      = []

    class << self
      attr_reader :mouse_x, :mouse_y, :mouse_wheel_pos

      # ゲームで使うキーでページがスクロールしたり、フォーカスが移ったりしないよう、
      # ブラウザの既定動作を止める（既定は true）。
      def prevent_default
        @prevent_default.nil? ? true : @prevent_default
      end

      def prevent_default=(value)
        @prevent_default = value ? true : false
        JS.global[:__picodx_prevent_default] = @prevent_default
      end

      # document 側のリスナーは最初の 1 回だけ登録し、canvas 側の設定は
      # Window.init で canvas を切り替えるたびに行う
      def setup(canvas = nil)
        _setup_document unless @listening
        _setup_canvas(canvas) if canvas
      end

      def _setup_document
        @listening = true

        JS.document.addEventListener('keydown') do |e|
          @keys_down[e[:code].to_s] = true
          JS.eval("window.__picodx_audio_ctx && window.__picodx_audio_ctx.state === 'suspended' && window.__picodx_audio_ctx.resume()")
        end
        JS.document.addEventListener('keyup') do |e|
          @keys_down.delete(e[:code].to_s)
        end

        # preventDefault はイベント配送中に同期的に呼ぶ必要があるので JS 側で行う。
        # 対象は現在のゲーム canvas（window.__picodx_game_canvas）にフォーカスがあるときだけ
        JS.global[:__picodx_prevent_default] = prevent_default
        JS.eval(
          "document.addEventListener('keydown', (e) => {" \
          " if (!window.__picodx_prevent_default || document.activeElement !== window.__picodx_game_canvas) return;" \
          " if (e.ctrlKey || e.metaKey || e.altKey) return;" \
          " if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Space', 'Tab'," \
          "      'PageUp', 'PageDown', 'Home', 'End', 'Backspace'].includes(e.code)) e.preventDefault();" \
          "});"
        )
      end

      def _setup_canvas(canvas)
        # キー入力の抑止は、いま使っている canvas を対象にする
        JS.global[:__picodx_game_canvas] = canvas

        # canvas ごとに番号を振り、リスナーは 1 回だけ登録する（同じ canvas で init し直しても
        # 重複しない）。負の値は登録済みの canvas を表す
        seq = JS.eval(
          "(c => {" \
          " if (c.__picodx_input_id) return -c.__picodx_input_id;" \
          " window.__picodx_input_seq = (window.__picodx_input_seq || 0) + 1;" \
          " c.__picodx_input_id = window.__picodx_input_seq;" \
          " return c.__picodx_input_id;" \
          "})(window.__picodx_game_canvas)"
        ).to_i
        first_time = seq > 0
        input_id   = seq.abs
        # マウスの入力は、いま使っている canvas のものだけを反映する
        @active_input_id = input_id

        if first_time
          # フォーカスできるようにし、クリックでフォーカスする。右クリックでコンテキストメニューを
          # 出さない（どちらもイベント配送中に同期的に行う必要があるので JS 側で登録する）
          JS.eval(
            "(c => {" \
            " c.tabIndex = 0;" \
            " c.addEventListener('mousedown', () => c.focus({ preventScroll: true }));" \
            " c.addEventListener('contextmenu', (e) => e.preventDefault());" \
            "})(window.__picodx_game_canvas)"
          )

          # Window.init で別の canvas に切り替えた後は、古い canvas のイベントを無視する
          canvas.addEventListener('mousemove') do |e|
            _update_mouse_pos(canvas, e) if input_id == @active_input_id
          end
          canvas.addEventListener('mousedown') do |e|
            if input_id == @active_input_id
              _update_mouse_pos(canvas, e)
              raw = e[:button].to_i
              btn = raw == 2 ? 1 : (raw == 1 ? 2 : 0)
              @mouse_down[btn] = true
              JS.eval("window.__picodx_audio_ctx && window.__picodx_audio_ctx.state === 'suspended' && window.__picodx_audio_ctx.resume()")
            end
          end
          canvas.addEventListener('mouseup') do |e|
            if input_id == @active_input_id
              _update_mouse_pos(canvas, e)
              raw = e[:button].to_i
              btn = raw == 2 ? 1 : (raw == 1 ? 2 : 0)
              @mouse_down.delete(btn)
            end
          end
          canvas.addEventListener('wheel') do |e|
            if input_id == @active_input_id
              _update_mouse_pos(canvas, e)
              @mouse_wheel_pos += e[:deltaY].to_i
            end
          end
        end

        # 読み込み直後からキー入力でページが動かないよう、canvas にフォーカスしておく
        JS.eval("window.__picodx_game_canvas.focus({ preventScroll: true })")
      end

      # CSS で拡大・縮小された canvas でも、canvas の内部解像度での座標を返す
      def _update_mouse_pos(canvas, e)
        rect = canvas.getBoundingClientRect()
        cw   = canvas[:clientWidth].to_f
        ch   = canvas[:clientHeight].to_f
        sx   = cw > 0 ? canvas[:width].to_f  / cw : 1.0
        sy   = ch > 0 ? canvas[:height].to_f / ch : 1.0
        @mouse_x = ((e[:clientX].to_f - rect[:left].to_f - canvas[:clientLeft].to_f) * sx).to_i
        @mouse_y = ((e[:clientY].to_f - rect[:top].to_f  - canvas[:clientTop].to_f)  * sy).to_i
      end

      def set_repeat(initial, interval)
        @repeat_initial  = initial
        @repeat_interval = interval
      end

      def set_key_repeat(key, initial, interval)
        @key_repeat[key] = [initial, interval]
      end

      def _update
        new_pushed   = {}
        new_released = {}
        @keys_down.each_key do |code|
          if @keys_prev.key?(code)
            @key_hold_frames[code] += 1
            frames = @key_hold_frames[code]
            ini, rep = @key_repeat[code] || [@repeat_initial, @repeat_interval]
            if rep > 0 && frames >= ini && (frames - ini) % rep == 0
              new_pushed[code] = true
            end
          else
            new_pushed[code] = true
            @key_hold_frames[code] = 0
          end
        end
        @keys_prev.each_key do |code|
          unless @keys_down.key?(code)
            new_released[code] = true
            @key_hold_frames.delete(code)
          end
        end
        @keys_pushed   = new_pushed
        @keys_released = new_released
        @keys_prev.replace(@keys_down)

        new_mouse_pushed   = {}
        new_mouse_released = {}
        @mouse_down.each_key do |btn|
          new_mouse_pushed[btn] = true unless @mouse_prev.key?(btn)
        end
        @mouse_prev.each_key do |btn|
          new_mouse_released[btn] = true unless @mouse_down.key?(btn)
        end
        @mouse_pushed   = new_mouse_pushed
        @mouse_released = new_mouse_released
        @mouse_prev.replace(@mouse_down)

        if JS.eval("typeof navigator.getGamepads === 'function'")
          gamepads = JS.eval("navigator.getGamepads()")
          max = JS.eval("navigator.getGamepads().length").to_i
          @pad_buttons_prev.replace(@pad_buttons_down)
          @pad_buttons_down    = {}
          @pad_buttons_pushed  = {}
          @pad_buttons_released= {}
          @connected_pads      = []
          pad_idx = 0
          while pad_idx < max
            gp = gamepads[pad_idx]
            if gp.nil? || gp[:connected].to_s == "false"
              @pad_buttons_prev.delete(pad_idx)
              @pad_hold_frames.delete(pad_idx)
            else
              @connected_pads << pad_idx
              btn_count = gp[:buttons][:length].to_i
              @pad_buttons_down[pad_idx]     = {}
              @pad_buttons_pushed[pad_idx]   = {}
              @pad_buttons_released[pad_idx] = {}
              @pad_hold_frames[pad_idx]      ||= {}
              btn_i = 0
              while btn_i < btn_count
                pressed = gp[:buttons][btn_i][:pressed].to_s == "true"
                prev    = @pad_buttons_prev.dig(pad_idx, btn_i)
                @pad_buttons_down[pad_idx][btn_i] = true if pressed
                if pressed && !prev
                  @pad_buttons_pushed[pad_idx][btn_i] = true
                  @pad_hold_frames[pad_idx][btn_i] = 0
                elsif pressed && prev
                  @pad_hold_frames[pad_idx][btn_i] = (@pad_hold_frames[pad_idx][btn_i] || 0) + 1
                  frames = @pad_hold_frames[pad_idx][btn_i]
                  ini = @pad_repeat_initial; rep = @pad_repeat_interval
                  if rep > 0 && frames >= ini && (frames - ini) % rep == 0
                    @pad_buttons_pushed[pad_idx][btn_i] = true
                  end
                elsif !pressed && prev
                  @pad_buttons_released[pad_idx][btn_i] = true
                  @pad_hold_frames[pad_idx].delete(btn_i)
                end
                btn_i += 1
              end
            end
            pad_idx += 1
          end
        end
      end

      def key_down?(key)
        @keys_down.key?(key)
      end

      def key_push?(key)
        @keys_pushed[key] || false
      end

      def key_release?(key)
        @keys_released[key] || false
      end

      def x
        if key_down?(K_LEFT) || key_down?(K_A)
          -1
        elsif key_down?(K_RIGHT) || key_down?(K_D)
          1
        else
          0
        end
      end

      def y
        if key_down?(K_UP) || key_down?(K_W)
          -1
        elsif key_down?(K_DOWN) || key_down?(K_S)
          1
        else
          0
        end
      end

      def mouse_down?(btn)
        @mouse_down.key?(btn)
      end

      def mouse_push?(btn)
        @mouse_pushed[btn] || false
      end

      def mouse_release?(btn)
        @mouse_released[btn] || false
      end

      def set_pad_repeat(initial, interval)
        @pad_repeat_initial  = initial
        @pad_repeat_interval = interval
      end

      def pad_num
        @connected_pads.length
      end

      def pad_down?(button, pad = 0)
        slot = _pad_slot(pad)
        return false unless slot && @pad_buttons_down[slot]
        @pad_buttons_down[slot][button] || false
      end

      def pad_push?(button, pad = 0)
        slot = _pad_slot(pad)
        return false unless slot && @pad_buttons_pushed[slot]
        @pad_buttons_pushed[slot][button] || false
      end

      def pad_release?(button, pad = 0)
        slot = _pad_slot(pad)
        return false unless slot && @pad_buttons_released[slot]
        @pad_buttons_released[slot][button] || false
      end

      def pad_axis(index, pad = 0)
        axes = _pad_axes(pad)
        return 0.0 unless axes
        axes[index] || 0.0
      end

      def pad_lstick(pad = 0)
        axes = _pad_axes(pad)
        return [0.0, 0.0] unless axes
        [axes[0] || 0.0, axes[1] || 0.0]
      end

      def pad_rstick(pad = 0)
        axes = _pad_axes(pad)
        return [0.0, 0.0] unless axes
        [axes[2] || 0.0, axes[3] || 0.0]
      end

      def pad_lx(pad = 0); pad_lstick(pad)[0]; end
      def pad_ly(pad = 0); pad_lstick(pad)[1]; end
      def pad_rx(pad = 0); pad_rstick(pad)[0]; end
      def pad_ry(pad = 0); pad_rstick(pad)[1]; end

      def pad_pov(pad = 0)
        up    = pad_down?(P_UP,    pad)
        down  = pad_down?(P_DOWN,  pad)
        left  = pad_down?(P_LEFT,  pad)
        right = pad_down?(P_RIGHT, pad)
        return  -1 unless up || down || left || right
        return   0 if up    && !right && !left
        return  45 if up    && right
        return  90 if right && !up   && !down
        return 135 if down  && right
        return 180 if down  && !right && !left
        return 225 if down  && left
        return 270 if left  && !up   && !down
        return 315 if up    && left
        -1
      end

      def pad_pov_x(pad = 0)
        right = pad_down?(P_RIGHT, pad)
        left  = pad_down?(P_LEFT,  pad)
        right ? 1 : (left ? -1 : 0)
      end

      def pad_pov_y(pad = 0)
        down = pad_down?(P_DOWN, pad)
        up   = pad_down?(P_UP,   pad)
        down ? 1 : (up ? -1 : 0)
      end

      private

      def _pad_slot(pad)
        @connected_pads[pad]
      end

      def _pad_axes(pad)
        return nil unless JS.eval("typeof navigator.getGamepads === 'function'")
        slot = _pad_slot(pad)
        return nil unless slot
        gamepads = JS.eval("navigator.getGamepads()")
        gp = gamepads[slot]
        return nil if gp.nil? || gp[:connected].to_s == "false"
        axis_count = gp[:axes][:length].to_i
        result = []
        i = 0
        while i < axis_count
          result << gp[:axes][i].to_f
          i += 1
        end
        result
      end
    end
  end
end

module PicoDX
  M_LBUTTON = 0
  M_RBUTTON = 1
  M_MBUTTON = 2

  K_LEFT   = "ArrowLeft"
  K_RIGHT  = "ArrowRight"
  K_UP     = "ArrowUp"
  K_DOWN   = "ArrowDown"
  K_SPACE  = "Space"
  K_ESCAPE = "Escape"
  K_RETURN = "Enter"

  K_A = "KeyA"; K_B = "KeyB"; K_C = "KeyC"; K_D = "KeyD"; K_E = "KeyE"
  K_F = "KeyF"; K_G = "KeyG"; K_H = "KeyH"; K_I = "KeyI"; K_J = "KeyJ"
  K_K = "KeyK"; K_L = "KeyL"; K_M = "KeyM"; K_N = "KeyN"; K_O = "KeyO"
  K_P = "KeyP"; K_Q = "KeyQ"; K_R = "KeyR"; K_S = "KeyS"; K_T = "KeyT"
  K_U = "KeyU"; K_V = "KeyV"; K_W = "KeyW"; K_X = "KeyX"; K_Y = "KeyY"
  K_Z = "KeyZ"

  K_0 = "Digit0"; K_1 = "Digit1"; K_2 = "Digit2"; K_3 = "Digit3"; K_4 = "Digit4"
  K_5 = "Digit5"; K_6 = "Digit6"; K_7 = "Digit7"; K_8 = "Digit8"; K_9 = "Digit9"

  K_LSHIFT   = "ShiftLeft";   K_RSHIFT   = "ShiftRight"
  K_LCONTROL = "ControlLeft"; K_RCONTROL = "ControlRight"
  K_LALT     = "AltLeft";     K_RALT     = "AltRight"

  K_TAB    = "Tab"
  K_BACK   = "Backspace"
  K_DELETE = "Delete"
  K_INSERT = "Insert"
  K_HOME   = "Home"
  K_END    = "End"
  K_PRIOR  = "PageUp"
  K_NEXT   = "PageDown"

  K_NUMPAD0 = "Numpad0"; K_NUMPAD1 = "Numpad1"; K_NUMPAD2 = "Numpad2"
  K_NUMPAD3 = "Numpad3"; K_NUMPAD4 = "Numpad4"; K_NUMPAD5 = "Numpad5"
  K_NUMPAD6 = "Numpad6"; K_NUMPAD7 = "Numpad7"; K_NUMPAD8 = "Numpad8"
  K_NUMPAD9 = "Numpad9"
  K_DECIMAL   = "NumpadDecimal"
  K_ADD       = "NumpadAdd"
  K_SUBTRACT  = "NumpadSubtract"
  K_MULTIPLY  = "NumpadMultiply"
  K_DIVIDE    = "NumpadDivide"
  K_NUMRETURN = "NumpadEnter"

  # 色定数（DXRuby と同じ [A, R, G, B]）
  C_BLACK   = [255, 0,   0,   0  ]
  C_WHITE   = [255, 255, 255, 255]
  C_RED     = [255, 255, 0,   0  ]
  C_GREEN   = [255, 0,   255, 0  ]
  C_BLUE    = [255, 0,   0,   255]
  C_YELLOW  = [255, 255, 255, 0  ]
  C_CYAN    = [255, 0,   255, 255]
  C_MAGENTA = [255, 255, 0,   255]
  C_DEFAULT = [0,   0,   0,   0  ]

  # ゲームパッドボタン定数（Gamepad API のボタンインデックス対応）
  P_BUTTON1  =  0; P_BUTTON2  =  1; P_BUTTON3  =  2; P_BUTTON4  =  3
  P_BUTTON5  =  4; P_BUTTON6  =  5; P_BUTTON7  =  6; P_BUTTON8  =  7
  P_BUTTON9  =  8; P_BUTTON10 =  9; P_BUTTON11 = 10; P_BUTTON12 = 11
  P_BUTTON13 = 12; P_BUTTON14 = 13; P_BUTTON15 = 14; P_BUTTON16 = 15
  P_BUTTON17 = 16; P_BUTTON18 = 17; P_BUTTON19 = 18; P_BUTTON20 = 19

  # 標準的なゲームパッドのボタンエイリアス（Standard Gamepad Layout）
  P_A     =  0  # A / Cross
  P_B     =  1  # B / Circle
  P_X     =  2  # X / Square
  P_Y     =  3  # Y / Triangle
  P_L     =  4  # L1 / LB
  P_R     =  5  # R1 / RB
  P_L2    =  6  # L2 / LT
  P_R2    =  7  # R2 / RT
  P_SELECT = 8  # Select / Back
  P_START  = 9  # Start / Menu
  P_UP    = 12  # D-Pad Up
  P_DOWN  = 13  # D-Pad Down
  P_LEFT  = 14  # D-Pad Left
  P_RIGHT = 15  # D-Pad Right
end

module PicoDX
  class Window
    class << self
      include Drawable

      attr_reader :real_fps

      def fps;     @fps     || 60;        end
      def ox;      @ox      || 0;         end
      def oy;      @oy      || 0;         end
      def bgcolor; @bgcolor || [0, 0, 0]; end

      # init 前に読まれた場合も canvas の実サイズを返せるよう、自動接続する
      def width
        _ensure_ready
        @width
      end

      def height
        _ensure_ready
        @height
      end

      def width=(value)
        @preset_width = value
        @preset_width_canvas_id = @canvas_id if @canvas_id
        if @canvas
          @canvas[:width] = value
          @width = value
          _restore_ctx_state
        end
      end

      def height=(value)
        @preset_height = value
        @preset_height_canvas_id = @canvas_id if @canvas_id
        if @canvas
          @canvas[:height] = value
          @height = value
          _restore_ctx_state
        end
      end

      def init(canvas_id)
        @canvas_id = canvas_id
        @canvas   = JS.document.getElementById(canvas_id)
        @ctx      = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
        apply_width  = @preset_width_canvas_id.nil? || @preset_width_canvas_id == canvas_id
        apply_height = @preset_height_canvas_id.nil? || @preset_height_canvas_id == canvas_id
        @canvas[:width]  = @preset_width  if apply_width && @preset_width
        @canvas[:height] = @preset_height if apply_height && @preset_height
        @preset_width_canvas_id = canvas_id if apply_width && @preset_width
        @preset_height_canvas_id = canvas_id if apply_height && @preset_height
        @width    = @canvas[:width].to_i
        @height   = @canvas[:height].to_i
        # init 前に setter で設定された値は保持する（Window.init を省略して
        # 自動接続したときも、先に書いた bgcolor= / fps= などが効くように）
        @bgcolor ||= [0, 0, 0]
        @fps     ||= 60
        @real_fps = 0.0
        @ox      ||= 0
        @oy      ||= 0
        @looping   = false
        @closed    = false
        @created   = true
        @frameskip = false if @frameskip.nil?
        @draw_queue = nil
        _apply_smoothing
        self.scale = @scale if @scale
        JS.eval("window.__picodx_nextFrame = () => new Promise(resolve => requestAnimationFrame(resolve))")
        Input.setup(@canvas)
      end

      def close
        @closed   = true
        @created  = false
        @looping  = false
      end

      def closed?
        @closed || false
      end

      def created?
        @created || false
      end

      def active?
        JS.eval("document.hasFocus()").to_s == "true"
      end

      def get_screen_shot(filename = nil)
        fname = filename || "screenshot.png"
        url = @canvas.toDataURL("image/png")
        a   = JS.document.createElement("a")
        a[:href]     = url
        a[:download] = fname
        a.click
      end

      def resize(w, h)
        @canvas[:width]  = w
        @canvas[:height] = h
        @width  = w
        @height = h
        _restore_ctx_state
      end

      def scale=(s)
        @scale = s
        return unless @canvas
        @canvas[:style][:width]  = "#{(@width  * s).to_i}px"
        @canvas[:style][:height] = "#{(@height * s).to_i}px"
      end

      def sync
      end

      def update
      end

      def min_filter=(filter)
        @min_filter = filter
        _apply_smoothing
      end

      def mag_filter=(filter)
        @mag_filter = filter
        _apply_smoothing
      end

      def frameskip=(val)
        @frameskip = val
      end

      def caption
        JS.document[:title].to_s
      end

      def caption=(str)
        JS.document[:title] = str
      end

      def bgcolor=(color)
        @bgcolor = color
      end

      def fps=(value)
        @fps = value
      end

      def ox=(value)
        @ox = value
      end

      def oy=(value)
        @oy = value
      end

      def running_time
        return 0 unless @loop_start_time
        (JS.eval("performance.now()").to_f - @loop_start_time).to_i
      end

      def loop(&block)
        _ensure_ready
        if @looping
          # Re-entrant call: run a nested frame loop until the block exits.
          # break/return inside the block raises LocalJumpError via .call,
          # which we rescue to cleanly exit the inner loop.
          # The exit_value carries the value from break/return so callers
          # can use: result = Window.loop { ... ; return chara_type }
          result = nil
          while !@closed
            JS.global.__picodx_nextFrame().await
            begin
              _tick_with(block)
            rescue LocalJumpError => e
              result = e.exit_value
              break
            end
          end
          result
        else
          @looping           = true
          @user_block        = block
          @loop_start_time   = nil
          @last_tick_time    = nil
          @last_process_time = nil
          @accumulated       = 0.0
          @real_fps          = 0.0
          # break / return / 例外のどれで抜けても、次の Window.loop が最上位の
          # ループとして始まるよう状態を戻す。ブロックの break / return は
          # PicoRuby ではそのまま Window.loop を抜けるが、Proc#call 経由で
          # LocalJumpError になる場合もネスト時と同じく値を返して抜ける
          begin
            while !@closed
              JS.global.__picodx_nextFrame().await
              begin
                _tick
              rescue LocalJumpError => e
                return e.exit_value
              end
            end
          ensure
            @looping    = false
            @user_block = nil
          end
        end
      end

      private

      # ctx に現在掛かっている平行移動量（_tick_with が translate した分の累計）。
      # ループ外の即時描画では 0。ブロック内で ox を変えても、ネストしたループで
      # translate が重なっても、実際の描画位置と一致する
      def _view_ox
        @view_ox || 0
      end

      def _view_oy
        @view_oy || 0
      end

      # canvas のサイズを変えると ctx の状態（平行移動・補間設定）がリセットされるので掛け直す。
      # ループのブロック内で変えた場合も、そのフレームの描画と画面外判定が同じ平行移動量になる
      def _restore_ctx_state
        _apply_smoothing
        return unless @ctx
        vox = @view_ox || 0
        voy = @view_oy || 0
        @ctx.translate(vox, voy) if vox != 0 || voy != 0
      end

      def _apply_smoothing
        return unless @ctx
        @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
      end

      # Window.init を省略したとき、最初の描画か Window.loop の時点で
      # #game、なければページ内の最初の <canvas> に自動で接続する。
      def _ensure_ready
        return if @ctx
        id = JS.eval(
          "(() => {" \
          " const c = document.querySelector('canvas#game') || document.querySelector('canvas');" \
          " if (!c) return '';" \
          " if (!c.id) c.id = 'picodx-game';" \
          " return c.id;" \
          "})()"
        ).to_s
        if id.empty?
          raise "PicoDX: no <canvas> found. Add <canvas id=\"game\"> to the page or call Window.init(canvas_id)."
        end
        init(id)
      end

      def _tick
        _tick_with(@user_block)
      end

      def _tick_with(blk)
        now = JS.eval("performance.now()").to_f
        @loop_start_time ||= now

        interval = 1000.0 / @fps
        if @last_tick_time
          delta = now - @last_tick_time
          @accumulated += delta
          if @accumulated < interval * 0.9
            @last_tick_time = now
            return
          end
          @accumulated -= interval
          @accumulated = interval if @accumulated > interval
        end
        @last_tick_time = now

        if @last_process_time
          elapsed = now - @last_process_time
          @real_fps = elapsed > 0 ? 1000.0 / elapsed : 0.0
        end
        @last_process_time = now

        Input._update
        @ctx[:fillStyle] = _css(@bgcolor)
        @ctx.fillRect(0, 0, @width, @height)
        saved_queue = @draw_queue
        saved_view_ox = @view_ox
        saved_view_oy = @view_oy
        @draw_queue = []
        @ctx.save
        @ctx.translate(@ox, @oy) if @ox != 0 || @oy != 0
        @view_ox = (saved_view_ox || 0) + @ox
        @view_oy = (saved_view_oy || 0) + @oy
        begin
          blk.call
        ensure
          _flush_draw_queue
          @draw_queue = saved_queue
          @view_ox = saved_view_ox
          @view_oy = saved_view_oy
          @ctx.restore
          # ブロック内で canvas のサイズを変えると save したスタックごと ctx がリセットされ、
          # restore が効かない。外側のフレームの平行移動量（ループ外なら 0）に明示的に戻す
          @ctx.setTransform(1, 0, 0, 1, saved_view_ox || 0, saved_view_oy || 0)
        end
      end
    end
  end
end

module PicoDX
  class RenderTarget
    include Drawable

    attr_reader :width, :height, :bgcolor, :ox, :oy, :canvas

    def initialize(width, height, bgcolor = [0, 0, 0])
      @width    = width
      @height   = height
      @bgcolor  = bgcolor
      @ox       = 0
      @oy       = 0
      @disposed = false
      @canvas   = JS.eval("new OffscreenCanvas(#{width}, #{height})")
      @ctx      = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      @ctx[:fillStyle] = _css(bgcolor)
      @ctx.fillRect(0, 0, width, height)
    end

    def bgcolor=(color)
      @bgcolor = color
    end

    # (ox, oy) が RenderTarget の左上に来るよう、以降の描画を (-ox, -oy) ずらす
    def ox=(value)
      @ox = value
      _apply_offset
    end

    def oy=(value)
      @oy = value
      _apply_offset
    end

    def min_filter=(filter)
      @min_filter = filter
      @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
    end

    def mag_filter=(filter)
      @mag_filter = filter
      @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
    end

    def discard; end
    def decide;  end

    def update
    end

    def to_image
      img = Image.new(@width, @height, [0, 0, 0, 0])
      img._copy_all_from(@canvas)
      img
    end

    def resize(w, h)
      return if @disposed
      @width  = w
      @height = h
      @canvas = JS.eval("new OffscreenCanvas(#{w}, #{h})")
      @ctx    = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
      # 新しい canvas は透明なので背景色で塗り、ox / oy のずれを掛け直す
      @ctx[:fillStyle] = _css(@bgcolor)
      @ctx.fillRect(0, 0, w, h)
      _apply_offset
    end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed
    end

    private

    def _apply_offset
      @ctx.setTransform(1, 0, 0, 1, -@ox, -@oy)
    end

    # 画面外判定（Drawable#_on_screen?）で使う、描画に掛かっている平行移動量
    def _view_ox
      -@ox
    end

    def _view_oy
      -@oy
    end
  end
end

module PicoDX
  class Sprite
    attr_writer :x, :y, :z, :angle, :scale_x, :scale_y, :center_x, :center_y
    attr_writer :alpha, :blend, :visible, :image, :collision, :target, :offset_sync
    attr_writer :collision_sync

    def x;              @x              || 0;      end
    def y;              @y              || 0;      end
    def z;              @z              || 0;      end
    def angle;          @angle          || 0;      end
    def scale_x;        @scale_x        || 1.0;    end
    def scale_y;        @scale_y        || 1.0;    end
    def center_x;       @center_x;                end
    def center_y;       @center_y;                end
    def alpha;          @alpha          || 255;    end
    def blend;          @blend          || :alpha; end
    def visible;        @visible.nil? ? true : @visible; end
    def image;          @image;                    end
    def collision;      @collision;                end
    def target;         @target;                   end
    def offset_sync;    @offset_sync    || false;  end
    def collision_sync; @collision_sync.nil? ? true : @collision_sync; end

    def initialize(x = 0, y = 0, image = nil)
      @x           = x.to_f
      @y           = y.to_f
      @z           = 0
      @angle       = 0
      @scale_x     = 1.0
      @scale_y     = 1.0
      @center_x    = nil
      @center_y    = nil
      @alpha       = 255
      @blend       = :alpha
      @visible     = true
      @image       = image
      @collision   = nil
      @vanished          = false
      @target            = nil
      @offset_sync       = false
      @collision_enable  = true
      @collision_sync    = nil
    end

    def draw
      return if @vanished || !visible || image.nil?
      cx = _center_x
      cy = _center_y
      dx = offset_sync ? x - cx : x
      dy = offset_sync ? y - cy : y
      t  = target || Window
      t.draw_ex(dx.to_i, dy.to_i, image, {
        z:       z,
        angle:   angle,
        scale_x: scale_x,
        scale_y: scale_y,
        alpha:   alpha,
        cx:      cx,
        cy:      cy,
        blend:   blend
      })
    end

    def update
    end

    def vanish
      @vanished = true
    end

    def vanished?
      @vanished || false
    end

    def collision_enable
      @collision_enable.nil? ? true : @collision_enable
    end

    def collision_enable=(val)
      @collision_enable = val
    end

    def collision_sync
      @collision_sync.nil? ? true : @collision_sync
    end

    def collision_sync=(val)
      @collision_sync = val
    end

    def param_hash
      ecx = _center_x
      ecy = _center_y
      {
        x: x, y: y, z: z,
        angle: angle,
        scale_x: scale_x, scale_y: scale_y,
        cx: ecx, cy: ecy,
        alpha: alpha, blend: blend,
        visible: visible,
        collision: collision,
        collision_enable: collision_enable
      }
    end

    def check(other)
      targets = other.is_a?(Array) ? other : [other]
      _check_against(targets, nil)
    end

    def ===(other)
      return false if other.nil?
      a = _world_shape(self)
      return false if a.nil?
      b = _world_shape(other)
      return false if b.nil?
      _shapes_hit?(a, b)
    end

    class << self
      def update(array)
        array.each { |sp| sp.update if sp && !sp.vanished? }
      end

      def draw(array)
        sorted = _insertion_sort_by_z(array)
        sorted.each do |sp|
          sp.draw if sp && !sp.vanished?
        end
      end

      def check(array_a, array_b)
        results = []
        shapes_b = nil
        array_a.each do |a|
          next if a.nil? || a.vanished?
          # array_b の判定範囲はすべての a で共通なので 1 回だけ求める
          # （PicoRuby には protected がないため、private の計算を __send__ で呼ぶ）
          shapes_b ||= a.__send__(:_world_shapes, array_b)
          hits = a.__send__(:_check_against, array_b, shapes_b)
          results << [a, hits] unless hits.empty?
        end
        results
      end

      def clean(array)
        i = array.length - 1
        while i >= 0
          sp = array[i]
          array.delete_at(i) if sp.nil? || sp.vanished?
          i -= 1
        end
        array
      end

      private

      def _insertion_sort_by_z(array)
        sorted = []
        array.each { |sp| sorted << sp }
        n = sorted.length
        i = 1
        while i < n
          key   = sorted[i]
          key_z = key ? key.z : 0
          j = i - 1
          while j >= 0 && (sorted[j] ? sorted[j].z : 0) > key_z
            sorted[j + 1] = sorted[j]
            j -= 1
          end
          sorted[j + 1] = key
          i += 1
        end
        sorted
      end
    end

    # center_x / center_y が nil のときの実効値（画像中央、画像がなければ 0）
    def _center_x
      center_x || (image ? image.width  / 2 : 0)
    end

    def _center_y
      center_y || (image ? image.height / 2 : 0)
    end

    private

    # collision 未設定なら画像全体を判定範囲にする（画像もなければ nil）
    def _collision(sp)
      c = sp.collision
      return c if c
      img = sp.image
      img ? [0, 0, img.width, img.height] : nil
    end

    def _check_against(targets, shapes)
      result = []
      mine = _world_shape(self)
      return result if mine.nil?
      i = 0
      n = targets.length
      while i < n
        sp = targets[i]
        if sp
          other = shapes ? shapes[i] : _world_shape(sp)
          result << sp if other && _shapes_hit?(mine, other)
        end
        i += 1
      end
      result
    end

    def _world_shapes(sprites)
      sprites.map { |sp| sp ? _world_shape(sp) : nil }
    end

    # 判定範囲をワールド座標で返す。判定しない Sprite は nil。
    #   矩形 [x1, y1, x2, y2] / 円 [cx, cy, r] / 点 [px, py]
    # collision_sync が真なら、中心まわりに拡縮・回転する（矩形は外接矩形で近似）
    def _world_shape(sp)
      return nil if sp.vanished? || !sp.collision_enable
      c = _collision(sp)
      return nil if c.nil?

      cx = sp._center_x
      cy = sp._center_y
      bx = sp.x
      by = sp.y
      if sp.offset_sync
        bx -= cx
        by -= cy
      end

      sx = 1
      sy = 1
      angle = 0
      if sp.collision_sync
        sx = sp.scale_x
        sy = sp.scale_y
        angle = sp.angle
      end

      if angle == 0 && sx == 1 && sy == 1
        if c.length == 4
          return [bx + c[0], by + c[1], bx + c[2], by + c[3]]
        elsif c.length == 3
          return [bx + c[0], by + c[1], c[2]]
        else
          return [bx + c[0], by + c[1]]
        end
      end

      # 中心 (cx, cy) まわりに拡縮してから回転する
      ox = bx + cx
      oy = by + cy
      if angle == 0
        cos_a = 1.0
        sin_a = 0.0
      else
        rad   = angle * Math::PI / 180.0
        cos_a = Math.cos(rad)
        sin_a = Math.sin(rad)
      end

      if c.length == 4
        # 拡縮後の矩形 (u1..u2, v1..v2) を回転した外接矩形
        u1 = (c[0] - cx) * sx; u2 = (c[2] - cx) * sx
        v1 = (c[1] - cy) * sy; v2 = (c[3] - cy) * sy
        xa = u1 * cos_a; xb = u2 * cos_a; ya = v1 * sin_a; yb = v2 * sin_a
        min_x = (xa < xb ? xa : xb) - (ya > yb ? ya : yb)
        max_x = (xa > xb ? xa : xb) - (ya < yb ? ya : yb)
        xa = u1 * sin_a; xb = u2 * sin_a; ya = v1 * cos_a; yb = v2 * cos_a
        min_y = (xa < xb ? xa : xb) + (ya < yb ? ya : yb)
        max_y = (xa > xb ? xa : xb) + (ya > yb ? ya : yb)
        [ox + min_x, oy + min_y, ox + max_x, oy + max_y]
      else
        u = (c[0] - cx) * sx
        v = (c[1] - cy) * sy
        px = ox + u * cos_a - v * sin_a
        py = oy + u * sin_a + v * cos_a
        if c.length == 3
          asx = sx < 0 ? -sx : sx
          asy = sy < 0 ? -sy : sy
          [px, py, c[2] * (asx > asy ? asx : asy)]
        else
          [px, py]
        end
      end
    end

    def _shapes_hit?(a, b)
      al = a.length
      bl = b.length
      if al == 4
        if bl == 4
          a[0] < b[2] && a[2] > b[0] && a[1] < b[3] && a[3] > b[1]
        elsif bl == 3
          _rect_circle?(a[0], a[1], a[2], a[3], b[0], b[1], b[2])
        else
          b[0] >= a[0] && b[0] <= a[2] && b[1] >= a[1] && b[1] <= a[3]
        end
      elsif al == 3
        if bl == 4
          _rect_circle?(b[0], b[1], b[2], b[3], a[0], a[1], a[2])
        elsif bl == 3
          dx = a[0] - b[0]; dy = a[1] - b[1]; sr = a[2] + b[2]
          dx * dx + dy * dy <= sr * sr
        else
          dx = b[0] - a[0]; dy = b[1] - a[1]
          dx * dx + dy * dy <= a[2] * a[2]
        end
      else
        if bl == 4
          a[0] >= b[0] && a[0] <= b[2] && a[1] >= b[1] && a[1] <= b[3]
        elsif bl == 3
          dx = a[0] - b[0]; dy = a[1] - b[1]
          dx * dx + dy * dy <= b[2] * b[2]
        else
          a[0] == b[0] && a[1] == b[1]
        end
      end
    end

    def _rect_circle?(rx1, ry1, rx2, ry2, cx, cy, r)
      dx = cx < rx1 ? rx1 - cx : (cx > rx2 ? cx - rx2 : 0)
      dy = cy < ry1 ? ry1 - cy : (cy > ry2 ? cy - ry2 : 0)
      dx * dx + dy * dy <= r * r
    end
  end
end

module PicoDX
  class Sound
    def self.load_from_memory(data)
      snd = new(nil)
      JS.eval("window.__picodx_audio_ctx = window.__picodx_audio_ctx || new AudioContext()")
      ctx = JS.eval("window.__picodx_audio_ctx")
      snd.instance_variable_set(:@buffer, ctx.decodeAudioData(data).await)
      snd
    end

    def initialize(filename)
      @playing    = false
      @disposed   = false
      @volume     = 1.0
      @pan        = 0.0
      @loop       = false
      @loop_start = 0.0
      @loop_end   = 0.0
      @play_start = 0.0
      @frequency  = nil
      @source     = nil
      @gain_node  = nil
      @pan_node   = nil
      @buffer     = nil
      return if filename.nil?

      JS.eval("window.__picodx_audio_ctx = window.__picodx_audio_ctx || new AudioContext()")
      @buffer = JS.eval(
        "fetch('#{filename}')" \
        ".then(r=>r.arrayBuffer())" \
        ".then(buf=>window.__picodx_audio_ctx.decodeAudioData(buf))"
      ).await
    end

    def play
      return if @disposed || @buffer.nil?
      stop if @playing

      ctx = JS.eval("window.__picodx_audio_ctx")
      JS.eval("window.__picodx_audio_ctx.state === 'suspended' && window.__picodx_audio_ctx.resume()")

      @gain_node = ctx.createGain
      @gain_node[:gain][:value] = @volume

      @pan_node = ctx.createStereoPanner
      @pan_node[:pan][:value] = @pan

      @source = ctx.createBufferSource
      @source[:buffer] = @buffer
      @source[:loop] = @loop
      if @loop
        @source[:loopStart] = @loop_start
        @source[:loopEnd]   = @loop_end if @loop_end > 0
      end
      if @frequency
        orig_rate = @buffer[:sampleRate].to_f
        @source[:playbackRate][:value] = @frequency / orig_rate if orig_rate > 0
      end

      @source.connect(@gain_node)
      @gain_node.connect(@pan_node)
      @pan_node.connect(ctx[:destination])

      @source.start(@play_start)
      @playing = true

      @source.addEventListener('ended') do |_|
        @playing = false
        @source  = nil
      end
    end

    def stop
      return unless @playing
      @source.stop rescue nil
      @source  = nil
      @playing = false
    end

    def start=(position)
      @play_start = position.to_f
    end

    def loop_count=(n)
      @loop = (n == 0 || n < 0)
    end

    def loop_start=(pos)
      @loop_start = pos.to_f
    end

    def loop_end=(pos)
      @loop_end = pos.to_f
    end

    def set_volume(vol)
      @volume = vol.to_f / 255
      @gain_node[:gain][:value] = @volume if @gain_node
    end

    def pan=(val)
      @pan = val.to_f
      @pan_node[:pan][:value] = @pan if @pan_node
    end

    def frequency=(hz)
      @frequency = hz.to_f
      if @source && @buffer
        orig_rate = @buffer[:sampleRate].to_f
        @source[:playbackRate][:value] = @frequency / orig_rate if orig_rate > 0
      end
    end

    def dispose
      stop if @playing
      @disposed = true
    end

    def disposed?
      @disposed
    end
  end
end

module PicoDX
  class Shader
    def initialize(*) = raise NotImplementedError, "Shader is not supported in PicoDX (Canvas 2D backend)"
    class Core
      def initialize(*) = raise NotImplementedError, "Shader::Core is not supported in PicoDX (Canvas 2D backend)"
    end
  end

  class Window
    class << self
      def hWnd             = raise NotImplementedError, "Window.hWnd is not supported (desktop-only API)"
      def get_screen_modes = raise NotImplementedError, "Window.get_screen_modes is not supported (desktop-only API)"
      def get_current_modes = raise NotImplementedError, "Window.get_current_modes is not supported (desktop-only API)"
      def load_icon(*)     = raise NotImplementedError, "Window.load_icon is not supported (desktop-only API)"
      def open_filename(*) = raise NotImplementedError, "Window.open_filename is not supported (desktop-only API)"
      def save_filename(*) = raise NotImplementedError, "Window.save_filename is not supported (desktop-only API)"
      def folder_dialog(*) = raise NotImplementedError, "Window.folder_dialog is not supported (desktop-only API)"
      def draw_shader(*)   = raise NotImplementedError, "Window.draw_shader is not supported (HLSL shader not available in Canvas 2D)"

      def full_screen=(*)
        raise NotImplementedError, "Window.full_screen= is not supported (desktop-only API)"
      end

      def windowed=(*)
        raise NotImplementedError, "Window.windowed= is not supported (desktop-only API)"
      end

      def x=(*)
        raise NotImplementedError, "Window.x= is not supported (no window position in browser)"
      end

      def y=(*)
        raise NotImplementedError, "Window.y= is not supported (no window position in browser)"
      end
    end
  end

  class RenderTarget
    def draw_shader(*) = raise NotImplementedError, "RenderTarget#draw_shader is not supported (HLSL shader not available in Canvas 2D)"
  end

  class Sprite
    def shader=(*)
      raise NotImplementedError, "Sprite#shader= is not supported (HLSL shader not available in Canvas 2D)"
    end
  end
end

include PicoDX
