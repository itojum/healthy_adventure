require_relative 'compat'

# $server_false を立てると goal() はランキングを表示しない
def ranking
  $server_false = true
end

require './main.rb'
