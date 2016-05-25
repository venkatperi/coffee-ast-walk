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


# <a name='classes'>API</a>

Class |  Summary
------| ------------
<code>[Walk](#class-Walk)</code> | Walk Coffeescript's AST nodes


### <a name="class-Walk">Walk</a><b><sub><sup><code>CLASS </code></sup></sub></b><a href="#classes"><img src="https://rawgit.com/venkatperi/atomdoc-md/master/assets/octicons/arrow-up.svg" alt="Back to Class List" height= "18px"></a>

<p>Walk Coffeescript&#39;s AST nodes</p>


<table width="100%">
  <tr>
    <td colspan="4"><h4>Methods</h4></td>
  </tr>
  
  <tr>
    <td><code>:: <b>constructor(</b> __id, __type <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>__id</code> A unique id (monotonically increasing count).</li>
  <li><code>__type</code> The type of AST node (<code>node.constructor.name</code>)</li>
  </ul>
  
      <p>Create AST Walker</p>
  <p>If <code>init</code> is set, <code>astwalk</code> will perform an initial
  walk over the AST tree and append a meta object as well as two
  properties to each AST node:</p>
  <h2 id="ast-node-meta-information">AST Node Meta Information</h2>
  <p><code>astwalk</code> adds a property meta to Base which is the base class for
   Coffeescript AST node classes. meta provides meta-information
  about the node and in many cases, it rolls up information from
  child nodes which can ease navigation and manipulation of the AST.</p>
  
      
    </td>
  </tr>
  
  <tr>
    <td><code>:: <b>walk(</b> [depth][, context] <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>depth</code> limits the walk up to <code>depth</code> levels from the <strong>current</strong> node (i.e. relative to the current node).</li>
  <li><code>context</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> is available to the visitor callback.</li>
  </ul>
  
      <p>Performs a walk -- calls the visitor for every node.</p>
  <h2 id="about-the-visitor-visitor-node-">About the Visitor: visitor(node)</h2>
  <p>The current node is passed ot the visitor. Additionaly,
  the following properties are available in the <code>this</code> context
   of the visitor callback:</p>
  <ul>
  <li><code>@path</code> The <code>path</code> to the current node as an array of strings.</li>
  <li><code>@depth</code> The depth of the current node.</li>
  <li><code>@isRoot</code> True if the node is the root node.</li>
  <li><code>@isLeaf</code> True of the node is a leaf node.</li>
  <li><code>@id</code> The <code>id</code> used to invoke the current node, also the last
    element of the path array.</li>
  <li><code>@isAstNode</code> True if the node is a coffeescript AST node, or a
  scalar (string etc).</li>
  <li><code>@context</code> An optional context, passed to walk.</li>
  <li><code>@parent</code> The node&#39;s parent (undefined for root node).</li>
  </ul>
  <p>The visitor callback can invoke <code>@abort()</code> to terminate the walk early.</p>
  <p> <strong>Visitor Return Value:</strong> If a visitor returns an <code><a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a></code>,
  the values from visiting the current AST node&#39;s child nodes are
  added to the object with the same key names as the original node.
  This can be viewed as a mapping operation on the AST tree (see example at
   the end).</p>
  
      
    </td>
  </tr>
  
  <tr>
    <td><code>:: <b>findAll(</b> [depth], f <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>depth</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> limits the traversal depth</li>
  <li><code>f</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> is called with each node. The node is returned if <code>f</code> returns true.</li>
  </ul>
  
      <p>Finds all nodes that satisfy the callback</p>
  
      <p>  <em>Returns</em></p>
  <ul>
  <li>Returns array of <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> ast nodes or .</li>
  </ul>
  
    </td>
  </tr>
  
  <tr>
    <td><code>:: <b>findFirst(</b> [depth], f <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>depth</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> limits the traversal depth</li>
  <li><code>f</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> is called with each node. The node is returned if <code>f</code> returns true.</li>
  </ul>
  
      <p>Finds the first node that satisfies the callback</p>
  
      <p>  <em>Returns</em></p>
  <ul>
  <li>Returns <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a>, the ast node or .</li>
  </ul>
  
    </td>
  </tr>
  
  <tr>
    <td><code>:: <b>findByType(</b> t[, depth] <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>t</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String">String</a> the node type to search for.</li>
  <li><code>depth</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> limits the traversal depth</li>
  </ul>
  
      <p>Finds all nodes with the given CoffeeScript node type.</p>
  
      <p>  <em>Returns</em></p>
  <ul>
  <li>Returns array of <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> ast nodes or .</li>
  </ul>
  
    </td>
  </tr>
  
  <tr>
    <td><code>:: <b>findFirstByType(</b> t[, depth] <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>t</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String">String</a> the node type to search for.</li>
  <li><code>depth</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number">Number</a> limits the traversal depth</li>
  </ul>
  
      <p>Finds the first node with the given CoffeeScript node type.</p>
  
      <p>  <em>Returns</em></p>
  <ul>
  <li>Returns <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object">Object</a> ast node or .</li>
  </ul>
  
    </td>
  </tr>
  
  <tr>
    <td><code>:: <b>reduce(</b>  <b>)</b></code></td>
    <td width="8%" align="center"><sub>public</sub></td>
    <td width="8%" align="center"><sub>instance</sub></td>
    <td width="8%" align="center"><sub><a href="#class-Walk">Walk</a></sub></td>
  </tr>
  <tr>
    <td colspan="4">
      <ul>
  <li><code>acc</code> The initial value of the accumulator</li>
  <li><code>f</code> <a href="https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function">Function</a> called with each node: <code>f(node, acc)</code>.</li>
  </ul>
  
      <p>Performs a <code>reduce</code> operation on the AST tree</p>
  <p>Updates an internal <strong>accumulator</strong> to the value returned by
  <code>f(node, acc)</code> and returns the final value of acc.</p>
  
      <p>  <em>Returns</em></p>
  <ul>
  <li>Returns the final accumulator value.</li>
  </ul>
  
    </td>
  </tr>
  
</table>




<br>
<sub>Markdown generated by [atomdoc-md](https://github.com/venkatperi/atomdoc-md).</sub>
