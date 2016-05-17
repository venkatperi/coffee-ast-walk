_ = require 'lodash'
type = ( node ) -> node?.type or node.constructor.name
isCSNode = ( n ) -> n?.compile?

class NodeVisitor
  constructor : ( @opts ) ->
    @path = @opts.path
    @depth = @path.length is 0
    @isRoot = @depth is 0
    @id = @path[ -1.. ][ 0 ]
    @isAstNode = isCSNode @opts.node
    if @isAstNode
      @type = type @opts.node
      @parent = @opts.parent
    @context = @opts.context
    @isLeaf = !_.isObjectLike @opts.node

  visit : =>
    @opts.visitor.call @, @opts.node

  abort : =>
    @opts.abort = true

class Walk
  constructor : ( @node ) ->
    @meta()

  _walk : ( opts ) =>
    return unless opts?.node or opts?.abort
    node = opts.node
    opts.path ?= []
    opts.context ?= {}
    opts.path.push opts.id if opts.id

    if _.isObjectLike node
      for own attr, ret of node when ret
        if Array.isArray ret
          for child, i in ret
            o = _.assign {}, opts,
              node : child,
              parent : node
              id : "#{attr}[#{i}]"
            @_walk o
        else if attr.indexOf('__') isnt 0
          o = _.assign {}, opts,
            node : ret,
            parent : node
            id : attr
          @_walk o

    new NodeVisitor(opts).visit()

  walk : ( context, visitor ) ->
    [visitor, context] = [ context, visitor ] unless visitor
    throw new Error 'Missing argument: visitor' unless visitor?
    @_walk node : @node, visitor : visitor, context : context

  meta : =>
    return if @node.__type?
    @walk nextId : 0, ( x ) ->
      return unless @isAstNode
      x.__id = @context.nextId++
      x.__type = type x
      x.__parent = @parent
      x

  findByType : ( t ) =>
    @walk [], ( x ) ->
      @context.push x if type(x) is t
      @context

  findFirstByType : ( t ) =>
    item = undefined
    @walk ( x ) ->
      if type(x) is t and !item
        item = x
        @abort()
    item

  reduce : ( acc, f ) =>
    [f, acc] = [ acc, f ] unless f?
    @walk ( x ) -> acc = f.call @, x, acc
    acc

  findParent : ( f ) =>
    parent = @node
    while (parent = parent.__parent)
      return parent if f parent

  findParentByType : ( t ) =>
    @findParent ( x ) -> x.__type is t

  up : ( fn ) =>
    parent = @node
    while (parent = parent.__parent)
      fn parent

  cleanup : =>
    return if @positionData?
    @positionData = {}
    @walk @positionData, ( x ) ->
      return unless @isAstNode
      if x.locationData?
        @context[ @id ] ?= {}
        @context[ @id ].location = x.locationData
        delete x.locationData
      for own k,v of x
        delete x[ k ] if Array.isArray(v) and v.length is 0

module.exports = ( node ) ->
  new Walk node

