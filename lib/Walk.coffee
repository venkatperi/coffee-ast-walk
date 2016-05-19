_ = require 'lodash'

type = ( node ) -> node?.type or node.constructor.name
isCSNode = ( n ) -> n?.compile?

class Meta
  constructor : ( {@node, @path, @type, @parent, @prev} ) ->
    @locationData = @node.locationData
    @depth = @path.length
    @isRoot = @depth is 0
    @id = @path[ -1.. ][ 0 ]
    @isAstNode = isCSNode @node
    @isLeaf = !_.isObjectLike @node

  Object.defineProperty @prototype, 'name',
    get : ->
      unless @_name?
        switch @type
          when 'Param'
            if @node.name.meta.type is 'Obj'
              @_name = @node.name.meta.objectKeys
            else
              @_name = @node.name?.meta.value
          when 'Assign'
            @_name = @node.variable?.meta.value
          when 'Class'
            @_name = @node.variable?.meta.value
          else
            @_name = undefined # no default name
      @_name

  Object.defineProperty @prototype, 'value',
    get : ->
      unless @_value
        switch @type
          when 'Comment'
            @_value = @node.comment
          when 'Param'
            @_value = @node.value?.meta.value
          when 'Assign'
            @_value = @node.value?.meta.value
            if @_value.meta?.type is 'Code'
              @isMethod = true
          when 'Literal'
            @_value = @node.value
          when 'Access'
            @_value = ".#{@node.name.meta.value}"
          when 'Value'
            @_value = @node.base?.meta.value
            x = @node.properties?[ 0 ]?.meta.value
            @_value += x if x
          else
            @_value = @node # default value is the node
      @_value

  Object.defineProperty @prototype, 'objectKeys',
    get : ->
      unless @_objectKeys
        switch @type
          when 'Obj'
            @_objectKeys = for p in @node.properties
              p.meta.value
      @_objectKeys

  Object.defineProperty @prototype, 'logicalItem',
    get : ->
      unless @_logicalItem
        switch @type
          when 'Assign'
            @_logicalItem = @node.value
          else
            @_logicalItem = @node
      @_logicalItem

  Object.defineProperty @prototype, 'superClass',
    get : ->
      unless @_superClass
        switch @type
          when 'Class'
            @_superClass = @node.parent?.meta.value
      @_superClass

  Object.defineProperty @prototype, 'classMembers',
    get : ->
      unless @_classMembers
        body = astwalk(@node).findFirst 1, ( x ) ->
          x.__type is 'Block' and x.classBody
        @_classMembers = members = static : [], instance : []
        for e in body.expressions
          if e.meta.type is 'Value' and e.meta.value?.meta.type is 'Obj'
            for m in e.meta.value.properties
              if m.meta.name?.indexOf('this.') is 0
                members.static.push m
              else
                members.instance.push m
          else
            members.static.push e

        for t in [ 'static', 'instance' ]
          # need this below, donno why
          [ m.meta.name, m.meta.value ] for m in members[ t ]
          for m in members[ t ] when m.meta.name
            names = m.meta.name.split '.'
            lastName = names[ names.length - 1 ]
            vis = if lastName[ 0 ] is '_' then 'private' else 'public'
            m.meta.visibility = vis

      @_classMembers

  Object.defineProperty @prototype, 'methodParams',
    get : ->
      unless @_methodParams
        @_methodParams = @node.params
      @_methodParams

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
      @prev = @opts.prev
    @context = @opts.context
    @isLeaf = !_.isObjectLike @opts.node

  visit : => @opts.visitor.call @, @opts.node

  abort : => @opts.abort = true

class Walk

  Object.defineProperty @prototype, 'topLevel',
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
    opts.path.push opts.id if opts.id
    depth = opts.path.length

    checkDepth =
      opts.maxDepth < 0 or
        (opts.maxDepth >= 0 and depth < opts.maxDepth)

    if _.isObjectLike(node) and checkDepth
      prev = undefined
      for own attr, val of node when val
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
      _data.topLevel.push x if @depth is 2
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
    while (parent = parent.meta.parent)
      return parent if f parent

  findParentByType : ( t ) =>
    @findParent ( x ) -> x.__type is t

  up : ( fn ) =>
    parent = @node
    while (parent = parent.meta().parent)
      fn parent

module.exports = astwalk = ( node, init ) ->
  new Walk node, init

