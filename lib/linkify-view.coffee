{View} = require 'atom'

module.exports =
class LinkifyView extends View
  @content: ->
    @div class: 'linkify overlay from-top', =>
      @div "The Linkify package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "linkify:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "LinkifyView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
