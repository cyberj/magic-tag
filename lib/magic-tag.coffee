{CompositeDisposable} = require 'atom'

module.exports = MagicTag =
  subscriptions: null

  activate: ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'magic-tag:delete': => @delete()

  deactivate: ->
    @subscriptions.dispose()


  getTags: (cursor) ->
    # Find backwards for a html tag
    editor = atom.workspace.getActiveTextEditor()
    rangetobegin = [[0,0], cursor]
    rangetoend = [cursor, [Infinity, Infinity]]
    htmlregop = /<(?:[\w\d\s]+)(?:[^>]|\/(?!>))*>/g
    optag = edtag = null

    editor.backwardsScanInBufferRange htmlregop, rangetobegin, (result) =>
      optag = result.range.copy()
      beforetag = editor.getTextInBufferRange(optag)
      # Now gets tag title
      gettag = /<([\w]+) ?/
      beforetagtitle = gettag.exec(beforetag)[1]
      htmlclosereg = new RegExp("<\/#{beforetagtitle} *>")
      editor.scanInBufferRange htmlclosereg, rangetoend, (result2) =>
        edtag = result2.range.copy()
        aftertag = editor.getTextInBufferRange(edtag)
        result2.stop()
      # Stops only if we found a corresponding closing tag
      if edtag?
        result.stop()
    # console.log optag
    # console.log edtag
    optag: optag
    edtag: edtag

  delete: ->
    if editor = atom.workspace.getActiveTextEditor()
      # I can't handle multiple curors
      return false if editor.hasMultipleCursors()
      mycursor = editor.getCursorBufferPosition()
      {buffer} = editor
      {optag, edtag} = @getTags mycursor

      # No tag found : nothing to do
      return false if not edtag? or not optag?
      # edmark = buffer.markRange(edtag)
      # opmark = buffer.markRange(optag)
      # and now the end

      # Add undo transaction
      buffer.transact =>
        buffer.delete(edtag)
        if buffer.isRowBlank(edtag.start.row)
          buffer.deleteRow(edtag.start.row)
        buffer.delete(optag)
        if buffer.isRowBlank(optag.start.row)
          buffer.deleteRow(optag.start.row)
        curpos = editor.getCursorBufferPosition()
        if curpos.column == 0
          curpos.row = curpos.row - 1
          curpos.column = Infinity
          editor.setCursorBufferPosition(curpos)
