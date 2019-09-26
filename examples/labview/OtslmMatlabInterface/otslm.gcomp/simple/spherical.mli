<?xml version="1.0" encoding="utf-8"?>
<SourceFile Checksum="BE747AAF427AE84FAB18E0A550AE10C9BE350CECD44CD3141E02496302239B273F2A4DBC888BDD1FE281027486EADE2A8B348013C26B41BCF29729A77ACC5F65" Timestamp="1D574394D0C4B69" xmlns="http://www.ni.com/PlatformFramework">
	<SourceModelFeatureSet>
		<ParsableNamespace AssemblyFileVersion="6.4.0.49504" FeatureSetName="Interface for MATLAB®" Name="http://www.ni.com/Matlab" OldestCompatibleVersion="5.3.1.49152" Version="5.3.1.49152" />
		<ParsableNamespace AssemblyFileVersion="6.4.0.49504" FeatureSetName="Editor" Name="http://www.ni.com/PlatformFramework" OldestCompatibleVersion="6.2.0.49154" Version="6.2.0.49154" />
		<ApplicationVersionInfo Build="6.4.0.49504" Name="LabVIEW NXG" Version="3.1.0" />
	</SourceModelFeatureSet>
	<MatlabDefinition Id="b6502e83bc634aa89d3a684aab918a00" xmlns="http://www.ni.com/Matlab">
		<p.PlatformAgnosticPathToLibrary>
			<Path a="0">
				<pE>otslm.simple.spherical</pE>
			</Path>
		</p.PlatformAgnosticPathToLibrary>
		<Icon Id="13955036fa05427e828bb9e1f9995c74" ListViewIconCrop="0 0 40 40" xmlns="http://www.ni.com/PlatformFramework">
			<IconPanel Height="[float]40" Id="40b0878738d64d1f98fdc2cdb607a10f" Left="[float]0" MinHeight="[float]0" MinWidth="[float]0" PanelSizeMode="Resize" Top="[float]0" Width="[float]40">
				<IconTemplate Height="[float]40" Id="e972b45785464a3581b54089f5049502" Left="[float]0" TemplateName="[string]Blank" Top="[float]0" Width="[float]40" />
			</IconPanel>
		</Icon>
	</MatlabDefinition>
	<EnvoyManagerFile Id="ab6c1195ab0f465e94126702b2832a7d" xmlns="http://www.ni.com/PlatformFramework">
		<ProjectSettings Id="83b1434743f9442093abe7c27b27038c" ModelDefinitionType="ProjectSettings" Name="ZProjectSettings" />
		<NameScopingEnvoy AutomaticallyResolveUp="True" Id="324670e3ea4744bc9012ba375e7a832a" Name="spherical.mli" NameTracksFileName="True">
			<EmbeddedDefinitionReference Id="ada60381107c45d3afe1f277ea4c3770" ModelDefinitionType="{http://www.ni.com/Matlab}MatlabEntryPoint" Name="otslm.simple.spherical">
				<MatlabEntryPoint Id="1a6ffc6b00384df9aae9d821c3ff4993" xmlns="http://www.ni.com/Matlab">
					<Icon Id="e8efc6c77e69496d8914f946b5622d66" ListViewIconCrop="0 0 40 100" xmlns="http://www.ni.com/PlatformFramework">
						<IconPanel Height="[float]100" Id="94a80702338141f28db67bc8bf7b9ce6" Left="[float]0" MinHeight="[float]0" MinWidth="[float]0" PanelSizeMode="Resize" Top="[float]0" Width="[float]40">
							<IconTemplate ClipMargin="[SMThickness]3,3,3,3" Height="[float]100" Id="65c427ab042347aca3972bf468ebec0f" Left="[float]0" TemplateName="[string]Gray" Top="[float]0" Width="[float]40">
								<Rectangle Fill="[SMSolidColorBrush]#ff727272" Id="e9613c908ed44f77bc5b062ce56aa298" IsHitTestVisible="[bool]False" Left="[float]0" MinHeight="[float]1" MinWidth="[float]1" RadiusX="[float]4" RadiusY="[float]4" Top="[float]0" />
								<Rectangle Fill="[SMSolidColorBrush]#ffe5e5e5" Id="621ff4351e834493b20be6dc330dd7b9" IsHitTestVisible="[bool]False" Left="[float]0" Margin="[SMThickness]1,1,1,1" MinHeight="[float]1" MinWidth="[float]1" RadiusX="[float]2.5" RadiusY="[float]2.5" Stroke="[SMSolidColorBrush]#fff2f2f2" Top="[float]0" />
								<FileNameText Attached="[bool]True" Height="[float]96" Id="7de2cdb32c49496da1796adde915a3eb" Left="[float]0" Margin="[SMThickness]2,2,2,2" SizeMode="[TextModelSizeMode]AutoFont" Text="[string]otslm.simple" TextAlignment="[TextAlignment]Center" TextWrapping="[TextWrapping]Wrap" Top="[float]0" VerticalScrollBarVisibility="[ScrollBarVisibility]Hidden" Width="[float]36">
									<FontSetting FontFamily="Verdana" FontSize="6" Id="d5d3e11b3f0c4ee7850f9601f9d98b22" />
								</FileNameText>
							</IconTemplate>
						</IconPanel>
					</Icon>
					<ConnectorPane Height="100" Id="fc0676afbf1f49efb77402269eaa5daf" ListViewHeight="235" ListViewWidth="150" Width="40" xmlns="http://www.ni.com/PlatformFramework">
						<ConnectorPaneTerminal />
						<ConnectorPaneTerminal Hotspot="0 15" ListViewHotspot="0 20" Parameter="f0e30fedb8f0445ea63e8d555f9b3493" />
						<ConnectorPaneTerminal Hotspot="0 25" ListViewHotspot="0 35" Parameter="dd6cd40bb440451d8764dafe10dcda0a" />
						<ConnectorPaneTerminal Hotspot="0 35" ListViewHotspot="0 5" Parameter="5a435cf197974ea5be966ba0dcf02b51" />
						<ConnectorPaneTerminal Hotspot="15 0" />
						<ConnectorPaneTerminal Hotspot="25 0" />
						<ConnectorPaneTerminal Hotspot="40 5" ListViewHotspot="150 80" Parameter="a004f9a262f4481db44eaf3ca1a8f696" />
						<ConnectorPaneTerminal Hotspot="40 15" />
						<ConnectorPaneTerminal Hotspot="40 25" />
						<ConnectorPaneTerminal Hotspot="40 35" />
						<ConnectorPaneTerminal Hotspot="15 100" />
						<ConnectorPaneTerminal Hotspot="25 100" />
						<ConnectorPaneTerminal Hotspot="0 45" ListViewHotspot="0 50" Parameter="212e76c87bae4d6aaf576809bcc9a267" />
						<ConnectorPaneTerminal Hotspot="40 45" />
						<ConnectorPaneTerminal Hotspot="0 55" ListViewHotspot="0 65" Parameter="3d296447afa048de9c7fa2e97d49e868" />
						<ConnectorPaneTerminal Hotspot="40 55" />
						<ConnectorPaneTerminal Hotspot="0 65" ListViewHotspot="0 95" Parameter="8c02ed7f37ab457492918314c4185945" />
						<ConnectorPaneTerminal Hotspot="40 65" />
						<ConnectorPaneTerminal Hotspot="0 75" ListViewHotspot="0 110" Parameter="5cc3ad2d8b3246b9bbb271bbc67d4193" />
						<ConnectorPaneTerminal Hotspot="40 75" />
						<ConnectorPaneTerminal Hotspot="0 85" ListViewHotspot="0 125" Parameter="e8d2e39fd72f4d4fb5de62c3dce45f78" />
						<ConnectorPaneTerminal Hotspot="40 85" />
						<ConnectorPaneTerminal Hotspot="0 95" ListViewHotspot="0 140" Parameter="a93a682b95d1421c97398c9b124f434a" />
						<ConnectorPaneTerminal Hotspot="40 95" ListViewHotspot="150 155" Parameter="4495f37bff1b4bf1bb7532320ccd828b" />
					</ConnectorPane>
					<MatlabErrorDiagramParameter CallDirection="Input" Id="a93a682b95d1421c97398c9b124f434a" Name="error in" />
					<MatlabErrorDiagramParameter CallDirection="Output" Id="4495f37bff1b4bf1bb7532320ccd828b" Name="error out" />
					<MatlabParameter DataType="Double[,]" Id="f6e475d36d8c4e22840e5d8245591cf7" Name="im">
						<MatlabDiagramParameter CallDirection="Input" Id="2657ecd08a6547a989dff17fd237a642" Name="im in" Visible="False" />
						<MatlabDiagramParameter CallDirection="Output" Id="a004f9a262f4481db44eaf3ca1a8f696" Name="im" />
					</MatlabParameter>
					<MatlabParameter DataType="Double[]" Id="bfb081aad3a84942a37cf9a673fcba3b" Name="sz">
						<MatlabDiagramParameter CallDirection="Input" Id="f0e30fedb8f0445ea63e8d555f9b3493" Name="sz" />
						<MatlabDiagramParameter CallDirection="Output" Id="5f9f64b6a957497db8b767d798868bdb" Name="sz out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="Double" Id="33fc0fb212724a1cb1dced6d479755fe" Name="radius">
						<MatlabDiagramParameter CallDirection="Input" Id="dd6cd40bb440451d8764dafe10dcda0a" Name="radius" />
						<MatlabDiagramParameter CallDirection="Output" Id="28e592c73b824a2c932bd9bdaf5a2f5e" Name="radius out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="String" Id="1c6d465a797c4546a4135366a0a8364e" Name="centre_str">
						<MatlabDiagramParameter CallDirection="Input" Id="5a435cf197974ea5be966ba0dcf02b51" Name="centre_str" />
						<MatlabDiagramParameter CallDirection="Output" Id="7b75ece2ea6f4d6095789944b5b8a506" Name="centre_str out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="Double[]" Id="f234de15a7bc40f991cd54e2a3497752" Name="centre">
						<MatlabDiagramParameter CallDirection="Input" Id="212e76c87bae4d6aaf576809bcc9a267" Name="centre" />
						<MatlabDiagramParameter CallDirection="Output" Id="3239cef1abf54af89e648328e93e9b8f" Name="centre out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="String" Id="33c1efbfbbab4774948848b51a63fcc0" Name="type_str">
						<MatlabDiagramParameter CallDirection="Input" Id="3d296447afa048de9c7fa2e97d49e868" Name="type_str" />
						<MatlabDiagramParameter CallDirection="Output" Id="cea44b1dea9e4ea8890e417a127c1427" Name="type_str out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="String" Id="5365c05d33494eb2bd2c5b5c02ce810a" Name="type">
						<MatlabDiagramParameter CallDirection="Input" Id="8c02ed7f37ab457492918314c4185945" Name="type" />
						<MatlabDiagramParameter CallDirection="Output" Id="e72d120e67774469894e4c564fa810ab" Name="type out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="String" Id="fe99b6d27dd443da84a932480706a984" Name="scale_str">
						<MatlabDiagramParameter CallDirection="Input" Id="5cc3ad2d8b3246b9bbb271bbc67d4193" Name="scale_str" />
						<MatlabDiagramParameter CallDirection="Output" Id="45e6625137044971b03e06125802880e" Name="scale_str out" Visible="False" />
					</MatlabParameter>
					<MatlabParameter DataType="Double" Id="6adc70a62961443ebb352342da389967" Name="scale">
						<MatlabDiagramParameter CallDirection="Input" Id="e8d2e39fd72f4d4fb5de62c3dce45f78" Name="scale" />
						<MatlabDiagramParameter CallDirection="Output" Id="26222451c88740799dafee9ef9265f46" Name="scale out" Visible="False" />
					</MatlabParameter>
				</MatlabEntryPoint>
			</EmbeddedDefinitionReference>
		</NameScopingEnvoy>
	</EnvoyManagerFile>
</SourceFile>