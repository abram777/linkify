module.exports =
  linkifyView: null

  activate: ->
    @commands = atom.commands.add 'atom-workspace', 'linkify:make-link', => @convert()

  deactivate: ->
    @commands.dispose()

  replaceURL: (text) ->
    exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/i
    text.replace(exp,'<a href="$1">$1</a>')

  convert: ->
    editor = atom.workspace.getActivePaneItem()
    selectedText = editor.getLastSelection().getText()
    editor.insertText @replaceURL selectedText
    @selectLinksText selectedText.length

  selectLinksText: (selectedTextLength)->
    anchorClosingTagLength = "</a>".length
    cursor = atom.workspace.getActivePaneItem().cursors[0]
    cursor.moveLeft anchorClosingTagLength
    cursor.selection.selectLeft selectedTextLength
