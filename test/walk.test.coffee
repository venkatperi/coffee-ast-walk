should = require 'should'
coffee = require 'coffee-script'
astwalk = require '../index'
fs = require 'fs'
path = require 'path'

file = ( f ) -> fs.readFileSync path.join(__dirname,
  'fixtures', "#{f}.coffee"), "utf8"
log = ( s ) -> console.log JSON.stringify s, null, 2
nodes = ( src ) -> coffee.nodes src
cleanup = ( src ) -> astwalk(nodes src).cleanup()
findByType = ( src, type ) -> astwalk(nodes src).findByType type
reduce = ( src, init, fn ) -> astwalk(nodes src).reduce init, fn
walk = ( src, fn ) -> astwalk(nodes src).walk fn

describe 'astwalk', ->

  it 'should walk empty source', ( done ) ->
    root = walk '', ->
    root.expressions.length.should.equal 0
    done()

  it 'one AST node for empty source', ( done ) ->
    val = reduce '', 0, ( x, acc ) ->
      if @isAstNode then acc + 1 else acc
    val.should.equal 1
    done()

  it 'should walk simple source', ( done ) ->
    walk 'a=0', ->
    done()

  it 'make the ast more readable / cleanup', ( done ) ->
    val = cleanup file 'TestClass'
    log val[0]
    done()

  it 'Find by type', ( done ) ->
    val = findByType file('TestClass'), 'Assign'
    log val.length
    done()

