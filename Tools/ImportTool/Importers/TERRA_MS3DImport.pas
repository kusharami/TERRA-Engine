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
 * TERRA_MS3DImporter
 * Implements Milkshape model importer
 ***********************************************************************************************************************
}
Unit TERRA_MS3DImport;

{$I terra.inc}
Interface
Uses TERRA_Application, TERRA_MS3D, TERRA_MeshAnimation, TERRA_Utils, TERRA_OS;

implementation

Uses TERRA_Mesh, TERRA_INI, TERRA_IO, TERRA_Matrix, TERRA_ResourceManager,
  TERRA_Vector3D, TERRA_Vector2D, TERRA_Math, TERRA_Color, TERRA_Log, TERRA_Lights,
  SysUtils, TERRA_MeshFilter, TERRA_FileImport, TERRA_FileIO,
  TERRA_FileUtils, TERRA_Texture, TERRA_FileManager, TERRA_GraphicsManager;

Const
  MaxMorphs = 256;

Var
  MS3D:Milkshape3DObject;
  MS3D2:Milkshape3DObject;
  Morphs:Array[0..Pred(MaxMorphs)] Of Milkshape3DObject;

  I,J,K,MM:Integer;
  W,Z,ZZ,N:Integer;
  S,S2,Params:AnsiString;
  VP:MeshVertex;
  Mirror,Cull,Shadows,Pick,Collision,Vegetation,SphereMap:Boolean;
  Parser:INIParser;
  AlphaTest:Boolean;
  ETyp:AnsiString;
  LightBone:AnsiString;

  P:Vector3D;
  V:PMeshVertex;

  PScale:Single;
  StartFrame,EndFrame,LoopFrame:Integer;
  LoopAnimation:Boolean;
  ActionName,NextAction:AnsiString;
  ActionList:Array Of AnsiString;
  BaseTime, MaxTime:Single;
  K1,K2:Integer;

  BonesParent:Array Of AnsiString;
  Bone:MeshBone;

//  BA:PMeshBoneAnimation;
  Transparency:Boolean;
  Link:Boolean;
  OverrideMaterial:Boolean;

  LightJoints:Array Of Milkshape3DJoint;
  LightJointCount:Integer;

  PinJoints:Array Of Milkshape3DJoint;
  PinJointCount:Integer;

  EmitterJoints:Array Of Milkshape3DJoint;
  EmitterJointCount:Integer;

  OfsX:Single;
  OfsY:Single;
  OfsZ:Single;
  ASpeed, KSpeed:Single;

  DiffuseInVertex:Boolean;


Procedure CopyFile(SourceFile,DestFile:AnsiString);
Var
  Source,Dest:Stream;
Begin
  Source := MemoryStream.Create(SourceFile);
  Dest := FileStream.Create(DestFile);
  Source.Copy(Dest);
  Source.Destroy;
  Dest.Destroy;
End;

Function FindMorphGroup(MorphIndex:Integer; Name:String):Integer;
Var
  I:Integer;
  S:String;
Begin
  Name := UpStr(Name);
  If (MorphIndex>=0) And (MorphIndex<MaxMorphs) Then
  For I:=0 To Pred(Morphs[MorphIndex].NumGroups) Do
  Begin
    S := Morphs[MorphIndex].Groups[I].Name;
		S := StrClean(S);

    If (UpStr(S)=Name) Then
    Begin
      Result := I;
      Exit;
    End;
  End;

  Result := -1;
End;

Procedure ImportAnimation(Const MS3D:Milkshape3DObject; Skeleton:MeshSkeleton; TargetDir, Prefix:AnsiString);
Var
  I, J, K, PK:Integer;
  Parser:INIParser;
  MyStream:Stream;
  Dest:Stream;
  Anim:Animation;
  Speed:Single;
  StartFrame, EndFrame, LoopFrame:Integer;
  ActionName, NextAction, S:AnsiString;
  LoopAnimation:Boolean;
  BaseTime, Z:Single;
  TargetName:AnsiString;
  ActionList:Array Of AnsiString;
  Bone:BoneAnimation;
  MaxTime:Single;
