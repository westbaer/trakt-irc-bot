require 'rubygems'
require 'net/http'
require 'cinch'
require 'json'
require 'cgi'

API_KEY = ""

bot = Cinch::Bot.new do
	configure do |c|
		c.server = "irc.yourserver.net"
		c.port = 6667
		c.nick = "traktbot"
		c.channels = [ "#yourchannel" ]
	end

	helpers do
		def trakt_get(query)
			url = "http://api.trakt.tv/user/watching.json/#{ API_KEY }/#{ CGI.escape(query) }"
			resp = Net::HTTP.get_response(URI.parse(url))
			data = resp.body
			chat_msg = ""

			result = JSON.parse(data)

			if not result.kind_of?(Array)
				if result.has_key? 'type'
					if result['type'] == "episode"
						chat_msg = "#{ query } is watching '#{ result['episode']['title'] }' (#{ result['episode']['season'] }x#{ result['episode']['number'] }) of '#{ result['show']['title'] }'."
					else
						chat_msg = "#{ query } is watching '#{ result['movie']['title'] }'."
					end
				end
			else
				chat_msg = "#{ query } is not watching anything."
			end

			chat_msg
		end		
	end

	on :message, /^!trakt (.+)/ do |m, term|
		m.channel.send trakt_get(term)
	end
end

bot.start

