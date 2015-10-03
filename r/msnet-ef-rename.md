2013

#EntityFramework Re-Namer

<!--- tags: csharp -->

*Oracle Data Provider .NET (ODP.NET)*, generates MS *EntityFramework* (EF) entities with upper-case names (for tables and columns), separated by underscore, such as, `PRODUCT_ID`. I personally have no problem to use any kind of generated names as such in code, but most people would prefer them in a more normal *CamelCase* notation.

**EfRenamer** tool (tested for EF5) works on model `*.edmx` file and renames ODP.NET upper-case names to CamelCase. To use the tool, unload the your EF project from VisualStudio, run the tool on the `*.edmx` file, and then reload the EF project in VisualStudio. You may want to backup your `*.edmx` and `*.edmx.diagram` files before.

Usage:

```
efrenamer -f PathToMyProject\MyModel.edmx -t *
```

This will use the default built-in name mapper, which is quite good and used EF `PluralizationService` on all found model entities.

Additionally, you can fine tune the behavior:

* Filter on what entities to modify - modify only some entities by repeating `-t entityName`, and / or by specifying some entity name prefix via `-tp prefix`.
* Specify how names (`-m nameMappingFile`) and / or name parts (`-p namePartMappingFile`) will be mapped, by using a `name=value` lines file. This can be useful if you want some special mapping for some strings. If something is not found the default built-in mapper applies.

All options:

```
Usage: efrenamer -f path.edmx [-m nameMappingFile] [-p namePartMappingFile] [-i] [-d] [-t] [-tp]
 -f model.edmx          : file to use. Unload the VS project first, run this command, then reload
 -m nameMappingFile     : a file with a name=value lines that specify how a full name is mapped to value, if not specified, or if something is not found, then the default built-in name mapper is used
 -p namePartMappingFile : a file with a namepart=value lines that specify how a name part (separated by _) is mapped to value, if not specified, or if something is not found, then the default built-in name mapper is used
 -i                     : use case insensitive for -m, -p
 -d                     : do not use default built-in name mapper, by default when nothing better is found, an automatic default name mapper is used
 -t entityName          : consider only entityName entity, can be repeated as needed, use * for all
 -tp entityNamePrefix   : consider only entities whose name starts with entityNamePrefix, can be repeated as needed
 -e                     : wait to press Enter on exit, useful to debug in Visual Studio
```