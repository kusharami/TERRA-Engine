Unit TERRA_GLRenderer;

{$I terra.inc}


{$IFDEF WINDOWS}
{$DEFINE DEBUG_SHADERS}
{$ENDIF}

(*Procedure MeshGroup.SetCombineWithColor(C:Color);
Var
  CC:Array[0..3] Of Single;
Begin
  {$IFDEF PC}
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );

  glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE0);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR );
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);

  glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE0);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);

  TextureManager.Instance.WhiteTexture.Bind(1);
  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );

  CC[0] := C.R/255;
  CC[1] := C.G/255;
  CC[2] := C.B/255;
  CC[3] := C.A/255;
  glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, @CC);

  glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
  glTexEnvi( GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_CONSTANT );
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_CONSTANT);

  glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
  glTexEnvi( GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_CONSTANT );
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_CONSTANT);

   {$ENDIF}
End;

Procedure SpriteBatch.SetupSaturationCombiners(Var Slot:Integer);
Var
  Values:Array[0..3] Of Single;
Begin
  Slot := 0;
{$IFDEF PC}
  Values[0] := 0.30;
  Values[1] := 0.59;
  Values[2] := 0.11;
  Values[3] := 1.0;

  glActiveTexture(GL_TEXTURE0);
  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );
  glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR );
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);

  glTexEnvi( GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
  glTexEnvi( GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);

  Inc(Slot);
  TextureManager.Instance.WhiteTexture.Bind(Slot);
  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB);
  glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
  glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_CONSTANT);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_ONE_MINUS_SRC_COLOR);
  glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, @Values);

  If (_Saturation<=0) Then
    Exit;

  If (GraphicsManager.Instance.Renderer.Features.MaxTextureUnits>3) Then
  Begin
    Values[0] := 0.5;
    Values[1] := Values[0];
    Values[2] := Values[0];
    Values[3] := Values[0];
    Inc(Slot);
    TextureManager.Instance.WhiteTexture.Bind(Slot);
    glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );
    glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD);
    glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
    glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_CONSTANT);
    glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
    glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, @Values);
  End;

  If (GraphicsManager.Instance.Renderer.Features.MaxTextureUnits>2) Then
  Begin
    Values[0] := _Saturation;
    Values[1] := Values[0];
    Values[2] := Values[0];
    Values[3] := Values[0];

    Inc(Slot);
    TextureManager.Instance.WhiteTexture.Bind(Slot);
    glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, @Values);
    glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE );
    glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_INTERPOLATE);
    glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE0);
    glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_PREVIOUS);
    glTexEnvi(GL_TEXTURE_ENV, GL_SRC2_RGB, GL_CONSTANT);
    glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
    glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
    glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND2_RGB, GL_SRC_COLOR);
  End;
{$ENDIF}
End;

*)

Interface
Uses
  {$IFDEF WINDOWS}Windows, {$ENDIF}
  {$IFDEF OSX}MacOSAll, AGL, {$ENDIF}
  {$IFDEF LINUX}GLX,X,Xlib,Xutil,{$ENDIF}
  TERRA_String, TERRA_Utils, TERRA_Stream, TERRA_Renderer, TERRA_VertexFormat,
  {$IFDEF DEBUG_GL}TERRA_DebugGL{$ELSE}TERRA_OpenGL{$ENDIF},
  TERRA_Color, TERRA_Image, TERRA_Vector2D, TERRA_Vector3D, TERRA_Vector4D,
  TERRA_Matrix3x3, TERRA_Matrix4x4;

{$DEFINE TRUE_VBO}
Type
  OpenGLFeatures = Class(RendererFeatures)
    Public
      Constructor Create(Owner:Renderer);
  End;

  OpenGLVBO = Class(VertexBufferInterface)
    Protected
      _Handle:Integer;

      Procedure Submit(Wireframe:Boolean); Override;

    Public
      Procedure Release; Override;

      Procedure Invalidate; Override;

      Function Generate(Vertices:VertexData; IndexData, EdgeData:Pointer; TriangleCount:Integer; DynamicUsage:Boolean):Boolean; Override;

      Function Update(Data:PByte):Boolean; Override;
  End;

  OpenGLTexture = Class(TextureInterface)
    Protected
      _Handle:Cardinal;
      _ShouldGenMips:Boolean;

    Public
      Function Generate(Pixels:Pointer; Width, Height:Integer; SourceFormat, TargetFormat:TextureColorFormat; ByteFormat:PixelSizeType):Boolean; Override;
      Procedure Release(); Override;

      Function Bind(Slot:Integer):Boolean; Override;

      Procedure SetFilter(Value:TextureFilterMode); Override;
      Procedure SetWrapMode(Value:TextureWrapMode); Override;
      Procedure SetMipMapping(Value:Boolean); Override;

      Function Update(Pixels:Pointer; X,Y, Width, Height:Integer):Boolean; Override;

      Function GetImage():Image; Override;

      Procedure Invalidate(); Override;
  End;

  OpenGLCubeMap = Class(CubeMapInterface)
    Protected
      _Handle:Cardinal;
      _ShouldGenMips:Boolean;

    Public
      Procedure Release(); Override;

      Function Bind(Slot:Integer):Boolean; Override;

      Procedure SetFilter(Value:TextureFilterMode); Override;
      Procedure SetWrapMode(Value:TextureWrapMode); Override;
      Procedure SetMipMapping(Value:Boolean); Override;

      Function Generate(Width, Height:Integer; SourceFormat, TargetFormat:TextureColorFormat; ByteFormat:PixelSizeType):Boolean; Override;

      Function UpdateFace(FaceID:Integer; Pixels:Pointer; X,Y, Width, Height:Integer):Boolean; Override;

      Procedure Invalidate(); Override;
  End;

  OpenGLFBO = Class(RenderTargetInterface)
    Protected
	    _Handle:Cardinal;
	    _mfb:Cardinal;
	    _color_rb:Cardinal;
	    _depth_rb:Cardinal;
        _stencil_rb:Cardinal;
  	  _targets:Array Of Cardinal;
      _targetCount:Integer;
	    _internalformat:Cardinal;
	    _multisample:Boolean;
      _drawBuffers:Array Of Cardinal;
      _hasDepthBuffer:Boolean;
      _hasStencilBuffer:Boolean;
      _Shared:Boolean;

	    _type:PixelSizeType;

      _Complete:Boolean;

  	  // Create a render texture
	    Function Init():Boolean;

      Function GetErrorString(Code:Cardinal):TERRAString;

      Function GetOrigin: SurfaceOrigin; Override;

    Public
      Function Generate(Width, Height:Integer; MultiSample:Boolean; PixelSize:PixelSizeType; TargetCount:Integer; DepthBuffer, StencilBuffer:Boolean):Boolean; Override;

  	  // Free OpenGL memory
	    Procedure Release(); Override;

      Function Bind(Slot:Integer):Boolean; Override;

      Procedure SetFilter(Value:TextureFilterMode); Override;
      Procedure SetWrapMode(Value:TextureWrapMode); Override;
      Procedure SetMipMapping(Value:Boolean); Override;

	    // Render to this target
	    Procedure BeginCapture(Flags:Cardinal = clearAll); Override;
	    Procedure EndCapture; Override;

      Procedure Resize(NewWidth, NewHeight:Integer); Override;

      Function GetImage():Image; Override;
      Function GetPixel(X,Y:Integer):Color; Override;

      Procedure Invalidate(); Override;

      {$IFDEF IPHONE}
      Procedure PresentToScreen(); Override;
      {$ENDIF}
  End;

  OpenGLShader = Class(ShaderInterface)
    Protected
      _VertexCode:TERRAString;
	    _FragmentCode:TERRAString;

	    _VertexShaderHandle:Cardinal;
	    _FragmentShaderHandle:Cardinal;

      _Program:Cardinal;
      _Linked:Boolean;
      _MRT:Boolean;

      Procedure UniformError(Const Name:TERRAString);

      Function CompileShader(Const Name:TERRAString; Source:TERRAString; ShaderType: Cardinal; var Shader: Cardinal): Boolean;
      Function LinkProgram:Boolean;

      Procedure Unload();

      Function Bind():Boolean; Override;
      Function Unbind():Boolean; Override;

    Public
      Function Generate(Const Name:TERRAString; ShaderCode:TERRAString):Boolean; Override;

      Function IsReady():Boolean; Override;

			Procedure SetIntegerUniform(Const Name:TERRAString; Const Value:Integer); Override;
			Procedure SetFloatUniform(Const Name:TERRAString; Const Value:Single); Override;
			Procedure SetVec2Uniform(Const Name:TERRAString; Const Value:Vector2D); Override;
			Procedure SetVec3Uniform(Const Name:TERRAString; const Value:Vector3D); Override;
			Procedure SetVec4Uniform(Const Name:TERRAString; const Value:Vector4D); Override;
      Procedure SetMat3Uniform(Const Name:TERRAString; Value:Matrix3x3); Override;
      Procedure SetMat4Uniform(Const Name:TERRAString; Value:Matrix4x4); Override;
      Procedure SetVec4ArrayUniform(Const Name:TERRAString; Count:Integer; Values:PVector4D); Override;

      Function HasUniform(Const Name:TERRAString):Boolean; Override;

      Function GetUniform(Name:TERRAString):Integer; Override;
      Function GetAttributeHandle(Const Name:TERRAString):Integer; Override;

      Procedure Invalidate(); Override;
  End;

  OpenGLRenderer = Class(Renderer)
    Protected
      {$IFDEF WINDOWS}
      _HDC:HDC;           // HDC of window
			_hRC:HGLRC;         // OpenGL rendering context
      _PixelFormat:Cardinal;
      {$ENDIF}

      {$IFDEF LINUX}
      _Ctx:GLXContext;
      {$ENDIF}

      {$IFDEF OSX}
      _Context: TAGLContext;
      {$ENDIF}

      _ClearColor:Color;

      _UsedTextures:Array[0..Pred(MaxTextureHandles)] Of Boolean;
      _UsedFrameBuffers:Array[0..Pred(MaxFrameBufferHandles)] Of Boolean;
      _UsedRenderBuffers:Array[0..Pred(MaxFrameBufferHandles)] Of Boolean;

      Function GenerateTexture():Cardinal;
      Function GenerateFrameBuffer():Cardinal;
      Function GenerateRenderBuffer():Cardinal;

      Procedure DeleteTexture(Var Handle:Cardinal);
      Procedure DeleteFrameBuffer(Var Handle:Cardinal);
      Procedure DeleteRenderBuffer(Var Handle:Cardinal);

      Function CreateContext():Boolean;
      Procedure DestroyContext();

      Function Initialize():Boolean; Override;

      Procedure ApplyTextureFilter(Handle, TextureKind:Integer; MipMapped, ShouldGenMips:Boolean; Filter:TextureFilterMode);
      Procedure ApplyTextureWrap(Handle, TextureKind:Integer; WrapMode:TextureWrapMode);

      Procedure ChangeVSync(Const Value:Boolean); Override;
      
    Public
      Procedure ResetState(); Override;
      Procedure BeginFrame(); Override;
      Procedure EndFrame(); Override;

      Procedure Resize(Width, Height:Integer); Override;

      Function GetScreenshot():Image; Override;

      Function CreateTexture():TextureInterface; Override;
      Function CreateCubeMap():CubeMapInterface; Override;
      Function CreateVertexBuffer():VertexBufferInterface; Override;
      Function CreateShader():ShaderInterface; Override;
      Function CreateRenderTarget():RenderTargetInterface; Override;

      Procedure ClearBuffer(Color, Depth, Stencil:Boolean); Override;
      Procedure SetClearColor(Const ClearColor:Color); Override;

      Procedure SetStencilTest(Enable:Boolean); Override;
      Procedure SetStencilFunction(Mode:CompareMode; StencilID:Cardinal; Mask:Cardinal = $FFFFFFFF); Override;
      Procedure SetStencilOp(fail, zfail, zpass:StencilOperation); Override;

      Procedure SetColorMask(Red, Green, Blue, Alpha:Boolean); Override;

      Procedure SetDepthMask(WriteZ:Boolean); Override;
      Procedure SetDepthTest(Enable:Boolean); Override;
      Procedure SetDepthFunction(Mode:CompareMode); Override;

      Procedure SetCullMode(Mode:CullMode); Override;

      Procedure SetBlendMode(BlendMode:Integer); Override;

      Procedure SetProjectionMatrix(Const Mat:Matrix4x4); Override;
      Procedure SetModelMatrix(Const Mat:Matrix4x4);  Override;
      Procedure SetTextureMatrix(Const Mat:Matrix4x4); Override;

      Procedure SetScissorState(Enabled:Boolean); Override;
      Procedure SetScissorArea(X,Y, Width, Height:Integer); Override;

      Procedure SetViewport(X,Y, Width, Height:Integer); Override;

      Procedure SetAttributeSource(Const Name:AnsiString; AttributeKind:Cardinal; ElementType:DataFormat; AttributeSource:Pointer); Override;

      Procedure SetDiffuseColor(Const C:Color); Override;

      Procedure DrawSource(Primitive:RenderPrimitive; Count:Integer); Override;
      Procedure DrawIndexedSource(Primitive:RenderPrimitive; Count:Integer; Indices:System.PWord); Override;
    Public

  End;

