# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
fs   = require "fs"
path = require "path"
tmp  = require "temp"

describe "Linkify", ->
  workspaceView = null
  editor = null
  buffer = null

  linkifyCommands =
    MAKE_LINK_COMMAND: "linkify:make-link"


  isCommandLoaded = (commandName) ->
    workspaceCommands = atom.commands.findCommands target: workspaceView
    for command in workspaceCommands
      return true if command.name is commandName
    false


  beforeEach ->
    # Setup test file
    test_dir = tmp.mkdirSync()
    atom.project.setPaths test_dir

    filePath = path.join test_dir, "text-test.txt"
    fs.writeFileSync filePath, ""

    workspaceView = atom.views.getView atom.workspace

    waitsForPromise -> atom.workspace.open(filePath).then (e) -> editor = e

    runs -> buffer = editor.getBuffer()

    waitsForPromise -> atom.packages.activatePackage("linkify")


  describe "when linkify is activated", ->
      it "creates #{linkifyCommands.MAKE_LINK_COMMAND} command", ->
        expect(isCommandLoaded(linkifyCommands.MAKE_LINK_COMMAND)).toBeTruthy()


  describe "when linkify is deactivated", ->
      beforeEach -> atom.packages.deactivatePackage("linkify")

      it "destroys #{linkifyCommands.MAKE_LINK_COMMAND} command", ->
        expect(isCommandLoaded(linkifyCommands.MAKE_LINK_COMMAND)).toBeFalsy()


  describe "when linkify is toggled", ->
    beforeEach ->
      buffer.setText "http://github.com/ibito"

    it "does nothing if no text is selected", ->
      atom.commands.dispatch workspaceView, linkifyCommands.MAKE_LINK_COMMAND
      expect(editor.getText()).toBe("http://github.com/ibito")

    it "does nothing if the selected text does not match a url pattern", ->
      buffer.setText "ibito.com"
      editor.selectAll()
      atom.commands.dispatch workspaceView, linkifyCommands.MAKE_LINK_COMMAND
      expect(editor.getText()).toBe("ibito.com")

    describe "when selected text matches a url pattern", ->
      describe "when the editor grammar is markdown", ->
        beforeEach ->
          waitsForPromise ->
            atom.packages.activatePackage('language-gfm')

        it "transforms the text into a markdown url tag", ->
          editor.setGrammar atom.grammars.selectGrammar ".md"

          editor.selectAll()
          atom.commands.dispatch workspaceView, linkifyCommands.MAKE_LINK_COMMAND

          expect(editor.getText())
                .toBe("[http://github.com/ibito](http://github.com/ibito)")
          expect(editor.getLastSelection().getText())
                .toBe("http://github.com/ibito")

      describe "when the editor grammar is anything else", ->
        it "transforms the text into an <a>", ->
          editor.selectAll()
          atom.commands.dispatch workspaceView, linkifyCommands.MAKE_LINK_COMMAND

          expect(editor.getText())
                .toBe("<a href=\"http://github.com/ibito\">http://github.com/ibito</a>")
          expect(editor.getLastSelection().getText())
                .toBe("http://github.com/ibito")

    describe "when there are several url patterns in the selected text", ->
      beforeEach ->
        buffer.setText "http://github.com/ibito
                        http://github.com/ibito
                        http://github.com/ibito"

      it "transforms all matches into an <a>", ->
        editor.selectAll()
        atom.commands.dispatch workspaceView, linkifyCommands.MAKE_LINK_COMMAND

        expect(editor.getText())
              .toBe("<a href=\"http://github.com/ibito\">http://github.com/ibito</a>
                     <a href=\"http://github.com/ibito\">http://github.com/ibito</a>
                     <a href=\"http://github.com/ibito\">http://github.com/ibito</a>")

      it "transforms all matches even if there is unmatched text in the selection", ->
        buffer.setText "http://github.com/ibito visit us on github!
                        http://github.com/ibito visit us on github!
                        http://github.com/ibito visit us on github!"

        editor.selectAll()
        atom.commands.dispatch workspaceView, linkifyCommands.MAKE_LINK_COMMAND

        expect(editor.getText())
              .toBe("<a href=\"http://github.com/ibito\">http://github.com/ibito</a> visit us on github!
                     <a href=\"http://github.com/ibito\">http://github.com/ibito</a> visit us on github!
                     <a href=\"http://github.com/ibito\">http://github.com/ibito</a> visit us on github!")
