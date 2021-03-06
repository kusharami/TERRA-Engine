{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores (relfos@gmail.com)
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_Texture
 * Implements a Texture resource
 ***********************************************************************************************************************
}
Unit TERRA_Texture;
{$I terra.inc}

Interface
Uses {$IFDEF USEDEBUGUNIT}TERRA_Debug,{$ENDIF}
  TERRA_String, TERRA_Image, TERRA_Stream, TERRA_Color, TERRA_Vector2D, TERRA_Math,
  TERRA_Resource, TERRA_ResourceManager, TERRA_Renderer;

{$IFDEF MOBILE}
{�-$DEFINE TEXTURES16BIT}
{$ENDIF}

{-$DEFINE KEEPCOPYONRAM}

Const
  MinTextureSize  = 2;

Type
  Texture = Class(Resource)
    Protected
      _Handles:Array Of SurfaceInterface;
      _FrameCount:Integer;

      _Width:Cardinal;
      _Height:Cardinal;

      _AnimationStart:Cardinal;

      _TargetFormat:TextureColorFormat;
      _ByteFormat:PixelSizeType;

      _Source:Image;
      _Ratio:Vector2D;

      _Dynamic:Boolean;

      _Managed:Boolean;

      _SizeInBytes:Cardinal;

      _CurrentFrame:Integer;

      _SettingsChanged:Boolean;
      _WrapMode:TextureWrapMode;
      _MipMapped:Boolean;
      _Filter:TextureFilterMode;

      Function GetCurrentFrame():Integer;
      Function GetCurrent:SurfaceInterface;

      Procedure AdjustRatio(Source:Image);

      Function IsNPOT():Boolean;

      Function DetectBestFormat(Source:Pointer; SourceFormat:TextureColorFormat):TextureColorFormat;
      Function ConvertToFormat(Source:Pointer; SourceFormat, TargetFormat:TextureColorFormat):Pointer;

      Procedure ApplySettings(Slot:Integer);

      Function GetOrigin: SurfaceOrigin;

    Public
      Uncompressed:Boolean;
      PreserveQuality:Boolean;

      Constructor Create();

      Procedure CreateFromSize(Const Name:TERRAString; TextureWidth, TextureHeight:Cardinal);
      Procedure CreateFromImage(Const Name:TERRAString; Source:Image);
      Procedure CreateFromSurface(Surface:SurfaceInterface);
      Procedure CreateFromLocation(Const Location:TERRAString);

      Procedure Build(); Virtual;

      Function Load(Source:Stream):Boolean; Override;
      Function Unload:Boolean; Override;
      Function Update:Boolean; Override;
      Class Function GetManager:Pointer; Override;

      Class Function RAM:Cardinal;

      Procedure Bind(Slot:Integer); 

      Procedure UpdateRect(Source:Image; X,Y:Integer); Overload;
      Procedure UpdateRect(Source:Image); Overload;

      Procedure SetWrapMode(Value:TextureWrapMode);
      Procedure SetMipMapping(Value:Boolean);
      Procedure SetFilter(Value:TextureFilterMode);

	    Procedure Save(Const FileName:TERRAString);

      Function GetImage():Image;
      Function GetPixel(X,Y:Integer):Color; Virtual;


      //Property Format:Cardinal Read _Format;

      Property Width:Cardinal Read _Width;
      Property Height:Cardinal Read _Height;
      Property Ratio:Vector2D Read _Ratio;

      Property WrapMode:TextureWrapMode Read _WrapMode Write SetWrapMode;
      Property MipMapped:Boolean Read _MipMapped Write SetMipMapping;
      Property Filter:TextureFilterMode Read _Filter Write SetFilter;

      Property Origin: SurfaceOrigin Read GetOrigin;

      Property SizeInBytes:Cardinal Read _SizeInBytes;

      Property Current:SurfaceInterface Read GetCurrent;
  End;

  TextureClass = Class Of Texture;
  TextureFormat = Record
    Extension:TERRAString;
    ClassType:TextureClass;
  End;

  TextureManager = Class(ResourceManager)
    Protected
      _DefaultColorTable:Texture;
      _DefaultNormalMap:Texture;

      _WhiteTexture:Texture;
      _BlackTexture:Texture;
      _NullTexture:Texture;

      Function GetDefaultNormalMap:Texture;
      Function GetDefaultColorTable:Texture;

      Function CreateTextureWithColor(Name:TERRAString; TexColor:Color):Texture;
      Procedure FillTextureWithColor(Tex:Texture; TexColor:Color);

      Function GetWhiteTexture:Texture;
      Function GetNullTexture:Texture;
      Function GetBlackTexture:Texture;


    Public
      Procedure OnContextLost; Override;

      Class Function Instance:TextureManager;
      Function GetTexture(Name:TERRAString):Texture;

      Procedure Release; Override;

      Property NullTexture:Texture Read GetNullTexture;
      Property WhiteTexture:Texture Read GetWhiteTexture;
      Property BlackTexture:Texture Read GetBlackTexture;

      Property DefaultColorTable:Texture Read GetDefaultColorTable;
      Property DefaultNormalMap:Texture Read GetDefaultNormalMap;

      Property Textures[Name:TERRAString]:Texture Read GetTexture; Default;
  End;

  DefaultColorTableTexture = Class(Texture)
    Public
      Procedure Build(); Override;
  End;

