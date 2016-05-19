fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
stringify = require 'json-stringify-safe'

file = ( f ) -> fs.readFileSync path.join(__dirname,
  '../fixtures', "#{f}.coffee"), 'utf8'
log = ( s ) -> console.log stringify s, null, 2
nodes = ( src ) -> coffee.nodes src

module.exports =
  file : file
  log : log
  nodes : nodes