# Description:
#   Messing around with the Star Wars Quotes
#
# Commands:
#   hubot quote - Queries an endpoint for a random star wars quote
#   hubot qt - Queries an endpoint for a random star wars quote
#
# Author:
#   ferronrsmith

cheerio = require('cheerio')

module.exports = (robot) ->
  robot.respond /quote|qt/i, (msg) ->
    robot.http("http://subfusion.net/cgi-bin/quote.pl?quote=starwars&number=1")
    .get() (err, res, body) ->
      quote = body

      if res? and res.statusCode is 200
        # parse quote from html
        # use { normalizeWhitespace: true } to remove line breaks and excess whitespace
        $ = cheerio.load(quote)
        msg.send $('body > b').text().trim()
      else
        msg.send "You didn't believe. That is why it failed!"
