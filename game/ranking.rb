require 'net/http'
require 'uri'
require 'json'

def ranking()
  uri = URI.parse("https://7cc9c897-97dc-4bc5-9dc4-1dbef383bee9-00-3n6n427qxadic.spock.replit.dev/post")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data({ "score" => $score })

  response = http.request(request)
  if response.body.length > 100
    puts "サーバーとの通信に失敗しました"
    $server_false = true
    return
  end
  puts response
  $ranking_players = eval(response.body.split("\n")[0])
  $player_name = response.body.split("\n")[1]
end