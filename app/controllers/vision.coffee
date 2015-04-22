Spine            = require('spine')
{Panel}          = require('spine.mobile')

class Intro extends Panel
  className:
    'vision'
    
  events:
    'click .back': 'next'   
    'load video': 'snapshot'
  elements:
    'video': 'video'
#    'canvas': 'canvas'
    
  constructor: ->
    super

    @render()
    
    if @canvas
      @canvas
        .attr('width', window.innerWidth)
        .attr('height', window.innerHeight);
    
    @video
      .attr('width', window.innerWidth)
      .attr('height', window.innerHeight)
      
    @ctx = @canvas?[0].getContext('2d');
    @index = 0
    @footer.html  require('views/intro/vision_footer')(@)
    

    navigator.getUserMedia ?= navigator.webkitGetUserMedia
    window.requestAnimationFrame ?= window.webkitRequestAnimationFrame
    
    if navigator.getUserMedia then @getUserMedia() else @fallback()

  snapshot:() =>
    if @ctx
      @ctx.drawImage(@video[0], 0, 0);
      @rafID = window.requestAnimationFrame(@snapshot);

  fallback: (e) =>
    @video[0].src = app_data.fallback_video;
    @snapshot()

  success: (stream) =>
    @video[0].src = window.URL.createObjectURL(stream);
    @snapshot()

  getUserMedia: () =>
    navigator.getUserMedia({video: true}, @success, @fallback);

    
  render: =>
    # Calculate currency conversion
    @html require('views/intro/vision')(@)
    
  
  active: (params)->
    @video.removeClass()
    @video.addClass(app_data.animals[params.index].filters)
    @log "active", @video[0].className
    @footer.html  require('views/intro/vision_footer')(@)
    super
    
  next: ->
     @navigate('/animals', trans: 'left')
module.exports = Intro