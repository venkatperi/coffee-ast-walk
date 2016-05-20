type = ( node ) -> node?.type or node.constructor.name
isCSNode = ( n ) -> n?.compile?

# syntactic sugar
Function::property = ( prop, desc ) ->
  Object.defineProperty @prototype, prop, desc

clamp = ( x, min, max ) ->
  if x < min then min else if x > max then max else x

module.exports =
  type : type
  isCSNode : isCSNode
  clamp : clamp
 
