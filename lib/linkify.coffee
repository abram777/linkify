module.exports =
  linkExp: /(\b((https?|ftp|file):\/\/|(www\.))[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gi

  activate: ->
    @commands = atom.commands.add 'atom-workspace', 'linkify:make-link', => @convert()

  deactivate: ->
    @commands.dispose()

  replaceHtml: (text) ->
    text.replace @linkExp, '<a href="$1">$1</a>'

  replaceGithubMd: (text) ->
    text.replace @linkExp, '[$1]($1)'

  convert: ->
    editor = atom.workspace.getActivePaneItem()
    grammar = editor.getGrammar()
    selectedText = editor.getLastSelection().getText().trim()
    selectedTextLength = selectedText.length
    matches = selectedText.match @linkExp
    numberOfMatches = matches?.length or 0

    if matches?
      switch grammar.name
        when "GitHub Markdown"
          editor.insertText @replaceGithubMd selectedText
          if numberOfMatches < 2
            @selectLinksText selectedTextLength, ("]()".length + selectedTextLength)
        else
          editor.insertText @replaceHtml selectedText
          if numberOfMatches < 2
            @selectLinksText selectedTextLength, "</a>".length


  selectLinksText: (selectedTextLength, anchorClosingTagLength) ->
    cursor = atom.workspace.getActivePaneItem().cursors[0]
    cursor.moveLeft anchorClosingTagLength
    cursor.selection.selectLeft selectedTextLength