Var
  _TextureFormatList:Array Of TextureFormat;
  _TextureFormatCount:Integer = 0;
  _TextureMemory:Cardinal;

Procedure RegisterTextureFormat(ClassType:TextureClass; Extension:TERRAString);

Implementation
Uses TERRA_Error, TERRA_Utils, TERRA_Application, TERRA_Log, TERRA_GraphicsManager, TERRA_OS,
  TERRA_FileUtils, TERRA_FileStream, TERRA_FileManager, TERRA_ColorGrading;

Var
  _TextureManager:ApplicationObject = Nil;

Procedure RegisterTextureFormat(ClassType:TextureClass; Extension:TERRAString);
Begin
  Inc(_TextureFormatCount);
  SetLength(_TextureFormatList, _TextureFormatCount);
  _TextureFormatList[Pred(_TextureFormatCount)].Extension := Extension;
  _TextureFormatList[Pred(_TextureFormatCount)].ClassType := ClassType;
End;
  
Class Function TextureManager.Instance:TextureManager;
Begin
  If _TextureManager = Nil Then
    _TextureManager := InitializeApplicationComponent(TextureManager, GraphicsManager);
    
  Result := TextureManager(_TextureManager.Instance);
End;

Function TextureManager.GetTexture(Name:TERRAString):Texture;
Var
  I:Integer;
Var
  S:TERRAString;
  TextureFormat:TextureClass;
  Info:ImageClassInfo;
