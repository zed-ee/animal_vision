Spine            = require('spine')
{Panel}          = require('spine.mobile')

class Intro extends Panel
  className:
    'animals'
    
  events:
    'click li': 'next'
  constructor: ->
    super

    @render()
  
  render: =>
    # Calculate currency conversion
    @html require('views/intro/animals')(@)
    
  next: (e) ->
    index = $( "ul li" ,@el).index( e.target )
    @navigate('/vision', index, trans: 'right')
module.exports = Intro