Implementation
Uses SysUtils, TERRA_Log, TERRA_Application, TERRA_GraphicsManager, TERRA_FileManager, TERRA_FileUtils, TERRA_FileStream,
  TERRA_Error, TERRA_OS;

{ OpenGLFeatures }
Constructor OpenGLFeatures.Create(Owner:Renderer);
Var
  HasShaders:Boolean;
  S:AnsiString;
Begin
  Inherited Create(Owner);

  {$IFDEF MOBILE}
  glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, @_MaxTextureUnits);
  {$ELSE}
  glGetIntegerv(GL_MAX_TEXTURE_UNITS, @_MaxTextureUnits);
  {$ENDIF}

	glGetIntegerv(GL_MAX_TEXTURE_SIZE, @_MaxTextureSize);

{$IFDEF MOBILE}
	_Settings._maxRenderTargets := 0;
{$ELSE}
  glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, @_maxRenderTargets);
{$ENDIF}

{$IFDEF PC}
  If (glExtensionSupported('GL_EXT_texture_filter_anisotropic')) Then
  Begin
    glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, @_maxAnisotrophy);
  End Else
{$ENDIF}
    _maxAnisotrophy := 0;

  If (glExtensionSupported('GL_ARB_multisample')) Then
    _multiSampleCount := 4
  Else
    _multiSampleCount := 0;

  _VertexCacheSize := 32;

(*  _Vendor := UpStr(_Vendor);
  If Pos('INTEL', _Vendor)>0 Then
    _Vendor := 'INTEL'
  Else
  If Pos('NVIDIA', _Vendor)>0 Then
    _Vendor := 'NVIDIA'
  Else
  If (Pos('ATI', _Vendor)>0) Or (Pos('AMD', _Vendor)>0) Then
    _Vendor := 'ATI';*)

  {$IFDEF PC}
	TextureCompression.Avaliable :=  glExtensionSupported('GL_EXT_texture_compression_s3tc');
  {$ELSE}
  {$IFDEF MOBILE}
  TextureCompression.Avaliable :=  True;
  {$ELSE}
  TextureCompression.Avaliable :=  False;
  {$ENDIF}
  {$ENDIF}

  {$IFDEF PC}
	HasShaders := (glExtensionSupported('GL_ARB_vertex_shader')) And (glExtensionSupported('GL_ARB_fragment_shader'));
//  HasShaders := HasShaders And (Pos('MESA', _Vendor)<=0);
  {$ELSE}

{$IFDEF IPHONE}
  HasShaders := shadersAvailable();
{$ELSE}
  HasShaders := True;
{$ENDIF}
  {$ENDIF}

  {$IFDEF DISABLESHADERS}
  HasShaders := False;
  {$ENDIF}

  Shaders.Avaliable := HasShaders;

  VertexBufferObject.Avaliable := glExtensionSupported('GL_ARB_vertex_buffer_object');

  {$IFDEF FRAMEBUFFEROBJECTS}
    {$IFDEF PC}
  	FrameBufferObject.Avaliable := glExtensionSupported('GL_ARB_framebuffer_object') Or glExtensionSupported('GL_EXT_framebuffer_object');
    {$ENDIF}

    {$IFDEF MOBILE}
	  FrameBufferObject.Avaliable := True;
    {$ENDIF}
  {$ELSE}
  FrameBufferObject.Avaliable := False;
  {$ENDIF}


  {$IFDEF POSTPROCESSING}
  PostProcessing.Avaliable := (FrameBufferObject.Avaliable) And (MaxRenderTargets>=4);
  {$ELSE}
  PostProcessing.Avaliable := False;
  {$ENDIF}

  CubeMapTexture.Avaliable := glExtensionSupported('GL_ARB_texture_cube_map');
  SeparateBlends.Avaliable := glExtensionSupported('GL_EXT_draw_buffers2');
  SeamlessCubeMap.Avaliable := glExtensionSupported('GL_ARB_seamless_cube_map') Or glExtensionSupported('GL_AMD_seamless_cubemap_per_texture');
  {$IFDEF MOBILE}
  NPOT.Avaliable := HasShaders;
  {$ELSE}
  NPOT.Avaliable := glExtensionSupported('GL_ARB_texture_non_power_of_two');//OES_texture_npot
  {$ENDIF}

  {$IFDEF MOBILE}
  PackedStencil.Avaliable := glExtensionSupported('GL_OES_packed_depth_stencil');
  {$ELSE}
  PackedStencil.Avaliable := True;
  {$ENDIF}

  (*glGetIntegerv(GL_MAX_VERTEX_UNIFORM_COMPONENTS, @_MaxUniformVectors);
  If (_MaxUniformVectors<128) Then
    VertexBufferObject.Avaliable := False;     *)

  TextureArray.Avaliable := glExtensionSupported('GL_EXT_texture_array');

  FloatTexture.Avaliable := glExtensionSupported('GL_ARB_color_buffer_float') Or
                            glExtensionSupported('GL_ATI_pixel_format_float') Or
                            glExtensionSupported('GL_NV_float_buffer');

  DeferredLighting.Avaliable := (MaxRenderTargets>=4) And (FrameBufferObject.Avaliable);

  {$IFDEF MOBILE}
  StencilBuffer.Avaliable := PackedStencil.Avaliable Or glExtensionSupported('GL_OES_stencil8');
  {$ELSE}
  StencilBuffer.Avaliable := True;
  {$ENDIF}

(*  {$IFDEF IPHONE}
  DynamicShadows.Avaliable := glExtensionSupported('GL_OES_packed_depth_stencil') Or glExtensionSupported('GL_OES_stencil8');
  {$ELSE}
  DynamicShadows.Avaliable := True;
  {$ENDIF}

  _Settings.DeferredLighting._Enabled := _Settings.DeferredLighting._Avaliable;
  _Settings.DeferredFog._Enabled := True;
  _Settings.DeferredShadows._Enabled := True;
  _Settings.FogMode := 0;

  _Settings.DynamicShadows._Enabled := False;

  _Settings.DynamicShadows._Quality := qualityMedium;
  _Settings.Textures._Quality := qualityMedium;

  _Settings.DepthOfField._Avaliable := True;
  _Settings.DepthOfField._Enabled := True;

  _Settings.NormalMapping._Avaliable := True;
  _Settings.NormalMapping._Enabled := False;

  _Settings.LightMapping._Avaliable := True;
  _Settings.LightMapping._Enabled := True;

  _Settings.DynamicLights._Avaliable := True;
  _Settings.DynamicLights._Enabled := True;

  _Settings.ToonShading._Avaliable := True;
  _Settings.ToonShading._Enabled := True;

  _Settings.AlphaTesting._Avaliable := True;
  {$IFDEF MOBILE}
  _Settings.AlphaTesting._Enabled := False;
  {$ELSE}
  _Settings.AlphaTesting._Enabled := True;
  {$ENDIF}

  _Settings.Specular._Avaliable := True;
  _Settings.Specular._Enabled := False;

  _Settings.Fur._Avaliable := True;
  _Settings.Fur._Enabled := True;

  {$IFDEF HAS_REFLECTIONS}
  _Settings.Reflections._Avaliable := True;
  {$ELSE}
  _Settings.Reflections._Avaliable := False;
  {$ENDIF}
  _Settings.Reflections._Enabled := False;

  _Settings.Sky._Avaliable := True;
  _Settings.Sky._Enabled := True;

  _Settings.SelfShadows._Avaliable := True;
  _Settings.SelfShadows._Enabled := False;

  _Settings.SSAO._Avaliable := _Settings.PostProcessing._Avaliable;
  _Settings.SSAO._Enabled := False;

  _Settings.ShadowSplitCount := 3;
  _Settings.ShadowSplitWeight := 0.75;
  _Settings.ShadowMapSize := 1024;
  _Settings.ShadowBias := 2.0;

  
  *)
  
  S := glGetExtensionString();
  TERRA_Log.Log(logDebug, 'Renderer', 'Extensions: '+ S);
End;

Function CompareToGL(Mode:CompareMode):Integer;
Begin
  Case Mode Of
  compareNever:       Result := GL_NEVER;
  compareLess:        Result := GL_LESS;
  compareEqual:       Result := GL_EQUAL;
  compareLessOrEqual: Result := GL_LEQUAL;
  compareGreater:     Result := GL_GREATER;
  compareDifferent:   Result := GL_NOTEQUAL;
  compareGreaterOrEqual: Result := GL_GEQUAL;
  compareAlways:      Result := GL_ALWAYS;
  End;
End;

Function StencilOpToGL(Op:StencilOperation):Integer;
Begin
  Case Op Of
  stencilKeep:      Result := GL_KEEP;
  stencilReplace:   Result := GL_REPLACE;
  stencilIncrement: Result := GL_INCR;
  stencilDecrement: Result := GL_DECR;
  stencilInvert:    Result := GL_INVERT;
  stencilIncrementWithWrap: Result := GL_INCR_WRAP;
  stencilDecrementWithWrap: Result := GL_DECR_WRAP;
  End;
End;

Function PrimitiveToGL(Primitive:RenderPrimitive):Integer;
Begin
  Case Primitive Of
  renderPoints:     Result := GL_POINTS;
  renderLines:      Result := GL_LINES;
  renderTriangles:  Result := GL_TRIANGLES;
  renderLineStrip:  Result := GL_LINE_STRIP;
  renderTriangleStrip: Result := GL_TRIANGLE_STRIP;
  End;
End;

Function TextureColorFormatToGL(Format:TextureColorFormat):Integer;
Begin
  Case Format Of
  colorRGB:   Result := GL_RGB;
  colorRGBA:  Result := GL_RGBA;
  colorBGR:   Result := GL_BGR;
  colorBGRA:   Result := GL_BGRA;
  colorAlpha: Result := GL_ALPHA; //GL_LUMINANCE;
  End;
End;

Function DataFormatToGL(Format:DataFormat):Integer;
Begin
  Case Format Of
  typeColor:  Result := GL_UNSIGNED_BYTE;
  typeByte:   Result := GL_UNSIGNED_BYTE;
  typeFloat:    Result:= GL_FLOAT;
  typeVector2D: Result:= GL_FLOAT;
  typeVector3D: Result := GL_FLOAT;
  typeVector4D: Result := GL_FLOAT;
    Else
      Result := 0;
  End;
End;

Function ByteFormatToGL(ByteFormat:PixelSizeType):Integer;
Begin
  Case ByteFormat Of
  pixelSizeByte: Result := GL_UNSIGNED_BYTE;
(*  //pixelSizeFloat:
  ,
                    GL_UNSIGNED_SHORT_5_6_5,
                    GL_UNSIGNED_SHORT_4_4_4_4, and
                    GL_UNSIGNED_SHORT_5_5_5_1.*)
    Else
      Result := 0;
  End;
End;


{ OpenGLRenderer }
Procedure OpenGLRenderer.ClearBuffer(Color, Depth, Stencil:Boolean);
Var
  Flags:Cardinal;
Begin
  Flags := 0;

  If (Color) Then
    Flags := Flags Or GL_COLOR_BUFFER_BIT;

  If (Depth) Then
    Flags := Flags Or GL_DEPTH_BUFFER_BIT;

  If (Stencil) Then
    Flags := Flags Or GL_STENCIL_BUFFER_BIT;

  If (Flags<>0) Then
  Begin
    glClearColor(_ClearColor.R/255, _ClearColor.G/255, _ClearColor.B/255, _ClearColor.A/255);
    glClear(Flags);
  End;
End;

Procedure OpenGLRenderer.SetClearColor(const ClearColor: Color);
Begin
  Self._ClearColor := ClearColor;
End;

