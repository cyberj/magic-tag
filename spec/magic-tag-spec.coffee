MagicTag = require '../lib/magic-tag'
{Point} = require 'atom'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MagicTag", ->
  [workspaceElement, editorElement, editor, buffer] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

    atom.packages.activatePackage('magic-tag')

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
      atom.commands.dispatch(workspaceElement, 'magic-tag:delete')
      expect(editor.lineTextForBufferRow(5)).toEqual('  </head>')
      expect(editor.getCursorBufferPosition()).toEqual([4, 26])
      atom.commands.dispatch(workspaceElement, 'magic-tag:delete')
      expect(editor.lineTextForBufferRow(3)).toEqual('    <meta charset="utf-8">')
      expect(editor.lineTextForBufferRow(2)).toEqual('')
      expect(editor.lineTextForBufferRow(5)).toEqual('  <body>')

    it "Fails if multiple cursors", ->
      expect(editor.lineTextForBufferRow(5)).toEqual('    <title></title>')
      console.log editor
      editor.setCursorBufferPosition([5,11])
      editor.addCursorAtBufferPosition([2,2])
      expect(editor.hasMultipleCursors()).toBe(true)
      atom.commands.dispatch(workspaceElement, 'magic-tag:delete')
      expect(editor.lineTextForBufferRow(5)).toEqual('    <title></title>')
