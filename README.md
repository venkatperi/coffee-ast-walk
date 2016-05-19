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

# AST Node Meta Information

`astwalk` adds a property `meta` to `Base` which is the base class for Coffeescript AST node classes. `meta` provides meta-information about the node and in many cases, it rolls up information from child nodes which can ease navigation and maipulation of the AST. See API for more details on the `meta` object.

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

## Meta Object

`node.meta` is a custom property is added to Coffeescript AST nodes. The following properties are available on all meta objects:

* `@node` The original AST node.
* `@path` The `path` to the current node as an array of strings.
* `@depth` The depth of the current node.
* `@isRoot` True if the node is the root node.
* `@isLeaf` True of the node is a leaf node.
* `@id` A unique id assigned to each id. Not the same as the `id` available during a walk. Same as `node.__id`.
* `@isAstNode` True if the node is a coffeescript AST node, or a scalar (string etc).
* `@parent` The node's parent (undefined for root node).


In addition, the following context-sensitive (i.e. node type) properties are available on `node.meta`:

* `name`

  * for `Class`, the class name.
  * for `Assign`, the `lhs` of the assignment operator.
  * for `Param`, the parameter name
* `value`

  * for `Comment`, the comment string
  * for  `Param`, the param's value
  * for `Assign`, the `rhs` of the assignment
  * for `Literal`, the value of the literal
  * for `Access`, the qualified name (e.g. `module.exports`)
  * for `Value`, the value
* `logicalItem` - for `Assign` nodes, returns the `rhs` of the assignment since it the logical basis for interpreting the `Assign` node sub-tree.
* `superClass` the name of the class' super class, if any
* `classMembers`, for classes, returns an object with `static` and `instance` members. Members which are methods also include parameter information.
* `methodParams` returns an array or parameters for methods.

