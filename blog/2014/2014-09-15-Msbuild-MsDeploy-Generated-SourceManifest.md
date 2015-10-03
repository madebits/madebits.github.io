#Msbuild MsDeploy-Generated SourceManifest.xml Usage

2014-09-15 

<!--- tags: deployment -->

Msbuild generates several files when told to build a msdeploy package, using something like the following command:
```
msbuild SomeWebProject.csproj /p:DeployOnBuild=true /p:PublishProfile=SomeProfile /p:VisualStudioVersion=11.0 /p:DesktopBuildPackageLocation=BuildWebPackages
```
I knew why `SomeWebProject.SetParameters.xml` was for (it can be passed to msdeploy via -setParameters), but I was not sure about why the generated `SomeWebProject.SourceManifest.xml` was good for.

It turns out, one can customize `SomeWebProject.SourceManifest.xml` file manually with own msdeploy provider calls. For example, I added in end of sitemanifest a new test msdeploy provider element:
```
...
  <runCommand path="notepad.exe"/>
</sitemanifest>
```

Then I regenerated the ZIP package using:
```
msdeploy -verb:sync -source:manifest=C:tempSomeWebProject.SourceManifest.xml -dest:package=SomeWebProject-modified.zip -declareParamFile:parameters.xml
```
`parameters.xml` file, I extracted from the original generated `SomeWebProject.zip`. The new file `SomeWebProject-modified.zip` can then be used to deploy directly with msdeploy applying any custom changes.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-11-08-Moving-Ubuntu-Hard-Disk-to-a-New-Machine.md'>Moving Ubuntu Hard Disk to a New Machine</a> <a rel='next' id='fnext' href='#blog/2014/2014-06-19-Connecting-Acer-Iconia-One-7-on-Lubuntu.md'>Connecting Acer Iconia One 7 on Lubuntu</a></ins>