Begin
    MyStream := MemoryStream.Create(Length(MS3D.Comment), @(MS3D.Comment[1]));
    Parser := INIParser.Create;
    Parser.ParseCommas:=True;
    Parser.AddToken('Start',tkInteger,@StartFrame);
    Parser.AddToken('End',tkInteger,@EndFrame);
    Parser.AddToken('LoopFrame',tkInteger,@LoopFrame);
    Parser.AddToken('Loop',tkBoolean,@LoopAnimation);
    Parser.AddToken('Name',tkString,@ActionName);
    Parser.AddToken('Next',tkString,@NextAction);
    Parser.AddToken('Speed',tkFloat,@Speed);

    While Not MyStream.EOF Do
    Begin
      MyStream.ReadLine(S);
      If S='' Then
        Continue;

      StartFrame:=0;
      EndFrame:=0;
      Speed := 1.0;
      LoopAnimation := False;
      LoopFrame:=0;
      ActionName:='untitled_animation';
      NextAction:='';
      Parser.LoadFromString(S);

      If EndFrame=0 Then
        EndFrame:=StartFrame;

      If LoopFrame=0 Then
        LoopFrame:=StartFrame;

      TargetName := lowStr(Prefix+'_'+ActionName);
      Anim := Animation.Create(TargetName);
      WriteLn('Importing animation: ', TargetName);
      Anim.FPS := MS3D.AnimationFPS;

      BaseTime := StartFrame/Anim.FPS;
      Anim.Loop := LoopAnimation;
      Anim.LoopPoint := SafeDiv(LoopFrame - StartFrame, EndFrame-StartFrame);
      Anim.Next := NextAction;
      Anim.Speed := 1.0;

      KSpeed := (ASpeed*Speed);

      For J:=0 To Pred(MS3D.NumJoints) Do
      Begin
        Bone := Anim.AddBone(Skeleton.GetBone(J).Name);

        Bone.Positions.Count := 0;
        For K:=0 To Pred(MS3D.Joints[J].NumKeyFramesTrans) Do
        Begin
          Z := Trunc(MS3D.Joints[J].KeyFramesTrans[K].Time * Anim.FPS);
          If (Z>=StartFrame) And (Z<=EndFrame) Then
            Bone.Positions.AddKey(((MS3D.Joints[J].KeyFramesTrans[K].Time - BaseTime)/KSpeed), MS3D.Joints[J].KeyFramesTrans[K].Vector);
        End;

        Bone.Rotations.Count := 0;
        For K:=0 To Pred(MS3D.Joints[J].NumKeyFramesRot) Do
        Begin
          Z := Trunc(MS3D.Joints[J].KeyFramesRot[K].Time * Anim.FPS);
          If (Z>=StartFrame) And (Z<=EndFrame) Then
            Bone.Rotations.AddKey((MS3D.Joints[J].KeyFramesRot[K].Time - BaseTime)/KSpeed, MS3D.Joints[J].KeyFramesRot[K].Vector);
        End;

{        If (Anim.Loop) Then
        Begin
          If (Bone.Positions.Count<=0) Or (Bone.Positions.Keyframes[0].Time>0.0) Then
          Begin
            PK := -1;
            For K:=0 To Pred(MS3D.Joints[J].NumKeyFramesTrans) Do
            Begin
              Z := Trunc(MS3D.Joints[J].KeyFramesTrans[K].Time * Anim.FPS);
              If (Z<StartFrame)  Then
                PK := K;
            End;

            If (PK>=0) Then
              Bone.Positions.AddKey(((MS3D.Joints[J].KeyFramesTrans[PK].Time - BaseTime)/KSpeed), MS3D.Joints[J].KeyFramesTrans[PK].Vector);
          End;


          If (Bone.Rotations.Count<=0) Or (Bone.Rotations.Keyframes[0].Time>0.0) Then
          Begin
            PK := -1;
            For K:=0 To Pred(MS3D.Joints[J].NumKeyFramesRot) Do
            Begin
              Z := Round(MS3D.Joints[J].KeyFramesRot[K].Time * Anim.FPS);
              If (Z<StartFrame)  Then
                PK := K;
            End;

            If (PK>=0) Then
            Bone.Rotations.AddKey(((MS3D.Joints[J].KeyFramesRot[PK].Time - BaseTime)/KSpeed), MS3D.Joints[J].KeyFramesRot[PK].Vector);
          End;
        End;  }
        
        Bone.Scales.Count := 0;
      End;

      Anim.Save(TargetDir + PathSeparator + TargetName+'.anim');
      Anim.Destroy;
    End;
    MyStream.Destroy;
    Parser.Destroy;
End;

