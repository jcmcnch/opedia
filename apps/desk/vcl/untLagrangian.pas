unit untLagrangian;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, cxLabel,
  cxCheckBox, dxToggleSwitch, dxActivityIndicator, dxMapControlTypes,
  dxMapControlBingMapImageryDataProvider, dxMapLayer, dxMapImageTileLayer,
  dxMapControl, dxMapItem, dxMapItemFileLayer,
  dxCustomMapItemLayer, dxMapItemLayer, ShellAPI, StrUtils, DateUtils;

type
  TfrmLagrangian = class(TForm)
    tsDirection: TdxToggleSwitch;
    cxLabel3: TcxLabel;
    edtMargin: TcxTextEdit;
    btnTracerTrack: TcxButton;
    btnColocalize: TcxButton;
    aiBusy: TdxActivityIndicator;
    procedure btnTracerTrackClick(Sender: TObject);
    procedure btnColocalizeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLagrangian: TfrmLagrangian;

procedure  LagrangianTrack(shapeFlag, colocateFlag:boolean);

implementation

uses
  untMain, untCommonDB;

procedure frmLagrangian_Busy(Enable:Boolean);
begin
  frmLagrangian.aiBusy.Active:=Enable;
  frmLagrangian.aiBusy.Visible:=Enable;
end;


procedure  LagrangianTrack(shapeFlag, colocateFlag:boolean);
var
  FileLayer: TdxMapItemFileLayer;
  fPath:String;
  dt, dir, sFlag, cFlag, count, i:integer;
  dt1, dt2, lat, lon, shapeFname, colocateFname:string;
  script, args, margin:string;
  Variable:TVar;
  vars, tables, exportflag: String;
  extV, extVV, extVars, extVarVals: String;
  extV2, extVV2, extVars2, extVarVals2: String;

begin
  frmLagrangian_Busy(True);

  dt:=3600*24;  // seconds per day
  if frmLagrangian.tsDirection.Checked then
    dir:=1
  else
    dir:=-1;
  dt1:=FormatDateTime('yyyy-mm-dd',frmMain.dtwpTimeStart.DateTime);
  dt2:=FormatDateTime('yyyy-mm-dd',frmMain.dtwpTimeEnd.DateTime);
  lat:=frmMain.edtLat1.Text;
  lon:=frmMain.edtLon1.Text;
  shapeFname:='tracer';
  colocateFname:='tracer';
  sFlag:=0;
  cFlag:=0;
  if shapeFlag then
    sFlag:=1;
  if colocateFlag then
    cFlag:=1;
  exportflag:=inttostr(getExportDataFlag);
  margin:=frmLagrangian.edtMargin.Text;


  vars:='';
  tables:='';
  extVars:='';
  extVarVals:='';
  extVars2:='';
  extVarVals2:='';
  count:=frmMain.ledtVars.Values.Count-1;
  for I := 0 to count do
  begin
    Variable:=GetVariable(frmMain.ledtVars.Values.Items[i].Tag);
    tables:=tables+Variable.Table_Name;
    vars:=vars+Variable.Short_Name;

    extV:='ignore';
    extVV:='ignore';
    extV2:='ignore';
    extVV2:='ignore';
    if ContainsText(Variable.Table_Name, 'Wind') then
    begin
      extV:='hour';
      extVV:=InttoStr(6*(Hourof(frmMain.dtwpTimeStart.DateTime) div 6));

      extV2:='hour';
      extVV2:=InttoStr(6*(Hourof(frmMain.dtwpTimeEnd.DateTime) div 6));
    end
    else if ContainsText(Variable.Table_Name, 'Pisces') then
    begin
      extV:='depth';
      extVV:=frmMain.cbPiscesDepthStart.Text;
    end;

    extVars:=extVars+extV;
    extVarVals:=extVarVals+extVV;

    extVars2:=extVars2+extV2;
    extVarVals2:=extVarVals2+extVV2;

    if i<count then
    begin
      tables:=tables+',';
      vars:=vars+',';
      extVars:=extVars+',';
      extVarVals:=extVarVals+',';
      extVars2:=extVars2+',';
      extVarVals2:=extVarVals2+',';
    end;
  end;


  script:=' ./script/python/Lagrangian.py ';
  args:=inttostr(dt)+' '+inttostr(dir)+' '+dt1+' '+dt2+' '+lat+' '+lon+' '+inttostr(sFlag)+' '+inttostr(cFlag)+' '+shapeFname+' ';
  args:=args+exportflag+' '+margin+' '+tables+' '+vars+' '+extVars+' '+extVarVals+' '+extVars2+' '+extVarVals2+' '+colocateFname;

  ShellExecute(0, nil, 'python', Pchar(script + args), nil, SW_HIDE);
  //frmMain.Edit1.Text:='python'+Pchar(script + args);

  if shapeFlag then
    DeleteFile('shape/'+shapeFname+'.shp');
  if colocateFlag then
    DeleteFile('embed/'+colocateFname+'.html');

  if shapeFlag then
  begin
    repeat
      Application.ProcessMessages;
    until FileExists('shape/'+shapeFname+'.shp');

    FileLayer:=(frmMain.map.Layers[2] as TdxMapItemFileLayer);
    FileLayer.Active:=False;
    FileLayer.FileType:=miftShape;
    fPath:='shape/'+shapeFname+'.shp';

    repeat
      Application.ProcessMessages;
      sleep(100);
    until not IsFileInUse(fPath);

    FileLayer.FileName:=fPath;
    FileLayer.LoadFromFile(fPath);
    FileLayer.Active:=True;
  end;


  if colocateFlag then
  begin
    repeat
      Application.ProcessMessages;
    until FileExists('embed/'+colocateFname+'.html');
  end;

  frmLagrangian_Busy(False);
end;



{$R *.dfm}



procedure TfrmLagrangian.btnColocalizeClick(Sender: TObject);
var
  shapeFlag, colocateFlag:boolean;
begin
  if frmMain.ledtVars.Values.Count<1 then
  begin
    MessageDlg('Please pick at least one variable.', mtError, [mbok], 0);
    Exit;
  end;

  shapeFlag:=False;
  colocateFlag:=True;
  LagrangianTrack(shapeFlag, colocateFlag);
end;

procedure TfrmLagrangian.btnTracerTrackClick(Sender: TObject);
var
  shapeFlag, colocateFlag:boolean;
begin
  shapeFlag:=True;
  colocateFlag:=False;
  LagrangianTrack(shapeFlag, colocateFlag);
end;

end.
