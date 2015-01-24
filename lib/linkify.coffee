module.exports =
  linkifyView: null
  count: 0
  grammar: null

  linkExp: /(\b((https?|ftp|file):\/\/|(www\.))[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gi

  activate: ->
    @commands = atom.commands.add 'atom-workspace', 'linkify:make-link', => @convert()

  deactivate: ->
    @commands.dispose()

  replaceHtml: (text) ->
      text.replace(this.linkExp,'<a href="$1">$1</a>')

  replaceGithubMd: (text) ->
      text.replace(this.linkExp,'[$1]($1)')

  convert: ->
    editor = atom.workspace.getActivePaneItem()
    this.grammar = editor.getGrammar()
    selectedText = editor.getLastSelection().getText()

    if selectedText.match(this.linkExp) is null
      this.count = 0
    else
      this.count = selectedText.match(this.linkExp).length
      switch this.grammar.name
        when "HTML", "Plain Text, Null Grammar"
          editor.insertText @replaceHtml selectedText
          @selectLinksTextHtml selectedText.length

        when "GitHub Markdown"
          editor.insertText @replaceGithubMd selectedText
          @selectLinksTextGithubMd selectedText.length

  selectLinksTextHtml: (selectedTextLength)->
    if this.count < 2
      anchorClosingTagLength = "</a>".length
      cursor = atom.workspace.getActivePaneItem().cursors[0]
      cursor.moveLeft anchorClosingTagLength
      cursor.selection.selectLeft selectedTextLength

  selectLinksTextGithubMd: (selectedTextLength)->
    if this.count < 2
      anchorClosingTagLength = ")".length
      cursor = atom.workspace.getActivePaneItem().cursors[0]
      cursor.moveLeft anchorClosingTagLength
      cursor.selection.selectLeft selectedTextLength
