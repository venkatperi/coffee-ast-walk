_ = require 'lodash'
{type, isCSNode} = require './helpers'

module.exports = class NodeVisitor
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
