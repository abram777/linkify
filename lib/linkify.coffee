module.exports =
  linkifyView: null

  activate: (state) ->
    atom.commands.add 'atom-text-editor', 'linkify:make-link', => @convert()

  replaceURL: (text) ->
    exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/i
    text.replace(exp,'<a href="$1">$1</a>')

  convert: ->
    editor = atom.workspace.activePaneItem
    selectedText = editor.getSelection().getText()
    editor.insertText(@replaceURL(selectedText))
    @selectLinksText(selectedText.length)

  selectLinksText: (selectedTextLength)->
    anchorClosingTagLength = "</a>".length
    cursor = atom.workspace.activePaneItem.cursors[0]
    cursor.moveLeft(anchorClosingTagLength) 
    cursor.selection.selectLeft(selectedTextLength)