Function OpenGLRenderer.CreateContext: Boolean;
{$IFDEF WINDOWS}
Var
  Pfd:PixelFormatDescriptor; // Settings for the OpenGL window
{$ENDIF}
{$IFDEF LINUX}
Const
  GLX_SAMPLE_BUFFERS  = 100000;
  GLX_SAMPLES         = 100001;
Var
  winDummy:TWindow;
  X,Y, Width, Height:Integer;
  borderDummy:Cardinal;
  Depth:Cardinal;
  Vi:PXVisualInfo;

Function TrySettings(zDepth:Integer; msaaSamples:Integer):PXVisualInfo;
Var
  Attr:Array[0..10] Of Integer;
Begin
  Attr[0] := GLX_RGBA;
  Attr[1] := GLX_DOUBLEBUFFER;
  Attr[2] := GLX_DEPTH_SIZE;
  Attr[3] := zDepth;
  Attr[4] := GLX_STENCIL_SIZE;
  Attr[5] := 8;
  If (msaaSamples>0) Then
  Begin
    Attr[6] := GLX_SAMPLE_BUFFERS;
    Attr[7] := 1;
    Attr[8] := GLX_SAMPLES;
    Attr[9] := msaaSamples;
    Attr[10] := None;
  End Else
    Attr[6] := None;

  Result := glXChooseVisual(Application.Instance.Display, Application.Instance.ScreenHandle, @Attr);
End;
{$ENDIF}
{$IFDEF OSX}
Var
  displayID:CGDirectDisplayID;
  openGLDisplayMask:CGOpenGLDisplayMask;
  attrib:Array[0..64] Of Integer;
  fmt:TAGLPixelFormat;
  index, Samples:Integer;
  Swap:Integer;

	Procedure AddAttrib(ID:Integer); Overload;
	Begin
		Attrib[Index] := ID; Inc(Index);
	End;
	Procedure AddAttrib(ID,Value:Integer); Overload;
	Begin
		Attrib[Index] := ID; Inc(Index);
		Attrib[Index] := Value; Inc(Index);
	End;
{$ENDIF}
Begin
  Result:=False;

  LoadOpenGL();

  {$IFDEF WINDOWS}
  _HDC := GetDC(Application.Instance.Handle);
  If _HDC=0 Then
  Begin
    RaiseError('Unable to retrieve a device context.');
    Halt;
  End;

 // Settings for the OpenGL window
  FillChar(Pfd,SizeOf(Pfd),0);
  With Pfd Do
  Begin
    nSize := SizeOf(PixelFormatDescriptor); // Size Of This Pixel Format Descriptor
    nVersion := 1;                          // The version of this data structure
    dwFlags := PFD_DRAW_TO_WINDOW Or PFD_SUPPORT_OPENGL Or PFD_DOUBLEBUFFER;
    iPixelType := PFD_TYPE_RGBA;            // RGBA color format
    cColorBits := 24;                       // OpenGL color depth
    cAlphaBits := 8;                        //
    cDepthBits := 24;                       // Specifies the depth of the depth buffer
    cStencilBits := 8;                      // Specificies the depth of the stencil buffer
    iLayerType := PFD_MAIN_PLANE;
  End;

  // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
  {If (_MultiSampleInitialized) And (_MultisampleFormat<>0) Then
    _PixelFormat := _MultisampleFormat
  Else}
    _PixelFormat := ChoosePixelFormat(_hDC, @Pfd);

  If (_PixelFormat=0) Then
  Begin
    RaiseError('Unable to find a suitable pixel format.');
    Exit;
  End;

  // Sets the specified device context's pixel format to the format specified by the PixelFormat.
  If (Not SetPixelFormat(_HDC, _PixelFormat, @Pfd)) then
  Begin
    RaiseError('Unable to set the pixel format.');
    Exit;
  End;

  // Create a OpenGL rendering context
  _hRC := wglCreateContext(_hDC);
  If (_hRC = 0) Then
  Begin
    RaiseError('Unable to create an OpenGL rendering context.');
    Exit;
  End;

  // Makes the specified OpenGL rendering context the calling thread's current rendering context
  If (Not wglMakeCurrent(_hDC,_hRC))Then
  Begin
    RaiseError('Unable to activate OpenGL rendering context.');
    Exit;
  End;

  {If (Not _MultiSampleInitialized) And (Not _Managed) Then
  Begin
    _MultiSampleInitialized := True;
    _MultisampleFormat := InitMultisample(Self._Handle, pfd, _HDC);
    If _MultisampleFormat<>0 Then
    Begin
      //glCoverage := GL_SAMPLE_ALPHA_TO_COVERAGE;
      DestroyWindow(_Handle);
      Self.InitWindow;
      Result := Self.InitGraphics;
      Exit;
    End;
  End;}
  {$ENDIF}

  {$IFDEF OSX}
  // get display ID to use for a mask
  	// the main display as configured via System Preferences
    displayID := CGMainDisplayID();
    openGLDisplayMask := CGDisplayIDToOpenGLDisplayMask(displayID);

  // Solely as an example of possible use, this pixel format limits
  // the possible GraphicsManagers to those supported by the screen mask.
  // In this case the main display.
    Samples := Application.Instance.GetAntialiasSamples();
      Repeat
  		Index := 0;
  		AddAttrib(AGL_RGBA);
  		AddAttrib(AGL_DOUBLEBUFFER);
  		//AddAttrib(AGL_WINDOW);
  		AddAttrib(AGL_RED_SIZE, 8);
  		AddAttrib(AGL_GREEN_SIZE, 8);
  		AddAttrib(AGL_BLUE_SIZE, 8);
  		AddAttrib(AGL_ALPHA_SIZE, 8);
  		AddAttrib(AGL_DEPTH_SIZE, 24);
  		AddAttrib(AGL_STENCIL_SIZE, 8);
  		AddAttrib(AGL_ACCELERATED, 1);
  		AddAttrib(AGL_NO_RECOVERY, 1);
  	//	AddAttrib(AGL_CLOSEST_POLICY);
  		AddAttrib(AGL_DISPLAY_MASK, openGLDisplayMask);
      {  If (Samples>0) Then
        Begin
          AddAttrib(AGL_MULTISAMPLE);
          AddAttrib(AGL_SAMPLE_BUFFERS_ARB, 1);
          AddAttrib(AGL_SAMPLES_ARB, Samples);
        End;      }
        AddAttrib(AGL_NONE);

  		fmt := aglCreatePixelFormat(attrib); // New to Mac OS X v10.5

        Samples := Samples Div 2;
      Until (Assigned(Fmt)) Or (Samples<=0);

  	If (fmt = Nil) Then
    Begin
      RaiseError('aglCreatePixelFormat failed!');
      Exit;
    End;

  	// create an AGL context
  	_context := aglCreateContext(fmt, Nil);
  	If (_context = Nil) Then
  	Begin
      RaiseError('Could not create OpenGL context');
      Exit;
    End;

  	// pixel format is no longer needed
  	aglDestroyPixelFormat(fmt);

  	//aglSetDrawable(_context, GetWindowPort(_window));
  	aglSetWindowRef(_context, Application.Instance.Handle);

  	// make the context the current context
  	aglSetCurrentContext(_context);

    If (Not Application.Instance.FullScreen) Then
       SetWindowBounds(Application.Instance.Handle, kWindowContentRgn, Application.Instance.InitRect);
  {$ENDIF}

  {$IFDEF LINUX}
  VI := TrySettings(24, 4);
  If Not Assigned(VI) Then
    VI := TrySettings(24, 2);
  If Not Assigned(VI) Then
    VI := TrySettings(24, 0);

  If (Not Assigned(VI)) Then
  Begin
    RaiseError('CreateWindow: glXChooseVisual failed.');
    Exit;
  End;

  // create a GLX context
  _Ctx := glXCreateContext(Application.Instance.Display, Vi, Nil, True);

	Depth := 32;

  // connect the glx-context to the window
  glXMakeCurrent(Application.Instance.Display, Application.Instance.Handle, _Ctx);
  XGetGeometry(Application.Instance.Display, Application.Instance.Handle, @winDummy, @X, @Y, @Width, @Height, @borderDummy, @Depth);

  Application.Instance.AddCoordEvent(eventWindowResize, Width, Height, 0);
  {$ENDIf}

  glLoadExtensions();

  {If _MultisampleFormat<>0 Then
    glEnable(GL_MULTISAMPLE);}

  Result := True;
End;

Procedure OpenGLRenderer.ChangeVSync(Const Value:Boolean);
Var
  N:Integer;
Begin
  If Value Then
    N := 1
  Else
    N := 0;

  {$IFDEF WINDOWS}
  If Assigned(wglSwapIntervalEXT) Then
      wglSwapIntervalEXT(N);  // Disable VSync
  {$ENDIF}

  {$IFDEF OSX}
  aglSetInteger(_context, AGL_SWAP_INTERVAL, @N);
  {$ENDIF}

  {$IFDEF LINUX}
  If Assigned(glXSwapIntervalEXT) Then
    glXSwapIntervalEXT(N);
  {$ENDIF}
End;

Procedure OpenGLRenderer.DestroyContext();
Begin
  {$IFDEF WINDOWS}
  // Makes current rendering context not current, and releases the device
  // context that is used by the rendering context.
  If (Not wglMakeCurrent(_hDC,0)) Then
  Begin
    RaiseError('Release of DC and RC failed.');
  End;

  // Attempts to delete the rendering context
  If (Not wglDeleteContext(_hRC)) Then
  Begin
    RaiseError('Release of rendering context failed.');
    _hRC:=0;
  End;

  ReleaseDC(Application.Instance.Handle, _HDC);
  {$ENDIF}

  {$IFDEF LINUX}
  If (Not glXMakeCurrent(Application.Instance.Display, None, Nil)) Then
  Begin
    RaiseError('Could not release drawing context.');
  End;

  glXDestroyContext(Application.Instance.Display, _Ctx);
  _Ctx := Nil;
  {$ENDIF}

  {$IFDEF OSX}
  	If (Assigned(_context)) Then
  	Begin
  		aglSetWindowRef(_context, Nil);

  		aglSetCurrentContext(Nil);
  		aglDestroyContext(_context);

  		_context := Nil;
  	End;

    {$ENDIF}
End;

Function OpenGLRenderer.Initialize():Boolean;
Var
  I:Integer;
  S:AnsiString;
Begin
  Result := CreateContext();

  If Not Result Then
    Exit;

  _ClearColor := ColorNull;

  _Features := OpenGLFeatures.Create(Self);

  _DeviceName := glGetString(GL_RENDERER);
  _DeviceVendor := glGetString(GL_VENDOR);

  _DeviceVersion := StringToVersion('0.0.0');

  {$IFNDEF MOBILE}
  If (Features.Shaders.Avaliable) Then
  Begin
    S := glGetString(GL_SHADING_LANGUAGE_VERSION);
    If (S<>'') Then
    Begin
      Log(logDebug, 'GraphicsManager', 'Version: '+ S);

      I := Pos(' ', S);
      If (I>0) Then
        S := Copy(S, 1, Pred(I));
      _DeviceVersion := StringToVersion(S);
    End;

    Log(logDebug,'GraphicsManager','GLSL version:'+VersionToString(_DeviceVersion));
  End;
  {$ENDIF}

  Result := True;
End;

Procedure OpenGLRenderer.SetColorMask(Red, Green, Blue, Alpha: Boolean);
Begin
  glColorMask(Red, Green, Blue, Alpha);
End;

Procedure OpenGLRenderer.SetDepthMask(WriteZ: Boolean);
Begin
  glDepthMask(WriteZ);
End;

Procedure OpenGLRenderer.SetDepthFunction(Mode: CompareMode);
Begin
  glDepthFunc(CompareToGL(Mode));
End;

Procedure OpenGLRenderer.SetStencilTest(Enable: Boolean);
Begin
  If Enable Then
    glEnable(GL_STENCIL_TEST)
  Else
    glDisable(GL_STENCIL_TEST);
End;

Procedure OpenGLRenderer.SetStencilFunction(Mode: CompareMode; StencilID, Mask: Cardinal);
Begin
  glStencilFunc(CompareToGL(Mode), StencilID, $FFFFFFFF);
End;

Procedure OpenGLRenderer.SetStencilOp(fail, zfail, zpass: StencilOperation);
Begin
  glStencilOp(StencilOpToGL(Fail), StencilOpToGL(ZFail), StencilOpToGL(ZPass));
End;


Procedure OpenGLRenderer.SetCullMode(Mode: CullMode);
Begin
  If (Mode = cullNone) Then
  Begin
    glDisable(GL_CULL_FACE);
  End Else
  Begin
    glEnable(GL_CULL_FACE);
    If (Mode = cullFront) Then
      glCullFace(GL_FRONT)
    Else
      glCullFace(GL_BACK);
  End;
