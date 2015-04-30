      attribute vec3 aVertexPosition;
      attribute vec2 aTextureCoord;
    
      varying highp vec2 vTextureCoord;
    
      void main(void) {
        gl_Position =  vec4(aVertexPosition.x, aVertexPosition.y, aVertexPosition.z, 1.0);;
        vTextureCoord = aTextureCoord;
      }