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
### astwalk(node[, init])

Returns a walker. `astwalk` . Setting **init** will perform an initial walk over the AST tree and append a meta object as well as two properties to each AST node:

* `__id` A unique id (monotonically increasing count).
* `__type` The type of AST node (`node.constructor.name`)

## Methods

### walk([context, ] visitor)

### walkToDepth([context, ] \[depth, ] visitor)

Walk's the AST tree and invokes the **visitor** for each node. **Context** is an optional `{Object}` which is available to the visitor callback. Providing **depth** will limit the walk up to `depth` nodes from the current node (i.e. relative to the current node).

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

**Return Value:** If a visitor returns an `{Object}`, the values from visiting the current AST node's child nodes are added to the object with the same key names as the original node. This can be viewed as a mapping operation on the AST tree (see example at the end). 

### findAll([depth, ] f(node))

Returns all nodes (unto to optional **depth**) that satisfy the callback **f**.

### findFirst([depth, ] f(node)

Returns the first node (limited by **depth**) that matches the callback **f**.

### findByType(type[, depth])

Returns a list of nodes with the given `{String}` type, up to optional **depth**.

### findFirstByType(type[, depth])

Returns the first node with the given `{String}` type, up to optional **depth**.

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


# Example - AST Tree View

Map the AST tree to a human readable JSON object and use the `treeify` module to display it as a tree.

```coffeescript
walk = astwalk(ast, true)
res = walk.walk ( x ) ->
  o = {}
  for t in [ 'type', 'name', 'value' ]
    v = x.meta?[ t ]
    o[ t ] = v if v and !_.isObjectLike v      
  o

  console.log treeify.asTree res, true
```

Let's apply it to this coffeescript:

```coffeescript
###
# Base class for all animals.
#
# @example How to subclass an animal
#   class Lion extends Animal
#     move: (direction, speed): ->
#
###
module.exports = class Example.Animal

  ###
  # The Answer to the Ultimate Question of Life, the Universe, and Everything
  ###
  @ANSWER = 42

  @create: ->

  ###
  # @property [Array<String>] the nicknames
  ###
  nicknames : []

  ###
  Construct a new animal.

  @param [String] name the name of the animal
  @param [Date] birthDate when the animal was born
  ###
  constructor : ( @type, @name, @birthDate = new Date() ) ->

    ###
     Move the animal.

     @example Move an animal
       new Lion('Simba').move('south', 12)

     @param [Object] options the moving options
     @option options [String] direction the moving direction
     @option options [Number] speed the speed in mph
     @public
    ###
  move : ( options = {} ) ->

class Tiger extends Example.Animal
  constructor : ( {@striped}, abc )->
    super 'Tiger'

module.exports = Tiger
```

And the tree view:

