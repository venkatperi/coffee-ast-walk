_ = require 'lodash'
type = ( node ) -> node?.type or node.constructor.name
isCSNode = ( n ) -> n?.compile?

class NodeVisitor
  constructor : ( @opts ) ->
    @path = @opts.path
    @depth = @path.length
    @isRoot = @depth is 0
    @id = @path[ -1.. ][ 0 ]
    @isAstNode = isCSNode @opts.node
    if @isAstNode
      @type = type @opts.node
      @parent = @opts.parent
    @context = @opts.context
    @isLeaf = !_.isObjectLike @opts.node
    @prev = @opts.prev

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
    opts.maxDepth ?= -1
    opts.context ?= {}
    opts.path.push opts.id if opts.id
    depth = opts.path.length

    checkDepth =
      opts.maxDepth < 0 or
        (opts.maxDepth >= 0 and depth < opts.maxDepth)

    if _.isObjectLike(node) and checkDepth
      prev = undefined
      for own attr, val of node when val
        #if Array.isArray val
        #  p = undefined
        #  prev = for child, i in val
        #    o = _.assign {}, opts,
        #      node : child
        #      prev : p
        #      parent : node
        #      id : "#{attr}[#{i}]"
        #    o.path = _.cloneDeep o.path
        #    p = child
        #    @_walk o
        if attr.indexOf('__') != 0 and attr != 'objects'
          o = _.assign {}, opts,
            node : val
            prev : prev
            parent : node
            id : attr
          o.path = _.cloneDeep o.path
          prev = val
          @_walk o

    new NodeVisitor(opts).visit()

  walk : ( context, visitor ) ->
    [visitor, context] = [ context, visitor ] unless visitor
    throw new Error 'Missing argument: visitor' unless visitor?
    @_walk node : @node, visitor : visitor, context : context

  walkToDepth : ( context, depth, visitor ) ->
    if !depth and !visitor
      visitor = context
    else if !visitor
      [visitor, depth] = [ depth, context ]
    throw new Error 'Missing argument: visitor' unless visitor?
    @_walk
      node : @node,
      visitor : visitor,
      context : context,
      maxDepth : depth

  meta : =>
    return if @node.__type?
    @walk nextId : 0, ( x ) ->
      return unless @isAstNode
      x.__id = @context.nextId++
      x.__type = type x
      x.__parent = @parent
      x

  findAll : ( depth, f ) =>
    [f, depth] = [ depth, f ] unless f?
    items = []
    @walkToDepth items, depth, ( x ) ->
      @context.push x if f.call @, x
    items

  findFirst : ( depth, f ) =>
    [f, depth] = [ depth, f ] unless f?
    item = undefined
    @walkToDepth [], depth, ( x ) ->
      if  !item and f.call @, x
        item = x
        @abort()
    item

  findByType : ( t, depth ) =>
    args = []
    args.push depth if depth?
    args.push ( x ) -> x.__type is t
    @findAll.apply @, args

  findFirstByType : ( t, depth ) =>
    @findFirst depth, ( x ) -> x.__type is t

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

