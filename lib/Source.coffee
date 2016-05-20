_ = require 'lodash'
{clamp} = require './helpers'

module.exports = class Source
  @property 'size', get : -> @lines.length

  constructor : ( @opts = {} ) ->
    @opts.indent ?= '  '
    @lines = []
    @indentLevel = 0

  load : ( src ) =>
    @lines = src.replace('\\n', '\n').split '\n'

  add : ( lines... ) =>
    throw new Error 'Read only' if @opts.readonly
    @lines.push _.flatten lines
    @

  line : ( line ) =>
    str = []
    # coffeelint: disable=check_scope
    str.push @opts.indent for i in [ 0..@indentLevel - 1 ]
    # coffeelint: enable=check_scope
    str.push line
    @add str.join ''

  @indentIn : => @indentLevel++

  @indentOut : => if @indentLevel > 0 then @indentLevel--

  blank : => @add ''

  comment : => @line '###'

  get : ( from, to ) =>
    from = clamp from, 0, @size - 1
    to = clamp to, from, @size - 1
    _.clone @lines[ from..to ]

  fromLocation : ( location ) =>
    @read location.start_line, location.end_line
    
