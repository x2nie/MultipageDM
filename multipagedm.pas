{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit MultipageDM;

{$warn 5023 off : no warning about unused units}
interface

uses
  DmWrapper, MultipageDmDsigner, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('MultipageDmDsigner', @MultipageDmDsigner.Register);
end;

initialization
  RegisterPackage('MultipageDM', @Register);
end.
