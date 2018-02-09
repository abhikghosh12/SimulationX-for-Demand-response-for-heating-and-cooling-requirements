// CP: 65001
// SimulationX Version: 3.6.5.34033 x64
within ;
model VolumeFlowController "VolumeFlowController.mo"
	input Modelica.Blocks.Interfaces.RealInput TRef(
		quantity="Thermics.Temp",
		displayUnit="°C") "Reference temperature" annotation(
		Placement(
			transformation(extent={{112,-129},{152,-89}}),
			iconTransformation(extent={{-170,80},{-130,120}})),
		Dialog(
			group="Temperature",
			tab="Results",
			showAs=ShowAs.Result));
	input Modelica.Blocks.Interfaces.RealInput TAct(
		quantity="Thermics.Temp",
		displayUnit="°C") "Actual temperature" annotation(
		Placement(
			transformation(
				origin={246,-195},
				extent={{-20,-20},{20,20}},
				rotation=90),
			iconTransformation(
				origin={-150,-100},
				extent={{-20,-20},{20,20}})),
		Dialog(
			group="Temperature",
			tab="Results",
			showAs=ShowAs.Result));
	input Modelica.Blocks.Interfaces.RealInput TReturn(
		quantity="Thermics.Temp",
		displayUnit="°C")if not useStandardTempDiff "Actual return temperature" annotation(
		Placement(
			transformation(
				origin={330,-55},
				extent={{-20,-20},{20,20}},
				rotation=-90),
			iconTransformation(
				origin={50,-150},
				extent={{-20,-20},{20,20}},
				rotation=90)),
		Dialog(
			group="Temperature",
			tab="Results",
			showAs=ShowAs.Result));
	input Modelica.Blocks.Interfaces.RealInput TFlow(
		quantity="Thermics.Temp",
		displayUnit="°C")if not useStandardTempDiff "Actual flow temperature" annotation(
		Placement(
			transformation(
				origin={235,-55},
				extent={{-20,-20},{20,20}},
				rotation=-90),
			iconTransformation(
				origin={-100,-150},
				extent={{-20,20},{20,-20}},
				rotation=90)),
		Dialog(
			group="Temperature",
			tab="Results",
			showAs=ShowAs.Result));
	output Modelica.Blocks.Interfaces.RealOutput qvRef(
		quantity="Thermics.VolumeFlow",
		displayUnit="m³/h") "Reference volume flow" annotation(
		Placement(
			transformation(extent={{547,-113},{567,-93}}),
			iconTransformation(extent={{140,-10},{160,10}})),
		Dialog(
			group="Volume Flow",
			tab="Results",
			showAs=ShowAs.Result));
	GreenBuilding.Interfaces.Ambience.AmbientCondition AmbientConditions "Ambient Conditions Connection" annotation(
		Placement(
			transformation(
				origin={235,-55},
				extent={{-20,-20},{20,20}},
				rotation=-90),
			iconTransformation(
				origin={150,100},
				extent={{-20,20},{20,-20}},
				rotation=90)),
		Dialog(
			group="Temperature",
			tab="Results",
			showAs=ShowAs.Result));
	parameter Real EPriceAvg=48;
	Modelica.Blocks.Tables.CombiTable1D EPricing(
		tableOnFile=true,
		tableName=CPTable,
		fileName=HPFile) "Electrical price circulation pump" annotation(
		Placement(transformation(extent={{-10,-10},{10,10}})),
		Dialog(
			group="Coefficient of Performance",
			tab="Results 1"));
	parameter String HPFile=GreenBuilding.Utilities.Functions.getModelDataDirectory()+"\\heat_pump\\hp_data\\Stiebel_Eltron\\WPL_10_ACS\\SE_WPL_10_ACS2.txt" "File name for heat pump characteristics" annotation(Dialog(
		group="Heating Power",
		tab="price - Power Data"));
	parameter String CPTable="Pricing" "Table name for Eprice behavior" annotation(Dialog(
		group="Power Data",
		tab="eprice"));
	Boolean Price "Price based model state on/off" annotation(Dialog(
		group="I/O",
		tab="Results 1",
		showAs=ShowAs.Result));
	Boolean ONheat "Switch-ON/OFF for heat controller" annotation(Dialog(
		group="Control",
		tab="Results",
		showAs=ShowAs.Result));
	Boolean ONcool "Switch-ON/OFF for cooling controller" annotation(Dialog(
		group="Control",
		tab="Results",
		showAs=ShowAs.Result));
	parameter Real deltaTCoolBound=3 "Cooling boundary temperature difference" annotation(Dialog(
		group="Heating/Cooling Control",
		tab="Parameters"));
	parameter Real deltaTHeatBound=0 "Heating boundary temperature difference" annotation(Dialog(
		group="Heating/Cooling Control",
		tab="Parameters"));
	parameter Real deltaTupHeat(
		quantity="Thermodynamics.TempDiff",
		displayUnit="K")=1 "Upper temperature difference for heating (heat power = 0)" annotation(Dialog(
		group="Temperature Control",
		tab="Parameters"));
	parameter Real deltaTlowHeat(
		quantity="Thermodynamics.TempDiff",
		displayUnit="K")=-1 "Lower temperature difference for heating (heat power = max)" annotation(Dialog(
		group="Temperature Control",
		tab="Parameters"));
	parameter Real deltaTupCool(
		quantity="Thermodynamics.TempDiff",
		displayUnit="K")=1 "Upper temperature difference for cooling (cooling power = max)" annotation(Dialog(
		group="Temperature Control",
		tab="Parameters"));
	parameter Real deltaTlowCool(
		quantity="Thermodynamics.TempDiff",
		displayUnit="K")=-1 "Lower temperature difference for cooling (cooling power = 0)" annotation(Dialog(
		group="Temperature Control",
		tab="Parameters"));
	parameter Real cpMed(
		quantity="Thermics.SpecHeatCapacity",
		displayUnit="kJ/(kg·K)")=4177 "Specific heat capacity of heating medium" annotation(Dialog(
		group="Medium",
		tab="Parameters"));
	parameter Real rhoMed(
		quantity="Thermics.Density",
		displayUnit="kg/m³")=1000 "Densitiy of heating medium" annotation(Dialog(
		group="Medium",
		tab="Parameters"));
	parameter Real QHeatMax(
		quantity="Basics.Power",
		displayUnit="kW")=5000 "Maximum heating power" annotation(Dialog(
		group="Heating Power",
		tab="Parameters"));
	parameter Real QCoolMax(
		quantity="Basics.Power",
		displayUnit="kW")=5000 "Maximum cooling power" annotation(Dialog(
		group="Heating Power",
		tab="Parameters"));
	parameter Real qvMax(
		quantity="Thermics.VolumeFlow",
		displayUnit="m³/h")=0.00055555555555555556 "Maximum volume flow for heating system" annotation(Dialog(
		group="Volume Flow",
		tab="Parameters"));
	parameter Real qvMin(
		quantity="Thermics.VolumeFlow",
		displayUnit="m³/h")=0.0000000000001 "Maximum volume flow for heating system" annotation(Dialog(
		group="Volume Flow",
		tab="Parameters"));
	initial equation
			assert(deltaTupCool>deltaTlowCool,"Upper temperature limit must be higher than lower one");
			assert(deltaTHeatBound+deltaTupHeat<deltaTCoolBound+deltaTlowCool, "Heating boundary must be lower than cooling boundary");
		
			if (TAct>(TRef+deltaTlowCool)) then
				ONcool=true;
				ONheat =false;
			else
			ONheat =true;
				ONcool=false;
			end if;
	equation
			           EPricing.u[1] = AmbientConditions.HourOfDay;
			                 if ( EPriceAvg > EPricing.y[1] ) then
						               Price = true;	
						else 
								Price=false;
							end if;                
						
		when ((TAct-TRef)<deltaTlowHeat)  then
			
			ONheat =true;
			ONcool=false;
		elsewhen ((TAct-TRef)>deltaTupHeat) then
			ONheat =false;
			ONcool=false;
		elsewhen ((TAct-TRef)>deltaTupCool) then
			ONheat =false;
			ONcool=true;
		elsewhen ((TAct-TRef)<deltaTlowCool)  then
			ONheat =false;
			ONcool=false;
		end when;	
			
			if  ( ONcool and Price ) then
				
					qvRef=min(min(max(((TAct-TRef-deltaTupCool)*qvMax/(deltaTupCool-deltaTlowCool)),0),qvMax), QCoolMax/(cpMed*rhoMed*max((TFlow-TReturn),0.1)));
				
			                elseif ( ONheat and Price ) then
			                                qvRef=min(min(max(((TRef+deltaTupHeat-TAct)*qvMax/(deltaTupHeat-deltaTlowHeat)),0),qvMax), QHeatMax/(cpMed*rhoMed*max((TFlow-TReturn),0.1)));
			else
				qvRef=0.00001;
			end if;
	annotation(
		qvRef(flags=2),
		Price(flags=2),
		ONheat(flags=2),
		ONcool(flags=2),
		viewinfo[0](
			minOrder=0.5,
			maxOrder=12,
			mode=0,
			minStep=0.01,
			maxStep=0.1,
			relTol=1e-005,
			oversampling=4,
			anaAlgorithm=0,
			typename="AnaStatInfo"),
		viewinfo[1](
			viewSettings(clrRaster=12632256),
			typename="ModelInfo"),
		Icon(
			coordinateSystem(extent={{-150,-150},{150,150}}),
			graphics={
							Bitmap(
								imageSource="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",
								extent={{-150,150},{150,-150}})}),
		Documentation(info="MIME-Version: 1.0
Content-Type: multipart/related;boundary=\"--$iti$\";type=\"text/html\"

----$iti$
Content-Type:text/html;charset=\"iso-8859-1\"
Content-Transfer-Encoding: quoted-printable
Content-Location: C:\\Users\\gasior\\AppData\\Local\\Temp\\iti2BAC.tmp\\hlp52B0.tmp\\VolumeFlowController.htm

<=21DOCTYPE HTML PUBLIC =22-//W3C//DTD HTML 4.0 Transitional//EN=22>
<HTML><HEAD><TITLE>Volume flow controller for heating and cooling systems</T=
ITLE>
<META content=3D=22text/html; charset=3Diso-8859-1=22 http-equiv=3DContent-T=
ype>
<STYLE type=3Dtext/css>
p, li =7Bfont-family: Verdana, Arial, Helvetica, sans-serif; font-size:12px;=
 color: =23000000;=7D
.Ueberschrift1 =7Bfont-family: Verdana, Arial, Helvetica, sans-serif; font-s=
ize:14px; font-weight:bold; color:=23000000; margin-top:0; margin-bottom:6px=
;=7D
.Ueberschrift2 =7Bfont-family: Verdana, Arial, Helvetica, sans-serif; font-s=
ize:12px; font-weight:bold; color:=23000000; margin-top:6px; margin-bottom:6=
px;=7D
.Ueberschrift3 =7Bfont-family: Verdana, Arial, Helvetica, sans-serif; font-s=
ize:12px; font-weight:bold; font-style:italic; color:=23000000; margin-top:6=
px; margin-bottom:6px;=7D
.SymbolTab =7Bfont-family: Verdana, Arial, Helvetica, sans-serif; font-size:=
12px; font-weight:bold; color:=23000000;=7D
</STYLE>
<LINK rel=3Dstylesheet href=3D=22../format_help.css=22>
<META name=3DGENERATOR content=3D=22MSHTML 11.00.9600.18377=22></HEAD>
<BODY link=3D=230000ff bgColor=3D=23ffffff vLink=3D=23800080>
<P class=3DUeberschrift1 style=3D=22MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px=22>V=
olume flow 
controller for heating and cooling systems</P>
<HR style=3D=22MARGIN-BOTTOM: 0px; MARGIN-TOP: 0px=22 SIZE=3D1 noShade>

<TABLE borderColor=3D=23ffffff cellSpacing=3D0 borderColorDark=3D=23ffffff c=
ellPadding=3D2 
width=3D=22100%=22 bgColor=3D=23cccccc borderColorLight=3D=23ffffff border=
=3D1>
  <TBODY>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Symbol:</P></TD>
    <TD bgColor=3D=23ffffff vAlign=3Dtop colSpan=3D3><IMG 
      src=3D=22VolumeFlowController=5Csymbol.png=22 width=3D94 height=3D94><=
/TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Ident:</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop colSpan=3D3>
      <P 
      class=3DSymbolTab>HRISimulationExtensions.AirConditioning.Control.Volu=
meFlowController</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Version:</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop colSpan=3D3>
      <P class=3DSymbolTab>1.0</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Datei:</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop colSpan=3D3>
      <P class=3DSymbolTab></P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Anschl=FCsse:</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Reference temperature</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>TRef</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Actual temperature</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>TAct</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Actual return temperature</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>TReturn</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Actual flow temperature</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>TFlow</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Reference volume flow</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>qvRef</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Parameter:</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Cooling boundary temperature difference</P></TD>=

    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>deltaTCoolBound</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Heating boundary temperature difference</P></TD>=

    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>deltaTHeatBound</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Upper temperature difference for heating (heat po=
wer =3D 
      0)</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>deltaTupHeat</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Lower temperature difference for heating (heat po=
wer =3D 
      max)</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>deltaTlowHeat</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Upper temperature difference for cooling (cooling=
 power 
      =3D max)</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>deltaTupCool</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Lower temperature difference for cooling (cooling=
 power 
      =3D 0)</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>deltaTlowCool</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Specific heat capacity of heating medium</P></TD>=

    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>cpMed</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Densitiy of heating medium</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>rhoMed</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Maximum heating power</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>QHeatMax</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Maximum cooling power</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>QCoolMax</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Maximum volume flow for heating system</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>qvMax</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>Ergebnisse:</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Reference volume flow</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>qvRef</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Switch-ON/OFF for heat controller</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>ONheat</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD bgColor=3D=2395c9f0 vAlign=3Dtop width=3D=2215%=22>
      <P>&nbsp;</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>Switch-ON/OFF for cooling controller</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop>
      <P class=3DSymbolTab>ONcool</P></TD>
    <TD bgColor=3D=23efefef vAlign=3Dtop width=3D=2235%=22>
      <P>&nbsp;</P></TD></TR></TBODY></TABLE>
<P class=3DUeberschrift2>Beschreibung:</P>
<P style=3D=22MARGIN-BOTTOM: 0px; MARGIN-TOP: 6pt=22>&nbsp;</P></BODY></HTML=
>


----$iti$
Content-Type: image/png
Content-Transfer-Encoding: base64
Content-Location: VolumeFlowController\\symbol.png

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

----$iti$--"),
		experiment(
			StopTime=1,
			StartTime=0,
			Interval=0.002));
end VolumeFlowController;
