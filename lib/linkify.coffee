module.exports =
  linkifyView: null

  activate: (state) ->
    atom.workspaceView.command "linkify", => @convert()

  replaceURL: (text) ->
    exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/i
    text.replace(exp,'<a href="$1">$1</a>')

  convert: ->
    editor = atom.workspace.activePaneItem
    selectedText = editor.getSelection().getText()
    editor.insertText(@replaceURL(selectedText))
