{CompositeDisposable} = require 'atom'

module.exports = MagicTag =
  subscriptions: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'magic-tag:delete': => @delete()

  deactivate: ->
    @subscriptions.dispose()

  delete: ->
    if editor = atom.workspace.getActiveTextEditor()
      # I can't handle multiple curors
      return false if editor.hasMultipleCursors()
      mycursor = editor.getCursorBufferPosition()
      {buffer} = editor

      rangetobegin = [[0,0], mycursor]
      rangetoend = [mycursor, [Infinity, Infinity]]
      htmlregop = /<([\w \d \s]+)([^<]+)([^<]+) *[^\/?]>/g

      # Find backwards for a html tag
      editor.backwardsScanInBufferRange(htmlregop, rangetobegin, (result) =>
        @optag = result.range.copy()
        @beforetag = editor.getTextInBufferRange(@optag)
        # Now gets tag title
        gettag = /<([\w]+) ?/
        @beforetagtitle = gettag.exec(@beforetag)[1]
        htmlclosereg = new RegExp("<\/#{@beforetagtitle} *>")
        editor.scanInBufferRange(htmlclosereg, rangetoend, (result) =>
          @edtag = result.range.copy()
          @aftertag = editor.getTextInBufferRange(@edtag)
          result.stop()
        )
        # Stops only if we found a corresponding closing tag
        if @edtag?
          result.stop()
      )

      # No tag found : nothing to do
      return false if not @edtag? or not @optag?
      edmark = buffer.markRange(@edtag)
      opmark = buffer.markRange(@optag)
      # and now the end
      console.log "hey"
      buffer.transact =>
        buffer.delete(@edtag)
        if buffer.isRowBlank(@edtag.start.row)
          buffer.deleteRow(@edtag.start.row)
        buffer.delete(@optag)
        if buffer.isRowBlank(@optag.start.row)
          buffer.deleteRow(@optag.start.row)
        curpos = editor.getCursorBufferPosition()
        console.log curpos.column
        if curpos.column == 0
          console.log "Zero !"
          curpos.row = curpos.row - 1
          curpos.column = Infinity
          editor.setCursorBufferPosition(curpos)
      console.log "hey2"

      # editor.setCursorBufferPosition(mycursor)
      @optag = @edtag = null