Begin
  Result := Nil;

  Name := StringTrim(Name);
  Name := GetFileName(Name, True);
  If (Name='') Then
    Exit;

  Result := Texture(GetResource(Name));
  If Not Assigned(Result) Then
  Begin
    S := '';
    TextureFormat := Nil;

    I := 0;
    While (S='') And (I<_TextureFormatCount) Do
    Begin
      S := FileManager.Instance.SearchResourceFile(Name+'.'+_TextureFormatList[I].Extension);
      If S<>'' Then
      Begin
        TextureFormat := _TextureFormatList[I].ClassType;
        Break;
      End;
      Inc(I);
    End;

    I := 0;
    {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Searching for file with extension for '+Name);{$ENDIF}
    While (S='') And (I<GetImageExtensionCount()) Do
    Begin
      Info := GetImageExtension(I);
      S := FileManager.Instance.SearchResourceFile(Name+'.'+Info.Name);
      Inc(I);
    End;

    If S<>'' Then
    Begin
      {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Found '+S+'...');{$ENDIF}

      If Assigned(TextureFormat) Then
        Result := TextureFormat.Create()
      Else
        Result := Texture.Create();

      Result.CreateFromLocation(S);

      {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Texture class instantiated sucessfully!');{$ENDIF}

      If (Pos('_',S)>0) Then
        Result.Priority := 30
      Else
        Result.Priority := 50;

      {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Texture loading priority set!');{$ENDIF}

      {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Texture settings set!');{$ENDIF}

      Self.AddResource(Result);

      {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Texture added to manager!');{$ENDIF}
    End Else
    Begin
      S := Self.ResolveResourceLink(Name);
      If S<>'' Then
      Begin
        Result := Self.GetTexture(S);
        If Assigned(Result) Then
          Exit;
      End;

      {If ValidateError Then
        RaiseError('Could not find texture. ['+Name+']');}
    End;
  End;
End;

Function TextureManager.CreateTextureWithColor(Name:TERRAString; TexColor:Color):Texture;
Begin
  Result := Texture.Create();
  Result.CreateFromSize(Name, 64, 64);
  Result.Uncompressed := True;
  Result.MipMapped := False;
  Result.Filter := filterLinear;
  Result.Update();
  Self.FillTextureWithColor(Result, TexColor);
End;

Procedure TextureManager.FillTextureWithColor(Tex: Texture; TexColor: Color);
Var
  Buffer:Image;
Begin
  If (Tex = Nil) Then
    Exit;

  Buffer := Image.Create(Tex.Width, Tex.Height);
  Buffer.FillRectangleByUV(0,0,1,1, TexColor);
  Tex.UpdateRect(Buffer, 0, 0);
  Buffer.Release();
End;

Function TextureManager.GetBlackTexture: Texture;
Begin
  If (Not Assigned(_BlackTexture)) Then
    _BlackTexture := Self.CreateTextureWithColor('default_black', ColorBlack)
  Else
  If (_BlackTexture.Status <> rsReady) Then
  Begin
    _BlackTexture.Update();
    FillTextureWithColor(_BlackTexture, ColorBlack);
  End;

  Result := _BlackTexture;
End;

Function TextureManager.GetWhiteTexture: Texture;
Begin
  If (Not Assigned(_WhiteTexture)) Then
    _WhiteTexture := Self.CreateTextureWithColor('default_white', ColorWhite)
  Else
  If (_WhiteTexture.Status <> rsReady) Then
  Begin
    _WhiteTexture.Update();
    FillTextureWithColor(_WhiteTexture, ColorWhite);
  End;

  Result := _WhiteTexture;
End;

Function TextureManager.GetNullTexture: Texture;
Begin
  If (Not Assigned(_NullTexture)) Then
    _NullTexture := Self.CreateTextureWithColor('default_null', ColorNull)
  Else
  If (_NullTexture.Status <> rsReady) Then
  Begin
    _NullTexture.Update();
    FillTextureWithColor(_NullTexture, ColorNull);
  End;

  Result := _NullTexture;
End;

Function GetDefaultNormalColor():Color;
Begin
  Result := ColorCreate(128,128,255);
End;

Function TextureManager.GetDefaultNormalMap:Texture;
Begin
  If (Not Assigned(_DefaultNormalMap)) Then
    _DefaultNormalMap := Self.CreateTextureWithColor('default_normal', GetDefaultNormalColor())
  Else
  If (_DefaultNormalMap.Status <> rsReady) Then
  Begin
    _DefaultNormalMap.Update();
    FillTextureWithColor(_DefaultNormalMap, GetDefaultNormalColor());
  End;

  Result := _DefaultNormalMap;
End;

{Function MyTest(P:Color):Color; CDecl;
Var
  V:ColorHSL;
Begin
  Result :=P; Exit;

   V := ColorRGBToHSL(P);
   V.H := 140;
   Result := ColorHSLToRGB(V);
   Result := ColorGreen;
End;}

Function TextureManager.GetDefaultColorTable:Texture;
Begin
  If (Not Assigned(_DefaultColorTable)) Then
  Begin
    _DefaultColorTable := DefaultColorTableTexture.Create();
    _DefaultColorTable.CreateFromSize('default_colortable', 1024, 32);
  End;

  Result := _DefaultColorTable;
End;

Procedure TextureManager.Release;
begin
  If Assigned(_WhiteTexture) Then
    _WhiteTexture.Release;

  If Assigned(_BlackTexture) Then
    _BlackTexture.Release();

  If Assigned(_NullTexture) Then
    _NullTexture.Release();

  If Assigned(_DefaultColorTable) Then
    _DefaultColorTable.Release();

  If (Assigned(_DefaultNormalMap)) Then
    _DefaultNormalMap.Release;

  Inherited;

  _TextureManager := Nil;
End;

{ Texture }
Class Function Texture.RAM:Cardinal;
Begin
  Result := _TextureMemory;
End;

Constructor Texture.Create();
Begin
  _TargetFormat := colorRGBA;
  _ByteFormat := pixelSizeByte;
  _Ratio := VectorCreate2D(1, 1);
  _Key := Name;

  _SettingsChanged := True;
  _WrapMode := wrapAll;
  _MipMapped := GraphicsManager.Instance.Renderer.Features.Shaders.Avaliable;
  _Filter := filterBilinear;

  _Managed := False;
End;

Procedure Texture.CreateFromLocation(const Location: TERRAString);
Begin
  Inherited Create(Location);
End;

Procedure Texture.CreateFromSurface(Surface: SurfaceInterface);
Begin
  _Key := '';

  If (Surface = Nil) Then
  Begin
    Self.CreateFromSize(CardinalToString(Application.GetTime()), 128, 128);
    Exit;
  End;

  _Width := Surface.Width;
  _Height := Surface.Height;

  _FrameCount := 1;

  SetLength(_Handles, _FrameCount);
  _Handles[0] := Surface;

  _Dynamic := True;
  Uncompressed := False;

  If (Self._Location='') Then
    Self._Status := rsReady;

  _SettingsChanged := True;

  Self._ContextID := Application.Instance.ContextID; // FIXME
  _Managed := True;
End;

Procedure Texture.CreateFromSize(Const Name:TERRAString; TextureWidth, TextureHeight:Cardinal);
Begin
  _Key := Name;
  _Location := '';

  _Width := TextureWidth;
  _Height := TextureHeight;


  If (Not GraphicsManager.Instance.Renderer.Features.NPOT.Avaliable) Then
  Begin
    _Width := IntMax(NearestPowerOfTwo(_Width), MinTextureSize);
    _Height := IntMax(NearestPowerOfTwo(_Height), MinTextureSize);

    If GraphicsManager.Instance.Renderer.Features.MaxTextureSize>0 Then
    Begin
      _Width := IntMin(_Width, GraphicsManager.Instance.Renderer.Features.MaxTextureSize);
      _Height := IntMin(_Height, GraphicsManager.Instance.Renderer.Features.MaxTextureSize);
    End;

    _Ratio := VectorCreate2D(_Width/TextureWidth, _Height/TextureHeight);
  End;

  _Source := Image.Create(_Width, _Height);
  _Source.Process(IMP_FillColor, ColorWhite);

  _Dynamic := True;
  Uncompressed := False;
End;

Procedure Texture.CreateFromImage(Const Name:TERRAString; Source:Image);
Begin
  If (Source = Nil) Then
    Self.CreateFromSize(Name, 128, 128)
  Else
  Begin
    AdjustRatio(Source);
    Self.CreateFromSize(Name, Source.Width, Source.Height);
    Self.Update();
    Self.UpdateRect(Source);
  End;
End;

Function Texture.Load(Source: Stream):Boolean;
Var
  Ofs:Cardinal;
Begin
  _Dynamic := False;
  Uncompressed := False;
  Ofs := Source.Position;
  _Source := Image.Create(Source);

  AdjustRatio(_Source);

  _Width := _Source.Width;
  _Height := _Source.Height;

  If (StringContains('_normal', Source.Name)) Then
    Uncompressed := True;

  _TargetFormat := colorRGBA;
  _ByteFormat := pixelSizeByte;

  Result := True;
End;

Function Texture.Unload:Boolean;
Var
	MemCount:Integer;
  I,S:Integer;
Begin
  If (Length(_Handles)>0) And (Not _Managed) Then
  Begin
  	MemCount := _Size * _FrameCount;
  	If (_TextureMemory>=MemCount) Then
	    Dec(_TextureMemory, MemCount);

    For I:=0 To Pred(_FrameCount) Do
    If (Application.Instance<>Nil) And (Self._ContextID = Application.Instance.ContextID)
    And (Assigned(_Handles[I])) Then
      ReleaseObject(_Handles[I]);

    _Handles := Nil;
    _FrameCount := 0;
  End;

  If (Assigned(_Source)) Then
  Begin
    _Source.Release();
	  _Source := Nil;
	End;

  _Status := rsUnloaded;
  Result := True;
End;

{$DEFINE FORCERGBA}
{$IFDEF IPHONE}
{$DEFINE FORCERGBA}
{$ENDIF}
{$IFDEF LINUX}
{$DEFINE FORCERGBA}
{$ENDIF}

Function Texture.Update:Boolean;
Var
  W,H,I, J, S:Cardinal;
  Pixels:PWord;
  SourceFormat:TextureColorFormat;
  Tex:TextureInterface;
Begin
  Inherited Update();

  Result := False;

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Allocating pixels');{$ENDIF}
  If (Not Assigned(_Source)) Then
  Begin
    {_Source := Image.Create(_Width, _Height);
    _Source.Process(IMP_FillColor, ColorWhite);}
    Exit;
  End;

  _FrameCount := _Source.FrameCount;

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Generating texture');{$ENDIF}
  If (Length(_Handles)<=0) Then
    SetLength(_Handles, _FrameCount);

  _CurrentFrame := 0;

  SourceFormat := colorRGBA;
  _TargetFormat := DetectBestFormat(_Source, SourceFormat);
  Pixels := ConvertToFormat(_Source.Pixels, SourceFormat, _TargetFormat);

  _Size := 0;
  For I:=0 To Pred(_FrameCount) Do
  Begin
    ReleaseObject(_Handles[I]);

    If (_FrameCount>0) Then
    Begin
      _Source.SetCurrentFrame(I);
      Pixels := PWord(_Source.Pixels);
    End;

    Tex := GraphicsManager.Instance.Renderer.CreateTexture();
    Tex.Generate(Pixels, _Source.Width, _Source.Height, SourceFormat, _TargetFormat, _ByteFormat);

    _Handles[I] := Tex;
    Inc(_Size, _Handles[I].Size);
  End;


  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Freeing pixels');{$ENDIF}

  {$IFNDEF KEEPCOPYONRAM}
  _Source.Release();
  _Source := Nil;
  {$ENDIF}

  If (Self._Location='') Then
    Self._Status := rsReady;

  Inc(_TextureMemory, _Size * _FrameCount);

  Result := True;

  Self.Build();

  _AnimationStart := Application.GetTime();
  _CurrentFrame := 0;

  _SettingsChanged := True;
End;

Procedure Texture.Build;
Begin
// do nothing
End;

Var
  _TextureSlots:Array[0..7] Of Texture;

Procedure Texture.Bind(Slot:Integer);
Begin
  If (Self = Nil) Or (Not Self.IsReady()) Then
  Begin
    //glBindTexture(GL_TEXTURE_2D, 0);
    Exit;
  End;

{  If (_TextureSlots[Slot] = MyTexture) Then
    Exit;

  _TextureSlots[Slot] := MyTexture;}

  _CurrentFrame := GetCurrentFrame();
  GraphicsManager.Instance.Renderer.BindSurface(Self.Current, Slot);

  If (_SettingsChanged) Then
  Begin
  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'Texture', 'Applying texture settings');{$ENDIF}
    _SettingsChanged := False;
    Self.ApplySettings(Slot);
  End;
End;

Procedure Texture.UpdateRect(Source:Image; X,Y:Integer);
Var
  Pixels:PWord;
  SourceFormat:TextureColorFormat;
Begin
  If Length(_Handles)<=0 Then
  Begin
    If (Self.Width = Source.Width) And (Self.Height = Source.Height) Then
    Begin
      If (_Source <> Nil) Then
        _Source.Release();

      _Source := Image.Create(Source);
    End Else
    If (Assigned(_Source)) Then
      _Source.Blit(X,Y, 0, 0, Source.Width, Source.Height, Source);

    Exit;
  End;

  SourceFormat := colorRGBA;
  Pixels := Self.ConvertToFormat(Source.Pixels, SourceFormat, _TargetFormat);

  If Self.Current Is TextureInterface Then
    TextureInterface(Self.Current).Update(Pixels, X, Y, Source.Width, Source.Height)
  Else
    RaiseError('Trying to update something that is not a TextureInterface!');
End;

Procedure Texture.UpdateRect(Source:Image);
Begin
  If (Self.Width<>Source.Width) Or (Self.Height <> Source.Height) Then
  Begin
    RaiseError('Invalid texture dimensions: '+IntToString(Self.Width)+' x' + IntToString(Self.Height));
    Exit;
  End;

  Self.UpdateRect(Source, 0, 0);
End;



Class Function Texture.GetManager: Pointer;
Begin
  Result := TextureManager.Instance;
End;

Procedure TextureManager.OnContextLost;
Begin
  Inherited;

  If Assigned(_WhiteTexture) Then
    _WhiteTexture.Unload();

  If Assigned(_BlackTexture) Then
    _BlackTexture.Unload();

  If Assigned(_NullTexture) Then
    _NullTexture.Unload();

  If Assigned(_DefaultNormalMap) Then
    _DefaultNormalMap.Unload();

  If Assigned(_DefaultColorTable) Then
    _DefaultColorTable.Unload();
End;

{ DefaultColorTable }
Procedure DefaultColorTableTexture.Build;
Var
  Temp:Image;
Begin
  Temp := CreateColorTable(32);
  Self.UpdateRect(Temp);
  Temp.Release;

  Self.MipMapped := False;
  Self.WrapMode := wrapNothing;
End;

Function Texture.GetCurrentFrame: Integer;
Var
  Delta:Single;
Begin
  If (_FrameCount<=1) Then
    Result := 0
  Else
  Begin
    Delta := (Application.GetTime - _AnimationStart);
    Delta := Delta / 1000;
    If (Delta>1) Then
      Delta := Frac(Delta);

    Result := Trunc(Delta * Pred(_FrameCount));
  End;
End;


Procedure Texture.AdjustRatio(Source:Image);
Var
  W,H:Cardinal;
Begin
  If Source = Nil Then
    Exit;

  If (Not GraphicsManager.Instance.Renderer.Features.NPOT.Avaliable) Then
  Begin
    W := IntMax(NearestPowerOfTwo(Source.Width), MinTextureSize);
    H := IntMax(NearestPowerOfTwo(Source.Height), MinTextureSize);

    If GraphicsManager.Instance.Renderer.Features.MaxTextureSize>0 Then
    Begin
      W := IntMin(W, GraphicsManager.Instance.Renderer.Features.MaxTextureSize);
      H := IntMin(H, GraphicsManager.Instance.Renderer.Features.MaxTextureSize);
    End;

    _Ratio := VectorCreate2D(W/Source.Width, H/Source.Height);

    If (W<>Source.Width) Or (H<>Source.Height) Then
      Log(logDebug, 'Texture', self.Name+ ' needs resizing: '+IntToString(W) +' ' +IntToString(H));

    Source.Resize(W,H);
  End Else
  Begin
    _Ratio := VectorCreate2D(1, 1);
  End;
End;

Var
  Scratch16:Array Of Word;

Function Texture.ConvertToFormat(Source:Pointer; SourceFormat, TargetFormat:TextureColorFormat):Pointer;
Begin
  Result := Source;
End;

Function Texture.DetectBestFormat(Source:Pointer; SourceFormat:TextureColorFormat):TextureColorFormat;
Begin
  Result := SourceFormat;
End;

(*
Procedure Texture.ConvertToFormat(Source:Image; Var Pixels:PWord);
Var
  HasMask:Boolean;
  HasAlpha:Boolean;
  Alpha:Byte;
  C:Color;
  P:PColor;
  OP:PWord;
  X, I, Count:Integer;
Begin
  If (_SourceFormat <=0) Then
  Begin
    _ByteFormat := GL_UNSIGNED_BYTE;
    _SourceFormat := GL_RGBA;
    _TargetFormat := GL_RGBA8;
  End;

  Source.SetCurrentFrame(0);
  Pixels := PWord(Source.Pixels);

  If (_Dynamic) Or (Not GraphicsManager.Instance.Settings.Shaders.Avaliable) Or (PreserveQuality) Or (_FrameCount>1) Then
    Exit;

  {$IFDEF PC}
    {$IFNDEF FORCERGBA}
    If (GraphicsManager.Instance.Settings.TextureCompression.Avaliable) And (Not Uncompressed) Then
      _TargetFormat := GL_COMPRESSED_RGBA;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF TEXTURES16BIT}
  If (Odd(_Width)) Or (Not GraphicsManager.Instance.Settings.TextureCompression.Enabled) Then
    Exit;

  HasMask := False;
  HasAlpha := False;

{    If (_Name='SPRITE320') Then
      IntToString(2);}

  
  I := 0;
  Count := Source.Width * Source.Height;
  P := Source.Pixels;

  While (I<Count) Do
  Begin
    Alpha := P.A;

    If (Alpha=0) Then
      HasMask := True
    Else
    If (Alpha<255) Then
    Begin
      HasAlpha := True;
      Break;
    End;

    Inc(P);
    Inc(I);
  End;

  If Length(Scratch16)<Count Then
    SetLength(Scratch16, Count);

  Pixels := @Scratch16[0];
  OP := PWord(Pixels);
  P := Source.Pixels;
  I := 0;
  X := 0;

  If (HasAlpha) Then
  Begin
    Log(logDebug, 'Texture', 'Converting '+_Name+' to RGBA4444');
    While (I<Count) Do
    Begin
      C := P^;

      C.R := C.R Shr 4;
      C.G := C.G Shr 4;
      C.B := C.B Shr 4;
      C.A := C.A Shr 4;

      OP^ := C.A + (C.B Shl 4) + (C.G Shl 8) + (C.R Shl 12);

      Inc(P);
      Inc(OP);
      Inc(I);
    End;

    _TargetFormat := GL_RGBA;
    _ByteFormat := GL_UNSIGNED_SHORT_4_4_4_4;
  End Else
  If (HasMask) Then
  Begin
    Log(logDebug, 'Texture', 'Converting '+_Name+' to RGBA5551');
    While (I<Count) Do
    Begin
      C := P^;

      C.R := C.R Shr 3;
      C.G := C.G Shr 3;
      C.B := C.B Shr 3;
      C.A := C.A Shr 7;

      OP^ := C.A + (C.B Shl 1) + (C.G Shl 6) + (C.R Shl 11);

      Inc(P);
      Inc(OP);
      Inc(I);
    End;

    _TargetFormat := GL_RGBA;
    _ByteFormat := GL_UNSIGNED_SHORT_5_5_5_1;
  End Else
  Begin
    Log(logDebug, 'Texture', 'Converting '+_Name+' to RGB565');
    While (I<Count) Do
    Begin
      C := P^;

      C.R := C.R Shr 3;
      C.G := C.G Shr 2;
      C.B := C.B Shr 3;

      OP^ := C.B + ((C.G Shl 5) + (C.R Shl 11));

      Inc(P);
      Inc(OP);
      Inc(I);
    End;

    _TargetFormat := GL_RGB;
    _ByteFormat := GL_UNSIGNED_SHORT_5_6_5;
  End;

  _SourceFormat := _TargetFormat;
  {$ENDIF}
End;*)


{Function Texture.GetHandle(Frame:Integer): Cardinal;
Begin
  If (Frame<0) Or (Frame>=_FrameCount) Then
    Frame := _CurrentFrame;

  Result := _Handles[Frame];
End;}

Procedure Texture.SetFilter(Value: TextureFilterMode);
Begin
  Self._Filter := Value;
  Self._SettingsChanged := True;
End;

Procedure Texture.SetMipMapping(Value: Boolean);
Begin
  Self._MipMapped := Value;
  Self._SettingsChanged := True;
End;

Procedure Texture.SetWrapMode(Value: TextureWrapMode);
Begin
  Self._WrapMode := Value;
  Self._SettingsChanged := True;
End;

Function Texture.GetCurrent:SurfaceInterface;
Begin
  If (_CurrentFrame>=_FrameCount) Then
    Result := Nil
  Else
    Result := _Handles[_CurrentFrame];
End;

Procedure Texture.ApplySettings(Slot: Integer);
Begin
  {$IFDEF MOBILE}
  If (IsNPOT()) Then
  Begin
    Filter := filterLinear;
    MipMapped := False;
    WrapMode := wrapNothing;
  End;
  {$ENDIF}

  Self.Current.WrapMode := Self.WrapMode;
  Self.Current.MipMapped := Self.MipMapped;
  Self.Current.Filter := Self.Filter;
End;

Procedure Texture.Save(const FileName: TERRAString);
Var
  Img:Image;
Begin
  Img := Self.GetImage();
  If Assigned(Img) Then
  Begin
    Img.Save(FileName);
    ReleaseObject(Img);
  End;
End;

Function Texture.IsNPOT: Boolean;
Var
  W, H:Cardinal;
Begin
  W := NearestPowerOfTwo(Self.Width);
  H := NearestPowerOfTwo(Self.Height);

  Result := (W<>Self.Width) Or (H<>Self.Height);
End;

Function Texture.GetImage: Image;
Begin
  Result := Self.Current.GetImage();
End;

Function Texture.GetPixel(X, Y: Integer): Color;
Begin
  Result := Self.Current.GetPixel(X, Y);
End;

Function Texture.GetOrigin: SurfaceOrigin;
Begin
  Result := Self.Current.Origin;
End;

End.
