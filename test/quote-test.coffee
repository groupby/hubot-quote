chai = require 'chai'
sinon = require 'sinon'
path = require("path")
chai.use require 'sinon-chai'
nock = require 'nock'
expect = chai.expect
helper = require 'hubot-mock-adapter-helper'
TextMessage = require("hubot/src/message").TextMessage
process.env.HUBOT_LOG_LEVEL = 'debug'

describe 'quote', ->
  {robot, user, adapter} = {}
  nockScope = null

  beforeEach (done)->

    nock.disableNetConnect()
    nockScope = nock 'http://subfusion.net/cgi-bin/quote.pl'
    nock.enableNetConnect '127.0.0.1'

    helper.setupRobot (ret) ->
      {robot, user, adapter} = ret
      robot.loadFile path.resolve('.', 'src'), 'quote.coffee'

      # load help scripts to test help messages
      hubotScripts = path.resolve 'node_modules', 'hubot-help', 'src'
      robot.loadFile hubotScripts, 'help.coffee'

      done()

  afterEach ->
    do robot.shutdown
    nock.cleanAll()
    process.removeAllListeners 'uncaughtException'


  describe 'help', ->
    it 'has help message', ->
      commands = robot.helpCommands()
      expect(commands).to.eql [
        "hubot help - Displays all of the help commands that Hubot knows about.",
        "hubot help <query> - Displays all help commands that match <query>.",
        "hubot qt - Queries an endpoint for a random star wars quote"
        "hubot quote - Queries an endpoint for a random star wars quote"
      ]

  describe 'robot response with 200', ->
    beforeEach ->
      nockScope = nockScope.get "?quote=starwars&number=1"

    it 'retrieve star wars quotes', ->
      nockScope.reply 200, "<body><br><br><b><hr><br>" +
          "C-3PO:" +
          "  R2 says that the chances of survival are 725 to 1." +
          "  Actually R2 has been known to make mistakes - from time" +
          "  to time... Oh dear..." +
          "<br><br><hr><br>" +
          " </b></body>"

      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          "C-3PO:  R2 says that the chances of survival are 725 to 1.  Actually R2 has been known to make mistakes - from time  to time... Oh dear..."
        ]
      adapter.receive new TextMessage(user, "hubot quote")


  describe 'robot response with 400', ->
    beforeEach ->
      nockScope = nockScope.get "?quote=starwars&number=1"

    it 'retrieve star wars quotes', ->
      nockScope.reply 400, "failed to query server"

      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          "You didn't believe. That is why it failed!"
        ]
      adapter.receive new TextMessage(user, "hubot quote")
