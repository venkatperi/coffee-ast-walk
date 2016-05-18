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

    it 'add meta info', ( done ) ->
      walk.meta()
      should(walk.node.__id).exist
      done()

    it 'cleanup', ( done ) ->
      walk.cleanup()
      should(walk.node.expressions).not.exist
      done()

    it 'has only one AST node', ( done ) ->
      val = walk.reduce 0, ( x, acc ) ->
        if @isAstNode then acc + 1 else acc
      val.should.equal 1
      done()

  describe 'a simple class', ->
    beforeEach ->
      source = file 'TestClass'
      walk = astwalk nodes source

    it 'add meta info', ( done ) ->
      walk.meta()
      should(walk.node.__id).exist
      done()

    it 'make the ast more readable / cleanup', ( done ) ->
      walk.cleanup()
      should(walk.node.__id).exist
      done()

    it 'Find by type', ( done ) ->
      val = walk.findByType 'Assign'
      val.length.should.equal 5
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

    it 'prev node', ( done ) ->
      walk.walk ( x ) ->
        return unless @isAstNode
        console.log x.__type, @prev?.__type
      done()

    it 'path', ( done ) ->
      walk.findAll ( x ) ->
        console.log @path
        true
      done()


