type = ( node ) -> node?.type or node.constructor.name
isCSNode = ( n ) -> n?.compile?
  
# syntactic sugar
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc
  
module.exports =
  type : type
  isCSNode : isCSNode
 
