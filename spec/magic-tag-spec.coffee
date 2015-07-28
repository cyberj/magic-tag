MagicTag = require '../lib/magic-tag'
{Point} = require 'atom'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MagicTag", ->
  [workspaceElement, editorElement, editor, buffer, activationPromise] = []

  # See https://discuss.atom.io/t/how-do-i-activate-a-package-in-specs/18766
  executeCommand = (callback) ->
    atom.commands.dispatch(workspaceElement, 'magic-tag:delete')
    waitsForPromise -> activationPromise
    runs(callback)

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

    activationPromise = atom.packages.activatePackage('magic-tag')

    waitsForPromise ->
      atom.workspace.open('test.html')

    runs ->
        editor = atom.workspace.getActiveTextEditor()
        editorElement = atom.views.getView(editor)
        {buffer} = editor

  describe "When tag is in same line", ->

    it "delete all HTML tag", ->
      editor.setCursorBufferPosition([5, 11])
      expect(editor.lineTextForBufferRow(5)).toEqual('    <title></title>')
      # This is an activation event, triggering it will cause the package to be
      # activated.
      executeCommand ->
        expect(editor.lineTextForBufferRow(5)).toEqual('  </head>')
        expect(editor.getCursorBufferPosition()).toEqual([4, 26])
        executeCommand ->
          expect(editor.lineTextForBufferRow(3)).toEqual('    <meta charset="utf-8">')
          expect(editor.lineTextForBufferRow(2)).toEqual('')
          expect(editor.lineTextForBufferRow(5)).toEqual('  <body>')

    it "Fails if multiple cursors", ->
      expect(editor.lineTextForBufferRow(5)).toEqual('    <title></title>')
      editor.setCursorBufferPosition([5,11])
      editor.addCursorAtBufferPosition([2,2])
      expect(editor.hasMultipleCursors()).toBe(true)
      executeCommand ->
        expect(editor.lineTextForBufferRow(5)).toEqual('    <title></title>')

    it "delete small HTML tags", ->
      editor.setCursorBufferPosition([10,13])
      expect(editor.lineTextForBufferRow(10)).toEqual('      <li><a></a></li>')
      executeCommand ->
        expect(editor.lineTextForBufferRow(10)).toEqual('      <li></li>')
        executeCommand ->
          expect(editor.lineTextForBufferRow(9)).toEqual('    <ul>')
          expect(editor.lineTextForBufferRow(10)).toEqual('    </ul>')

  # describe "Snif", ->
    it "delete composite HTML tags", ->
      expect(editor.lineTextForBufferRow(14)).toEqual('<div class="toto" id="tata">')
      expect(editor.lineTextForBufferRow(15)).toEqual('  <a href="//#">Hello</a>')
      editor.setCursorBufferPosition([15,16])
      executeCommand ->
        expect(editor.lineTextForBufferRow(15)).toEqual('  Hello')
        executeCommand ->
          expect(editor.lineTextForBufferRow(14)).toEqual('  Hello')
