_ = require 'lodash'
astwalk = require '../index'
stringify = require 'json-stringify-safe'
{file, log, nodes} = require './ext/ext'

replacer = ( k, v ) -> return v unless k in [ '__parent', 'node' ]

log = ( x ) ->console.log stringify x, replacer, 2

class Base
  constructor : ( @node ) ->
    @id = @node.__id
    @type = @node.meta.type
    @init()

  init : ->

class Class extends Base
  init : =>
    @name = @node.meta.name
    @superClass = @node.meta.superClass
    @members = []
    members = @node.meta.classMembers
    for own type,list of members
      for m in list
        isMethod = m.meta.isMethod
        info =
          name : m.meta.name
          membership : type
          visibility : m.meta.visibility
          memberType : if isMethod then 'method' else 'variable'

        if isMethod and m.meta.value.meta.methodParams?.length > 0
          info.params = for p in m.meta.value.meta.methodParams
            p.meta.name

        @members.push info
    delete @members if @members.length is 0

class Comment extends Base
  init : =>
    @comment = @node.comment

class Value extends Base
  init : =>
    @value = @node.meta.value

class Block extends Base
  init : =>
    super()
    @children = []
    for e in @node.expressions ? []
      x = process e
      @children.push x if x

handlers =
  Block : Block
  Class : Class
  Comment : Comment
  Value : Value

process = ( node ) ->
  item = node.meta.logicalItem
  handler = handlers[ item.meta.type ]
  new handler(item) if handler?

processFile = ( node ) ->
  walk = astwalk(node, true)
  throw new Error 'Root item must be Block' unless node.__type is 'Block'
  items = process node
  log items