End;

Procedure OpenGLRenderer.SetDepthTest(Enable: Boolean);
Begin
  If Enable Then
    glEnable(GL_DEPTH_TEST)
  Else
    glDisable(GL_DEPTH_TEST);
End;

Procedure OpenGLRenderer.SetBlendMode(BlendMode: Integer);
Var
  NeedsAlpha:Boolean;
Begin
{glEnable(GL_BLEND);
glBlendFunc(GL_ONE, GL_ONE);
exit;}

{  If (BlendMode = _CurrentBlendMode) Then
    Exit;}

  NeedsAlpha := BlendMode>0;

  (*If (Settings.SeparateBlends.Avaliable) And (Settings.PostProcessing.Avaliable)
  And (Shader.ActiveShader<>Nil) And (Shader.ActiveShader.MRT) Then
  Begin
    If NeedsAlpha Then
      glEnableIndexedEXT(GL_BLEND, 0)
    Else
      glDisableIndexedEXT(GL_BLEND, 0);

  End Else*)
  Begin
    If NeedsAlpha Then
    Begin
      glEnable(GL_BLEND);
    End Else
    Begin
      glDisable(GL_BLEND);
    End;

  End;


  If (NeedsAlpha) Then
  Case BlendMode Of
  blendBlend:   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  blendAdd:     glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  blendFilter:  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  blendModulate:glBlendFunc(GL_SRC_COLOR, GL_ONE);
  blendJoin:    glBlendFunc(GL_ONE, GL_ONE);
  blendZero:    glBlendFunc(GL_ZERO, GL_ZERO);
  blendOne:     glBlendFunc(GL_ONE, GL_ZERO);
  blendColor:   glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
  blendColorAdd:   glBlendFunc(GL_SRC_COLOR, GL_ONE);
  blendReflection:   glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
  End;

 //_CurrentBlendMode := BlendMode;
End;

Procedure OpenGLRenderer.SetModelMatrix(Const Mat: Matrix4x4);
Begin
  _ModelMatrix := Mat;

  If (Features.Shaders.Avaliable) Then
  Begin
    If Assigned(Self.ActiveShader) Then
    Begin
      Self.ActiveShader.SetMat4Uniform('modelMatrix', Mat);

      If Self.Settings.SurfaceProjection<>surfacePlanar Then
        Self.ActiveShader.SetMat4Uniform('modelMatrixInverse', Matrix4x4Inverse(Mat));
      Exit;
    End;
  End;

  glMatrixMode(GL_MODELVIEW);
  glLoadMatrixf(@Mat);
End;

Procedure OpenGLRenderer.SetProjectionMatrix(Const Mat:Matrix4x4);
Begin
  _ProjectionMatrix := Mat;

  If (Features.Shaders.Avaliable) Then
  Begin
    If Assigned(Self.ActiveShader) Then
    Begin
      Self.ActiveShader.SetMat4Uniform('projectionMatrix', Mat);
      Exit;
    End;
  End;

  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf(@Mat);
End;

Procedure OpenGLRenderer.SetTextureMatrix(Const Mat: Matrix4x4);
Begin
  _TextureMatrix := Mat;

  If (Features.Shaders.Avaliable) Then
  Begin
    If Assigned(Self.ActiveShader) Then
    Begin
      Self.ActiveShader.SetMat4Uniform('textureMatrix', Mat);
      Exit;
    End;
  End;

  glActiveTexture(GL_TEXTURE0);
  glMatrixMode(GL_TEXTURE);
  glLoadMatrixf(@Mat);
End;

Procedure OpenGLRenderer.SetDiffuseColor(Const C: Color);
Begin
  _DiffuseColor := C;

  If (Features.Shaders.Avaliable) Then
  Begin
    If Assigned(Self.ActiveShader) Then
    Begin
      Self.ActiveShader.SetColorUniform('diffuse', C);
      Exit;
    End;
  End;

  glColor4f(C.R/255, C.G/255, C.B/255, C.A/255);
End;

Procedure OpenGLRenderer.SetAttributeSource(Const Name:AnsiString; AttributeKind:Cardinal; ElementType:DataFormat; AttributeSource:Pointer);
Var
  Count, Format:Integer;
  Norm:Boolean;
  Handle:Integer;
Begin
  Format := DataFormatToGL(ElementType);
  Case ElementType Of
  typeColor:
    Begin
      Count := 4;
      Norm := True;
    End;

  typeByte:
    Begin
      Count := 1;
      Norm := True;
    End;

  typeFloat:
    Begin
      Count := 1;
      Norm := False;
    End;

  typeVector2D:
    Begin
      Count := 2;
      Norm := False;
    End;

  typeVector3D:
    Begin
      Count := 3;
      Norm := False;
    End;

  typeVector4D:
    Begin
      Count := 4;
      Norm := False;
    End;

    Else
      Exit;
  End;

  If _CurrentSource = Nil Then
  Begin
    RaiseError('Please call Renderer.SetVertexSize() before drawing anything!');
    Exit;
  End;

  If (Not Features.Shaders.Avaliable) {Or (Self.ActiveShader = Nil) }Then
  Begin
    If (AttributeKind = vertexPosition) Then
    Begin
      glEnableClientState(GL_VERTEX_ARRAY);
      glVertexPointer(Count, Format, _CurrentSource.Size, AttributeSource);
    End Else
    If (AttributeKind = vertexNormal) Then
    Begin
      glEnableClientState(GL_NORMAL_ARRAY);
      glNormalPointer(Format, _CurrentSource.Size, AttributeSource);
    End Else
    If (AttributeKind = vertexColor) Then
    Begin
      glEnableClientState(GL_COLOR_ARRAY);
      glColorPointer(Count, Format, _CurrentSource.Size, AttributeSource);
    End Else
    If (AttributeKind = vertexUV0) Then
    Begin
      glClientActiveTexture(GL_TEXTURE0);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glTexCoordPointer(Count, Format, _CurrentSource.Size, AttributeSource);
    End Else
    If (AttributeKind = vertexUV1) Then
    Begin
      glClientActiveTexture(GL_TEXTURE1);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glTexCoordPointer(Count, Format, _CurrentSource.Size, AttributeSource);
    End Else
    If (AttributeKind = vertexUV2) Then
    Begin
      glClientActiveTexture(GL_TEXTURE2);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glTexCoordPointer(Count, Format, _CurrentSource.Size, AttributeSource);
    End Else
    If (AttributeKind = vertexUV3) Then
    Begin
      glClientActiveTexture(GL_TEXTURE3);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glTexCoordPointer(Count, Format, _CurrentSource.Size, AttributeSource);
    End Else
    Begin
      RaiseError('Unknown attribute: '+Name);
    End;

    Exit;
  End;

  If Self.ActiveShader = Nil Then
    Exit;

  Handle := Self.ActiveShader.GetAttributeHandle(Name);

  If (Handle<0) Then
    Exit;

  glVertexAttribPointer(Handle, Count, Format, Norm, _CurrentSource.Size, AttributeSource);
End;

Procedure OpenGLRenderer.DrawSource(Primitive: RenderPrimitive; Count: Integer);
Begin
  If (Count<0) Then
    Exit;

  If Assigned(_CurrentSource) Then
  Begin
    If Not _CurrentSource.Bind(True) Then
      Exit;
  End Else
    RaiseError('Cannot draw null buffer!');

  {$IFDEF DEBUG_GRAPHICS}
  Log(logDebug, 'Renderer', 'glDrawArrays: '+IntToString(Count));
  {$ENDIF}

  glDrawArrays(PrimitiveToGL(Primitive), 0, Count);
  Inc(_Stats.TriangleCount, Count Div 3);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);

  _CurrentSource := Nil;
End;

Procedure OpenGLRenderer.DrawIndexedSource(Primitive:RenderPrimitive; Count:Integer; Indices:System.PWord);
Begin
  If (Count<0) Then
    Exit;

  If Assigned(_CurrentSource) Then
    _CurrentSource.Bind(True)
  Else
    RaiseError('Cannot draw null buffer!');

  {$IFDEF DEBUG_GRAPHICS}
  Log(logDebug, 'Renderer', 'glDrawElements: '+IntToString(Count));
  {$ENDIF}

  glDrawElements(PrimitiveToGL(Primitive), Count, GL_UNSIGNED_SHORT, Indices);

  Inc(_Stats.TriangleCount, Count Div 3);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
End;

Procedure OpenGLRenderer.SetViewport(X, Y, Width, Height:Integer);
Begin
  glViewport(X,Y, Width, Height);
End;


Procedure OpenGLRenderer.SetScissorArea(X,Y, Width, Height:Integer);
Begin
  glScissor(X, Y, Width, Height);
End;

Procedure OpenGLRenderer.SetScissorState(Enabled: Boolean);
Begin
  If Enabled Then
    glEnable(GL_SCISSOR_TEST)
  Else
    glDisable(GL_SCISSOR_TEST);
End;

Procedure OpenGLRenderer.ResetState();
Begin
	glEnable(GL_CULL_FACE);

  {$IFDEF PC}
	glEnable(GL_TEXTURE_2D);
  {$ENDIF}

  glEnable(GL_DEPTH_TEST);
	//glDisable(GL_FOG);
	//glEnable(GL_LIGHTING);

  //glDisable(GL_ALPHA_TEST);
  //glDisable(GL_LINE_SMOOTH);
  //glClearDepth(1.0);
  glClearStencil(0);
  glStencilMask($FFFFFFF);
  glDepthFunc(GL_LEQUAL);
End;


Function OpenGLRenderer.GenerateFrameBuffer: Cardinal;
Begin
  Log(logDebug, 'GraphicsManager', 'Generating a new frame buffer...');
  Repeat
    glGenFramebuffers(1, @Result);
    Log(logDebug, 'GraphicsManager', 'Got handle: '+IntToString(Result));
  Until (Result>=MaxFrameBufferHandles) Or (Not _UsedFrameBuffers[Result]);

  If (Result<MaxFrameBufferHandles) Then
    _UsedFrameBuffers[Result] := True;
End;

Function OpenGLRenderer.GenerateRenderBuffer: Cardinal;
Begin
  Log(logDebug, 'GraphicsManager', 'Generating a new render buffer...');
  Repeat
    glGenRenderbuffers(1, @Result);
    Log(logDebug, 'GraphicsManager', 'Got handle: '+IntToString(Result));
  Until (Result>=MaxFrameBufferHandles) Or (Not _UsedRenderBuffers[Result]);

  If (Result<MaxFrameBufferHandles) Then
    _UsedRenderBuffers[Result] := True;
End;

Function OpenGLRenderer.GenerateTexture: Cardinal;
Begin
  Log(logDebug, 'GraphicsManager', 'Generating a new texture...');
  Repeat
    glGenTextures(1, @Result);
    Log(logDebug, 'GraphicsManager', 'Got handle: '+IntToString(Result));
  Until (Result>=MaxTextureHandles) Or (Not _UsedTextures[Result]);

  If (Result<MaxTextureHandles) Then
    _UsedTextures[Result] := True;
End;

Procedure OpenGLRenderer.DeleteFrameBuffer(Var Handle: Cardinal);
Begin
  If (Handle<=0) Then
    Exit;

  glDeleteFramebuffers(1, @Handle);
  If (Handle < MaxFrameBufferHandles) Then
    _UsedFrameBuffers[Handle] := False;

  Handle := 0;
End;

Procedure OpenGLRenderer.DeleteRenderBuffer(Var Handle: Cardinal);
Begin
  If (Handle<=0) Then
    Exit;

  glDeleteRenderbuffers(1, @Handle);
  If (Handle < MaxFrameBufferHandles) Then
    _UsedRenderBuffers[Handle] := False;

  Handle := 0;
End;

Procedure OpenGLRenderer.DeleteTexture(Var Handle: Cardinal);
Begin
  If (Handle<=0) Then
    Exit;

  glDeleteTextures(1, @Handle);
  If (Handle < MaxTextureHandles) Then
    _UsedTextures[Handle] := False;

  Handle := 0;
End;

