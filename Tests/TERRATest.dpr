Program TERRATest;

{$I terra.inc}

Uses TERRA_MemoryManager, TERRA_String, TERRA_Application, TERRA_Client, TERRA_Log, TERRA_Utils,
  TERRA_TestSuite, TERRA_TestCore, TERRA_TestImage, TERRA_TestMath, TERRA_TestString, TERRA_TestXML
  {$IFDEF WINDOWS},Windows{$ENDIF};

{$IFDEF WINDOWS}
{$APPTYPE CONSOLE}
{$ENDIF}

{$IFDEF WINDOWS}
Procedure MyLogFilter(Module, Desc:AnsiString);
Var
  S:WideString;
  Written:Cardinal;
Begin
  StringAppendChar(Desc, 13);
  StringAppendChar(Desc, 10);
  S := StringToWideString(Desc);
  WriteConsoleW(GetStdHandle(STD_OUTPUT_HANDLE), PWideChar(S), Length(S), Written, nil)
End;
{$ENDIF}

Var
	Tests:TestSuite;
  Errors:Integer;
Begin
  {$IFDEF WINDOWS}
  SetConsoleOutputCP(CP_UTF8);
  {$ENDIF}

	WriteLn('Testing TERRA engine: v'+VersionToString(EngineVersion));

  ApplicationStart(ConsoleClient.Create());

	//AddLogFilter(logDebug, '', MyLogIgnore);
	{$IFDEF WINDOWS}
  	AddLogFilter(logConsole, '', MyLogFilter);
	{$ENDIF}

  //ApplicationStart(ConsoleClient.Create());

	Tests := TestSuite.Create();
  	Tests.RegisterTest(TERRACore_TestList);
  	Tests.RegisterTest(TERRACore_TestHashMap);
    Tests.RegisterTest(TERRACore_TestObjectArray);
  	Tests.RegisterTest(TERRACore_TestSort);

  	Tests.RegisterTest(TERRAImage_TestColorBlend);
  	Tests.RegisterTest(TERRAImage_TestColorBlendWithSeparateAlpha);

    Tests.RegisterTest(TERRAMath_TestLogFunctions);
    //Tests.RegisterTest(TERRAMath_TestPowFunctions);

    Tests.RegisterTest(TERRAString_TestIterator);
    Tests.RegisterTest(TERRAString_TestReverseIterator);

    Tests.RegisterTest(TERRAString_TestGetChar);
    Tests.RegisterTest(TERRAString_TestUnicodeIterator);
    Tests.RegisterTest(TERRAString_TestUnicodeReverseIterator);
    Tests.RegisterTest(TERRAString_TestRegex);
    Tests.RegisterTest(TERRAString_TestCharPos);
    Tests.RegisterTest(TERRAString_TestSubStrPos);
    Tests.RegisterTest(TERRAString_TestCopy);
    Tests.RegisterTest(TERRAString_TestSplits);
    Tests.RegisterTest(TERRAString_TestIteratorSplits);
    Tests.RegisterTest(TERRAString_TestWordExtract);
    Tests.RegisterTest(TERRAString_TestPad);
    Tests.RegisterTest(TERRAString_TestReplace);
    Tests.RegisterTest(TERRAString_TestReverse);
    Tests.RegisterTest(TERRAString_TestTrim);
    Tests.RegisterTest(TERRAString_TestConversions);

    Tests.RegisterTest(TERRAXML_TestSimple);
    Tests.RegisterTest(TERRAXML_TestShortcuts);

  	Errors := Tests.Run();


  	Tests.Release();

    If Application.Instance.DebuggerPresent Then
      ReadLn;

    Halt(Errors);
End.
