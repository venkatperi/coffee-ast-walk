_ = require 'lodash'
{isCSNode} = require './helpers'

module.exports = class Meta
  constructor : ( {@node, @path, @type, @parent, @prev} ) ->
    @locationData = @node.locationData
    @depth = @path.length
    @isRoot = @depth is 0
    @id = @path[ -1.. ][ 0 ]
    @isAstNode = isCSNode @node
    @isLeaf = !_.isObjectLike @node

  @property 'name',
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

  @property 'value',
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

  @property 'objectKeys',
    get : ->
      unless @_objectKeys
        switch @type
          when 'Obj'
            @_objectKeys = for p in @node.properties
              p.meta.value
      @_objectKeys

  @property 'logicalItem',
    get : ->
      unless @_logicalItem
        switch @type
          when 'Assign'
            @_logicalItem = @node.value
          else
            @_logicalItem = @node
      @_logicalItem

  @property 'superClass',
    get : ->
      unless @_superClass
        switch @type
          when 'Class'
            @_superClass = @node.parent?.meta.value
      @_superClass

  @property 'classMembers',
    get : ->
      unless @_classMembers
        body = require('./Walk')(@node).findFirst 1, ( x ) ->
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

  @property 'methodParams',
    get : ->
      unless @_methodParams
        @_methodParams = @node.params
      @_methodParams