Procedure OpenGLRenderer.ApplyTextureFilter(Handle, TextureKind:Integer; MipMapped, ShouldGenMips:Boolean; Filter:TextureFilterMode);
Begin
  If Handle = 0 Then
    Exit;

  {$IFDEF PC}
    {$IFNDEF WINDOWS}
    MipMapped := False; {FIXME}
    {$ENDIF}
  {$ENDIF}

  If (Not Features.Shaders.Avaliable) Then
    MipMapped := False;

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Setting texture filtering');{$ENDIF}

  If (Filter = filterBilinear) Then
  Begin
    If (MipMapped) Then
      glTexParameteri(TextureKind, GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
    Else
      glTexParameteri(TextureKind, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(TextureKind, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  End Else
  Begin
    If (MipMapped) Then
      glTexParameteri(TextureKind, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST)
    Else
      glTexParameteri(TextureKind, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(TextureKind, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  End;

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Generating mipmap');{$ENDIF}
  If (MipMapped) And (ShouldGenMips) Then
  Begin
    glGenerateMipmap(TextureKind);
  End;
End;

Procedure OpenGLRenderer.ApplyTextureWrap(Handle, TextureKind:Integer; WrapMode:TextureWrapMode);
Begin
  If Handle = 0 Then
    Exit;

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Setting wrap mode');{$ENDIF}

  If ((Cardinal(WrapMode) And Cardinal(wrapHorizontal))<>0) Then
    glTexParameteri(TextureKind, GL_TEXTURE_WRAP_S, GL_REPEAT)
  Else
    glTexParameteri(TextureKind, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);

  If ((Cardinal(WrapMode) And Cardinal(wrapVertical))<>0) Then
    glTexParameteri(TextureKind, GL_TEXTURE_WRAP_T, GL_REPEAT)
  Else
    glTexParameteri(TextureKind, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  {$IFNDEF MOBILE}
{	If (_Owner.Settings.Textures.Quality>=QualityHigh) And (_Onwer.Settings.MaxAnisotrophy > 1) Then
  Begin
	  glTexParameteri(TextureKind, GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, GraphicsManager.Instance.Settings.MaxAnisotrophy);
  End; BIBI}
  {$ENDIF}
End;

Function OpenGLRenderer.CreateCubeMap: CubeMapInterface;
Begin
  Result := OpenGLCubeMap.Create(Self);
End;

Function OpenGLRenderer.CreateRenderTarget: RenderTargetInterface;
Begin
  Result := OpenGLFBO.Create(Self);
End;

Function OpenGLRenderer.CreateTexture: TextureInterface;
Begin
  Result := OpenGLTexture.Create(Self);
End;

Function OpenGLRenderer.CreateVertexBuffer: VertexBufferInterface;
Begin
  Result := OpenGLVBO.Create(Self);
End;

Function OpenGLRenderer.CreateShader: ShaderInterface;
Begin
  Result := OpenGLShader.Create(Self);
End;

Procedure OpenGLRenderer.BeginFrame;
Begin
  Inherited;

  //glClearColor(_BackgroundColor.R/255, _BackgroundColor.G/255, _BackgroundColor.B/255, 0{_BackgroundColor.A/255});
End;

Procedure OpenGLRenderer.EndFrame();
Begin
  Inherited;

  {$IFDEF WINDOWS}
	Windows.SwapBuffers(_hDC);
  {$ENDIF}

  {$IFDEF LINUX}
    glXSwapBuffers(Application.Instance.Display, Application.Instance.Handle);
  {$ENDIF}

  {$IFDEF OSX}
  	aglSwapBuffers(_Context);
  {$ENDIF}

  //Application.Instance.SetTitle(IntToString(GraphicsManager.Instance.Renderer.Stats.FramesPerSecond));
End;

Procedure OpenGLRenderer.Resize(Width, Height: Integer);
{$IFDEF OSX}
Var
  bufferRect:Array[0..3] Of Integer;
{$ENDIF}  
Begin
  Inherited;

  {$IFDEF OSX}
  If (_Context <> Nil) Then
  Begin
    // Set the AGL buffer rectangle (i.e. the bounds that we will use)
    bufferRect[0] := 0; // 0 = left edge
    bufferRect[1] := 0; // 0 = bottom edge
    bufferRect[2] := Width; // width of buffer rect
    bufferRect[3] := Height; // height of buffer rect

    aglSetInteger(_Context, AGL_BUFFER_RECT, @bufferRect);

    aglEnable(_Context, AGL_BUFFER_RECT);
    aglUpdateContext(_Context);
  End;
  {$ENDIF}
End;

Function OpenGLRenderer.GetScreenshot: Image;
Var
  W,H:Integer;
Begin
  W := GraphicsManager.Instance.Width;
  H := GraphicsManager.Instance.Height;
  Result := Image.Create(W, H);
  glReadPixels(0, 0, W, H, GL_RGBA, GL_UNSIGNED_BYTE, Result.Pixels);
  Result.Process(IMP_FlipVertical);
End;

{ OpenGLVBO }
Function OpenGLVBO.Generate(Vertices:VertexData; IndexData, EdgeData:Pointer; TriangleCount:Integer; DynamicUsage:Boolean):Boolean;
Var
  Index:Single;
  I, N:Integer;
  Flags:Integer;
  P:Pointer;
Begin
  Self._Vertices := Vertices;
  Self._IndexList := IndexData;
  Self._EdgeList := EdgeData;
  Self._Dynamic := DynamicUsage;
  Self._TriangleCount := TriangleCount;
  Self._EdgeCount := 0;
  Self._WireframeIndices := Nil;

  If _Dynamic Then
    Flags := GL_DYNAMIC_DRAW
  Else
    Flags := GL_STATIC_DRAW;

  {$IFDEF TRUE_VBO}
  glGenBuffers(1, @_Handle);
  glBindBuffer(GL_ARRAY_BUFFER, _Handle);
  glBufferData(GL_ARRAY_BUFFER, Vertices.Size * Vertices.Count, Vertices.Buffer, Flags);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  {$ENDIF}

  Result := True;
End;

Procedure OpenGLVBO.Invalidate;
Begin
  _Handle := 0;
End;

Procedure OpenGLVBO.Release;
Begin
  {$IFDEF TRUE_VBO}
  If (_Handle<>0) Then
  Begin
    glDeleteBuffers(1, @_Handle);
    _Handle := 0;
  End;
  {$ENDIF}

  Inherited;
End;

Procedure OpenGLVBO.Submit(Wireframe:Boolean);
Var
  I:Integer;
Begin
  {$IFDEF TRUE_VBO}
  glBindBuffer(GL_ARRAY_BUFFER, _Handle);
  {$ELSE}
  Ofs := Cardinal(_Buffer);
  {$ENDIF}

  _Vertices.Bind(False);

{
  For I:=0 To Pred(_AttributeCount) Do
  If (_Attributes[I].Handle>=0) Then
    glVertexAttribPointer(_Attributes[I].Handle, _Attributes[I].Count, DataFormatToGL(_Attributes[I].Format), _Attributes[I].Normalized, _VertexSize, Pointer(_Attributes[I].Offset));}


  {$IFDEF DEBUG_GRAPHICS}
  Log(logDebug, 'Mesh', 'glDrawElements: '+IntToString(_TriangleCount*3));
  {$ENDIF}

  If WireFrame Then
  Begin
    glDrawElements(GL_LINES, _EdgeCount * 2, GL_UNSIGNED_SHORT, @(_WireframeIndices[0]));
  End Else
  Begin
    glDrawElements(GL_TRIANGLES, _TriangleCount * 3, GL_UNSIGNED_SHORT, _IndexList);
  End;
//    GraphicsManager.Instance.Internal(0 , _TriangleCount);

  {$IFDEF TRUE_VBO}
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  {$ENDIF}
End;

(*Function VBO.Lock: Pointer;
Begin
{$IFDEF TRUE_VBO}
  If (_Handle<=0) Then
  Begin
    Result := Nil;
    Exit;
  End;
{$ENDIF}

{$IFDEF MAPBUFFERS}
{$IFDEF TRUE_VBO}
  glBindBuffer(GL_ARRAY_BUFFER, _Handle);                                   
  Result := glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
{$ENDIF}
{$ELSE}
  If Not Assigned(_Temp) Then
  Begin
    GetMem(_Temp, _VertexCount * _VertexSize);
    Move(_Buffer^, _Temp^, _VertexCount * _VertexSize);
  End;
  Result := _Temp;
{$ENDIF}
End;

Procedure VBO.Unlock;
Begin
  If (_Handle<=0) Then
    Exit;

{$IFDEF TRUE_VBO}
{$IFDEF MAPBUFFERS}
  glUnmapBuffer(GL_ARRAY_BUFFER);
{$ELSE}
  glBindBuffer(GL_ARRAY_BUFFER, _Handle);
  glBufferSubData(GL_ARRAY_BUFFER, 0, _VertexCount * _VertexSize, _Temp);
{$ENDIF}

  glBindBuffer(GL_ARRAY_BUFFER, 0);
{$ENDIF}
End;*)

Function OpenGLVBO.Update(Data:PByte):Boolean;
Begin
  If (_Handle<=0) Then
  Begin
    Result := False;
    Exit;
  End;

  glBindBuffer(GL_ARRAY_BUFFER, _Handle);
  glBufferSubData(GL_ARRAY_BUFFER, 0, _Vertices.Count * _Vertices.Size, Data);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  Result := True;
End;

{ OpenGLCubeMap }
Function OpenGLCubeMap.Bind(Slot: Integer):Boolean;
Begin
  Result := _Handle>0;

  glActiveTexture(GL_TEXTURE0 + Slot);

  {$IFDEF PC}
  glEnable(GL_TEXTURE_CUBE_MAP);
  {$ENDIF}
  glBindTexture(GL_TEXTURE_CUBE_MAP, _Handle);

  //glBindTexture(GL_TEXTURE_CUBE_MAP, 0);

  Result := True;
End;

Function OpenGLCubeMap.Generate(Width, Height:Integer; SourceFormat, TargetFormat:TextureColorFormat; ByteFormat:PixelSizeType): Boolean;
Begin
  _Width := Width;
  _Height := Height;

  _Handle := OpenGLRenderer(_Owner).GenerateTexture();
  glBindTexture(GL_TEXTURE_CUBE_MAP, _Handle);

  glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, TextureColorFormatToGL(TargetFormat),	_Width, _Height, 0,	TextureColorFormatToGL(SourceFormat), GL_UNSIGNED_BYTE, Nil);
  glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, TextureColorFormatToGL(TargetFormat),	_Width, _Height, 0,	TextureColorFormatToGL(SourceFormat), GL_UNSIGNED_BYTE, Nil);
  glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, TextureColorFormatToGL(TargetFormat),	_Width, _Height, 0,	TextureColorFormatToGL(SourceFormat), GL_UNSIGNED_BYTE, Nil);
  glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, TextureColorFormatToGL(TargetFormat),	_Width, _Height, 0,	TextureColorFormatToGL(SourceFormat), GL_UNSIGNED_BYTE, Nil);
  glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, TextureColorFormatToGL(TargetFormat),	_Width, _Height, 0,	TextureColorFormatToGL(SourceFormat), GL_UNSIGNED_BYTE, Nil);
  glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, TextureColorFormatToGL(TargetFormat), _Width, _Height, 0,	TextureColorFormatToGL(SourceFormat), GL_UNSIGNED_BYTE, Nil);

  _ShouldGenMips := True;

  Self.SetWrapMode(wrapNothing);
  Self.MipMapped := False;
  Self.SetFilter(filterBilinear);

  Result := True;
End;

Function OpenGLCubeMap.UpdateFace(FaceID: Integer; Pixels: Pointer; X, Y, Width, Height: Integer):Boolean;
Var
  N:Integer;
Begin
  Case FaceID Of
  cubemap_PositiveX: N := GL_TEXTURE_CUBE_MAP_POSITIVE_X;
  cubemap_NegativeX: N := GL_TEXTURE_CUBE_MAP_NEGATIVE_X;

  cubemap_PositiveY: N := GL_TEXTURE_CUBE_MAP_POSITIVE_Y;
  cubemap_NegativeY: N := GL_TEXTURE_CUBE_MAP_NEGATIVE_Y;

  cubemap_PositiveZ: N := GL_TEXTURE_CUBE_MAP_POSITIVE_Z;
  cubemap_NegativeZ: N := GL_TEXTURE_CUBE_MAP_NEGATIVE_Z;
  End;

  glBindTexture(GL_TEXTURE_CUBE_MAP, _Handle);
  glTexImage2D(N, 0, GL_RGBA8,	_Width, _Height, 0,	GL_RGBA, GL_UNSIGNED_BYTE, Pixels);

  Result := True;
End;

Procedure OpenGLCubeMap.Invalidate;
Begin
  _Handle := 0;
End;

