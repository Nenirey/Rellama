{Hint: save all files to location: C:\adt32\eclipse\workspace\AppIntentDemo3\jni }
unit unit1;
  
{$mode delphi}
  
interface
  
uses
  Classes, SysUtils, strutils, And_jni, Laz_And_Controls,
  AndroidWidget, intentmanager, seekbar, contactmanager, textfilemanager,
  Spinner, telephonymanager, preferences, menu, contextmenu, modaldialog;
  
type

  { TRellama }

  TRellama = class(jForm)
      jButton1: jButton;
      jButton2: jButton;
      jCheckBox1: jCheckBox;
      jContactManager1: jContactManager;
      jContextMenu1: jContextMenu;
      jEditText1: jEditText;
      jIntentManager1: jIntentManager;
      jMenu1: jMenu;
      jModalDialog1: jModalDialog;
      jPreferences1: jPreferences;
      jSeekBar1: jSeekBar;
      jSeekBar2: jSeekBar;
      jSpinner1: jSpinner;
      jTelephonyManager1: jTelephonyManager;
      jTextFileManager1: jTextFileManager;
      jTextView1: jTextView;
      jTextView2: jTextView;
      jTextView3: jTextView;
      jTimer1: jTimer;
      procedure jButton1AfterDispatchDraw(Sender: TObject; canvas: JObject;
        tag: integer);
      procedure jContactManager1GetContactsProgress(Sender: TObject;
        contactInfo: string; contactShortInfo: string;
        contactPhotoUriAsString: string; contactPhoto: jObject;
        progress: integer; out continueListing: boolean);
      procedure jEditText1Change(Sender: TObject; txt: string; count: integer);
      procedure jEditText1Changed(Sender: TObject; txt: string; count: integer);
      procedure jSeekBar1ProgressChanged(Sender: TObject; progress: integer;
        fromUser: boolean);
      procedure jSeekBar2ProgressChanged(Sender: TObject; progress: integer;
        fromUser: boolean);
      procedure jSpinner1ItemSelected(Sender: TObject; itemCaption: string;
        itemIndex: integer);
      procedure jTelephonyManager1CallStateChanged(Sender: TObject;
        state: TTelephonyCallState; phoneNumber: string);
      procedure jTimer1Timer(Sender: TObject);
      procedure RellamaActivityCreate(Sender: TObject; intentData: jObject);
      procedure RellamaActivityPause(Sender: TObject);
      procedure RellamaActivityResult(Sender: TObject;
        requestCode: integer; resultCode: TAndroidResult; intentData: jObject);
      procedure jButton1Click(Sender: TObject);
      procedure Finalizar(Sender:TObject);
      procedure jButton2Click(Sender: TObject);
      procedure RellamaActivityResume(Sender: TObject);
      procedure RellamaClickOptionMenuItem(Sender: TObject;
        jObjMenuItem: jObject; itemID: integer; itemCaption: string;
        checked: boolean);
      procedure RellamaClose(Sender: TObject);
      procedure RellamaCreateContextMenu(Sender: TObject; jObjMenu: jObject);
      procedure RellamaCreateOptionMenu(Sender: TObject; jObjMenu: jObject);
      procedure RellamaJNIPrompt(Sender: TObject);
    private
      {private declarations}
    public
      {public declarations}
  end;
  
var
  Rellama: TRellama;
  llamando:boolean=false;
  buscando:boolean=false;
  intentos,demora:integer;

implementation
  
{$R *.lfm}

{ TRellama }
procedure TRellama.Finalizar(Sender: TObject);
begin
  llamando:=false;
  jTimer1.Enabled:=false;
  jTextView1.Text:='';
  jButton1.OnClick:=Rellama.jButton1Click;
end;

