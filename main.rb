require 'discordrb'
require 'nokogiri'

token = File.read('token')

bot = Discordrb::Commands::CommandBot.new token: token, prefix: '.'


BASE_URL = "http://kpop.wikia.com/api/v1/"
SEARCH = "Search/List/?query="
ARTICLE = "Articles/Details?ids="

bot.command :wikia do |event, *args|
  query = args.join(' ')
  search_uri = URI "#{BASE_URL}#{SEARCH}#{query}&limit=1"
  result = JSON.parse(Net::HTTP.get(search_uri))["items"].first
  article_uri = URI "#{BASE_URL}#{ARTICLE}#{result["id"]}"
  article = JSON.parse(Net::HTTP.get(article_uri))["items"][result["id"].to_s]

  embed = Discordrb::Webhooks::Embed.new(
      title: article["title"],
      url: result["url"],
      description: Nokogiri::HTML(result["snippet"]).text,
      thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: article["thumbnail"]),
      footer: Discordrb::Webhooks::EmbedFooter.new(text: "Match quality: #{result["quality"]}"))
  event.channel.send_embed(nil, embed)
end

bot.run