Procedure OpenGLCubeMap.Release();
Begin
  OpenGLRenderer(_Owner).DeleteTexture(_Handle);
End;

Procedure OpenGLCubeMap.SetFilter(Value: TextureFilterMode);
Begin
  Self._Filter := Value;
  OpenGLRenderer(_Owner).ApplyTextureFilter(_Handle, GL_TEXTURE_CUBE_MAP, MipMapped, _ShouldGenMips, Filter);
  _ShouldGenMips := False;
End;

procedure OpenGLCubeMap.SetMipMapping(Value: Boolean);
Begin
  Self._MipMapped := Value;
End;

procedure OpenGLCubeMap.SetWrapMode(Value: TextureWrapMode);
Begin
  Self._WrapMode := Value;
  OpenGLRenderer(_Owner).ApplyTextureWrap(_Handle, GL_TEXTURE_CUBE_MAP, WrapMode);
End;

{ OpenGLFBO }
Function OpenGLFBO.Generate(Width, Height:Integer; MultiSample:Boolean; PixelSize:PixelSizeType; TargetCount:Integer; DepthBuffer,StencilBuffer:Boolean):Boolean;
Var
  I:Integer;
Begin
  Self._Size := Width * Height * 4 * 2;

  _BackgroundColor := ColorCreate(Byte(0), Byte(0), Byte(0), Byte(0));

  _PixelSize := PixelSize;

	_Handle := 0;
	_color_rb := 0;
	_depth_rb := 0;

//  _ContextID := Application.Instance.ContextID;

  If (Multisample) And (_Owner.Features.MultiSampleCount<=0) Then
    Multisample := False;

  _TargetCount := TargetCount;
  SetLength(_Targets, _TargetCount);
  SetLength(_DrawBuffers, _TargetCount);
  For I:=0 To Pred(_TargetCount) Do
  Begin
    _targets[I] := 0;
    _DrawBuffers[I] := GL_COLOR_ATTACHMENT0 + I;
  End;

  _Shared := False;

	_Width := Width;
	_Height := Height;
	_type := PixelSize;
	_multisample := multisample;
  _hasDepthBuffer := DepthBuffer;
  _HasStencilBuffer := StencilBuffer;

  Log(logDebug,'Framebuffer', 'Creating Framebuffer with size: '+IntToString(_Width)+' x '+IntToString(_Height));

  {$IFDEF PC}
	If (_type = pixelSizeFloat) Then
		_internalformat := GL_RGBA16F
	Else
  {$ENDIF}
		_internalformat := GL_RGBA8;

  Result := Self.Init();
End;


Function OpenGLFBO.GetErrorString(Code: Cardinal): TERRAString;
Begin
	Case Code Of
		GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
        Result := 'Framebuffer incomplete: Attachment is NOT complete.';

		GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
        Result := 'Framebuffer incomplete: No image is attached to FBO.';

		GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
        Result := 'Framebuffer incomplete: Attached images have different dimensions.';

		GL_FRAMEBUFFER_INCOMPLETE_FORMATS:
        Result := 'Framebuffer incomplete: Color attached images have different internal formats.';

		GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:
        Result := 'Framebuffer incomplete: Draw buffer.';

		GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:
        Result := 'Framebuffer incomplete: Read buffer.';

		GL_FRAMEBUFFER_UNSUPPORTED:
        Result := 'Unsupported by FBO implementation.';
		Else
        Result := 'Unknow FBO error code '+CardinalToString(Code);
    End;
End;

Function OpenGLFBO.Init():Boolean;
Var
  I, Status:Integer;
  R:OpenGLRenderer;
Begin
  Log(logDebug, 'Framebuffer','Initializing framebuffer: '{+ Self.Name});

  R := OpenGLRenderer(_Owner);
  
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glBindRenderbuffer(GL_RENDERBUFFER, 0);

  {$IFDEF IPHONE}
{    bool isSimulator = ( 0 == strcmp((const char*)"Apple Software GraphicsManager",
                                       (const char*) glGetString(GL_GraphicsManager)) )?TRUE:FALSE;

	char *extensions = glGetString(GL_EXTENSIONS);
	hasStencil = (strstr(extensions, "GL_OES_packed_depth_stencil")!=0);
	hasMsaa = (_msaaSamples>0) && (strstr(extensions, "GL_APPLE_framebuffer_multisample")!=0);}

			{// simulator hasMsaa = false;

		glGenFramebuffersOES(1, &viewFramebuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

		glGenRenderbuffersOES(1, &viewRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

		[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

		glGenRenderbuffersOES(1, &depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT24_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);

		glGenRenderbuffersOES(1, &stencilRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, stencilRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_STENCIL_INDEX8_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_STENCIL_ATTACHMENT_OES, GL_RENDERBUFFER_OES, stencilRenderbuffer);

     // msaa
		glGenFramebuffersOES(1, &viewFramebuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

		glGenRenderbuffersOES(1, &viewRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

		[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

		glGenFramebuffersOES(1, &msaaFramebuffer);
		glGenRenderbuffersOES(1, &msaaRenderBuffer);

		glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderBuffer);

		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, _msaaSamples, GL_RGB5_A1_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, msaaRenderBuffer);
		glGenRenderbuffersOES(1, &msaaDepthBuffer);

		glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaDepthBuffer);
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, _msaaSamples, GL_DEPTH24_STENCIL8_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, msaaDepthBuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_STENCIL_ATTACHMENT_OES, GL_RENDERBUFFER_OES, msaaDepthBuffer);
    }

  If (_Name='device_target0') Then
  Begin
    _Handle := GraphicsManager.Instance.GenerateFrameBuffer();
    glBindFramebuffer(GL_FRAMEBUFFER, _Handle);

    _color_rb := GraphicsManager.Instance.GenerateRenderBuffer();
    glBindRenderbuffer(GL_RENDERBUFFER, _color_rb);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _color_rb);
    SetRenderbufferStorage(); //[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    Log(logDebug,'Framebuffer', 'Linked framebuffer to display memory');

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, @_Width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, @_Height);
    Log(logDebug,'Framebuffer', 'Framebuffer size:  '+IntToString(_Width)+' x '+IntToString(_Height));

    _depth_rb := GraphicsManager.Instance.GenerateRenderBuffer();
    glBindRenderbuffer(GL_RENDERBUFFER, _depth_rb);

    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _Width, _Height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depth_rb);
  End;
  {$ENDIF}

  {$IFDEF MOBILE}
  If (_Handle = 0) Then
  Begin
    // Create a framebuffer and renderbuffer
    _Handle := GraphicsManager.Instance.GenerateFrameBuffer();
    _depth_rb := GraphicsManager.Instance.GenerateRenderBuffer();
    Log(logDebug,'Framebuffer', 'Created framebuffer with handle: '+IntToString(_Handle));

    // Create a texture to hold the frame buffer
    _Targets[0] := GraphicsManager.Instance.GenerateTexture();
	  glBindTexture(GL_TEXTURE_2D, _Targets[0]);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _Width, _Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Nil);
    Log(logDebug,'Framebuffer', 'Framebuffer size: W: '+IntToString(_Width)+' H: '+IntToString(_Height));

    If GraphicsManager.Instance.Settings.PackedStencil.Avaliable Then
    Begin
      I := GL_DEPTH24_STENCIL8_OES;
      Log(logDebug,'Framebuffer', 'Packed stencil supported, using it!');
    End Else
      I := GL_DEPTH_COMPONENT16;

    //bind renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _depth_rb);
    glRenderbufferStorage(GL_RENDERBUFFER, I, _Width, _Height);
    Log(logDebug,'Framebuffer', 'Binding depth renderbuffer to framebuffer with handle: '+IntToString(_depth_rb));

    // bind the framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _Handle);

    // specify texture as color attachment
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _Targets[0], 0);
    Log(logDebug,'Framebuffer', 'Binding texture to framebuffer with handle: '+IntToString(_Targets[0]));

    // specify depth_renderbufer as depth attachment
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depth_Rb);

    If GraphicsManager.Instance.Settings.PackedStencil.Avaliable Then
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depth_rb);
  End;
  {$ENDIF}

  {$IFDEF PC}
	If (_multisample) Then
	Begin
    _Handle := R.GenerateFrameBuffer();
		glBindFramebuffer(GL_FRAMEBUFFER, _Handle);

		_Targets[0] := R.GenerateTexture();
		glBindTexture(GL_TEXTURE_2D, _Targets[0]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		// initialize color texture
    {$IFDEF PC}
    If (_type = pixelSizeFloat) Then
    Begin
      _internalformat := GL_RGBA16F;
      glTexImage2D(GL_TEXTURE_2D, 0, _internalformat, _Width, _Height, 0, GL_RGBA, GL_HALF_FLOAT, Nil);      
    End Else
    {$ENDIF}
    Begin
      _internalformat := GL_RGBA8;
      glTexImage2D(GL_TEXTURE_2D, 0, _internalformat, _Width, _Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Nil);    
		End;
		glBindTexture(GL_TEXTURE_2D, 0);      

    _color_rb := R.GenerateRenderBuffer();
		glBindRenderbuffer(GL_RENDERBUFFER, _color_rb);
		glRenderbufferStorageMultisample(GL_RENDERBUFFER, _Owner.Features.MultiSampleCount , _internalformat, _Width, _Height);
		glBindRenderbuffer(GL_RENDERBUFFER, 0);    

    If (_HasDepthBuffer) Then
    Begin
  		_depth_rb := R.GenerateRenderBuffer();
	  	glBindRenderbuffer(GL_RENDERBUFFER, _depth_rb);      
  		glRenderbufferStorageMultisample(GL_RENDERBUFFER, _Owner.Features.MultiSampleCount, {$IFDEF IPHONE}GL_DEPTH24_STENCIL8_OES{$ELSE}GL_DEPTH24_STENCIL8{$ENDIF}, _Width, _Height);      
	  	glBindRenderbuffer(GL_RENDERBUFFER, 0);
    End;

    _MFB := R.GenerateFrameBuffer();
		glBindFramebuffer(GL_FRAMEBUFFER, _mfb);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _color_rb);

    If (_HasDepthBuffer) Then
    Begin
  	  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depth_rb);      
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depth_rb);
    End;

    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    _Handle := R.GenerateFrameBuffer();
		glBindFramebuffer(GL_FRAMEBUFFER, _Handle);    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _Targets[0], 0);    
	End Else
	Begin
		// initalize FrameBufferObject
    _Handle := R.GenerateFrameBuffer();
		glBindFramebuffer(GL_FRAMEBUFFER, _Handle);
    Log(logDebug,'Framebuffer', 'Created framebuffer with handle: '+IntToString(_Handle));

		// initialize color texture
    For I:=0 To Pred(_TargetCount) Do
    Begin
      _Targets[I] := R.GenerateTexture();
	  	glBindTexture(GL_TEXTURE_2D, _Targets[I]);      
  		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);      
	  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);      

      If (_type = pixelSizeFloat) Then
		  Begin
			  glTexImage2D(GL_TEXTURE_2D, 0, _internalformat, _Width, _Height, 0, GL_RGBA, GL_HALF_FLOAT, Nil);
      End Else
  		Begin
	  	  glTexImage2D(GL_TEXTURE_2D, 0, _internalformat, _Width, _Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Nil);
      End;
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + I, GL_TEXTURE_2D, _Targets[I], 0);

      Log(logDebug,'Framebuffer', 'Binding texture to framebuffer with handle: '+IntToString(_Targets[I]));
    End;

		If (_HasDepthBuffer) Then
		Begin
			// initialize depth renderbuffer
			_depth_rb := R.GenerateRenderBuffer();
			glBindRenderbuffer(GL_RENDERBUFFER, _depth_rb);
			glRenderbufferStorage(GL_RENDERBUFFER, {$IFDEF IPHONE}GL_DEPTH24_STENCIL8_OES{$ELSE}GL_DEPTH24_STENCIL8{$ENDIF}, _Width, _Height);

			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depth_rb);
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depth_rb);
		End;
	End;
  {$ENDIF}

	// check for errors
	Status := glCheckFramebufferStatus(GL_FRAMEBUFFER);
  _Complete := (Status = GL_FRAMEBUFFER_COMPLETE);

  If _Complete Then
  Begin
    Self.SetWrapMode(wrapNothing);
    Self.MipMapped := False;
    Self.SetFilter(filterBilinear);
  End Else
    Log(logError, 'Framebuffer', GetErrorString(Status));

  // set default framebuffer
	glBindFramebuffer(GL_FRAMEBUFFER, 0);

  Result := _Complete;