procedure TRellama.jButton1Click(Sender: TObject);
begin
  if intentos>0 then
  begin
    if IsRuntimePermissionGranted('android.permission.CALL_PHONE') and
       IsRuntimePermissionGranted('android.permission.READ_PHONE_STATE')  and
       IsRuntimePermissionGranted('android.permission.MODIFY_AUDIO_SETTINGS') then   //from AndroodManifest.xml
    begin
      Dec(intentos);
      llamando:=true;
      jButton1.OnClick:=Rellama.Finalizar;
      jTextView1.Text:=inttostr(jSeekBar2.Progress);
      jTelephonyManager1.Call(jEditText1.Text);
    end
    else
    begin
      ShowMessage('Debe conceder los permisos necesarios!!!');
    end;
   end
   else
     ShowMessage('Debe poner al menos 1 intento');
end;

procedure TRellama.RellamaActivityResult(Sender: TObject;
  requestCode: integer; resultCode: TAndroidResult; intentData: jObject);
var
   jContactUri: jObject;
   strContactNumber,id: string;
begin
   if IsRuntimePermissionGranted('android.permission.READ_CONTACTS') then
   begin
     strContactNumber:= '';
     jContactUri:= jIntentManager1.GetDataUri(intentData);
     strContactNumber:= jIntentManager1.GetContactNumber(jContactUri);
     if strContactNumber <> '' then
     begin
       jEditText1.Text:=strContactNumber;
       jButton2.Text:=strContactNumber;
     end;
     buscando:=false;
   end;
end;

procedure TRellama.jSeekBar1ProgressChanged(Sender: TObject; progress: integer;
  fromUser: boolean);
begin
  jTextView2.Text:='Intentos: '+inttostr(progress*(jSpinner1.SelectedIndex+1));
  intentos:=progress*(jSpinner1.SelectedIndex+1);
end;


procedure TRellama.jContactManager1GetContactsProgress(Sender: TObject;
  contactInfo: string; contactShortInfo: string;
  contactPhotoUriAsString: string; contactPhoto: jObject; progress: integer;
  out continueListing: boolean);
begin
  if isRunTimePermissionGranted('android.permission.READ_CONTACTS') then
  begin
    if Pos(jEditText1.Text,contactInfo)>0 then
    begin
      jButton2.Text:=ExtractWord(1,contactInfo,['|']);
      if jEditText1.Text=ExtractWord(1,contactInfo,['|']) then
        jButton2.SetCompoundDrawables(contactPhoto, cdsAbove);
      continueListing:=false;
    end;
  end;
end;

procedure TRellama.jButton1AfterDispatchDraw(Sender: TObject; canvas: JObject;
  tag: integer);
begin
  if llamando then
  begin
    jButton1.Text:='Finalizar restantes '+inttostr(intentos);
    jButton1.BackgroundColor:=colbrRed;
  end
  else
  begin
    jButton1.Text:='Llamar';
    jButton1.BackgroundColor:=colbrLimeGreen;
  end;
end;

procedure TRellama.jEditText1Change(Sender: TObject; txt: string; count: integer
  );
begin
  if jEditText1.Text<>'' then
    jButton2.Text:=jEditText1.Text
  else
    jButton2.Text:='Contactos';
  if isRunTimePermissionGranted('android.permission.READ_CONTACTS') then
    jContactManager1.GetContactsAsync('|');
end;

procedure TRellama.jEditText1Changed(Sender: TObject; txt: string;
  count: integer);
begin
  if jEditText1.Text<>'' then
    jButton2.Text:=jEditText1.Text
  else
    jButton2.Text:='Contactos';
end;

procedure TRellama.jSeekBar2ProgressChanged(Sender: TObject; progress: integer;
  fromUser: boolean);
begin
  jTextView3.Text:='Demora: '+inttostr(progress)+' segundos';
end;

procedure TRellama.jSpinner1ItemSelected(Sender: TObject; itemCaption: string;
  itemIndex: integer);
begin
  intentos:=jSeekbar1.Progress*(jSpinner1.SelectedIndex+1);
  jTextView2.Text:='Intentos: '+inttostr(intentos);
end;

