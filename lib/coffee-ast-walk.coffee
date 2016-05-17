_ = require 'lodash'
type = ( node ) -> node?.type or node.constructor.name
isCSNode = ( n ) -> n?.compile?

class NodeVisitor
  constructor : ( @node, @walk, @parent ) ->
    @path = @walk.path
    @depth = @path.length is 0
    @isRoot = @depth is 0
    @id = @path[ -1.. ][ 0 ]
    @isAstNode = isCSNode @node
    @context = @walk.context
    @isLeaf = !_.isObjectLike @node

  abort : => @walk.abort = true

  visit : => @walk.visitor.call @, @node

class Walk
  constructor : ( @visitor, @context ) ->
    @path = []
    @abort = false

  walk : ( node, id, parent ) =>
    return unless node
    @_pushPath id if id?
    @visit node, parent

    if _.isObjectLike node
      for own attr, val of node when val
        if Array.isArray val
          for child, i in val
            @walk child, "#{attr}[#{i}]", node
        else
          @walk val, attr, node unless attr.indexOf('__') is 0

    @_popPath()
    node

  visit : ( node, parent ) =>
    return if @abort
    new NodeVisitor node, @, parent
    .visit()

  _pushPath : ( id ) => @path.push id

  _popPath : => @path = @path[ 0..-2 ]

_walk = ( node, context, visitor ) ->
  [visitor, context] = [ context, visitor ] unless visitor
  throw new Error 'Missing argument: ast node' unless node?
  throw new Error 'Missing argument: visitor' unless visitor?
  new Walk(visitor, context).walk node

astwalk = ( node ) ->
  walk : ( context, visitor ) ->
    _walk node, context, visitor

  findByType : ( t ) ->
    items = []
    _walk node, ( x ) -> items.push x if type(x) is t
    items

  findFirstByType : ( t ) ->
    item = undefined
    _walk node, ( x ) ->
      if type(x) is t and !item
        item = x
        @abort()
    item

  reduce : ( acc, cb ) ->
    [cb, acc] = [acc, cb] unless cb?
    _walk node, ( x ) -> acc = cb.call @, x, acc
    acc

  cleanup : ->
    meta = {}
    nextId = 0
    _walk node, ( x ) ->
      return unless @isAstNode
      id = x.__id = nextId++
      x.__type = type x
      if x.locationData?
        meta[ id ] ?= {}
        meta[ id ].location = x.locationData
        delete x.locationData
      for own k,v of x
        delete x[ k ] if Array.isArray(v) and v.length is 0
    [ node, meta ]

module.exports = astwalk

