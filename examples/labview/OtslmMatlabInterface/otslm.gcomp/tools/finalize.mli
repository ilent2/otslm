<?xml version="1.0" encoding="utf-8"?>
<SourceFile Checksum="C25DA14797A6DE8E4B0B502D8853153C2EAD406F18641B944D7D4CD11E0A439E61E2317C17ABD8B9BCDECBBACB68114B3066A43D8655D72E7D53C1E21EF45EBB" Timestamp="1D5743530C9F2FC" xmlns="http://www.ni.com/PlatformFramework">
	<SourceModelFeatureSet>
		<ParsableNamespace AssemblyFileVersion="6.4.0.49504" FeatureSetName="Interface for MATLAB®" Name="http://www.ni.com/Matlab" OldestCompatibleVersion="5.3.1.49152" Version="5.3.1.49152" />
		<ParsableNamespace AssemblyFileVersion="6.4.0.49504" FeatureSetName="Editor" Name="http://www.ni.com/PlatformFramework" OldestCompatibleVersion="6.2.0.49154" Version="6.2.0.49154" />
		<ApplicationVersionInfo Build="6.4.0.49504" Name="LabVIEW NXG" Version="3.1.0" />
	</SourceModelFeatureSet>
	<MatlabDefinition Id="6451376b82a46ddbc3960b05b807f9c" xmlns="http://www.ni.com/Matlab">
		<p.PlatformAgnosticPathToLibrary>
			<Path a="0">
				<pE>otslm.tools.finalize</pE>
			</Path>
		</p.PlatformAgnosticPathToLibrary>
		<Icon Id="cbc62da7e2e34b77b9e12e2060bb3c2c" ListViewIconCrop="0 0 40 40" xmlns="http://www.ni.com/PlatformFramework">
			<IconPanel Height="[float]40" Id="855efc71fac747a8b5d53ef425ff2072" Left="[float]0" MinHeight="[float]0" MinWidth="[float]0" PanelSizeMode="Resize" Top="[float]0" Width="[float]40">
				<IconTemplate Height="[float]40" Id="846f6ce0dcad40dca726842ce7b525d1" Left="[float]0" TemplateName="[string]Blank" Top="[float]0" Width="[float]40" />
			</IconPanel>
		</Icon>
	</MatlabDefinition>
	<EnvoyManagerFile Id="c95965e7f4004c49a795424ee3df1be7" xmlns="http://www.ni.com/PlatformFramework">
		<ProjectSettings Id="8803d06f53794b129c70b23cf43389a7" ModelDefinitionType="ProjectSettings" Name="ZProjectSettings" />
		<NameScopingEnvoy AutomaticallyResolveUp="True" Id="b7004d6383e34f4bb017ac7edeb48da9" Name="Interface.mli" NameTracksFileName="True">
			<EmbeddedDefinitionReference Id="f1c6b64d8e34429a88a6ef8307a3917" ModelDefinitionType="{http://www.ni.com/Matlab}MatlabEntryPoint" Name="otslm.tools.finalize">
				<MatlabEntryPoint Id="1e1a629c1cb64ced8087cc6c175c843a" xmlns="http://www.ni.com/Matlab">
					<Icon Id="2b8fe6c517a44f1495feb2b6415134a2" ListViewIconCrop="0 0 40 40" xmlns="http://www.ni.com/PlatformFramework">
						<IconPanel Height="[float]40" Id="6993123bd1634491a8e486f29f3feff2" Left="[float]0" MinHeight="[float]0" MinWidth="[float]0" PanelSizeMode="Resize" Top="[float]0" Width="[float]40">
							<IconTemplate ClipMargin="[SMThickness]3,3,3,3" Height="[float]40" Id="e1ece2f15a604f90be0afeb509020a25" Left="[float]0" TemplateName="[string]Gray" Top="[float]0" Width="[float]40">
								<Rectangle Fill="[SMSolidColorBrush]#ff727272" Id="a0a712a6a760463fa0580a21f4467c8a" IsHitTestVisible="[bool]False" Left="[float]0" MinHeight="[float]1" MinWidth="[float]1" RadiusX="[float]4" RadiusY="[float]4" Top="[float]0" />
								<Rectangle Fill="[SMSolidColorBrush]#ffe5e5e5" Id="8e206d982e874a2fb47e4c3f4061c5bf" IsHitTestVisible="[bool]False" Left="[float]0" Margin="[SMThickness]1,1,1,1" MinHeight="[float]1" MinWidth="[float]1" RadiusX="[float]2.5" RadiusY="[float]2.5" Stroke="[SMSolidColorBrush]#fff2f2f2" Top="[float]0" />
								<FileNameText Attached="[bool]True" Height="[float]36" Id="3824fda0848a4d1aaf669b4a228be17c" Left="[float]0" Margin="[SMThickness]2,2,2,2" SizeMode="[TextModelSizeMode]AutoFont" Text="[string]otslm.tools" TextAlignment="[TextAlignment]Center" TextWrapping="[TextWrapping]Wrap" Top="[float]0" VerticalScrollBarVisibility="[ScrollBarVisibility]Hidden" Width="[float]36">
									<FontSetting FontFamily="Verdana" FontSize="6" Id="3ece3684dc684f0cbf7aad77d6760979" />
								</FileNameText>
							</IconTemplate>
						</IconPanel>
					</Icon>
					<ConnectorPane Height="40" Id="6337b5c10f9d4b08a7726401d961f39f" ListViewHeight="115" ListViewWidth="150" Width="40" xmlns="http://www.ni.com/PlatformFramework">
						<ConnectorPaneTerminal />
						<ConnectorPaneTerminal Hotspot="0 15" ListViewHotspot="0 80" Parameter="60c4b66d3a9742298bb428ffca6d58bf" />
						<ConnectorPaneTerminal Hotspot="0 25" />
						<ConnectorPaneTerminal Hotspot="0 35" ListViewHotspot="0 35" Parameter="847b62da47aa40a0bbe878e2a439ea71" />
						<ConnectorPaneTerminal Hotspot="15 0" />
						<ConnectorPaneTerminal Hotspot="25 0" />
						<ConnectorPaneTerminal Hotspot="40 5" ListViewHotspot="150 65" Parameter="c2a2042a9bbe4fb693cb8fb19977cfb0" />
						<ConnectorPaneTerminal Hotspot="40 15" />
						<ConnectorPaneTerminal Hotspot="40 25" />
						<ConnectorPaneTerminal Hotspot="40 35" ListViewHotspot="150 50" Parameter="e4f115c9b5a748ff9f2b72f6145d3ee6" />
						<ConnectorPaneTerminal Hotspot="15 40" />
						<ConnectorPaneTerminal Hotspot="25 40" />
					</ConnectorPane>
					<MatlabErrorDiagramParameter CallDirection="Input" Id="847b62da47aa40a0bbe878e2a439ea71" Name="error in" />
					<MatlabErrorDiagramParameter CallDirection="Output" Id="e4f115c9b5a748ff9f2b72f6145d3ee6" Name="error out" />
					<MatlabParameter DataType="Double[,]" Id="6d42c7236ba4448d8ce4e9c908651518" Name="im">
						<MatlabDiagramParameter CallDirection="Input" Id="fcf27133780645dfb470e982b708d019" Name="im in" Visible="False" />
						<MatlabDiagramParameter CallDirection="Output" Id="c2a2042a9bbe4fb693cb8fb19977cfb0" Name="im" />
					</MatlabParameter>
					<MatlabParameter DataType="Double[,]" Id="5577983b50524e37bd2b8084b0813419" Name="input">
						<MatlabDiagramParameter CallDirection="Input" Id="60c4b66d3a9742298bb428ffca6d58bf" Name="input" />
						<MatlabDiagramParameter CallDirection="Output" Id="6575303378ef4d9199da86fe5fe2d9bd" Name="input out" Visible="False" />
					</MatlabParameter>
				</MatlabEntryPoint>
			</EmbeddedDefinitionReference>
		</NameScopingEnvoy>
	</EnvoyManagerFile>
</SourceFile>