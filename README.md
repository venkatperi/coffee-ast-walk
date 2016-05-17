# coffee-ast-walk
Walk Coffeescript's AST nodes

[![Build Status](https://travis-ci.org/venkatperi/coffee-ast-walk.svg?branch=master)](https://travis-ci.org/venkatperi/coffee-ast-walk)

## Installation

Install with npm:

```shell
npm install coffee-ast-walk --save
```

```coffeescript
astwalk = require 'coffee-ast-walk'
```

# API
## Methods
### astwalk(node).walk([context, ] visitor)
Walk's the AST tree and invokes the visitor for each node.
#### visitor(node)
The current node is passed ot the visitor. Additionaly, the following are available in the `this` context of the visitor callback:
##### path
The `path` to the current node as an array of strings.

##### depth
The depth of the current node

##### isRoot
True if the node is the root node

##### isLeaf
True of the node is a leaf node

##### id
The `id` used to invoke the current node, also the last element of the path array

##### isAstNode
True if the node is a coffeescript AST node, or a scalar (string etc)

##### context
An optional context, passed to walk
