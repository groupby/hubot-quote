# Description:
#   Messing around with the YouTube API.
#
# Commands:
#   hubot quote - Searches YouTube for the query and returns the video embed link.

cheerio = require('cheerio')

module.exports = (robot) ->
  robot.respond /quote|qt/i, (msg) ->
    robot.http("http://subfusion.net/cgi-bin/quote.pl?quote=starwars&number=1")
    .get() (err, res, body) ->
      quote = body

      unless quote?
        msg.send "No video results for \"#{query}\""
        return


      $ = cheerio.load(quote, {
#        normalizeWhitespace: true
      })
      msg.send $('body > b').text().trim()
