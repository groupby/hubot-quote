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

      unless res.statusCode is 200
        msg.send "You didn't believe. That is why it failed!"
        return

      # parse quote from html
      $ = cheerio.load(quote, {
#        normalizeWhitespace: true
      })
      msg.send $('body > b').text().trim()
