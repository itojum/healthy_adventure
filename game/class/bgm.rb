

class Bgm
    # 音量（0〜255）。BGM はほんのり聞こえる程度にする
    VOLUME = 40

    def initialize (files)
        @bgms=[]
        files.each do |path|
            sound = Sound.new(path)
            sound.set_volume(VOLUME)
            @bgms << sound
        end
        @now_bgm=nil
        @playing = false
    end

    def set_bgm(page)
        @now_bgm = @bgms[page]
    end

    def play
       # p "BGM2"
        @playing = true
        @now_bgm.play
    end

    def playing?
        return @playing
    end
end