End;

Procedure OpenGLFBO.Invalidate;
Var
  I:Integer;
Begin
  _Handle := 0;
	_color_rb := 0;
  _depth_rb := 0;
  _stencil_rb := 0;

  For I:=0 To Pred(_TargetCount) Do
    _Targets[I] := 0;
End;

Procedure OpenGLFBO.BeginCapture(Flags: Cardinal);
Var
  ClearFlags:Cardinal;
Begin
  If (_Handle = 0) Then
    Self.Init();

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Framebuffer','Begin framebuffer capture: W:'+IntToString(_Width)+' H:'+IntToString(_Height));{$ENDIF}

	If (_multisample) Then
  Begin
		glBindFramebuffer(GL_FRAMEBUFFER, _mfb);
	End Else
  Begin
		glBindFramebuffer(GL_FRAMEBUFFER, _Handle);
  End;

  {$IFDEF PC}
  glDrawBuffers(_TargetCount, @_DrawBuffers[0]);
  {$ENDIF}

  GraphicsManager.Instance.ActiveViewport.SetViewArea(0, 0, _Width, _Height);

  If (Flags<>0) Then
  Begin
    ClearFlags := 0;

    If ((Flags And clearColor)<>0) Then
      ClearFlags := ClearFlags Or GL_COLOR_BUFFER_BIT;

    If ((Flags And clearDepth)<>0) Then
      ClearFlags := ClearFlags Or GL_DEPTH_BUFFER_BIT;

    If ((Flags And clearStencil)<>0) Then
      ClearFlags := ClearFlags Or GL_STENCIL_BUFFER_BIT;

    glClearStencil(0);
    glClearColor(_BackgroundColor.R/255.0, _BackgroundColor.G/255.0, _BackgroundColor.B/255.0, _BackgroundColor.A/255.0);
    glClear(ClearFlags);
  End;
End;

Procedure OpenGLFBO.EndCapture;
Begin
  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Framebuffer','End framebuffer capture');{$ENDIF}

  {$IFDEF PC}
	If (_multisample) Then
	Begin
		glBindFramebuffer(GL_READ_FRAMEBUFFER, _mfb);
		glReadBuffer(GL_COLOR_ATTACHMENT0);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _Handle);
		glDrawBuffer(GL_COLOR_ATTACHMENT0);
		glBlitFramebuffer(0, 0, _Width, _Height, 0, 0, _Width, _Height, GL_COLOR_BUFFER_BIT Or GL_DEPTH_BUFFER_BIT, GL_NEAREST);
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
	End Else
  {$ENDIF}
  Begin
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
  End;
End;

Procedure OpenGLFBO.Resize(NewWidth, NewHeight:Integer);
Begin
	Self.Release();
  _Width := NewWidth;
  _Height := NewHeight;
	Self.Init();
End;

Function OpenGLFBO.Bind(Slot: Integer):Boolean;
Begin
	glActiveTexture(GL_TEXTURE0 + Slot);
  {$IFDEF PC}
	glEnable(GL_TEXTURE_2D);
  {$ENDIF}

  If (Not _Complete) Then
  Begin
    glBindTexture(GL_TEXTURE_2D, 0);
    Result := False;
    Exit;
  End;


	glBindTexture(GL_TEXTURE_2D, _Targets[0]);
  Result := True;
End;

Procedure OpenGLFBO.Release();
Var
  I:Integer;
  R:OpenGLRenderer;
Begin
{  If (_ContextID <> Application.Instance.ContextID) Then
  Begin
  Self.Invalidate();
    Exit;
  End;}

  R := OpenGLRenderer(_Owner);

  R.DeleteRenderBuffer(_color_rb);

	If (Not _Shared) Then
  Begin
		R.DeleteRenderBuffer(_depth_rb);
    R.DeleteRenderBuffer(_stencil_rb);
  End;

  For I:=0 To Pred(_TargetCount) Do
		R.DeleteTexture(_Targets[I]);

  R.DeleteFrameBuffer(_Handle);
End;

Function OpenGLFBO.GetImage():Image;
Begin
  Result := Image.Create(_Width, _Height);

	glBindFramebuffer(GL_FRAMEBUFFER, _Handle);
  {$IFDEF PC}
	glReadBuffer(GL_COLOR_ATTACHMENT0 + 0);
  {$ENDIF}

	glReadPixels(0,0, _Width, _Height, GL_RGBA, GL_UNSIGNED_BYTE, Result.Pixels);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);

	Result.Process(IMP_FlipVertical);
End;

Function OpenGLFBO.GetPixel(X,Y:Integer):Color;
Var
  P:Color;
Begin
  Y := _Height - Y;
  {$IFDEF PC}
	glBindFramebuffer(GL_FRAMEBUFFER, _Handle);
	glReadBuffer(GL_COLOR_ATTACHMENT0);
	glReadPixels(X,Y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, @P);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
  {$ELSE}
  P := ColorNull;
  {$ENDIF}
  Result := P;
End;

{$IFDEF IPHONE}
Procedure OpenGLFBO.PresentToScreen();
Begin
  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Framebuffer','Presenting framebuffer: '+_Name);{$ENDIF}
  glBindRenderbuffer(GL_RENDERBUFFER, _color_rb);
  PresentRenderBuffer();
  glBindRenderbuffer(GL_RENDERBUFFER, 0);
End;
{$ENDIF}

Procedure OpenGLFBO.SetFilter(Value: TextureFilterMode);
Begin
  _Filter := Value;
  OpenGLRenderer(_Owner).ApplyTextureFilter(_Handle, GL_TEXTURE_2D, False, False, Filter);
End;

procedure OpenGLFBO.SetMipMapping(Value: Boolean);
Begin
  _MipMapped := Value;
End;

procedure OpenGLFBO.SetWrapMode(Value: TextureWrapMode);
Begin
  _WrapMode := Value;
  OpenGLRenderer(_Owner).ApplyTextureWrap(_Handle, GL_TEXTURE_2D, WrapMode);
End;

Function OpenGLFBO.GetOrigin: SurfaceOrigin;
Begin
  Result := surfaceBottomRight;
End;

{ OpenGLTexture }
Function OpenGLTexture.Bind(Slot: Integer): Boolean;
Begin
  Result := (_Handle > 0);

  glActiveTexture(GL_TEXTURE0 + Slot);

  {$IFDEF PC}
  glEnable(GL_TEXTURE_2D);
  {$ENDIF}

  glBindTexture(GL_TEXTURE_2D, _Handle);
  Result := True;
End;

Function OpenGLTexture.Generate(Pixels: Pointer; Width, Height:Integer; SourceFormat, TargetFormat:TextureColorFormat; ByteFormat:PixelSizeType): Boolean;
Var
  Mult:Single;
Begin
  _Handle := OpenGLRenderer(_Owner).GenerateTexture();
  _Width := Width;
  _Height := Height;

  glActiveTexture(GL_TEXTURE0);
  {$IFDEF PC}
  glEnable(GL_TEXTURE_2D);
  {$ENDIF}
  glBindTexture(GL_TEXTURE_2D, _Handle);

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Uploading texture frame...');{$ENDIF}
  glTexImage2D(GL_TEXTURE_2D, 0, TextureColorFormatToGL(TargetFormat), Width, Height, 0, TextureColorFormatToGL(SourceFormat), ByteFormatToGL(ByteFormat), Pixels);

  //_Source.Save('debug\temp\pp'+IntTOString(I)+'.png');

(*  If (_Format = GL_COMPRESSED_RGBA) Then
  Begin
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_INTERNAL_FORMAT, @_Format);
    glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_COMPRESSED_IMAGE_SIZE, @_Size);
  End;
*)

  Case ByteFormatToGL(ByteFormat) Of
  GL_UNSIGNED_SHORT_4_4_4_4,
  GL_UNSIGNED_SHORT_5_5_5_1,
  GL_UNSIGNED_SHORT_5_6_5:
    Begin
      Mult := 2;
    End;

  Else
    Mult := 4.0;
  End;

  _Size := Trunc(Mult * _Width * _Height);

  {$IFDEF PC}
  glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, @_Width);
  glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, @_Height);
  {$ENDIF}

  _ShouldGenMips := True;

  Self.SetWrapMode(wrapAll);
  Self.MipMapped := True;
  Self.SetFilter(filterBilinear);

  Result := True;
End;

Function OpenGLTexture.GetImage:Image;
Begin
  Log(logDebug, 'Texture', 'Getting image from texture '{+Self.Name});

  Result := Image.Create(_Width, _Height);

  {$IFDEF PC}
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, _Handle);

  glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, @_Width);
  glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, @_Height);

  glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, Result.Pixels);

  Result.Process(IMP_FlipVertical);
  {$ENDIF}
End;

Procedure OpenGLTexture.Invalidate;
Begin
  _Handle := 0;
End;

Function OpenGLTexture.Update(Pixels: Pointer; X, Y, Width, Height: Integer):Boolean;
Begin
	glBindTexture(GL_TEXTURE_2D, _Handle);
	//glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, Source.Width, Source.Height, _TargetFormat, _ByteFormat, Pixels);
  glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, Pixels);

  _ShouldGenMips := True;

  Result := True;
End;

Procedure OpenGLTexture.Release;
Begin
  OpenGLRenderer(_Owner).DeleteTexture(_Handle);
End;

Procedure OpenGLTexture.SetFilter(Value: TextureFilterMode);
Begin
  Self._Filter := Value;
  OpenGLRenderer(_Owner).ApplyTextureFilter(_Handle, GL_TEXTURE_2D, MipMapped, _ShouldGenMips, Filter);

  _ShouldGenMips := False;
End;

Procedure OpenGLTexture.SetMipMapping(Value: Boolean);
Begin
  Self._MipMapped := Value;
End;

Procedure OpenGLTexture.SetWrapMode(Value: TextureWrapMode);
Begin
  Self._WrapMode := Value;
  OpenGLRenderer(_Owner).ApplyTextureWrap(_Handle, GL_TEXTURE_2D, Value);
End;

{ OpenGLShader }

Function OpenGLShader.Bind:Boolean;
Var
  I:Integer;
Begin
  Result := False;

  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

  {$IFDEF ANDROID}
  If (Not glIsProgram(_Program)) And (_Status = rsReady) Then
  Begin
    Self.Unload();
    Exit;
  End;
  {$ENDIF}

  {$IFDEF DEBUG_GRAPHICS}
  Log(logDebug, 'Shader', 'Binding shader: ');
  {$ENDIF}

  glUseProgram(_Program);

  If (_AttributeCount<=0) Then
  Begin
    {$IFDEF DEBUG_GRAPHICS}
    Log(logDebug, 'Shader', 'Adding attributes');
    {$ENDIF}

    AddAttributes(_VertexCode);
  End;

  For I:=0 To Pred(_AttributeCount) Do
  Begin
    If (_Attributes[I].Handle<0) Then
    Begin
      _Attributes[I].Handle := glGetAttribLocation(_Program, PAnsiChar(_Attributes[I].Name));
      If (_Attributes[I].Handle<0) Then
      Begin
      {$IFDEF DEBUG_GRAPHICS}
        Log(logError, 'Shader', 'Could not find attribute '+_Attributes[I].Name+' on shader: '+_Name);
      {$ENDIF}
        Continue;
      End;
    End;

    {$IFDEF DEBUG_GRAPHICS}
    Log(logDebug, 'Shader', 'Enabling attribarray '+_Attributes[I].Name);
    {$ENDIF}
    glEnableVertexAttribArray(_Attributes[I].Handle);
  End;

  {$IFDEF DEBUG_GRAPHICS}
  Log(logDebug, 'Shader', 'End bind');
  {$ENDIF}

  Result := True;
End;

Function OpenGLShader.Unbind():Boolean;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_AttributeCount) Do
  Begin
    If (_Attributes[I].Handle<0) Then
    Begin
      _Attributes[I].Handle := glGetAttribLocation(_Program, PAnsiChar(_Attributes[I].Name));
      If (_Attributes[I].Handle<0) Then
      Begin
      {$IFDEF DEBUG_GRAPHICS}
        Log(logError, 'Shader', 'Could not find attribute '+_Attributes[I].Name+' on shader: '+_Name);
      {$ENDIF}
        Continue;
      End;
    End;

    {$IFDEF DEBUG_GRAPHICS}
    Log(logDebug, 'Shader', 'Enabling attribarray '+_Attributes[I].Name);
    {$ENDIF}
    glDisableVertexAttribArray(_Attributes[I].Handle);
  End;

  Result := True;