procedure TRellama.jTelephonyManager1CallStateChanged(Sender: TObject;
  state: TTelephonyCallState; phoneNumber: string);
begin
    case state of
      csIdle: begin
         jTelephonyManager1.SetSpeakerphoneOn(False);
      end;
      csRinging: begin
         jTelephonyManager1.SetSpeakerphoneOn(jCheckBox1.Checked);
      end;
      csOffHook: begin
         jTelephonyManager1.SetSpeakerphoneOn(jCheckBox1.Checked);
      end;
    end;
end;

procedure TRellama.jTimer1Timer(Sender: TObject);
begin
  if demora>0 then
  begin
    Dec(demora);
    jTextView1.Text:=inttostr(demora);
    jButton1.Text:='Finalizar restantes '+inttostr(intentos);
  end
  else
  begin
    jTimer1.Enabled:=false;
    if intentos>0 then
    begin
      Rellama.jButton1Click(nil);
    end
    else
    begin
      llamando:=false;
    end;
  end;
end;

procedure TRellama.RellamaActivityCreate(Sender: TObject; intentData: jObject);
begin
  llamando:=false;
  jSpinner1.SelectedIndex:=jPreferences1.GetIntData('multiple',0);
  jButton2.Text:=jPreferences1.GetStringData('lastname','Contactos');
  jEditText1.Text:=jPreferences1.GetStringData('lastnumber','');
  jSeekBar1.Progress:=jPreferences1.GetIntData('trycount',5);
  jSeekBar2.Progress:=jPreferences1.GetIntData('delay',3);
  jCheckBox1.Checked:=jPreferences1.GetBoolData('Speaker',false);
  demora:=jSeekBar2.Progress;
end;

procedure TRellama.RellamaActivityPause(Sender: TObject);
begin
  if llamando then
  begin
    //ShowMessage('Intentos restantes: '+inttostr(intentos));
    jTimer1.Enabled:=false;
  end
  else
  begin
    if buscando=false then
    begin
      ShowMessage('Hasta pronto');
      jPreferences1.SetStringData('lastnumber',jEditText1.Text);
      jPreferences1.SetStringData('lastname',jButton2.Text);
      jPreferences1.SetIntData('trycount',jSeekBar1.Progress);
      jPreferences1.SetIntData('delay',jSeekBar2.Progress);
      jPreferences1.SetIntData('multiple',jSpinner1.SelectedIndex);
      jPreferences1.SetBoolData('Speaker',jCheckBox1.Checked);
    end
    else
      ShowMessage('Seleccione un contacto...');
  end;
end;

procedure TRellama.jButton2Click(Sender: TObject);
begin
  if isRunTimePermissionGranted('android.permission.READ_CONTACTS') then
  begin
     jIntentManager1.SetAction(jIntentManager1.GetActionGetContentUri());
     jIntentManager1.SetMimeType('vnd.android.cursor.item/phone_v2');

     if jIntentManager1.ResolveActivity() then
     begin
       buscando:=true;
       jIntentManager1.StartActivityForResult(1003, 'Dial ...');
     end
     else
         ShowMessage('Unable to find an App to perform this action...');
  end;
end;

procedure TRellama.RellamaActivityResume(Sender: TObject);
begin
  if llamando and (intentos>0) then
  begin
    demora:=jSeekBar2.Progress;
    jTimer1.Enabled:=true;
  end
  else
  begin
    intentos:=jSeekBar1.Progress*(jSpinner1.SelectedIndex+1);
    demora:=jSeekBar2.Progress;
    jButton1.Text:='Llamar';
    jTextView1.Text:='';
    llamando:=false;
  end;
end;

procedure TRellama.RellamaClickOptionMenuItem(Sender: TObject;
  jObjMenuItem: jObject; itemID: integer; itemCaption: string; checked: boolean
  );
var
  i: integer;
