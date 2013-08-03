program K_Replace_Name;

uses
    Use32, Dos, SysUtils;

function ReplaceNameString( const FileSpec, SubString, ReplaceString : string; SubDir : Boolean ) : Longint;
var
    SR              : TSearchRec;
    RC              : Integer;
    F               : File;
    Dir             : string;
    NewName         : string;
    Count           : Integer;

function ReplaceStr : Boolean;
var
    Pos1, Pos2 : Longint;

begin
    ReplaceStr := FALSE;

    NewName := SR.Name;
    Pos1 := 1;
    repeat
        Pos2 := Pos( SubString, Copy( NewName, Pos1, Length( NewName )));
        if  Pos2 > 0 then
        begin
            Delete( NewName, Pos1 + Pos2 - 1, Length( SubString ));
            Insert( ReplaceString, NewName, Pos1 + Pos2 - 1 );
            Inc( Pos1, Pos2 + Length( ReplaceString ) - 1 );

            ReplaceStr := TRUE;
        end;
    until Pos2 = 0;
end;

begin
    Count := 0;
    Dir := ExtractFileDir( FExpand( FileSpec ));
    if Dir[ Length( Dir )] <> '\' then
        Dir := Dir + '\';

    RC := FindFirst( FileSpec, faAnyFile, SR );
    while RC = 0 do
    begin
        if(( SR.Name <> '.' ) and ( SR.Name <> '..' )) then
        begin
            if ReplaceStr then
            begin
                WriteLn( Dir + SR.Name, ' -> ', Dir + NewName );

                Assign( F, Dir + SR.Name );
                {$I-}
                Rename( F, Dir + NewName );
                {$I+}
                RC := IOResult;
                if RC <> 0 then
                    WriteLn( 'Error renaming files !!!, rc : ', RC )
                else
                    Inc( Count );
            end;
        end;

        RC := FindNext( SR );
    end;
    FindClose( SR );

    if SubDir then
    begin
        RC := FindFirst( Dir + '*', ( faDirectory shl 8 ) or faAnyFile, SR );
        while RC = 0 do
        begin
            if ( SR.Name <> '.' ) and ( SR.Name <> '..' ) then
            begin
                Inc( Count,
                     ReplaceNameString( Dir + SR.Name + '\' + ExtractFileName( FileSpec ),
                                            SubString, ReplaceString, SubDir ));
            end;

            RC := FindNext( SR );
        end;

        FindClose( SR );
    end;

    ReplaceNameString := Count;
end;

var
    Count           : Longint;
    SubDir          : Boolean;
    FileSpec        : string;
    SubString       : string;
    ReplaceString   : string;

begin
    Subdir := False;
    if(( ParamStr( 1 ) = '/S' ) or ( ParamStr( 1 ) = '/s' )) then
        SubDir := True;

    if ParamCount < ( 2 + Ord( SubDir )) then
    begin
        WriteLn('Usage : KRN [/S] filename sub-string replace-string');
        WriteLn;
        Halt( 1 );
    end;

    FileSpec := ParamStr( 1 + Ord( SubDir ));
    SubString := ParamStr( 2 + Ord( SubDir ));
    ReplaceString := ParamStr( 3 + Ord( SubDir ));

    Count := ReplaceNameString( FileSpec, SubString, ReplaceString, SubDir );

    WriteLn( #9 + ' ', Count, ' file(s) renamed.');

end.