```shell
├─ type: Block
└─ expressions
   ├─ 0
   │  ├─ type: Comment
   │  └─ value: 
# Base class for all animals.
#
# @example How to subclass an animal
#   class Lion extends Animal
#     move: (direction, speed): ->
#

   ├─ 1
   │  ├─ type: Assign
   │  ├─ name: module.exports
   │  ├─ variable
   │  │  ├─ type: Value
   │  │  ├─ value: module.exports
   │  │  ├─ base
   │  │  │  ├─ type: Literal
   │  │  │  └─ value: module
   │  │  └─ properties
   │  │     └─ 0
   │  │        ├─ type: Access
   │  │        ├─ value: .exports
   │  │        └─ name
   │  │           ├─ type: Literal
   │  │           └─ value: exports
   │  └─ value
   │     ├─ type: Class
   │     ├─ name: Example.Animal
   │     ├─ variable
   │     │  ├─ type: Value
   │     │  ├─ value: Example.Animal
   │     │  ├─ base
   │     │  │  ├─ type: Literal
   │     │  │  └─ value: Example
   │     │  └─ properties
   │     │     └─ 0
   │     │        ├─ type: Access
   │     │        ├─ value: .Animal
   │     │        └─ name
   │     │           ├─ type: Literal
   │     │           └─ value: Animal
   │     └─ body
   │        ├─ type: Block
   │        └─ expressions
   │           ├─ 0
   │           │  ├─ type: Comment
   │           │  └─ value: 
# The Answer to the Ultimate Question of Life, the Universe, and Everything

   │           ├─ 1
   │           │  ├─ type: Assign
   │           │  ├─ name: this.ANSWER
   │           │  ├─ value
   │           │  │  ├─ type: Value
   │           │  │  ├─ value: 42
   │           │  │  └─ base
   │           │  │     ├─ type: Literal
   │           │  │     └─ value: 42
   │           │  └─ variable
   │           │     ├─ type: Value
   │           │     ├─ value: this.ANSWER
   │           │     ├─ base
   │           │     │  ├─ type: Literal
   │           │     │  └─ value: this
   │           │     └─ properties
   │           │        └─ 0
   │           │           ├─ type: Access
   │           │           ├─ value: .ANSWER
   │           │           └─ name
   │           │              ├─ type: Literal
   │           │              └─ value: ANSWER
   │           └─ 2
   │              ├─ type: Value
   │              └─ base
   │                 ├─ type: Obj
   │                 └─ properties
   │                    ├─ 0
   │                    │  ├─ type: Assign
   │                    │  ├─ name: this.create
   │                    │  ├─ variable
   │                    │  │  ├─ type: Value
   │                    │  │  ├─ value: this.create
   │                    │  │  ├─ base
   │                    │  │  │  ├─ type: Literal
   │                    │  │  │  └─ value: this
   │                    │  │  └─ properties
   │                    │  │     └─ 0
   │                    │  │        ├─ type: Access
   │                    │  │        ├─ value: .create
   │                    │  │        └─ name
   │                    │  │           ├─ type: Literal
   │                    │  │           └─ value: create
   │                    │  ├─ value
   │                    │  │  ├─ type: Code
   │                    │  │  └─ body
   │                    │  │     └─ type: Block
   │                    │  └─ operatorToken
   │                    │     ├─ type: Literal
   │                    │     └─ value: :
   │                    ├─ 1
   │                    │  ├─ type: Comment
   │                    │  └─ value: 
# @property [Array<String>] the nicknames

   │                    ├─ 2
   │                    │  ├─ type: Assign
   │                    │  ├─ name: nicknames
   │                    │  ├─ variable
   │                    │  │  ├─ type: Value
   │                    │  │  ├─ value: nicknames
   │                    │  │  └─ base
   │                    │  │     ├─ type: Literal
   │                    │  │     └─ value: nicknames
   │                    │  ├─ value
   │                    │  │  ├─ type: Value
   │                    │  │  └─ base
   │                    │  │     └─ type: Arr
   │                    │  └─ operatorToken
   │                    │     ├─ type: Literal
   │                    │     └─ value: :
   │                    ├─ 3
   │                    │  ├─ type: Comment
   │                    │  └─ value: 
Construct a new animal.

@param [String] name the name of the animal
@param [Date] birthDate when the animal was born

   │                    ├─ 4
   │                    │  ├─ type: Assign
   │                    │  ├─ name: constructor
   │                    │  ├─ variable
   │                    │  │  ├─ type: Value
   │                    │  │  ├─ value: constructor
   │                    │  │  └─ base
   │                    │  │     ├─ type: Literal
   │                    │  │     └─ value: constructor
   │                    │  ├─ value
   │                    │  │  ├─ type: Code
   │                    │  │  ├─ params
   │                    │  │  │  ├─ 0
   │                    │  │  │  │  ├─ type: Param
   │                    │  │  │  │  └─ name
   │                    │  │  │  │     ├─ type: Value
   │                    │  │  │  │     ├─ value: this.type
   │                    │  │  │  │     ├─ base
   │                    │  │  │  │     │  ├─ type: Literal
   │                    │  │  │  │     │  └─ value: this
   │                    │  │  │  │     └─ properties
   │                    │  │  │  │        └─ 0
   │                    │  │  │  │           ├─ type: Access
   │                    │  │  │  │           ├─ value: .type
   │                    │  │  │  │           └─ name
   │                    │  │  │  │              ├─ type: Literal
   │                    │  │  │  │              └─ value: type
   │                    │  │  │  ├─ 1
   │                    │  │  │  │  ├─ type: Param
   │                    │  │  │  │  └─ name
   │                    │  │  │  │     ├─ type: Value
   │                    │  │  │  │     ├─ value: this.name
   │                    │  │  │  │     ├─ base
   │                    │  │  │  │     │  ├─ type: Literal
   │                    │  │  │  │     │  └─ value: this
   │                    │  │  │  │     └─ properties
   │                    │  │  │  │        └─ 0
   │                    │  │  │  │           ├─ type: Access
   │                    │  │  │  │           ├─ value: .name
   │                    │  │  │  │           └─ name
   │                    │  │  │  │              ├─ type: Literal
   │                    │  │  │  │              └─ value: name
   │                    │  │  │  └─ 2
   │                    │  │  │     ├─ type: Param
   │                    │  │  │     ├─ name
   │                    │  │  │     │  ├─ type: Value
   │                    │  │  │     │  ├─ value: this.birthDate
   │                    │  │  │     │  ├─ base
   │                    │  │  │     │  │  ├─ type: Literal
   │                    │  │  │     │  │  └─ value: this
   │                    │  │  │     │  └─ properties
   │                    │  │  │     │     └─ 0
   │                    │  │  │     │        ├─ type: Access
   │                    │  │  │     │        ├─ value: .birthDate
   │                    │  │  │     │        └─ name
   │                    │  │  │     │           ├─ type: Literal
   │                    │  │  │     │           └─ value: birthDate
   │                    │  │  │     └─ value
   │                    │  │  │        ├─ type: Call
   │                    │  │  │        └─ variable
   │                    │  │  │           ├─ type: Value
   │                    │  │  │           ├─ value: Date
   │                    │  │  │           └─ base
   │                    │  │  │              ├─ type: Literal
   │                    │  │  │              └─ value: Date
   │                    │  │  └─ body
   │                    │  │     ├─ type: Block
   │                    │  │     └─ expressions
   │                    │  │        └─ 0
   │                    │  │           ├─ type: Comment
   │                    │  │           └─ value: 
 Move the animal.

 @example Move an animal
   new Lion('Simba').move('south', 12)

 @param [Object] options the moving options
 @option options [String] direction the moving direction
 @option options [Number] speed the speed in mph
 @public

   │                    │  └─ operatorToken
   │                    │     ├─ type: Literal
   │                    │     └─ value: :
   │                    └─ 5
   │                       ├─ type: Assign
   │                       ├─ name: move
   │                       ├─ variable
   │                       │  ├─ type: Value
   │                       │  ├─ value: move
   │                       │  └─ base
   │                       │     ├─ type: Literal
   │                       │     └─ value: move
   │                       ├─ value
   │                       │  ├─ type: Code
   │                       │  ├─ params
   │                       │  │  └─ 0
   │                       │  │     ├─ type: Param
   │                       │  │     ├─ name
   │                       │  │     │  ├─ type: Literal
   │                       │  │     │  └─ value: options
   │                       │  │     └─ value
   │                       │  │        ├─ type: Value
   │                       │  │        └─ base
   │                       │  │           └─ type: Obj
   │                       │  └─ body
   │                       │     └─ type: Block
   │                       └─ operatorToken
   │                          ├─ type: Literal
   │                          └─ value: :
   ├─ 2
   │  ├─ type: Class
   │  ├─ name: Tiger
   │  ├─ variable
   │  │  ├─ type: Value
   │  │  ├─ value: Tiger
   │  │  └─ base
   │  │     ├─ type: Literal
   │  │     └─ value: Tiger
   │  ├─ parent
   │  │  ├─ type: Value
   │  │  ├─ value: Example.Animal
   │  │  ├─ base
   │  │  │  ├─ type: Literal
   │  │  │  └─ value: Example
   │  │  └─ properties
   │  │     └─ 0
   │  │        ├─ type: Access
   │  │        ├─ value: .Animal
   │  │        └─ name
   │  │           ├─ type: Literal
   │  │           └─ value: Animal
   │  └─ body
   │     ├─ type: Block
   │     └─ expressions
   │        └─ 0
   │           ├─ type: Value
   │           └─ base
   │              ├─ type: Obj
   │              └─ properties
   │                 └─ 0
   │                    ├─ type: Assign
   │                    ├─ name: constructor
   │                    ├─ variable
   │                    │  ├─ type: Value
   │                    │  ├─ value: constructor
   │                    │  └─ base
   │                    │     ├─ type: Literal
   │                    │     └─ value: constructor
   │                    ├─ value
   │                    │  ├─ type: Code
   │                    │  ├─ params
   │                    │  │  ├─ 0
   │                    │  │  │  ├─ type: Param
   │                    │  │  │  └─ name
   │                    │  │  │     ├─ type: Obj
   │                    │  │  │     └─ properties
   │                    │  │  │        └─ 0
   │                    │  │  │           ├─ type: Value
   │                    │  │  │           ├─ value: this.striped
   │                    │  │  │           ├─ base
   │                    │  │  │           │  ├─ type: Literal
   │                    │  │  │           │  └─ value: this
   │                    │  │  │           └─ properties
   │                    │  │  │              └─ 0
   │                    │  │  │                 ├─ type: Access
   │                    │  │  │                 ├─ value: .striped
   │                    │  │  │                 └─ name
   │                    │  │  │                    ├─ type: Literal
   │                    │  │  │                    └─ value: striped
   │                    │  │  └─ 1
   │                    │  │     ├─ type: Param
   │                    │  │     └─ name
   │                    │  │        ├─ type: Literal
   │                    │  │        └─ value: abc
   │                    │  └─ body
   │                    │     ├─ type: Block
   │                    │     └─ expressions
   │                    │        └─ 0
   │                    │           ├─ type: Call
   │                    │           └─ args
   │                    │              └─ 0
   │                    │                 ├─ type: Value
   │                    │                 ├─ value: 'Tiger'
   │                    │                 └─ base
   │                    │                    ├─ type: Literal
   │                    │                    └─ value: 'Tiger'
   │                    └─ operatorToken
   │                       ├─ type: Literal
   │                       └─ value: :
   └─ 3
      ├─ type: Assign
      ├─ name: module.exports
      ├─ value
      │  ├─ type: Value
      │  ├─ value: Tiger
      │  └─ base
      │     ├─ type: Literal
      │     └─ value: Tiger
      └─ variable
         ├─ type: Value
         ├─ value: module.exports
         ├─ base
         │  ├─ type: Literal
         │  └─ value: module
         └─ properties
            └─ 0
               ├─ type: Access
               ├─ value: .exports
               └─ name
                  ├─ type: Literal
                  └─ value: exports
```

