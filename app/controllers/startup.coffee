Spine            = require('spine')
{Panel}          = require('spine.mobile')

class Intro extends Panel
  className:
    'startup'
    
  events:
    'click .button': 'next'   
  constructor: ->
    super

    @render()
  
  render: =>
    # Calculate currency conversion
    @html require('views/intro/index')(@)
    
  next: ->
     @navigate('/animals', trans: 'right')
module.exports = Intro