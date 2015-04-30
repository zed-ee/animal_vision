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
    'canvas.copy': 'canvas_copy'
    'canvas.final': 'canvas_final'
    'div.extra': 'extra'
    'section': 'popup'
    
  backgroundColor: [0.1, 0.1, 0.1, 1.0];

  foregroundColor: [0.0 / 255.0,
        175.0 / 255.0,
        255.0 / 255.0,
        1.0
  ];

    
  constructor: ->
    super

    @render()
    
    if @canvas_copy
      @canvas_copy
        .attr('width', window.innerWidth)
        .attr('height', window.innerHeight);
      @canvas_final
        .attr('width', window.innerWidth)
        .attr('height', window.innerHeight);
    
    @video
      .attr('width', window.innerWidth)
      .attr('height', window.innerHeight)
      
    @w = @canvas_final.width()
    @h = @canvas_final.height()
    
    @ctx_copy = @canvas_copy?[0].getContext('2d');
    #@ctx_copy = @canvas_final?[0].getContext('2d');
    #@gl = @canvas_final?[0].getContext("experimental-webgl");
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
    @models = []
    

  snapshot:() =>
    if @ctx_copy
      @ctx_copy.drawImage(@video[0], 0,0, window.innerWidth, window.innerHeight);
      #@fishEye()
      @updateTexture() if @gl && @shaders.length > 0
      @renderScene() if @renderer
      @rafID = window.requestAnimationFrame(@snapshot);
      

  fishEye: () =>
    w = @canvas_final.width()
    h = @canvas_final.height()
    refractionIndex = 0.5; # [0..1]
    #refraction index of the sphere
    radius = w/5;
    radius2 = radius * radius;
    centerX = w/2; 
    centerY = h/2; 
    #center of the sphere
    origX = 0;
    origY = 0;
    _this = @

    for x in [0..w]
      for y in [0..h]
        distX = x - centerX;
        distY = y - centerY;


        r2 = distX * distX + distY * distY;

        origX = x;
        origY = y;

        if ( r2 > 0.0 && r2 < radius2 )
        
            # distance
            z2 = radius2 - r2;
            z = Math.sqrt(z2);

            # refraction
            xa = Math.asin( distX / Math.sqrt( distX * distX + z2 ) );
            xb = xa - xa * refractionIndex;
            ya = Math.asin( distY / Math.sqrt( distY * distY + z2 ) );
            yb = ya - ya * refractionIndex;

            #displacement
            origX = origX - z * Math.tan( xb );
            origY = origY - z * Math.tan( yb );
        
        # read
        imgData=_this.ctx_copy.getImageData(origX,origY,1,1);
        imgData[0] = 0
        # write
        _this.ctx_final.putImageData(imgData,x, y);
    
    null
    
  fallback: (e) =>
    @video[0].src = app_data.fallback_video;
    @initGL() if @gl
    @initTreeJs() if !@gl    
    @snapshot()

  success: (stream) =>
    
    @stream = stream
    @video[0].src = window.URL.createObjectURL(stream);
    @initGL() if @gl
    @initTreeJs() if !@gl    
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
    @canvas_final.removeClass()
    @canvas_final.addClass(app_data.animals[@index]+ " final")
    @extra.removeClass()
    @extra.addClass(app_data.animals[@index]+ " extra")
    @log "active", @video[0].className, @index
    @footer.html  require('views/intro/vision_footer')(@)
    @popup.hide()
    
    @loadModel(app_data.distortions[@index])
    super
    
  next: ->
     @navigate('/animals', trans: 'left')
     
  loadModel: (file)->
    #file = "plane.json"
    loader = new THREE.JSONLoader();
    loader.load("effects/" + file, (geometry, materials)=>
      @model = new THREE.Mesh(geometry, @faceMaterial);
      @model.rotation.z = 180 * (Math.PI / 180);
      @scene.add(@model);
    );
  
  initTreeJs: =>
    @renderer = new THREE.WebGLRenderer(canvas :@canvas_final[0]);
    @texture = new THREE.VideoTexture(@video[0]);
    @texture.minFilter = @texture.magFilter = THREE.LinearFilter;
    # camera
    @camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 1000);
    @camera.position.y = 0;
    @camera.position.z = -3;
    @camera.rotation.x = 180 * (Math.PI / 180);

    @scene = new THREE.Scene();
    #material
    #materialArray = [];
    #materialArray.push(new THREE.MeshBasicMaterial({map: @texture}));
    #faceMaterial = new THREE.MeshFaceMaterial(materialArray);
    shader = THREE.SimpleShader;
    
    uniforms = THREE.UniformsUtils.clone( shader.uniforms );
    uniforms[ "texture1" ].value = @texture   
    #uniforms[ "radius" ].value = window.innerWidth/5
    #uniforms[ "centerX" ].value = window.innerWidth / 2
    #uniforms[ "centerY" ].value = window.innerHeight / 2
    #uniforms[ "refractionIndex" ].value = 0.5
    
    @faceMaterial = new THREE.ShaderMaterial({
        uniforms: uniforms
        vertexShader: shader.vertexShader,
        fragmentShader: shader.fragmentShader
    })
    
    
    ###
    # plane
    @log @h,@w
    @plane = new THREE.Mesh(new THREE.PlaneBufferGeometry(6, 4), faceMaterial);
    @plane.overdraw = true;
    
    @scene.add(@plane);
    
    #sphere
    shader2 = THREE.SimpleShader2;
    uniforms = THREE.UniformsUtils.clone( shader.uniforms );
    uniforms[ "texture1" ].value = @texture
    
    parameters = { fragmentShader: shader2.fragmentShader, vertexShader: shader2.vertexShader, uniforms: uniforms };
    material = new THREE.ShaderMaterial( parameters );
    

    @sphere = new THREE.Mesh( new THREE.SphereGeometry( 10, 32, 32 ), material );
    @sphere.position.z = -4
    @scene.add( @sphere );
    #
    ###
   
      
   renderScene: () ->
      @renderer.render(@scene, @camera);
module.exports = Intro