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


