_ = require 'lodash'
should = require 'should'
coffee = require 'coffee-script'
astwalk = require '../index'
fs = require 'fs'
path = require 'path'
stringify = require 'json-stringify-safe'

file = ( f ) -> fs.readFileSync path.join(__dirname,
  'fixtures', "#{f}.coffee"), 'utf8'
log = ( s ) -> console.log stringify s, null, 2
nodes = ( src ) -> coffee.nodes src

source = undefined
walk = undefined

describe 'astwalk', ->

  describe 'empty source file', ->
    beforeEach ->
      source = ''
      walk = astwalk nodes source

    it 'walk', ( done ) ->
      root = walk.walk ( x ) -> x
      walk.node.expressions.length.should.equal 0
      # we're returning the original node
      walk.node.should.equal root
      done()

    it 'has only one AST node', ( done ) ->
      val = walk.reduce 0, ( x, acc ) ->
        if @isAstNode then acc + 1 else acc
      val.should.equal 1
      done()

  describe 'a simple class', ->
    before ->
      source = file 'TestClass'
      ast = nodes source
      walk = astwalk ast, true
    #log ast

    it 'Find by type', ( done ) ->
      val = walk.findByType 'Assign'
      val.length.should.equal 8
      done()

    it 'find first class node', ( done ) ->
      val = walk.findFirstByType 'Class'
      val.__type.should.equal 'Class'
      done()

    it 'find root of class node', ( done ) ->
      klass = walk.findFirstByType 'Class'
      root = astwalk(klass).findParent ( x ) -> x.__type is 'Assign'
      root.__type.should.equal 'Assign'
      done()

    it 'node name', ( done ) ->
      klass = walk.findFirstByType 'Class'
      klass.meta.name.should.equal 'Example.Animal'
      assign = astwalk(klass).findParent ( x ) -> x.__type is 'Assign'
      assign.meta.name.should.equal 'module.exports'
      done()

    it 'class body', ( done ) ->
      info = ( x ) ->
        type : x.meta.type
        name : x.meta.name
        value : x.meta.value
        visibility : x.meta.visibility

      for klass, i in walk.findByType 'Class'
        console.log klass.meta.name, klass.meta.superClass
        members = klass.meta.classMembers
        if i is 0
          members.static.length.should.equal 3
          members.instance.length.should.equal 5

        for m in members.instance when m.meta.isMethod
          params = m.meta.value.meta.methodParams
          log _.map params, info

      done()

    it 'top level items', ( done ) ->
      top = walk.topLevel
      top.length.should.equal 4
      #log _.map top, ( x ) ->
      #  [ x.meta.type, x.meta.logicalItem.meta?.type ]
      done()



