unit GenericClock;

interface

uses
  Classes, Types, EmuTypes, VirtualDevice, ExtCtrls, SiAuto, SmartInspect;

type


  TGenericClock = class(TVirtualDevice)
  private
    FMessage: Word;
    FLastTick: TDateTime;
    FInterval: Cardinal;
    FCalls: Cardinal;
  public
    constructor Create(ARegisters: PD16RegisterMem; ARam: PD16Ram);
    procedure Interrupt(); override;
    procedure UpdateDevice(); override;
  end;

implementation

uses
  SysUtils, DateUtils;

{ TGenericClock }

constructor TGenericClock.Create(ARegisters: PD16RegisterMem; ARam: PD16Ram);
begin
  inherited;
  FHardwareID := $12d0b402;
  FHardwareVerion := $1;
  FManufactorID := 0;
  FMessage := 0;
  FNeedsUpdate := True;
  FCalls := 0;
end;


procedure TGenericClock.Interrupt;
begin
  SiMain.EnterMethod(Self, 'Interrupt');
  SiMAin.LogInteger('RegA', FRegisters[CRegA]);
  case FRegisters[CRegA] of
    0:
    begin
      if FRegisters[CRegB] <> 0 then
      begin
        FLastTick := Now();
        FInterval := 1000;// div (60 div FRegisters[CRegB]);
      end
      else
      begin
        FInterval := 0;
      end;
    end;
    1:
    begin
      if FCalls = 0 then
      begin

      end;
      Inc(FCalls);
    end;
    2:
    begin
      FMessage := FRegisters[CRegB];
    end;
  end;
  SiMain.LeaveMethod(Self, 'Interrupt');
end;

procedure TGenericClock.UpdateDevice;
begin
  inherited;
  if (FMessage <> 0) and (FInterval <> 0) and (MilliSecondsBetween(FLastTick, Now()) >= FInterval) then
  begin
    SiMain.LogMessage('ticket');
    FLastTick := Now();
    SoftwareInterrupt(FMessage);
  end;
end;

end.
