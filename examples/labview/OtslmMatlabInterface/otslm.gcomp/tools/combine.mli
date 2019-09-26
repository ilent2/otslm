<?xml version="1.0" encoding="utf-8"?>
<SourceFile Checksum="38610851CBE0965AA05C0486510C656FF6EABB286136ADBE26F9E83DB03F2666CE578ABBE0E124974A953A69555105E64ACD6A1DE9BE6AA1985ECE2C3A4A3E2D" Timestamp="1D5743C855D9997" xmlns="http://www.ni.com/PlatformFramework">
	<SourceModelFeatureSet>
		<ParsableNamespace AssemblyFileVersion="6.4.0.49504" FeatureSetName="Interface for MATLAB®" Name="http://www.ni.com/Matlab" OldestCompatibleVersion="5.3.1.49152" Version="5.3.1.49152" />
		<ParsableNamespace AssemblyFileVersion="6.4.0.49504" FeatureSetName="Editor" Name="http://www.ni.com/PlatformFramework" OldestCompatibleVersion="6.2.0.49154" Version="6.2.0.49154" />
		<ApplicationVersionInfo Build="6.4.0.49504" Name="LabVIEW NXG" Version="3.1.0" />
	</SourceModelFeatureSet>
	<MatlabDefinition Id="b1225faaca6e409a809a406bf4bae31f" xmlns="http://www.ni.com/Matlab">
		<p.PlatformAgnosticPathToLibrary>
			<Path a="0">
				<pE>unpackCombine</pE>
			</Path>
		</p.PlatformAgnosticPathToLibrary>
		<Icon Id="4241477164bc44bcaf1f6b7bc1c2e204" ListViewIconCrop="0 0 40 40" xmlns="http://www.ni.com/PlatformFramework">
			<IconPanel Height="[float]40" Id="2a210935caf048b98c0136435c593b35" Left="[float]0" MinHeight="[float]0" MinWidth="[float]0" PanelSizeMode="Resize" Top="[float]0" Width="[float]40">
				<IconTemplate Height="[float]40" Id="ed5afa5cf24a4d27881c553ef9110b9a" Left="[float]0" TemplateName="[string]Blank" Top="[float]0" Width="[float]40" />
			</IconPanel>
		</Icon>
	</MatlabDefinition>
	<EnvoyManagerFile Id="a8c9cbff32e94157a04c18c4f509c205" xmlns="http://www.ni.com/PlatformFramework">
		<ProjectSettings Id="db100cd8ca1040b4a394a135f065c735" ModelDefinitionType="ProjectSettings" Name="ZProjectSettings" />
		<NameScopingEnvoy AutomaticallyResolveUp="True" Id="b9565d4551442a19bea802881d1591b" Name="combine.mli" NameTracksFileName="True">
			<EmbeddedDefinitionReference Id="d2e96ea8011b4926a3b2ea89673feff9" ModelDefinitionType="{http://www.ni.com/Matlab}MatlabEntryPoint" Name="otslm.tools.combine">
				<MatlabEntryPoint Id="51c906c4d45f49a9a0edca9567e98e2b" xmlns="http://www.ni.com/Matlab">
					<Icon Id="4e50176cee87472fbcee5cea118bf330" ListViewIconCrop="0 0 40 40" xmlns="http://www.ni.com/PlatformFramework">
						<IconPanel Height="[float]40" Id="f6a7e33051e84e99a12475b49fcb7302" Left="[float]0" MinHeight="[float]0" MinWidth="[float]0" PanelSizeMode="Resize" Top="[float]0" Width="[float]40">
							<IconTemplate ClipMargin="[SMThickness]3,3,3,3" Height="[float]40" Id="dd72dd0233a84504b25b4144904234f7" Left="[float]0" TemplateName="[string]Gray" Top="[float]0" Width="[float]40">
								<Rectangle Fill="[SMSolidColorBrush]#ff727272" Id="b7b4bb6a94c9472c8661aa8750d2b8a5" IsHitTestVisible="[bool]False" Left="[float]0" MinHeight="[float]1" MinWidth="[float]1" RadiusX="[float]4" RadiusY="[float]4" Top="[float]0" />
								<Rectangle Fill="[SMSolidColorBrush]#ffe5e5e5" Id="e115f0f9e19040598b8828985c42e9c9" IsHitTestVisible="[bool]False" Left="[float]0" Margin="[SMThickness]1,1,1,1" MinHeight="[float]1" MinWidth="[float]1" RadiusX="[float]2.5" RadiusY="[float]2.5" Stroke="[SMSolidColorBrush]#fff2f2f2" Top="[float]0" />
								<FileNameText Attached="[bool]True" Height="[float]36" Id="a56b96886a524be181fc69455859b5c1" Left="[float]0" Margin="[SMThickness]2,2,2,2" SizeMode="[TextModelSizeMode]AutoFont" Text="[string]otslm.tools" TextAlignment="[TextAlignment]Center" TextWrapping="[TextWrapping]Wrap" Top="[float]0" VerticalScrollBarVisibility="[ScrollBarVisibility]Hidden" Width="[float]36">
									<FontSetting FontFamily="Verdana" FontSize="6" Id="bbc232e464294af18ebf2ae26e7d83d1" />
								</FileNameText>
							</IconTemplate>
						</IconPanel>
					</Icon>
					<ConnectorPane Height="40" Id="4f1eae0d10964085b0736fe90ddb0d88" ListViewHeight="115" ListViewWidth="150" Width="40" xmlns="http://www.ni.com/PlatformFramework">
						<ConnectorPaneTerminal ListViewHotspot="0 65" Parameter="4fa2bbb63fda4bc99ab12c622dbfdb3c" />
						<ConnectorPaneTerminal Hotspot="0 15" />
						<ConnectorPaneTerminal Hotspot="0 25" />
						<ConnectorPaneTerminal Hotspot="0 35" ListViewHotspot="0 35" Parameter="1468cf8c297f4a46bdf0e4087edfc6f7" />
						<ConnectorPaneTerminal Hotspot="15 0" />
						<ConnectorPaneTerminal Hotspot="25 0" />
						<ConnectorPaneTerminal Hotspot="40 5" />
						<ConnectorPaneTerminal Hotspot="40 15" ListViewHotspot="150 80" Parameter="382e2d86d0ef4af8977280592ac25341" />
						<ConnectorPaneTerminal Hotspot="40 25" />
						<ConnectorPaneTerminal Hotspot="40 35" ListViewHotspot="150 50" Parameter="49539ee45ba449c0903001965cded231" />
						<ConnectorPaneTerminal Hotspot="15 40" />
						<ConnectorPaneTerminal Hotspot="25 40" />
					</ConnectorPane>
					<MatlabErrorDiagramParameter CallDirection="Input" Id="1468cf8c297f4a46bdf0e4087edfc6f7" Name="error in" />
					<MatlabErrorDiagramParameter CallDirection="Output" Id="49539ee45ba449c0903001965cded231" Name="error out" />
					<MatlabParameter DataType="Double[,,]" Id="27f90d0b3faf42268e0ec583b06b72ef" Name="inputs">
						<MatlabDiagramParameter CallDirection="Input" Id="4fa2bbb63fda4bc99ab12c622dbfdb3c" Name="inputs" />
						<MatlabDiagramParameter CallDirection="Output" Id="93c404406eb84e69800900ea5efa4768" Name="inputs out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="Double[,]" Id="964be476b65f4640aa2ef93f3252a520" Name="im">
						<MatlabDiagramParameter CallDirection="Input" Id="c99df4f22cc044e3855c6b32a00a9056" Name="im in" Visible="False" />
						<MatlabDiagramParameter CallDirection="Output" Id="382e2d86d0ef4af8977280592ac25341" Name="im" />
					</MatlabParameter>
				</MatlabEntryPoint>
			</EmbeddedDefinitionReference>
		</NameScopingEnvoy>
	</EnvoyManagerFile>
</SourceFile>