

class Bgm
    def initialize (files)
        @bgms=[]
        files.each do |path|
            @bgms << Sound.new(path)
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