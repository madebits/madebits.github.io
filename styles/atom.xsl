<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>
<xsl:template match="/atom:feed">
<html>
	<head>
		<title><xsl:value-of select="atom:title"/></title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css" />
	</head>
	<body style="margin: 5px;">
		<div class="panel panel-default">
		  <div class="panel-heading">
		  	<h1 class="panel-title"><a href="{atom:link/@href}"><xsl:value-of select="atom:title"/></a></h1>
		  </div>
		  <div class="panel-body">
		  	<p>Latest feed items:</p>
		    <ul class="list-group">
			<xsl:for-each select="atom:entry">
				<li class="list-group-item"><a href="{atom:link/@href}"><xsl:value-of select="atom:title"/></a></li>
			</xsl:for-each>
			</ul>
		  </div>
		</div>
  </body>
 </html>
</xsl:template>
</xsl:stylesheet>