begin
  if itemID <> 0 then  // itemID = 0 --> subMenu entry point
  begin
    if not checked then
    begin

      jMenu1.UnCheckAllMenuItem(); //UnCheck menu items
      for i:= 0  to jMenu1.CountSubMenus()-1 do
      begin
         jMenu1.UnCheckAllSubMenuItemByIndex(i);  //UnCheck All SubMenus items...
      end;

      jMenu1.CheckItem(jObjMenuItem);
      case itemID of
          1003: ShowMessage('Created by nenirey@gmail.com');
          1004: Rellama.Close;
          1005:
            begin
              jIntentManager1.SetAction(jIntentManager1.GetActionViewAsString());  //or 'android.intent.action.VIEW'
              jIntentManager1.SetMimeType('text/html');
              jIntentManager1.SetDataUriAsString('https://github.com/Nenirey/Rellama');
              if jIntentManager1.ResolveActivity then
                jIntentManager1.StartActivity()
              else
                ShowMessage('El codigo es accesible desde un navegador https://github.com/Nenirey/Rellama');
            end;
      end;
    end
    else
    begin
      jMenu1.UnCheckItem(jObjMenuItem);
      jEditText1.FontColor:= colbrSilver; //colbrDefault was gone!
    end;
  end;
end;

procedure TRellama.RellamaClose(Sender: TObject);
begin
  jPreferences1.SetStringData('lastnumber',jEditText1.Text);
  jPreferences1.SetStringData('lastname',jButton2.Text);
  jPreferences1.SetIntData('trycount',jSeekBar1.Progress);
  jPreferences1.SetIntData('delay',jSeekBar2.Progress);
  jPreferences1.SetIntData('multiple',jSpinner1.SelectedIndex);
  jPreferences1.SetBoolData('Speaker',jCheckBox1.Checked);
end;

procedure TRellama.RellamaCreateContextMenu(Sender: TObject; jObjMenu: jObject);
var
  i: integer;
  jItem: jObject;
begin
  if jObjMenu <> nil then
  begin
    jContextMenu1.SetHeader(jObjMenu, 'Options', 'ic_launcher');
    for i:=0 to jContextMenu1.Options.Count-1 do
    begin                                                                                      //0:mitDefault, 1:mitCheckable
       jItem:= jContextMenu1.AddItem(jObjMenu, 10+i {itemID}, jContextMenu1.Options.Strings[i], mitCheckable);

       if jContextMenu1.IsItemChecked(10+i) then //Checkable persistence need for Context Menu
       begin
          jContextMenu1.CheckItem(jItem);
       end;
    end;
  end;
end;

procedure TRellama.RellamaCreateOptionMenu(Sender: TObject; jObjMenu: jObject);
begin
   jMenu1.Add(jObjMenu, 1003 {itemID}, 'Acerca de...');
   jMenu1.Add(jObjMenu, 1005 {itemID}, 'Codigo fuente');
   jMenu1.Add(jObjMenu, 1004 {itemID}, 'Salir');
end;

procedure TRellama.RellamaJNIPrompt(Sender: TObject);
var
  manifestPermissions: TDynArrayOfString;
begin
   //https://developer.android.com/guide/topics/security/permissions#normal-dangerous
   //https://www.captechconsulting.com/blogs/runtime-permissions-best-practices-and-how-to-gracefully-handle-permission-removal
  jButton2.SetCompoundDrawables('ic_action_person_add', cdsRight);
  if IsRuntimePermissionNeed() then   // that is, target API >= 23
   begin
      SetLength(manifestPermissions, 4);
      manifestPermissions[0]:= 'android.permission.CALL_PHONE';  //from AndroodManifest.xml
      manifestPermissions[1]:= 'android.permission.READ_PHONE_STATE'; //from AndroodManifest.xml
      manifestPermissions[2]:= 'android.permission.MODIFY_AUDIO_SETTINGS';
      manifestPermissions[3]:= 'android.permission.READ_CONTACTS';
      Self.RequestRuntimePermission(manifestPermissions, 2001);
      SetLength(manifestPermissions, 0);
   end;
end;


end.