Function MS3DImporter(SourceFile, TargetDir:AnsiString; TargetPlatform:Integer; Settings:AnsiString):AnsiString;
Var
  Source, Dest, MyStream:Stream;
  Max:Integer;

  Diffuse,Specular:Color;
  Emission:Single;
  Mode:Byte;

  S, Name:AnsiString;

  IsCloth:Boolean;
  FurPattern:AnsiString;
  FurWaviness,FurThickness, FurLength, FurDensity:Single;
  SecondaryTexture, MeshEmitter:AnsiString;

  Dist,Min, Sgn:Single;
  PA,PB:Cardinal;
  PinID:Word;

  DepthOff:Boolean;

  MyMesh:Mesh;
  Group, Other:MeshGroup;
  ExpAnim:Boolean;
  Triplanar:Boolean;
  BlendMode:Integer;
  Outline:Boolean;

  TargetVertex, TargetGroup:Integer;
  TargetPos:Vector3D;

  Indices:Array Of Word;

  PS:AnsiString;
  DestFile:AnsiString;
  LMFile:AnsiString;
  MorphFile:AnsiString;

  LightType:Integer;
  LightPulse:Cardinal;
  LightFlicker:Cardinal;
  LightColor:Color;
  LightRadius:Single;
  Param1, Param2, Param3:Vector3D;
