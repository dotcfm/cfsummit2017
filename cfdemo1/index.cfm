<cfscript>

  hostname = CreateObject("java","java.net.InetAddress").getLocalHost().getHostName();

</cfscript>

<cfoutput>
  <h1>Demo 1</h1>
  <h2>Container: #hostname#</h2>
</cfoutput>