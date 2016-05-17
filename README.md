# coffee-ast-walk
Walk Coffeescript's AST nodes

[![Build Status](https://travis-ci.org/venkatperi/coffee-ast-walk.svg?branch=master)](https://travis-ci.org/venkatperi/coffee-ast-walk)

# Installation

Install with npm

```shell
npm install coffee-ast-walk --save
```

# Examples

Create a ast walker

```coffeescript
astwalk = require 'coffee-ast-walk'
root = coffee.nodes source
walk = astwalk(root)
```

## Dump Every Node

```coffeescript
walk.walk (x) -> 
  console.log x  
```

## AST Node Count

```coffeescript
walk.reduce 0, (x, acc) -> 
	if @isAstNode then acc + 1 else acc
```

## Find the First Class

```coffeescript
walk.findFirstByType 'Class'
```

## Get Parent of Type

```coffeescript
klass = walk.findFirstByType 'Class'

# fire up another walker
astwalk(klass).findParent ( x ) -> x.__type is 'Assign'
```

# API

## Create Walker
### astwalk(node)

Returns a walker. `astwalk` performs an initial walk over the AST tree and appends meta information to each AST node:

* `__id` A unique id (monotonically increasing count).
* `__type` The type of AST node (`node.constructor.name`)
* `__parent` The node's parent (undefined for the root node).

## Methods

### walk([context, ] visitor)

Walk's the AST tree and invokes the visitor for each node. Context is an optional `{Object}` which is available to the visitor callback.
#### About the Visitor: visitor(node)
The current node is passed ot the visitor. Additionaly, the following properties are available in the `this` context of the visitor callback:
* `@path` The `path` to the current node as an array of strings.
* `@depth` The depth of the current node.
* `@isRoot` True if the node is the root node.
* `@isLeaf` True of the node is a leaf node.
* `@id` The `id` used to invoke the current node, also the last element of the path array.
* `@isAstNode` True if the node is a coffeescript AST node, or a scalar (string etc).
* `@context` An optional context, passed to walk.
* `@parent` The node's parent (undefined for root node).

The visitor callback can invoke `@abort()` to terminate the walk early.

### findByType(type)

Returns a list of nodes with the given `{String}` type.

### findFirstByType(type)

Returns the first node with the given `{String}` type.

### reduce([initial,] f)

Updates an internal **accumulator** to the value returned by `f(node, acc)` and returns the final value of acc. The accumulator is optionally set to **initial**.

### findParent(pred)

Returns the closes ancestor that satisfies the supplied predicate **pred**.

### findParentByType(type)

Returns the closest ancestor with the given type.

### up(f)

Walks up the ancestor list and invokes the given callback **f** .

### cleanup()

Reduces clutter in the  AST.

* Remove empty arrays
* Move locationData to `walk.meta` which can be accessed with the node's `__id` property.