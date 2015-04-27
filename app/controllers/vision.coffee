Spine            = require('spine')
{Panel}          = require('spine.mobile')

class Intro extends Panel
  className:
    'vision'
    
  events:
    'click .back': 'next'   
    'click .info': 'info'   
    'click .popup': 'close'   
    'click .camera': 'switchCam'   
    'load video': 'snapshot'
  elements:
    'video': 'video'
    #"'canvas': 'canvas'
    'section': 'popup'
    
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
    @mediaIndex = 0
    
    MediaStreamTrack.getSources((sourceInfos) =>
      @videoSources = [];

      for sourceInfo in sourceInfos
        if sourceInfo.kind == 'video'
          console.log(sourceInfo.id, sourceInfo.label || 'camera')
          @videoSources.push(sourceInfo.id)

      if @videoSources.length > 1
        @header.addClass("camera")
        
      navigator.getUserMedia ?= navigator.webkitGetUserMedia
      window.requestAnimationFrame ?= window.webkitRequestAnimationFrame
      
      if navigator.getUserMedia && @videoSources.length > 0 then @getUserMedia(@mediaIndex) else @fallback()
    )
    
    $(window).resize(() =>
      if @canvas
        @canvas
          .attr('width', window.innerWidth)
          .attr('height', window.innerHeight);
    
      @video
        .attr('width', window.innerWidth)
        .attr('height', window.innerHeight)
      
    )
    

  snapshot:() =>
    if @ctx
      @ctx.drawImage(@video[0], 0,0, window.innerWidth, window.innerHeight);
      @rafID = window.requestAnimationFrame(@snapshot);

  fallback: (e) =>
    @video[0].src = app_data.fallback_video;
    @snapshot()

  success: (stream) =>
    
    @stream = stream
    @video[0].src = window.URL.createObjectURL(stream);
    @snapshot()

  switchCam:() =>
    @getUserMedia(++@mediaIndex % @videoSources.length)
    
  getUserMedia: (index) =>
    if @stream
      @video[0].src = null;
      @stream.stop();
      
    navigator.getUserMedia({video: {
      optional: [{sourceId: @videoSources[index]}]
    }}, @success, @fallback);

    
  render: =>
    # Calculate currency conversion
    @html require('views/intro/vision')(@)
    
  close: =>
    @popup.hide()
  info: =>
    @popup.html(require('views/intro/vision_info')(@)).show()
    
  active: (params)->
    @index = params.index
    @video.removeClass()
    @video.addClass(app_data.animals[@index])
    @log "active", @video[0].className, @index
    @footer.html  require('views/intro/vision_footer')(@)
    @popup.hide()
    super
    
  next: ->
     @navigate('/animals', trans: 'left')
module.exports = Intro