Begin
  FileManager.Instance.AddPath(GetFilePath(SourceFile));

  DestFile := TargetDir + PathSeparator + GetFileName(SourceFile, True) + '.mesh';
  If (Not AssetModified(SourceFile, DestFile)) Then
  Begin
    Log(logConsole, 'Import', 'Skipping '+SourceFile+'...[Not modified]');
    Result := DestFile;
    Exit;
  End;

  If (Pos('_L.', UpStr(SourceFile))>0)
  Or (Pos('_LIGHTMAP.', UpStr(SourceFile))>0) Then
  Begin
    Log(logConsole, 'Import', 'Skipping '+SourceFile+'...[Lightmap mesh]');
    Result := DestFile;
    Exit;
  End;

  If (Pos('_MORPH', UpStr(SourceFile))>0) Then
  Begin
    Log(logConsole, 'Import', 'Skipping '+SourceFile+'...[Morph mesh]');
    Result := DestFile;
    Exit;
  End;

  OfsX := 0.0;
  OfsY := 0.0;
  OfsZ := 0.0;
  ASpeed := 1.0;

  PS := SourceFile;
  ReplaceText('ms3d', 'settings', PS);
  If FileStream.Exists(PS) Then
  Begin
    Log(logConsole, 'Import', 'Found settings file: '+PS+'...');
    Parser := INIParser.Create;
    Parser.ParseCommas:=True;
    Parser.AddToken('ofsx', tkFloat, @OfsX);
    Parser.AddToken('ofsy', tkFloat, @OfsY);
    Parser.AddToken('ofsz', tkFloat, @OfsZ);
    Parser.AddToken('speed', tkFloat, @ASpeed);
    Parser.Load(PS);
	  Parser.Destroy;
  End;

  Log(logConsole, 'Import', 'Reading Milkshape file ('+GetFileName(SourceFile, False)+')...');

  MS3D.Clear();

  Source := FileStream.Open(SourceFile);
  MS3D.Load(Source);
  Source.Destroy;

  LMFile := GetFilePath(SourceFile) + GetFileName(SourceFile, True)+'_l.ms3d';
  If Not FileStream.Exists(LMFile) Then
    LMFile := GetFilePath(SourceFile) + GetFileName(SourceFile, True)+'_lightmap.ms3d';

  If FileStream.Exists(LMFile) Then
  Begin
    Source := FileStream.Open(LMFile);
    MS3D2.Load(Source);
    Source.Destroy;

    If (MS3D.NumVertices<>MS3D2.NumVertices) Then
    Begin
      Log(logConsole, 'Import', 'Invalid lightmap mesh!');
      LMFile := '';
    End Else
      Log(logConsole, 'Import', 'Imported lightmap mesh...');
  End Else
    LMFile := '';

  For I:=0 To Pred(MaxMorphs) Do
  Begin
    MorphFile := GetFilePath(SourceFile) + GetFileName(SourceFile, True)+'_morph'+IntToString(I)+'.ms3d';
    If FileStream.Exists(MorphFile) Then
    Begin
      Log(logConsole, 'Import', 'Loading vertex morph '+IntToString(I)+'...');
      Source := FileStream.Open(MorphFile);
      Morphs[I].Load(Source);
      Source.Destroy;
    End Else
      Morphs[I].NumVertices := 0;
  End;

  Log(logConsole, 'Import', 'Processing metadata...');

  If GetFileName(SourceFile, True)='obj004' Then
    IntToString(2);

  LightJointCount:=0;
  PinJointCount:=0;
  EmitterJointCount:=0;

  MyMesh := Mesh.Create('');

  I:=0;
  While I<MS3D.NumJoints Do
  Begin
    S := UpStr(StrClean(MS3D.Joints[I].Name));
    If (Pos('#PIN',S)>0) Then
    Begin
      Inc(PinJointCount);
      SetLength(PinJoints, PinJointCount);
      PinJoints[Pred(PinJointCount)] := MS3D.Joints[I];

      MS3D.RemoveJoint(I);
    End Else
    If (Pos('#LIGHT',S)>0) Then
    Begin
      Inc(LightJointCount);
      SetLength(LightJoints, LightJointCount);
      LightJoints[Pred(LightJointCount)] := MS3D.Joints[I];

      If (MS3D.Joints[I].Comment='') Then
      Begin
        WriteLn('Invalid light in ',SourceFile);
        Halt(1);
      End;

      S := '';
      LightPulse := 0;
      LightFlicker := 0;

  		Parser := INIParser.Create;                                                   
	  	Parser.AddToken('type',tkString,@S);
	  	Parser.AddToken('color',tkColor,@LightColor);
	  	Parser.AddToken('radius',tkFloat,@LightRadius);
	  	Parser.AddToken('pulse',tkInteger,@LightPulse);
	  	Parser.AddToken('flicker',tkInteger,@LightFlicker);

	  	Parser.LoadFromString(MS3D.Joints[I].Comment);
	  	Parser.Destroy;

      Param1 := VectorZero;
      Param2 := VectorZero;
      Param3 := VectorCreate(LightPulse, LightFlicker, 0);

      S := LowStr(S);
      If S='point' Then
      Begin
        LightType := lightTypePoint;
        Param1 := VectorCreate(LightRadius, 0, 0);
      End Else
      If S='spot' Then
        LightType := lightTypeSpot
      Else
        LightType := -1;

      If LightType>=0 Then
      Begin
        S := TrimRight(TrimLeft(MS3D.Joints[I].ParentName));
        Name := 'light'+IntToString(LightJointCount);
        MyMesh.AddLight(Name, MS3D.Joints[I].Position, LightType, LightColor, Param1, Param2, Param3, S);
        WriteLn('Adding light');
      End Else
        WriteLn('Invalid light joint!');
       MS3D.RemoveJoint(I);
    End Else
    If (Pos('#EMITTER',S)>0) Then
    Begin
      If (MS3D.Joints[I].Comment='') Then
      Begin
        WriteLn('Invalid emitter in ',SourceFile);
        Halt(1);
      End;

      Inc(EmitterJointCount);
      SetLength(EmitterJoints, EmitterJointCount);
      EmitterJoints[Pred(EmitterJointCount)] := MS3D.Joints[I];
      S := TrimRight(TrimLeft(MS3D.Joints[I].ParentName));
      Name := 'emmiter'+IntToString(EmitterJointCount);
      MyMesh.AddEmitter(Name, MS3D.Joints[I].Position, MS3D.Joints[I].Comment, S);
      WriteLn('Adding emitter: ', MS3D.Joints[I].Comment);

      MS3D.RemoveJoint(I);
    End Else
    If (Pos('$',S)>0) Then
    Begin
      S := Copy(S, 2, MaxInt);
      MyMesh.AddMetadata(S, MS3D.Joints[I].Position, MS3D.Joints[I].Comment);
      WriteLn('Found metadata: ', S);

      MS3D.Joints[I] := MS3D.Joints[Pred(MS3D.NumJoints)];
      For J:=0 To Pred(MS3D.NumVertices) Do
      If (MS3D.Vertices[J].BoneIndex=Pred(MS3D.NumJoints)) Then
        MS3D.Vertices[J].BoneIndex := I;
      Dec(MS3D.NumJoints);
    End Else
    If (Not MS3D.IsJointUsed(I)) Then
    Begin
      MS3D.RemoveJoint(I);
    End Else
      Inc(I);
  End;

  WriteLn('Joints imported: ', MS3D.NumJoints);

  SetLength(BonesParent, MS3D.NumJoints);

  If (MS3D.NumJoints>0) Then
	Begin
    Log(logConsole, 'Import', 'Processing bones...');

    If (MS3D.NumJoints>MaxBones) Then
      Log(logConsole, 'Import', 'Warning: Bone limit reached!');

  	For I:=0 To Pred(MS3D.NumJoints) Do
		  Begin
			  S := MS3D.Joints[I].Name;
			  S := StrClean(S);

        If (MyMesh.Skeleton.GetBone(S)<>Nil) Then
          Log(logConsole, 'Import', 'Warning: Duplicated bones: '+S);

			  Bone := MyMesh.Skeleton.AddBone;
			  Bone.Name := S;
        {$IFNDEF NO_ROTS}
		  	Bone.StartPosition := MS3D.Joints[I].Position;
			  Bone.StartRotation := MS3D.Joints[I].Rotation;
        {$ELSE}
		  	Bone.StartPosition := MS3D.Joints[I].RelativePosition;
        {$ENDIF}

        If I=0 Then
          Bone.StartPosition.Add(VectorCreate(OfsX, OfsY, OfsZ));


			  S := MS3D.Joints[I].ParentName;
			  S := StrClean(S);
			  Bone.Parent := Nil;
			  BonesParent[I] := S;
		  End;

  	For I:=0 To Pred(MyMesh.Skeleton.BoneCount) Do
	    For J:=0 To Pred(MyMesh.Skeleton.BoneCount) Do
	  	If (UpStr(MyMesh.Skeleton.GetBone(J).Name) = UpStr(BonesParent[I])) Then
		  Begin
			  MyMesh.Skeleton.GetBone(I).Parent := MyMesh.Skeleton.GetBone(J);
			  Break;
		  End;
  End;

  If (MS3D.NumJoints>0)And(MS3D.Comment<>'') Then
  Begin
    ImportAnimation(MS3D, MyMesh.Skeleton, TargetDir, LowStr(GetFileName(SourceFile, True)));
  End;

	  For N:=0 To Pred(MS3D.NumGroups) Do
    Begin
      Log(logConsole, 'Import', 'Processing group ' + IntToString(Succ(N))+'...');

		  S := MS3D.Groups[N].Name;
		  S := StrClean(S);

      Link := Pos('*', S)>0;
      ReplaceText('*', '', S);

      Group := MyMesh.AddGroup(S);

      If (MS3D.Groups[N].MaterialIndex>=0) Then
      Begin
		    Group.DiffuseColor := ColorCreate(
                  MS3D.Materials[MS3D.Groups[N].MaterialIndex].Diffuse.R,
		              MS3D.Materials[MS3D.Groups[N].MaterialIndex].Diffuse.G,
		              MS3D.Materials[MS3D.Groups[N].MaterialIndex].Diffuse.B,
		              MS3D.Materials[MS3D.Groups[N].MaterialIndex].Transparency);
		    {Group.SpecularColor := ColorCreate(
          MS3D.Materials[MS3D.Groups[N].MaterialIndex].Specular.R,
		      MS3D.Materials[MS3D.Groups[N].MaterialIndex].Specular.G,
		      MS3D.Materials[MS3D.Groups[N].MaterialIndex].Specular.B);
        Group.SpecularFactor := MS3D.Materials[MS3D.Groups[N].MaterialIndex].Shininess;

		    Group.GlowFactor := MS3D.Materials[MS3D.Groups[N].MaterialIndex].Emissive.R * 0.3 +
		      MS3D.Materials[MS3D.Groups[N].MaterialIndex].Emissive.G * 0.59 +
          MS3D.Materials[MS3D.Groups[N].MaterialIndex].Emissive.B * 0.11;}
      End Else
      Begin
        Group.DiffuseColor := ColorWhite;
        {Group.SpecularColor := ColorWhite;
        Group.SpecularFactor := 0.0;
        Group.GlowFactor := 0.0;}
      End;

		  S := MS3D.GetMaterialFile(MS3D.Groups[N].MaterialIndex, SourceFile);
		  Group.DiffuseMap := TextureManager.Instance.GetTexture(GetFileName(S, True));

      If LMFile<>'' Then
      Begin
  		  S := MS3D2.GetMaterialFile(MS3D2.Groups[N].MaterialIndex, LMFile);
	  	  Group.LightMap := TextureManager.Instance.GetTexture(GetFileName(S, True));
      End;

		  // Parse group comments
		  Mirror:=False;
		  Cull:=True;
      Vegetation := False;
		  Shadows:=True;
		  Pick:=True;
		  Collision:=True;
		  IsCloth := False;
		  If (MS3D.Groups[N].MaterialIndex>=0) And (MS3D.Groups[N].MaterialIndex<MS3D.NumMaterials) Then
			  SphereMap := MS3D.Materials[MS3D.Groups[N].MaterialIndex].Mode And 128<>0
			Else
				SphereMap := False;
  		//Group.FurSettings.Pattern := '';
  		AlphaTest := False;

  		Transparency := False;
      OverrideMaterial := False;
      Triplanar := False;
      Outline := True;
      BlendMode := -1;
      SecondaryTexture := '';
      MeshEmitter := '';
      DiffuseInVertex := False;

  		Parser := INIParser.Create;
	  	Parser.AddToken('mirror',tkBoolean,@Mirror);
	  	Parser.AddToken('cull',tkBoolean,@Cull);
	  	Parser.AddToken('depthoff',tkBoolean,@DepthOff);
	  	Parser.AddToken('shadows',tkBoolean,@Shadows);
	  	Parser.AddToken('pick',tkBoolean,@Pick);
	  	Parser.AddToken('collision',tkBoolean,@Collision);
	  	Parser.AddToken('spheremap',tkBoolean,@SphereMap);
	  	Parser.AddToken('blendmode',tkInteger,@BlendMode);
	  	Parser.AddToken('vegetation',tkBoolean,@Vegetation);
	  	Parser.AddToken('alpha_test',tkBoolean,@AlphaTest);
	  	Parser.AddToken('transparency',tkBoolean,@Transparency);
	  	Parser.AddToken('triplanar',tkBoolean,@Triplanar);
	  	Parser.AddToken('outline',tkBoolean,@Outline);
      Parser.AddToken('link',tkBoolean,@Link);
	  	Parser.AddToken('override_material',tkBoolean,@OverrideMaterial);
	  	Parser.AddToken('secondarytexture',tkString,@SecondaryTexture);
      Parser.AddToken('emitter',tkString,@MeshEmitter);
      Parser.AddToken('diffuseinvertex',tkBoolean,@DiffuseInVertex);

	  	(*Parser.AddToken('fur_pattern',tkString,@Group.FurSettings.Pattern);
	  	Parser.AddToken('fur_waviness',tkFloat, @Group.FurSettings.Waviness);
	  	Parser.AddToken('fur_thickness',tkFloat, @Group.FurSettings.Thickness);
	  	Parser.AddToken('fur_length',tkFloat, @Group.FurSettings.Length);
	  	Parser.AddToken('fur_density',tkFloat, @Group.FurSettings.Density);
	  	Parser.AddToken('cloth',tkBoolean, @IsCloth);
      *)

	  	Parser.LoadFromString(MS3D.Groups[N].Comment);
	  	Parser.Destroy;

      Group.Flags := 0;
	  	SetFlag(Group.Flags, meshGroupHidden, (MS3D.Groups[N].Flags And 2<>0));
	  	SetFlag(Group.Flags, meshGroupDoubleSided, Not Cull);
	  	SetFlag(Group.Flags, meshGroupCastShadow, Shadows);
	  	SetFlag(Group.Flags, meshGroupPick, Pick);
	  	SetFlag(Group.Flags, meshGroupVegetation, Vegetation);
