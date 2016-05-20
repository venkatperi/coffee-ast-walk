# coffeelint: disable=check_scope
should = require 'should'
# coffeelint: enable=check_scope
Location = require '../lib/Location'

describe 'location', ->

  it 'should init with CS locationData', ->
    l = new Location first_line : 10, last_line : 20
    should(l).exist
    l.from.should.equal 10
    l.to.should.equal 20

  it 'should do a union op', ->
    l1 = new Location first_line : 10, last_line : 20
    l2 = new Location first_line : 25, last_line : 45
    u = Location.union l1, l2
    should(u).exist
    u.from.should.equal l1.from
    u.to.should.equal l2.to

  it 'should sort based on start line', ->
    l1 = new Location first_line : 10, last_line : 20
    l2 = new Location first_line : 25, last_line : 45
    sorted = Location.sort l2, l1
    sorted[ 0 ].should.equal l1
    sorted[ 1 ].should.equal l2


