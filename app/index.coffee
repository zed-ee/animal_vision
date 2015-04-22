require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')
{Panel}          = require('spine.mobile')
Startup = require('controllers/startup')
Animals = require('controllers/animals')
Vision = require('controllers/vision')

class App extends Stage.Global
  events:
    'tap .set_lang': 'set_lang'   
    'tap .restart': 'restart'   
  
  set_lang: (e) =>
    @log(e)
    @navigate('/'+window.lang, trans: 'right')
    window.lang = if window.lang == 'en' then 'et' else 'en'
    @lang = window.lang
    @log(window.lang)
    @intro.active()
    
  restart: (e) =>
    @navigate('/', trans: 'right')
    
  constructor: (params)->
    super
    @mic = null
    #@header.append(@spectrum)
    @app_data = params.data
    @intro = new Startup
    @animals = new Animals
    @vision = new Vision


    @intro.active()
    
    @routes
      '/':        (params) -> @intro.active(params)
      '/en':        (params) -> @intro.active(params)
      '/et':        (params) -> @intro.active(params)
      '/animals':        (params) -> @animals.active(params)
      '/vision/:index':        (params) -> @vision.active(params)
      
    #@footer.html require('views/intro/footer')
    @navigate('/vision/3', trans: 'right')
       
module.exports = App