//	  	SetFlag(Group.Flags, mgCollision, Collision);
	  	SetFlag(Group.Flags, meshGroupSphereMap, SphereMap);
	  	SetFlag(Group.Flags, meshGroupAlphaTest, AlphaTest);
		  SetFlag(Group.Flags, meshGroupTransparency, Transparency);
      SetFlag(Group.Flags, meshGroupLinked, Link);
		  SetFlag(Group.Flags, meshGroupTriplanar, Triplanar);
		  //SetFlag(Group.Flags, mgOverrideMaterial, OverrideMaterial);
		  //SetFlag(Group.Flags, mgCloth, IsCloth);
      SetFlag(Group.Flags, meshGroupLightmap, LMFile<>'');
      SetFlag(Group.Flags, meshGroupDepthOff, DepthOff);
      SetFlag(Group.Flags, meshGroupOutlineOff, Not Outline);

      Group.BlendMode := BlendMode;

      If (SecondaryTexture='') And (MS3D.Groups[N].MaterialIndex>=0) Then
      Begin
        SecondaryTexture := StrClean(MS3D.Materials[MS3D.Groups[N].MaterialIndex].AlphaMap);
        If (SecondaryTexture<>'') And (SecondaryTexture<>StrClean(MS3D.Materials[MS3D.Groups[N].MaterialIndex].Texture)) Then
        Begin
          SecondaryTexture := GetFileName(SecondaryTexture, False);
		      SetFlag(Group.Flags, meshGroupTriplanar, True);
        End;
      End;

      Group.TriplanarMap := TextureManager.Instance.GetTexture(GetFileName(SecondaryTexture, True));

      If Assigned(Group.DiffuseMap) Then
      Begin
        Group.NormalMap  := TextureManager.Instance.GetTexture(Group.DiffuseMap.Name+'_nrm');
        Group.SpecularMap  := TextureManager.Instance.GetTexture(Group.DiffuseMap.Name+'_spec');
        Group.RefractionMap  := TextureManager.Instance.GetTexture(Group.DiffuseMap.Name+'_refr');
        Group.ReflectiveMap  := TextureManager.Instance.GetTexture(Group.DiffuseMap.Name+'_refl');
        Group.GlowMap  := TextureManager.Instance.GetTexture(Group.DiffuseMap.Name+'_glow');
        Group.EnviromentMap  := TextureManager.Instance.GetTexture(Group.DiffuseMap.Name+'_env');
      End;

      Group.EmitterFX := MeshEmitter;

      PS := '';
      If Not Cull Then
        PS := PS + 'DoubleSided,';
      If SphereMap Then
        PS := PS + 'SphereMap,';
      If AlphaTest Then
        PS := PS + 'AlphaTest,';
      If Transparency Then
        PS := PS + 'Transparent,';
      If Vegetation Then
        PS := PS + 'Vegetation,';
      If PS<>'' Then
      Begin
        PS := Copy(PS, 1, Length(PS)-1);
        Log(logConsole, 'Import', 'Group flags: ' + PS);
      End;

		  Group.TriangleCount := MS3D.Groups[N].NumTriangles;
      Group.VertexCount := 0;

      Log(logConsole, 'Import', 'Generating geometry...');

      // gen morphs
      For I:=0 To Pred(MaxMorphs) Do
      If (Morphs[I].NumVertices>0) Then
      Begin
        Log(logConsole, 'Import', 'Generating vertex morph '+IntToString(I)+' for '+Group.Name+'...');
        If FindMorphGroup(I, Group.Name)>=0 Then
          Group.AddVertexMorph(I);
      End;

		  For I:=0 To Pred(Group.TriangleCount) Do
			  For J:=0 To 2 Do
			  Begin
			    W:=-1;

			    Z := MS3D.Groups[N].TriangleIndices[I];
			    VP.Position := MS3D.Vertices[MS3D.Triangles[Z].VertexIndices[Succ(J)]].Vertex;
          Vp.Position.Add(VectorCreate(OfsX, OfsY, OfsZ));
          If DiffuseInVertex Then
            Vp.Color := Group.DiffuseColor
          Else
            Vp.Color := ColorWhite;
			    VP.Normal:= MS3D.Triangles[Z].VertexNormals[Succ(J)];
			    VP.TextureCoords.X:= MS3D.Triangles[Z].S[Succ(J)];
			    VP.TextureCoords.Y := MS3D.Triangles[Z].T[Succ(J)];
			    VP.BoneIndex := Succ(MS3D.Vertices[MS3D.Triangles[Z].VertexIndices[Succ(J)]].BoneIndex);
          If LMFile<>'' Then
          Begin
  			    VP.TextureCoords2.X:= MS3D2.Triangles[Z].S[Succ(J)];
	  		    VP.TextureCoords2.Y := MS3D2.Triangles[Z].T[Succ(J)];
          End;

			    For K:=0 To Pred(Group.VertexCount) Do
			    If (Group.Vertices[K].Position.Distance(VP.Position)<=0.001) And (Group.Vertices[K].Normal.Distance(VP.Normal)<=0.001)
			    And(Group.Vertices[K].TextureCoords.Distance(VP.TextureCoords)<=0.001) And (Group.Vertices[K].BoneIndex=VP.BoneIndex) Then
			    Begin
				    W:=K;
				    Break;
			    End;

			    If W=-1 Then
          Begin
				    Group.VertexCount := Group.VertexCount + 1;
				    W := Pred(Group.VertexCount);
				    Group.Vertices[W] := VP;
			    End;

          ZZ := MS3D.Triangles[Z].VertexIndices[Succ(J)];
          For MM:=0 To Pred(MaxMorphs) Do
          If (Morphs[MM].NumVertices>0) And (Group.HasVertexMorph(MM)) Then
          Begin
            If (Morphs[MM].NumVertices<=ZZ) Then
            Begin
              Log(logConsole, 'Import', 'Failed generating vertex morph '+IntToString(I)+' for '+Group.Name+' in vertex '+IntToString(ZZ)+'...');
              Halt(1);
            End;

            P := Morphs[MM].Vertices[ZZ].Vertex;
            Group.SetVertexMorph(MM, W, P);
          End;

		      Group.Triangles[I].Indices[J] := W;
		    End;

        If DiffuseInVertex Then
          Group.DiffuseColor := ColorWhite;

        Log(logConsole, 'Import', 'Calculating tangents...');

  		  Group.CalculateTangents;

        Log(logConsole, 'Import', 'Calculating triangle normals...');
        Group.CalculateTriangleNormals;

    // search for pinned vertices
      If (IsCloth) Then
		  Begin
		    For I:=0 To Pred(PinJointCount) Do
		    Begin
			      Min := 9999;
			      For J:=0 To Pred(Group.VertexCount) Do
			      Begin
			        Dist := Group.Vertices[J].Position.Distance(PinJoints[I].Position);
			        If (Dist<=Min) Then
			        Begin
				        Min := Dist;
				        PinID := J;
              End;
			      End;
			  End;

			  If (Min<2) Then
			    Group.AddVertexPin(PinID)
        Else
			    Log(logConsole, 'Import', 'Could not find pin vertex for '+ Group.Name);
		  End;
    End;

  // bone morphs
  For I:=0 To Pred(MaxMorphs) Do
  If (Morphs[I].NumVertices>0) Then
  Begin
    Log(logConsole, 'Import', 'Generating bones morph '+IntToString(I)+'...');
    MyMesh.AddBoneMorph(I);
    For J:=0 To Pred(Morphs[I].NumJoints) Do
    Begin
      MyMesh.SetBoneMorph(I, J, Morphs[I].Joints[J].Position);
    End;
  End;

  // gen links
  For J:=0 To Pred(MyMesh.GroupCount) Do
  Begin
    Group := MyMesh.GetGroup(J);
    If (Group.Flags And meshGroupLinked=0) Then
      Continue;

    Log(logConsole, 'Import', 'Generating vertex links for '+Group.Name+'...');
    For I:=0 To Pred(Group.VertexCount) Do
    Begin
      V := Group.GetVertexPointer(I);

      TargetVertex := -1;
      TargetGroup := -1;
      TargetPos := VectorZero;
      Min := 9999;

      For K:=0 To Pred(MyMesh.GroupCount) Do
      If (K<>J) Then
      Begin
        Other := MyMesh.GetGroup(K);
        If (Other.Flags And meshGroupLinked<>0) Then
          Continue;

        For W:=0 To Pred(Other.VertexCount) Do
        Begin
          P := Other.GetVertex(W).Position;

          Dist := P.Distance(V.Position);
          If (Dist<Min) Then
          Begin
            TargetVertex := W;
            TargetGroup := K;
            TargetPos := P;
            Min := Dist;

            If (Dist<=0) Then
              Break;
          End;
        End;
      End;

      //Log(logConsole, 'Import', 'Found '+IntToString(TargetVertex)+' in '+IntToString(TargetGroup));
      Group.SetVertexLink(I, TargetGroup, TargetVertex);
      If (TargetGroup>=0) Then
        V.Position.Subtract(TargetPos);
    End;
  End;

  //ReadLn;

  Log(logConsole, 'Import', 'Saving mesh...');
  Dest := FileStream.Create(DestFile);
  MyMesh.Save(Dest);
  Dest.Destroy;

  MyMesh.Destroy;
End;


Initialization
  RegisterFileImporter('ms3d', 'mesh', MS3DImporter);
End.
