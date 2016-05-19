_ = require 'lodash'
Meta = require './Meta'
NodeVisitor = require './NodeVisitor'
{type, isCSNode} = require './helpers'

class Walk

  @property 'topLevel',
    get : -> @data.topLevel

  constructor : ( @node, init ) ->
    @data =
      topLevel : []
      byId : {}
    @_addProperty() if init
    @_processMeta()

  _addProperty : =>
    _data = @data
    proto = @node.constructor
    proto = proto.__super__ while (proto.__super__)
    Object.defineProperty proto, 'meta',
      get : -> _data.byId[ @__id ]

  _walk : ( opts ) =>
    return unless opts?.node or opts?.abort
    node = opts.node
    opts.path ?= []
    opts.maxDepth ?= -1
    opts.context ?= {}
    opts.ignore ?= ( x ) -> x.indexOf('__') is 0 or
      x in [ 'objects', 'locationData' ]
    opts.path.push opts.id if opts.id
    depth = opts.path.length

    checkDepth =
      opts.maxDepth < 0 or
        (opts.maxDepth >= 0 and depth < opts.maxDepth)

    res = new NodeVisitor(opts).visit()

    cloneOpts = ( n, child, id, p ) ->
      x = _.assign {}, opts,
        { node : child, prev : p, parent : n, id : id }
      x.path = _.cloneDeep opts.path
      [ x, child ]

    if _.isObjectLike(node) and checkDepth
      prev = undefined
      for own attr, val of node when !opts.ignore(attr)
        if Array.isArray val
          ret = for c,i in val
            [o, prev] = cloneOpts node, c, "attr[#{i}]", prev
            @_walk o
        else
          [o, prev] = cloneOpts node, val, attr, prev
          ret = @_walk o
        res[ attr ] = ret if _.isObjectLike(res) and !_.isEmpty(ret)
    res

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

  _processMeta : =>
    return if @node.__type?
    _data = @data
    @walk nextId : 0, ( x ) ->
      return unless @isAstNode
      id = x.__id = @context.nextId++
      t = x.__type = type x
      _data.byId[ id ] = new Meta
        node : x
        type : t
        parent : @parent
        path : @path
        prev : @prev
        locationData : x.locationData

      # note the top level items
      _data.topLevel.push x if @depth is 1
      return undefined

  findAll : ( depth, f ) =>
    [f, depth] = [ depth, f ] unless f?
    items = []
    @walkToDepth items, depth, ( x ) ->
      @context.push x if f.call @, x
      undefined
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
    while (parent = parent.meta.parent)
      return parent if f parent

  findParentByType : ( t ) =>
    @findParent ( x ) -> x.__type is t

  up : ( fn ) =>
    parent = @node
    while (parent = parent.meta().parent)
      fn parent

module.exports = ( node, init ) ->
  new Walk node, init