End;

Function OpenGLShader.CompileShader(Const Name:TERRAString; Source:TERRAString; ShaderType: Cardinal; var Shader: Cardinal): Boolean;
Var
  CompileStatus, ShaderLength:Integer;
  LogInfo,PS:TERRAString;
  LogLength,slen:Integer;
  Dest:FileStream;
  P:Pointer;
Begin
  Result := False;
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

  Source := '#version 120'+CrLf + Source;

  {$IFDEF PC}
  StringReplaceText('highp', '', Source);
  StringReplaceText('lowp', '', Source);
  StringReplaceText('mediump', '', Source);
  {$ENDIF}

  // Create shader
  ShaderLength := Length(Source);

  Shader := glCreateShader(ShaderType);

  P := PAnsiChar(Source);
  glShaderSource(Shader,1 ,@P, @ShaderLength);
  glCompileShader(Shader);
  glGetShaderiv(Shader, GL_COMPILE_STATUS, @CompileStatus);

  glGetShaderiv(Shader, GL_INFO_LOG_LENGTH, @LogLength);
  If LogLength > 1 Then
  Begin
    SetLength(LogInfo, LogLength);
    glGetShaderInfoLog(Shader, LogLength, @slen, @LogInfo[1]);    
    LogInfo := StringTrimRight(LogInfo);

    If ShaderType=GL_VERTEX_SHADER Then
      PS:='Vertex'
    Else
      PS:='Fragment';
    Log(logDebug,'Shader', LogInfo);
  End Else
    LogInfo:='';

  If CompileStatus=0 Then
  Begin
    If ShaderType=GL_VERTEX_SHADER Then
      PS:='Vertex'
    Else
      PS:='Fragment';

    StringReplaceText('ERROR:','@', LogInfo);
    StringReplaceText('@', StringFromChar(NewLineChar)+'ERROR:', LogInfo);
    //Delete(LogInfo, 1, Length(crLf));
    Log(logDebug,'Shader', Source);
    RaiseError(Name+'.'+PS+': ' + LogInfo);
    Result:=False;
  End Else
    Result:=True;
End;

Function OpenGLShader.LinkProgram: Boolean;
Var
  LinkStatus:Integer;
  LogInfo:TERRAString;
  LogLength,slen:Integer;
Begin
  Result := False;
  _Program := 0;
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

  // Create program
  _Program := glCreateProgram;
  glAttachShader(_Program, _VertexShaderHandle);
  glAttachShader(_Program, _FragmentShaderHandle);

  glLinkProgram(_Program);
  glGetProgramiv(_Program, GL_LINK_STATUS, @LinkStatus);
  glGetProgramiv(_Program, GL_INFO_LOG_LENGTH, @LogLength);
  If LogLength > 1 Then
  Begin
    SetLength(LogInfo, LogLength);
    glGetProgramInfoLog(_Program, LogLength, @slen, @LogInfo[1]);
  End Else
    LogInfo := '';

  _Linked := (LinkStatus=1);
  If Not _Linked Then
  Begin
    RaiseError('Shader Linking failed.['{+Name}+']'+StringFromChar(NewLineChar)+LogInfo);
    Exit;
  End;

  Result := True;
End;

Function OpenGLShader.GetAttributeHandle(const Name: TERRAString): Integer;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_AttributeCount) Do
  If (_Attributes[I].Name = Name) Then
  Begin
    Result := _Attributes[I].Handle;
    Exit;
  End;

//  Log(logError, 'Shader', 'Attribute '+Name+' not found in shader '+_Name);
  Result := -1;
End;

Function OpenGLShader.GetUniform(Name: TERRAString): Integer;
Begin
  Result := glGetUniformLocation(_Program, PAnsiChar(Name));
End;

Function OpenGLShader.HasUniform(const Name: TERRAString): Boolean;
Begin
  Result := GetUniform(Name)>=0;
End;

Procedure OpenGLShader.Invalidate;
Begin
  _VertexShaderHandle := 0;
  _FragmentShaderHandle := 0;
  _Program := 0;

  _AttributeCount := 0;
//  _Status := rsUnloaded;
  _Linked := False;
End;

Function OpenGLShader.IsReady: Boolean;
Begin
  Result := _Linked;
End;

Procedure OpenGLShader.UniformError(const Name: TERRAString);
Begin
  {$IFDEF PC}
//  Log(logWarning, 'Shader', 'Invalid uniform: '+Name+' in '+Self._Name);
  {$ENDIF}
End;


Procedure OpenGLShader.SetFloatUniform(const Name: TERRAString; const Value: Single);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := glGetUniformLocation(_Program, PAnsiChar(Name));
  If (ID>=0) Then
  Begin
	  glUniform1f(Id, Value);
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetIntegerUniform(const Name: TERRAString; const Value: Integer);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := glGetUniformLocation(_Program, PAnsiChar(Name));
  If (ID>=0) Then
  Begin
	  glUniform1i(Id, Value);
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetMat3Uniform(const Name: TERRAString; Value: Matrix3x3);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := GetUniform(Name);
  If (ID>=0) Then
  Begin
    glUniformMatrix3fv(Id, 1, False, @(Value.V[0]));
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetMat4Uniform(const Name: TERRAString; Value: Matrix4x4);
Var
  ID:Integer;
  IsModelMatrix:Boolean;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := GetUniform(Name);
  If (ID>=0) Then
  Begin
    If (GraphicsManager.Instance().RenderStage = renderStageReflection) Then
    Begin
      IsModelMatrix := False;

      If Length(Name) = 11 Then
      Begin
        IsModelMatrix := (UpCase(Name[1])='M') And (UpCase(Name[2])='O') And (UpCase(Name[3])='D') And (UpCase(Name[4])='E') And (UpCase(Name[5])='L')
           And (UpCase(Name[6])='M')  And (UpCase(Name[7])='A') And (UpCase(Name[8])='T');
      End;

      If IsModelMatrix Then
        Value := Matrix4x4Multiply4x3(GraphicsManager.Instance().ReflectionMatrix, Value);
    End; 
      

    glUniformMatrix4fv(Id, 1, False, @(Value.V[0]));
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetVec2Uniform(const Name: TERRAString; const Value: Vector2D);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := GetUniform(Name);
  If (ID>=0) Then
  Begin
	  glUniform2fv(Id, 1, @Value);
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetVec3Uniform(const Name: TERRAString; const Value: Vector3D);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := GetUniform(Name);
  If (ID>=0) Then
  Begin
	  glUniform3fv(Id, 1, @Value);
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetVec4Uniform(const Name: TERRAString; const Value:Vector4D);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := GetUniform(Name);
  If (ID>=0) Then
  Begin
	  glUniform4fv(Id, 1, @Value);
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.SetVec4ArrayUniform(const Name: TERRAString; Count:Integer; Values: PVector4D);
Var
  ID:Integer;
Begin
  If (Not _Owner.Features.Shaders.Avaliable) Then
    Exit;

	ID := GetUniform(Name);
  If (ID>=0) Then
  Begin
    glUniform4fv(Id, Count, Pointer(Values));
  End Else
    UniformError(Name);
End;

Procedure OpenGLShader.Unload;
Begin
  If (_Program>0) Then
  Begin
    If (_VertexShaderHandle>0) Then
    Begin
//      If (Self._Context = Application.Instance.ContextID) Then
      Begin
        glDetachShader(_Program, _VertexShaderHandle);
        glDeleteShader(_VertexShaderHandle);
      End;

      _VertexShaderHandle := 0;
    End;

    If (_FragmentShaderHandle>0) Then
    Begin
//      If (Self._ContextID = Application.Instance.ContextID) Then
      Begin
        glDetachShader(_Program, _FragmentShaderHandle);
        glDeleteShader(_FragmentShaderHandle);
      End;

      _FragmentShaderHandle := 0;
    End;

  //  If (Self._ContextID = Application.Instance.ContextID) Then
    Begin
      glDeleteProgram(_Program);
    End;

    _Program := 0;
  End;

  _AttributeCount := 0;
//  _Status := rsUnloaded;
  _Linked := False;
//	Result := True;
End;

{$IFDEF DEBUG_SHADERS}
Procedure SaveShader(Const Code, Name, Prefix:TERRAString);
Var
  FileName:TERRAString;
  Dest:Stream;
Begin
  FileName := 'Shaders'+PathSeparator + Name+'.'+Prefix+'.txt';

  //CreateDir('Debug');
  Dest := FileStream.Create(FileName);
  Dest.WriteLine(Code);
  ReleaseObject(Dest);
End;
{$ENDIF}

Function OpenGLShader.Generate(const Name: TERRAString; ShaderCode: TERRAString): Boolean;
Var
  I:Integer;

Function ReadBlock(Name:TERRAString):TERRAString;
Var
  S2:TERRAString;
  I:Integer;
  N:Integer;
Begin
  I := Pos(StringUpper(Name), StringUpper(ShaderCode));
  If (I>0) Then
  Begin
    S2 := Copy(ShaderCode, I +1, MaxInt);
    I := Pos('{', S2);
    S2 := Copy(S2, I+1, MaxInt);
    I := 1;
    N := 0;
    Repeat
      If (S2[I]='}') Then
      Begin
        If (N=0) Then
          Break
        Else
          Dec(N);
      End Else
      If (S2[I]='{') Then
        Inc(N);
      Inc(I);
    Until (I>=Length(S2));

    ShaderCode := Copy(S2, I + 1, MaxInt);
    S2 := Copy(S2, 1, I-1);
    Result := S2;
  End Else
    Result := '';

  Result := StringTrim(Result);
End;

Var
  Version:TERRAString;
Begin
  _Name := Name;
  Log(logDebug, 'Shader', 'Creating shader from string: '+ Name);

{  Version := Version + '#define ' + _Owner.Vendor + StringFromChar(NewLineChar);
  If (HasGLSL120) Then
    Version := Version + '#define MATRIX_CAST' + StringFromChar(NewLineChar);

  If (_Owner.Features.PostProcessing.Avaliable) Then
    Version := Version + '#define POSTPROCESSING' + StringFromChar(NewLineChar);

  If (_Owner.Settings.NormalMapping.Enabled) Then
    Version := Version + '#define NORMAL_MAPPING' + StringFromChar(NewLineChar);

{  If (_Owner.Features.FloatTexture.Avaliable) Then
    Version := Version + '#define FLOATBUFFERS' + StringFromChar(NewLineChar);

  If (_Owner.Settings.DepthOfField.Enabled) Then
    Version := Version + '#define DEPTHOFFIELD' + StringFromChar(NewLineChar);

  If (_Owner.Settings.ShadowSplitCount>1) Then
    Version := Version + '#define SHADOWSPLIT1' + StringFromChar(NewLineChar);
  If (_Owner.Settings.ShadowSplitCount>2) Then
    Version := Version + '#define SHADOWSPLIT2' + StringFromChar(NewLineChar);
  If (_Owner.Settings.ShadowSplitCount>3) Then
    Version := Version + '#define SHADOWSPLIT3' + StringFromChar(NewLineChar);}

  Version := ''; //'#version 120'+StringFromChar(NewLineChar);
	_VertexCode := Version + ReadBlock('vertex');
	_FragmentCode := Version + ReadBlock('fragment');

  _MRT := Pos('gl_FragData', _FragmentCode)>0;

//  Inherited Update();

  {$IFDEF DEBUG_SHADERS}
  If Application.Instance.DebuggerPresent Then
  Begin
    CreateDir('Shaders');
    SaveShader(_VertexCode, Name, 'vs');
    SaveShader(_FragmentCode, Name, 'fs');
  End;
  {$ENDIF}

  _AttributeCount := 0;
  If (_VertexCode ='') Or (_FragmentCode ='') Then
  Begin
    Result := False;
    Exit;
  End;

  Log(logDebug, 'Shader', 'Compiling vertex code for ' + Name);

  _Linked := False;
  Result := CompileShader(Name, _VertexCode, GL_VERTEX_SHADER, _VertexShaderHandle);
  If Not Result Then
    Exit;

  Log(logDebug, 'Shader', 'Compiling fragment code for ' + Name);

  Result := CompileShader(Name, _FragmentCode, GL_FRAGMENT_SHADER, _FragmentShaderHandle);
  If Not Result Then
    Exit;

  Log(logDebug, 'Shader', 'Linking ' + Name);
  Result := LinkProgram;
  Log(logDebug, 'Shader', 'Finished linking ' +Name+', result='+BoolToString(Result));

  Log(logDebug, 'Shader', 'Shader loaded ok!');
End;



End.
